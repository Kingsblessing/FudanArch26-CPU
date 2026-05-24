# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

RISC-V RV64I CPU implemented in SystemVerilog for Fudan University's "Computer Organization and Architecture (H)" course (Spring 2026). The CPU is a 5-stage in-order pipeline verified via Verilator simulation with Difftest (differential testing against NEMU reference).

## Build & Test Commands

```bash
make init                 # One-time: initialize difftest submodule
make test-lab1            # Build + run Lab1 test (basic pipeline)
make test-lab2            # Build + run Lab2 test (memory load/store)
make test-lab3            # Build + run Lab3 test (branches, shifts)
make test-lab3-extra      # Lab3 with multiply/divide (bonus)
make test-lab4            # CSR instructions test
make test-lab5            # MMU/Sv39 page table test
make test-lab6            # Interrupt/exception test
make clean                # Remove build directory
```

Waveform debugging: `make test-lab1 VOPT="--dump-wave"`, then `gtkwave build/*.fst`. Range filtering: `VOPT="--dump-wave -b <start_cycle> -e <end_cycle>"`.

Test pass indicators: "HIT GOOD TRAP" (Lab1-4), "Return from init! Test passed" (Lab5), "Privileged test finished." (Lab6).

Verilator acts as the linter — `-Wall` with selective suppressions. No separate lint target.

## Code Modification Rules

- **Only modify files under `vsrc`** — everything else is infrastructure/scaffolding.
- One module per file; filename must match module name (e.g., `fetch.sv` contains `module fetch`).
- Main CPU entry point: `vsrc/src/core.sv` — all pipeline modules are instantiated here.

## SystemVerilog Constraints (Verilator Compatibility)

- **Avoid**: unpacked structs, `interface`, `package`, `initial` statements, latches, negedge clocks, async resets, cross-clock-domain logic.
- **Use `assign` for wire declarations**: not `logic [6:0] opcode = instr[6:0]` but `logic [6:0] opcode; assign opcode = instr[6:0];`
- **Conditional compilation**: `ifdef VERILATOR` for simulation-only code (Difftest, includes); `ifdef VIVADO` for FPGA-only paths.
- `include` directives must be guarded by `ifdef VERILATOR` or `ifdef VIVADO`.

## Architecture

### Pipeline (5-stage in-order)

`fetch.sv` -> `decode.sv` -> `execute.sv` -> `memory.sv` -> `writeback.sv`

- **Pipeline registers**: `REG_IF_ID`, `REG_ID_EX`, `REG_EX_MEM`, `REG_MEM_WB` — packed structs in `core.sv`.
- **Step-based sync**: global `step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok`; pipeline advances only when all stages ready.
- **Forwarding**: EX-MEM and MEM-WB paths via `forward_unit.sv`; register file has combinational WB-to-ID forwarding.
- **Branches**: resolved in EX; taken branches flush pipeline via `redirect_valid`/`redirect_pc`. Static not-taken prediction.
- **CSR writes**: computed in EX, committed in WB (to match NEMU commit order). CSR changes always flush pipeline.
- **Multiply/divide**: iterative state machine in EX (restore-division, shift-add multiplication). Blocks pipeline until done.

### Bus Hierarchy

```
CPU (ibus + dbus) -> IBusToCBus/DBusToCBus -> CBusArbiter (ibus priority) -> CBus -> RAM/AXI
```

Bus types in `vsrc/include/common.sv`: `ibus_req_t`/`ibus_resp_t`, `dbus_req_t`/`dbus_resp_t`, `cbus_req_t`/`cbus_resp_t`.

### Difftest (core.sv)

Four modules connected under `ifdef VERILATOR`:
- `DifftestInstrCommit` — committed instruction (pc, instr, skip, wen, wdest, wdata)
- `DifftestArchIntRegState` — all 32 GPRs via `next_reg` shadow
- `DifftestTrapEvent` — triggers on halt instruction `0x0005006b`
- `DifftestCSRState` — mstatus, mtvec, mepc, mcause, mip, mie, satp

The `skip` signal is set for MMIO loads/stores (`addr[31] == 0`).

### CSR Registers (csr_regfile.sv)

mstatus, mtvec, mip, mie, mscratch, mcause, mtval, mepc, mcycle (auto-increment), mhartid (hardwired 0), satp. Write masks defined in `vsrc/include/csr.sv`.

### FPGA Deployment

Target: Basys-3. `VTop.sv` is synthesis top (no RAM, exposes CBus). `mycpu_top.sv` wraps with AXI-like interface. Vivado project at `vivado/test-cpu/project/project_1.xpr`.

## Lab Progression

| Lab | Focus | Key Instructions |
|-----|-------|-----------------|
| 1 | Basic pipeline | addi, xori, ori, andi, add, sub, and, or, xor, addiw, addw, subw |
| 2 | Memory | ld, sd, lb, lh, lw, lbu, lhu, lwu, sb, sh, sw, lui |
| 3 | Branches, shifts, FPGA | beq, bne, blt, bge, bltu, bgeu, slli, srli, srai, sll, slt, sltu, srl, sra, auipc, jalr, jal |
| 4 | CSR | CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI |
| 5 | Privilege, MMU | MRET, ECALL, Sv39 page tables |
| 6 | Interrupts | Clock/external/software interrupts, ecall, illegal instruction, page faults |

## Notes

- The `VIVADO` ifdef path uses different include paths (no `src/` prefix) — maintain both when adding new modules.
- Initial PC is `0x80000000` (`PCINIT` in `common.sv`).
- The `pc` output to `if_id_reg` must be the PC at request time (`req_pc`), not `pc + 4`.

## Lab notes

`Lab.md` contains per-lab implementation notes from the student. Read it before making changes — it documents which lab is currently in progress and any known issues.