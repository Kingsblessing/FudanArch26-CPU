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

Verilator acts as the linter — `-Wall` with selective suppressions. No separate lint target.

---

# Code Construction Rules

## Verilator SystemVerilog Constraints

Verilator has limited SystemVerilog support. The following must be avoided:

- **Unsupported syntax**: unpacked structs, `interface`/`package` (partial support, may behave incorrectly), delays (`#N`), `initial` statements.
- **Forbidden patterns**: latches, little-endian bit indexing like `[0:31]`, logic X-state and Z-state, falling-edge (`negedge`) clock triggers, async resets, cross-clock-domain logic, gating global clock signals.
- **One module per file**: Filename must match module name (e.g., `fetch.sv` contains `module fetch`).
- **Use `assign` for wire declarations**: DO NOT use `logic [6:0] opcode = instr[6:0]` — instead use `logic [6:0] opcode; assign opcode = instr[6:0];` (Vivado cannot handle inline initialization).
- **Use packed structs** to organize pipeline stage signals (e.g., `typedef struct packed { ... } REG_IF_ID;`).
- **Conditional compilation**: `ifdef VERILATOR` for simulation-only code (Difftest, includes); `ifdef VIVADO` for FPGA-only paths.
- **`include` directives** must be guarded by `ifdef VERILATOR` or `ifdef VIVADO`.
- **`$display` / `$monitor`** may be used for debug output during simulation.

## Code Modification Rules

- **Only modify files under `vsrc`** — everything else is infrastructure/scaffolding.
- Main CPU entry point: `vsrc/src/core.sv` — all pipeline modules are instantiated here.

## Memory Bus Protocol

- **Bus naming convention**: CPU→cache is `*_req_t`, cache→CPU is `*_resp_t`. Cache is master, CPU is worker.
- **Handshake**: `valid`/`addr` must remain stable until `data_ok` goes high. After `data_ok`, if `valid` is still 1 next cycle, it starts a new request.
- **`ibus_req_t`**: `valid` (request?), `addr` (4-byte aligned).
- **`ibus_resp_t`**: `addr_ok`, `data_ok`, `data` (32-bit instruction).
- **`dbus_req_t`**: `valid`, `addr`, `size` (MSIZE1/2/4/8), `strobe` (byte enable, `0` for reads), `data`.
- **Strobe rule**: Memory auto-aligns `addr` down to 8 bytes. To write 1 byte `0xCD` at `0x1F2`: set `addr=0x1F2`, `data=0x00CD0000`, `strobe=0b0000_0100`, `size=MSIZE1` (size is advisory; strobe is authoritative).

## Difftest Connection Rules

- **Timing principle**: When an instruction commits (`valid=1`), its effects must already be visible. Difftest reads signals at `posedge clk` — the value set in the *current* cycle is compared on the *next* posedge.
- **Register file solution**: Use a `next_reg` shadow array (combinational write) connected to Difftest; actual `REG` updates on posedge.
- **First committed instruction** must be at `PCINIT` (`0x80000000`).
- **Skip signal**: Set for MMIO addresses (`addr[31] == 0`) — loads/stores to peripheral space. Must NOT always be 1, or Difftest loses all checking.

---

# Architecture

## Pipeline (5-stage in-order)

```
fetch.sv -> decode.sv -> execute.sv -> memory.sv -> writeback.sv
```

- **Pipeline registers** (packed structs in `core.sv`): `REG_IF_ID`, `REG_ID_EX`, `REG_EX_MEM`, `REG_MEM_WB`.
- **Step-based sync**: `step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok`; pipeline advances only when all stages ready.
- **Forwarding**: EX-MEM and MEM-WB paths via `forward_unit.sv`; register file has combinational WB-to-ID forwarding via `next_reg`. CSR registers do NOT forward — CSR writes always flush the pipeline.
- **Branches**: resolved in EX; taken branches flush pipeline via `redirect_valid`/`redirect_pc`. Static not-taken prediction.
- **CSR writes**: computed in EX, committed in WB (to match NEMU commit order). CSR changes always flush pipeline (treated as "jump to pc+4" with static not-taken mispredict).
- **Multiply/divide**: iterative state machine in EX (restore-division, shift-add multiplication). 64 cycles for 64-bit, 32 for 32-bit. Blocks pipeline until done via `execute_ok`.

## Module Reference (`vsrc/src/`)

### `core.sv`
Top-level CPU module. Instantiates all pipeline modules, regfile, csr_regfile, forward_unit. Defines pipeline register structs and `step` signal. Contains Difftest connections (under `ifdef VERILATOR`). Implements interrupt evaluation logic (Lab6). Exposes `priv_mode_out` and `satp_out` for external MMU in SimTop.

Key signals:
- `combined_redirect_valid` = `redirect_valid | interrupt_fire` — flushes fetch/decode
- `combined_trap` = `trap_fire | interrupt_fire` — flushes fetch/decode/memory
- `trap_in_progress` = `ex_mem_reg.trap_pending | mem_wb_reg.trap_pending` — prevents nested traps

### `fetch.sv`
Instruction fetch stage. Drives `ibus_req_t`/consumes `ibus_resp_t`. Exposes `current_pc` for interrupt mepc capture. Handles:
- `redirect_valid`: saves pending redirect if fetch in progress, otherwise immediate PC update
- `trap_fire`: immediate redirect to mtvec, clears fetch state
- Normal flow: `step & fetch_ok` → start request → wait `data_ok & addr_ok` → latch instruction, advance PC+4

**Critical**: `if_id_reg.pc` must be `req_pc` (PC at request time), not `pc + 4`.

### `decode.sv`
Instruction decode. Combinational decode from `if_id_reg.instr` fields (opcode, funct3, funct7, rd, rs1, rs2, immediate extraction). Generates control signals: `alu_op`, `alu_src`, `reg_write`, `mem_write`, `mem_read`, `mem_to_reg`, instruction type flags (`is_load`, `is_store`, `is_branch`, `is_jump`, `is_alu`, `is_aluimm`, `is_lui`, `is_auipc`, `is_system`, `is_csr`). Detects illegal instructions via default case in opcode switch — sets `is_illegal` flag passed through `except_illegal_instr` in `REG_ID_EX`. Flushed by `flush` signal.

Supported opcodes and immediate formats:
- U-type (`lui`, `auipc`): `{imm_u, 12'b0}` sign-extended
- I-type (load, ALUIMM, jalr, system): `{52{imm_i[11]}, imm_i}`
- S-type (store): `{52{imm_s[11]}, imm_s}`
- B-type (branch): `{51{imm_b[12]}, imm_b}` — bit 0 forced to 0
- J-type (jal): `{43{imm_j[20]}, imm_j}` — bit 0 forced to 0
- R-type: no immediate

### `execute.sv`
Execution stage. Selects operands via forwarding mux (forward_a/b from `forward_ctrl_t`). Executes ALU operations (ALU_OP codes 0-25). Branch resolution with condition evaluation. Jump target calculation. CSR read/write value computation. Multi-cycle multiply/divide state machine. Exception detection (instruction/data address misaligned, illegal instruction). Interrupt injection into pipeline. Generates `redirect_valid`, `redirect_pc`, `trap_fire`.

**ALU_OP mapping**:
| Code | Operation | Code | Operation |
|------|-----------|------|-----------|
| 0 | ADD | 14 | SRLW |
| 1 | SUB | 15 | SRAW |
| 2 | ADDW | 16 | MUL |
| 3 | SUBW | 17 | DIV |
| 4 | SLL | 18 | DIVU |
| 6 | SRL | 19 | REM |
| 7 | SRA | 20 | REMU |
| 8 | SLT | 21 | MULW |
| 9 | SLTU | 22 | DIVW |
| 10 | AND | 23 | DIVUW |
| 11 | OR | 24 | REMW |
| 12 | XOR | 25 | REMUW |
| 13 | SLLW | | |

**CSR instruction decode** (funct3-based):
- `001` (CSRRW): `csr_wval = rs1` (always write)
- `010` (CSRRS): `csr_wval = csr_rdata | rs1` (write if rs1 != 0)
- `011` (CSRRC): `csr_wval = csr_rdata & ~rs1` (write if rs1 != 0)
- `101` (CSRRWI): `csr_wval = {59'b0, rs1}` (always write, zimm)
- `110` (CSRRSI): `csr_wval = csr_rdata | {59'b0, rs1}` (write if rs1 != 0)
- `111` (CSRRCI): `csr_wval = csr_rdata & ~{59'b0, rs1}` (write if rs1 != 0)

**Forwarding mux** (forward_a/b): `00` = regfile, `01` = EX/MEM (mem_forward_data for loads, alu_result otherwise), `10` = WB data.

**Multiply/divide FSM**: States — idle, `md_busy` (iterating), `md_finishing` (last cycle), `md_result_ready`. `execute_ok` blocked during `md_busy`. Multiplication: shift-add with Booth-like signed handling. Division: restore algorithm.

**Exception detection** (all in EX):
- Instruction address misaligned (cause=0): branch target or JALR target `[1:0] != 0`
- Illegal instruction (cause=2): from decode's `except_illegal_instr`
- Load address misaligned (cause=4): load addr + size field check
- Store address misaligned (cause=6): store addr + size field check
- ECALL (cause=8/9/11): depends on current privilege level

### `memory.sv`
Memory access stage. Drives `dbus_req_t`/consumes `dbus_resp_t`. Handles store data alignment (data shift, strobe generation) and load data extraction (shift + sign/zero extension). Pipeline blocking via `mem_ok`:
- `mem_ok = ~(ex_mem_reg.valid && (is_load || is_store) && !req_completed)`
- Blocks `step` when a valid load/store has not completed

`req_completed` flag prevents duplicate requests for the same instruction. `saved_rdata` holds loaded data; exposed as `mem_forward_data` (combinational) for EX→MEM load forwarding.

Store strobe generation: shifts `1`/`3`/`F`/`FF` by `addr[2:0]` for byte/half/word/dword. Data shifted by `{addr[2:0], 3'b0}`.

On `flush` (trap): cancels in-progress dreq, but completed data is preserved.

### `writeback.sv`
Writeback stage. Always ready (`writeback_ok = 1'b1`). Writes to register file (`reg_wen` high when `valid & reg_write & rd != 0 & step`). Selects writeback data: ALU result or memory data based on `mem_to_reg`. Generates Difftest commit signals. `block_commit` suppresses commit during ecall (mret still commits for Difftest).

### `regfile.sv`
32-entry × 64-bit register file (x0 hardwired to 0). Combinational read with internal WB-to-ID forwarding (if `wen && raddr == waddr`, return `wdata` directly). Maintains `next_reg` shadow array (combinational) for Difftest connection — `next_reg[0]` forced to 0. Sequential write on posedge (writes `REG[waddr] <= wdata`). Reset clears all registers.

### `csr_regfile.sv`
CSR register file implementing all privileged CSRs. Two-layer design: `*_d` (combinational next state) and `*_q` (sequential current state).

**Implemented CSRs** (read/write):
| CSR | Address | Description | Special Behavior |
|-----|---------|-------------|------------------|
| mstatus | 0x300 | Machine status | Write mask: `MSTATUS_MASK` |
| mtvec | 0x305 | Machine trap vector | Write mask: `MTVEC_MASK` |
| mip | 0x344 | Machine interrupt pending | Bits [7,3,11] from external signals; write mask: `MIP_MASK` |
| mie | 0x304 | Machine interrupt enable | Full 64-bit writable |
| mscratch | 0x340 | Machine scratch | Full 64-bit writable |
| mcause | 0x342 | Machine cause | [63]=interrupt flag, [62:0]=code |
| mtval | 0x343 | Machine trap value | Full 64-bit writable |
| mepc | 0x341 | Machine exception PC | Full 64-bit writable |
| mcycle | 0xB00 | Machine cycle counter | Auto-increment each cycle; write overrides |
| mhartid | 0xF14 | Hardware thread ID | Read-only, hardwired to 0 |
| satp | 0x180 | Supervisor address translation | Full 64-bit writable |

**Trap CSR updates** (committed in WB via `trap_csr_commit`):
- **MRET**: `priv_mode <= mstatus.MPP`, `MIE <= MPIE`, `MPIE <= 1`, `MPP <= 0`, `XS <= 0`
- **Exception/Interrupt**: `mepc <= trap_pc`, `priv_mode <= M`, `MPP <= old_priv`, `MPIE <= MIE`, `MIE <= 0`, `mcause <= {is_interrupt, 57'b0, cause_code[5:0]}`

**Trap fire** (in EX, combinatorial): `priv_mode_d` immediately set — for MRET to `mstatus.MPP`, otherwise to M. This avoids combinational loops with interrupt evaluation.

**mip driven by external signals** (combinational): `mip_d[7]=trint`, `mip_d[3]=swint`, `mip_d[11]=exint`.

### `forward_unit.sv`
Data hazard forwarding control. Compares EX stage source registers (rs1, rs2) against destination registers in EX/MEM and MEM/WB:
- EX/MEM match → `forward_a/b = 01` (newest data)
- MEM/WB match → `forward_a/b = 10` (second-newest)
- No match → `forward_a/b = 00` (register file)
Only forwards when `reg_write` is set and `rd != 0`.

### `mmu.sv`
Sv39 page table walker, placed on CBus after the arbiter (`SimTop.sv`). FSM states: `ST_IDLE` (passthrough when MMU off), `ST_PTE` (page table walk in progress), `ST_WAIT` (translated address applied). Enabled only when `priv_mode != M` and `satp.mode == 8`. Uses `PTEHelper` (Verilator simulation support) for page table lookup. Supports variable-level page table resolution (level 0 = 1GB page, level 1 = 2MB page, level 2 = 4KB page). When MMU is off, acts as transparent passthrough.

## Bus Hierarchy

```
Core (ibus + dbus)
  IBusToCBus → icreq/icresp
  DBusToCBus → dcreq/dcresp
       ↓
  CBusArbiter (2 inputs, ibus priority)
       ↓
  MMU (Sv39 address translation when enabled)
       ↓
  RAMHelper2 (testbench memory + interrupt signals)
```

- `CBusArbiter`: Priority arbiter — ibus has priority (index=0). One-cycle latency on all requests.
- `IBusToCBus`: Converts `ibus_req_t` → `cbus_req_t` (read-only, 4-byte burst).
- `DBusToCBus`: Converts `dbus_req_t` → `cbus_req_t` (read/write, variable size).

## FPGA Deployment

Target: Basys-3. `VTop.sv` is synthesis top (no RAM, exposes CBus). `mycpu_top.sv` wraps with AXI-like interface. Vivado project at `vivado/test-cpu/project/project_1.xpr`. The `VIVADO` ifdef path uses different include paths (no `src/` prefix) — maintain both when adding new modules.

---

# Lab Goals & Test Methods

## Lab 1 — Basic Pipeline

**Goal**: Build a 5-stage in-order pipeline CPU supporting RV64I arithmetic/logical instructions.

**Required instructions**: `addi`, `xori`, `ori`, `andi`, `add`, `sub`, `and`, `or`, `xor`, `addiw`, `addw`, `subw`

**Implementation tasks**:
- Wire up fetch module with ibus (instruction memory bus)
- Implement all 5 pipeline stages and pipeline registers
- Connect Difftest: `DifftestInstrCommit` (pc, instr, wen, wdest, wdata), `DifftestArchIntRegState` (all 32 GPRs via `next_reg`)

**Test**: `make test-lab1`
**Expected output**: `HIT GOOD TRAP` in the log

---

## Lab 2 — Memory Load/Store

**Goal**: Support memory read/write instructions and implement dreq/dresp handling in Memory stage.

**Required instructions**: `ld`, `sd`, `lb`, `lh`, `lw`, `lbu`, `lhu`, `lwu`, `sb`, `sh`, `sw`, `lui`

**Implementation tasks**:
- Add data bus (dbus) interface in Memory stage
- Handle `dreq` fields: addr, size, strobe, data for stores; addr, size for loads
- Implement data alignment: shift data by `{addr[2:0], 3'b0}`, generate strobe by shifting byte mask by `addr[2:0]`
- Implement load data extraction and sign/zero extension (lb/lh/lw/ld/lbu/lhu/lwu)

**Test**: `make test-lab2`
**Expected output**: `HIT GOOD TRAP`

---

## Lab 3 — Branches, Shifts, FPGA

**Goal**: Support control flow (branches, jumps) and shift instructions. FPGA deployment.

**Required instructions**: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `slti`, `sltiu`, `slli`, `srli`, `srai`, `sll`, `slt`, `sltu`, `srl`, `sra`, `slliw`, `srliw`, `sraiw`, `sllw`, `srlw`, `sraw`, `auipc`, `jalr`, `jal`

**Implementation tasks**:
- Branch resolution in EX stage with condition evaluation
- Jump target calculation (JAL: `pc+imm`, JALR: `(rs1+imm) & ~1`)
- Pipeline flush on taken branches/jumps
- Add `skip` to `DifftestInstrCommit`: `skip = (mem && memaddr[31] == 0)` — skip MMIO loads/stores
- FPGA board testing

**Test**: `make test-lab3`
**Expected output**: `HIT GOOD TRAP`

### Lab 3 Extra (Bonus)

**Bonus instructions**: `mul`, `div`, `divu`, `rem`, `remu`, `mulw`, `divw`, `divuw`, `remw`, `remuw`

**Key constraint**: Cannot use `*` or `/` operators directly (would create combinational paths with hundreds of gate delays). Must implement iterative state machine:
- Multiplication: shift-add algorithm (64 cycles for 64-bit, 32 for 32-bit)
- Division: restore algorithm (64 cycles)
- Signed operations: convert to absolute values, compute, then fix signs
- Edge cases: div by 0 → all 1's; overflow (MIN_INT / -1) → MIN_INT; rem by 0 → dividend

**Test**: `make test-lab3-extra`
**Expected output**: `HIT GOOD TRAP`, with visible performance difference vs non-mul/div tests.

---

## Lab 4 — CSR Instructions

**Goal**: Implement CSR (Control and Status Register) read/write instructions.

**Required instructions**: `CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`

**Required CSRs**: `mstatus`, `mtvec`, `mip`, `mie`, `mscratch`, `mcause`, `mtval`, `mepc`, `mcycle` (auto-increment each cycle, write overrides), `mhartid` (hardwired to 0), `satp`

**Implementation tasks**:
- Implement `csr_regfile.sv` with all above CSR registers
- Connect `DifftestCSRState` (mstatus, sstatus, mepc, mtval, mtvec, mcause, satp, mip, mie, mscratch)
- Apply write masks: `MSTATUS_MASK`, `MIP_MASK`, `MTVEC_MASK` (defined in `csr.sv`)
- `sstatus` = `mstatus & SSTATUS_MASK` (it's a view/subset of mstatus, not a separate physical register)
- CSR writes flush pipeline (treated as "jump to pc+4" mispredict)
- CSR registers do NOT use forwarding — always flush on write
- `coreid` for all Difftest modules should be `mhartid[7:0]`

**Test**: `make test-lab4`
**Expected output**: `HIT GOOD TRAP`

### Lab 4 Bonus

- **Bonus**: Implement S-mode CSRs (`stvec`, `sstatus`, `sscratch`, `sepc`, `scause`, `stval`, `sie`, `sip`) — addresses defined in `csr.sv`.

---

## Lab 5 — Privilege Levels & MMU

**Goal**: Implement privilege mode switching and Sv39 virtual memory.

**Required instructions**: `MRET`, `ECALL`

**Implementation tasks**:

### Privilege Levels
- Maintain `priv_mode` register (encodings: M=3, S=1, U=0 per RISC-V spec). Connect to Difftest.
- Power-on: M mode.
- **MRET** (privilege lowering):
  - `pc ← mepc`, flush pipeline
  - `priv_mode ← mstatus.MPP`
  - `mstatus.MPIE ← 1`, `mstatus.MIE ← mstatus.MPIE`, `mstatus.MPP ← 0` (U if supported, else M)
- **ECALL** (privilege raising):
  - `pc ← mtvec`, flush pipeline
  - `priv_mode ← M`
  - `mepc ← pc` (of the ecall instruction)
  - `mcause ← 8` (ecall from U) or `11` (ecall from M)
  - `mstatus.MPIE ← mstatus.MIE`, `mstatus.MIE ← 0`, `mstatus.MPP ← old_priv`

### MMU (Sv39)
- `satp` register: `mode[63:60]`, `asid[59:44]`, `ppn[43:0]`.
- MMU enabled only when: `priv_mode != M` AND `satp.mode == 8`.
- Three-level page table walk:
  - Level 0: Base = `{satp.ppn, 12'b0}`, Index = `vaddr[38:30]`
  - Level 1: Base = `{pte.ppn, 12'b0}`, Index = `vaddr[29:21]`
  - Level 2: Base = `{pte.ppn, 12'b0}`, Index = `vaddr[20:12]`
  - Physical address = `{leaf_pte.ppn, vaddr[11:0]}`
- Both fetch and memory stages need address translation — MMU is placed on CBus after the arbiter in `SimTop.sv`.
- `priv_mode` and `satp` signals must be routed from Core through SimTop to MMU.

**Test**: `make test-lab5`
**Expected output**: `Return from init! Test passed` (CPU may appear to hang after — this is normal)

**Board test required**.

### Lab 5 Bonus

- **Bonus**: Support giant pages (2MB at level 1, 1GB at level 0) — check PTE flags (R/W/X) to determine if a non-leaf PTE is actually a leaf. At leaf, the remaining VPN bits become part of the page offset.

---

## Lab 6 — Interrupts & Exceptions

**Goal**: Support exception handling and interrupt processing.

**Required features**: Clock interrupt (MTI), external interrupt (MEI), software interrupt (MSI), exceptions (ECALL, illegal instruction, instruction/load/store address misaligned).

### Exception Handling

**Detection locations**:
| Exception | mcause | Detection | Condition |
|-----------|--------|-----------|-----------|
| Instruction addr misaligned | 0 | EX | Branch/JALR target `[1:0] != 0` |
| Illegal instruction | 2 | Decode | opcode not recognized |
| Load addr misaligned | 4 | EX | Load addr misaligned for size |
| Store addr misaligned | 6 | EX | Store addr misaligned for size |
| ECALL (U-mode) | 8 | EX | `ecall` in U-mode |
| ECALL (S-mode) | 9 | EX | `ecall` in S-mode |
| ECALL (M-mode) | 11 | EX | `ecall` in M-mode |

**Exception flow**:
1. `mepc ← pc`
2. `next_pc ← mtvec`
3. `mcause[63] ← 0` (exception), `mcause[62:0] ← code`
4. `mstatus.mpie ← mstatus.mie`
5. `mstatus.mie ← 0`
6. `mstatus.mpp ← mode`
7. `mode ← M`
8. Flush pipeline, cancel pending dreq

### Interrupt Handling

**Interrupt sources**:
| Interrupt | Signal | mip bit | mcause |
|-----------|--------|---------|--------|
| Clock (MTI) | `trint` | mip[7] | 7 |
| Software (MSI) | `swint` | mip[3] | 3 |
| External (MEI) | `exint` | mip[11] | 11 |

mip bits for interrupts are driven by external signals (combinational). Interrupts are persistent level signals, not edges — can use `=` assignment, no need to manually clear.

**Interrupt trigger conditions** (both must be true):
1. Interrupt enabled: `(priv == M && mstatus.MIE == 1) || (priv != M)`
2. Specific interrupt pending: `mip[i] == 1 && mie[i] == 1`

**Interrupt evaluation timing** (Lab6 simplified — only condition 1):
- When a new interrupt signal arrives (detected at instruction boundary: `step && fetch_ok && !trap_fire`)

**Interrupt priority** (in code): MEI > MSI > MTI

**Interrupt flow**:
1. Same as exception, except `mcause[63] ← 1` (interrupt)
2. `mepc ← fetch_current_pc` (the PC of the next instruction to be fetched, not a completed instruction)
3. Interrupt injected through execute module as a trap bubble

### MRET (updated for Lab6)
- `mstatus.mie ← mstatus.mpie`
- `mstatus.mpie ← 1`
- `mode ← mstatus.mpp`
- `mstatus.mpp ← 0`
- `mstatus.xs ← 0` (added in Lab6)

### Design Notes
- `priv_mode` output uses `priv_mode_q` (registered) to avoid combinational loops with interrupt evaluation in `core.sv`.
- During interrupt/trap handling, `priv_mode` is forced to M (combinational override: `interrupt_taken || trap_in_progress`).
- Trap CSR updates flow through pipeline: EX fire → MEM pending → WB commit (`trap_csr_commit`).
- `trap_in_progress` (EX+MEM+WB trap_pending) prevents nested traps.

**Test**: `make test-lab6`
**Expected output**:
```
Single test passed.
Run sys-test
trap here, epc 8000600c, cause 8
Test ecall_u [OK]
trap here, epc 8000608c, cause 8
trap here, epc 80006028, cause 0
Test instr_misalign [OK]
trap here, epc 8000608c, cause 8
trap here, epc 80006040, cause 4
Test load_misalign [OK]
trap here, epc 8000608c, cause 8
trap here, epc 80006050, cause 6
Test store_misalign [OK]
trap here, epc 8000608c, cause 8
trap here, epc 80007f68, cause 8000000000000007
Test timer_intr [OK]
trap here, epc 8000608c, cause 8
trap here, epc 80007f68, cause 8000000000000003
Test software_intr [OK]
...
Privileged test finished.
```

Lab6 test does not use Difftest. "Privileged test finished." indicates pass. Subsequent "m_trap_test [X] ---TEST FAILED---" is normal (Ctrl+C to exit).

**No board test required for Lab6**.

### Lab 6 Bonus

- **Bonus 1**: Implement MMU page fault exception (cause=12 for instruction page fault, cause=13 for load page fault, cause=15 for store page fault). Detect page faults in `mmu.sv` during page table walk (V=0, permission mismatch), export `pf_valid`/`pf_vaddr`/`pf_is_fetch` to core. Set `mtval` to faulting virtual address.

- **Bonus 2**: Write a clock interrupt handler in C/assembly using `mtime` (at `0x3800bff8`) and `mtimecmp` (at `0x38004000`). The handler should print content on timer interrupt and reset `mtimecmp`. Provide complete C/C++/assembly code in the report (no source file required).

- **Bonus 3**: Explain why clock interrupt uses MMIO timers instead of CSR registers:
  1. Independent clock domain — timer keeps running when CPU is in low-power/sleep (WFI)
  2. Multi-core synchronization — all cores share the same `mtime` for consistent timebase
  3. Frequency independence — timer can use a different (more stable) clock source than CPU core
  4. Hot-plug support — timer survives individual core reset/power-down
  5. `mcycle` (CSR, per-core, CPU-clock-gated) cannot replace `mtime` for these reasons

---

# Key Design Decisions & Known Patterns

## Trap/CSR Pipeline Flow
- **CSR writes**: computed in EX (`csr_pwdata`, `csr_paddr`), passed through EX_MEM and MEM_WB, committed in WB (`csr_pending` flag).
- **Traps (exceptions/interrupts/mret)**: fired in EX as a bubble (`trap_pending=1`), CSR state update committed in WB via `trap_csr_commit`.
- **Pipeline flush**: `combined_redirect_valid` flushes fetch/decode; `combined_trap` additionally cancels pending dreq in memory.
- **`block_commit`**: prevents WB from committing the ecall instruction itself to Difftest (mret still commits).

## Interrupt Evaluation Safety
- Uses `priv_mode_q` (registered/sequential) not `priv_mode` (combinational) — avoids `priv_mode → interrupt_fire → trap_fire → priv_mode` combinational loop.
- `priv_mode` is still available (combinational with M override during trap_in_progress) for other uses.
- Priority: MEI (11) > MSI (3) > MTI (7).

## Test Pass Indicators Summary

| Lab | Command | Success Indicator |
|-----|---------|-------------------|
| Lab1 | `make test-lab1` | `HIT GOOD TRAP` |
| Lab2 | `make test-lab2` | `HIT GOOD TRAP` |
| Lab3 | `make test-lab3` | `HIT GOOD TRAP` |
| Lab3 Extra | `make test-lab3-extra` | `HIT GOOD TRAP` |
| Lab4 | `make test-lab4` | `HIT GOOD TRAP` |
| Lab5 | `make test-lab5` | `Return from init! Test passed` |
| Lab6 | `make test-lab6` | `Privileged test finished.` |

## Common Issues & Debugging

| Error | Cause | Fix |
|-------|-------|-----|
| `No rule to make target 'emu'` | Submodule not initialized | `make init` |
| `Unexpected CBus request modification` | Changed ireq valid/addr before data_ok | Keep ireq stable until data_ok |
| `Settle region did not converge` | Combinational loop (e.g., `a=b; b=~a`) | Check signal dependency chain |
| `No instruction commits for 5000 cycles` | First commit not at PCINIT, or valid not working | Check first instruction is at `0x80000000` |
| Vivado `X` state on signals | Used inline initialization `logic x = y` | Use `logic x; assign x = y;` |
| `different at pc` in Difftest | Instruction result mismatch vs NEMU | Check the `.S` file at that PC, use waveform |

---

# Notes

- Initial PC is `0x80000000` (`PCINIT` in `common.sv`).
- The `pc` output to `if_id_reg` must be the PC at request time (`req_pc`), not `pc + 4`.
- `Lab.md` contains per-lab implementation notes from the student. Read it before making changes — it documents which lab is currently in progress and any known issues.
- `Lab6_report.md` contains detailed Lab6 implementation analysis and bonus content.
