# Lab6 实验报告：中断与异常

## 一、实验目标与完成情况

Lab6 在 Lab5（特权级切换与 MMU）基础上，实现 RISC-V 特权架构中的**中断与异常**处理。本 CPU 现已通过 `make test-lab6`，输出包含 `Privileged test finished.`。

| 功能 | 状态 |
|------|------|
| 指令/Load/Store 地址不对齐异常 | 通过 |
| 非法指令异常 | 通过 |
| ECALL（U/S/M 模式） | 通过 |
| 时钟中断（MTI） | 通过 |
| 软件中断（MSI） | 通过 |
| 外部中断（MEI） | 已实现（与 MTI/MSI 共用评估逻辑） |
| MRET 返回（含 `mstatus.xs ← 0`） | 通过 |
| M 模式定时中断（`m_trap_test`） | 通过 |

---

## 二、异常处理

### 2.1 异常类型与检测位置

| 异常类型 | mcause | 检测阶段 | 检测条件 |
|----------|--------|----------|----------|
| 指令地址不对齐 | 0 | EX | 分支/JALR 目标 `[1:0] != 00` |
| 非法指令 | 2 | Decode | opcode 不在支持列表 |
| Load 地址不对齐 | 4 | EX | 地址与 load size 不对齐 |
| Store 地址不对齐 | 6 | EX | 地址与 store size 不对齐 |
| ECALL (U-mode) | 8 | EX | `ecall` 且 `priv_mode_q == U` |
| ECALL (S-mode) | 9 | EX | `ecall` 且 `priv_mode_q == S` |
| ECALL (M-mode) | 11 | EX | `ecall` 且 `priv_mode_q == M` |

### 2.2 异常处理流程

发生异常时，硬件依次完成：

1. `mepc ←` 异常指令 PC
2. `pc ← mtvec`，冲刷流水线
3. `mcause[63] ← 0`，`mcause[5:0] ←` 异常码
4. `mstatus.MPIE ← mstatus.MIE`，`mstatus.MIE ← 0`
5. `mstatus.MPP ←` 当前特权级
6. `priv_mode ← M`
7. 取消当周期未完成的 dreq

异常在 EX 阶段触发 `trap_fire`，经 EX→MEM→WB 流水传递 `trap_pending`，在 WB 阶段 `trap_csr_commit` 时更新 CSR（与 CSR 写、MRET 提交顺序一致）。

### 2.3 非法指令检测

Decode 阶段对未知 opcode 置 `except_illegal_instr`，经 `REG_ID_EX` 传入 EX，参与 `except_fire` 判定。

---

## 三、中断处理

### 3.1 中断源映射

| 类型 | 外部信号 | mip 位 | mie 位 | mcause |
|------|----------|--------|--------|--------|
| 时钟 (MTI) | `trint` | [7] | [7] | 7 |
| 软件 (MSI) | `swint` | [3] | [3] | 3 |
| 外部 (MEI) | `exint` | [11] | [11] | 11 |

`mip` 的 MTIP/MSIP/MEIP 由外部信号组合逻辑驱动；`mie` 由 CSR 写入维护。

### 3.2 中断触发条件

中断实际发生需同时满足：

1. **全局/特权使能**：`(priv == M && mstatus.MIE == 1) || (priv != M)`
2. **局部使能**：`mip[i] == 1 && mie[i] == 1`

### 3.3 中断评估时机（Lab6 简化）

仅在流水线即将推进（`step && fetch_ok`）且**无 trap 提交/进行中**时评估：

```systemverilog
// core.sv — 中断评估核心逻辑
if (step && fetch_ok && !trap_fire && !trap_csr_commit && !trap_in_progress) begin
    if ((priv_mode_q == 2'b11 && csr_mstatus[3]) || (priv_mode_q != 2'b11)) begin
        if      (exint && csr_mie_q[11]) interrupt_fire = 1; // MEI 优先
        else if (swint && csr_mie_q[3])  interrupt_fire = 1; // MSI
        else if (trint && csr_mie_q[7])  interrupt_fire = 1; // MTI
    end
end
```

要点：

- 使用 **`priv_mode_q`（寄存器值）** 判断特权级，避免与 `interrupt_fire` 的组合环路。
- M 模式下 **`mstatus.MIE` 使用 `mstatus_d[3]`（组合下一态）**，使 `csrsi mstatus, 8` 写入 MIE 的同一周期即可响应 M 模式定时中断（`m_trap_test` 所需）。
- **`!trap_csr_commit`** 阻止 MRET 提交周期误触发中断（此前导致 U 模式定时测试出现 `Unexpected M-mode trap`）。
- **`!trap_in_progress`** 防止 trap 气泡在流水线中尚未提交时嵌套响应新中断。

### 3.4 mepc 保存策略

Lab 要求 `mepc ← fetch_current_pc`（下一条待取指 PC）。`m_trap_test` 中 M 模式 MIE 窗口极窄（`csrsi`/`csrci` 之间），若仅取 IF/ID 的 PC，会在 `csrci` 已进入 EX/MEM 时保存错误地址。

最终采用**流水线最前有效段的 PC**：

```systemverilog
assign interrupt_save_pc = ex_mem_reg.valid ? ex_mem_reg.pc :
                           id_ex_reg.valid  ? id_ex_reg.pc  : fetch_current_pc;
```

这样在 `csrci` 处于 EX/MEM 且 MIE 仍为 1 时，`mepc` 仍指向 `0x80008048`，满足测试对 `m_test_trap_entry` 的检查。

### 3.5 中断注入与 CSR 更新

1. `interrupt_fire` → execute 注入 trap 气泡（`trap_pending=1`, `trap_is_interrupt=1`）
2. `combined_trap` 冲刷 fetch/decode/memory，取消未完成 dreq
3. `combined_redirect_pc ← mtvec`
4. WB 阶段 `trap_csr_commit` 更新 `mepc/mcause/mstatus/priv_mode`

---

## 四、MRET 与 CSR 更新

MRET 在 WB 提交时：

- `priv_mode ← mstatus.MPP`
- `mstatus.MIE ← mstatus.MPIE`，`mstatus.MPIE ← 1`
- `mstatus.MPP ← 0`，`mstatus.xs ← 0`

`trap_fire_ex` 在 EX 阶段对 MRET 提前组合更新 `priv_mode_d`，避免特权级评估滞后。

---

## 五、模块修改汇总

| 文件 | 主要修改 |
|------|----------|
| `core.sv` | 中断评估、`trap_in_progress`、`interrupt_save_pc`、Difftest 连接 |
| `csr_regfile.sv` | mip 外部驱动、trap CSR 提交、MRET xs 清零 |
| `fetch.sv` | 输出 `current_pc` |
| `decode.sv` | 非法指令检测 |
| `execute.sv` | 异常检测、中断/陷阱气泡、trap_code |
| `memory.sv` | trap 字段透传、flush 时取消 dreq |

---

## 六、测试结果

```text
Single test passed.
Run sys-test
Test ecall_u [OK]
Test instr_misalign [OK]
Test load_misalign [OK]
Test store_misalign [OK]
Test timer_intr [OK]
Test software_intr [OK]
Timer interrupt in test_trap, this should happen 50 times.
...
Test m_trap [OK]
Privileged test finished.
```

Lab1–Lab6 仿真测试均通过：

| Lab | 命令 | 通过标志 |
|-----|------|----------|
| Lab1–4 | `make test-labN` | `HIT GOOD TRAP` |
| Lab3 Extra | `make test-lab3-extra` | `HIT GOOD TRAP`（乘除法） |
| Lab5 | `make test-lab5` | `Return from init! Test passed` |
| Lab6 | `make test-lab6` | `Privileged test finished.` |

---

## 七、Lab1–Lab6 与 Bonus 完成情况

### 7.1 必做实验

| Lab | 内容 | 状态 |
|-----|------|------|
| Lab1 | 五级流水线、基础算术 | 完成 |
| Lab2 | Load/Store | 完成 |
| Lab3 | 分支/移位/跳转 | 完成 |
| Lab4 | CSR 读写 | 完成 |
| Lab5 | MRET/ECALL、Sv39 MMU | 完成 |
| Lab6 | 中断与异常 | 完成 |

### 7.2 Bonus

| 项目 | 状态 | 说明 |
|------|------|------|
| Lab3 Extra 乘除法 | **完成** | 迭代状态机，`make test-lab3-extra` 通过 |
| Lab5 巨页（2MB/1GB） | **完成** | `mmu.sv` 中 `sv39_paddr` 按 PTE level 拼接 |
| Lab4 S 模式 CSR | 未完成 | 未实现 `stvec/sepc/scause` 等物理寄存器 |
| Lab6 缺页异常 | 未完成 | MMU 检测 `pte_pf` 但未向 core 上报 trap |
| Lab6 时钟中断 C 程序 | 报告内给出示例 | 见下文 Bonus 2 |
| Lab6 MMIO 计时器说明 | 报告内完成 | 见下文 Bonus 3 |

---

## 八、Bonus 2：时钟中断处理程序（示例）

`mtime` / `mtimecmp` 地址（仿真环境）：

- `mtime`：`0x3800bff8`
- `mtimecmp`：`0x38004000`

```c
#define MTIME_ADDR    ((volatile unsigned long long *)0x3800bff8ULL)
#define MTIMECMP_ADDR ((volatile unsigned long long *)0x38004000ULL)

void handle_timer(void) {
    puts("[Timer Interrupt]");
    unsigned long long now = *MTIME_ADDR;
    *MTIMECMP_ADDR = now + 1000000ULL;  // 重设下次中断
}
```

汇编入口在 `mtvec` 保存上下文后读取 `mcause`/`mepc`，调用 C 处理函数，再 `mret` 返回。

---

## 九、Bonus 3：为何使用 MMIO 计时器

1. **独立于 CPU 时钟**：CPU 休眠（WFI）时 MMIO 计时器仍可运行，CSR `mcycle` 会随核心停钟。
2. **多核共享时间基准**：所有 hart 读取同一 `mtime`，便于调度与 IPI。
3. **频率解耦**：计时器可用更稳定的外部时钟源。
4. **符合 RISC-V 规范**：ACLINT/CLINT 将 `mtime`/`mtimecmp` 定义为 MMIO 设备，而非 per-hart CSR。

`mcycle` 仅统计核心周期，不能替代全局 wall-clock 计时。

---

## 十、调试经验

1. **`Unexpected M-mode trap`**：MRET 提交周期 `mstatus_d.MIE` 已为 1 但 `priv_mode_q` 仍为 M，需用 `!trap_csr_commit` 屏蔽该周期的中断评估。
2. **`m_trap_test` 仅成功数次后失败**：M 模式 MIE 窗口极窄，需用 EX/MEM 段 PC 作为 `mepc`，并依赖 `mstatus_d` 使 `csrsi` 同周期生效。
3. **组合环路**：中断评估必须用 `priv_mode_q`，CSR 输出 `priv_mode` 在 trap 期间组合强制为 M 仅用于 MMU 等外部模块。

---

## 十一、总结

Lab6 完整实现了 RISC-V M 模式下的异常与三类中断处理，并与 Lab5 的特权级、MMU 协同工作。通过修正中断评估时序与 `mepc` 保存策略，解决了定时中断在 U 模式与 M 模式下的测试失败问题。Lab1–Lab6 必做目标及 Lab3 乘除法、Lab5 巨页等 bonus 均已完成；S 模式 CSR 与硬件缺页 trap 留作后续扩展。
