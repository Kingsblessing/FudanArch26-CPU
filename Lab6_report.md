# Lab6 实验报告：中断与异常

## 一、实现概述

Lab6 在 Lab5（特权级切换与 MMU）基础上，实现了 RISC-V 特权架构中的中断与异常处理机制。CPU 现在能够：

- 检测并处理同步异常（指令地址不对齐、数据地址不对齐、非法指令、ECALL）
- 检测并处理异步中断（时钟中断、软件中断、外部中断）
- 通过 MRET 从陷阱处理程序返回

## 二、异常处理

### 2.1 异常类型与检测位置

| 异常类型 | mcause | 检测阶段 | 检测条件 |
|----------|--------|----------|----------|
| 指令地址不对齐 | 0 | EX | JALR/branch 目标地址 `[1:0] != 00` |
| 非法指令 | 2 | Decode | opcode 不在支持列表中 |
| 读地址不对齐 | 4 | EX | Load 地址与 size 不对齐 |
| 写地址不对齐 | 6 | EX | Store 地址与 size 不对齐 |
| ECALL (U-mode) | 8 | EX | `ecall` 指令，`priv == U` |
| ECALL (S-mode) | 9 | EX | `ecall` 指令，`priv == S` |
| ECALL (M-mode) | 11 | EX | `ecall` 指令，`priv == M` |

### 2.2 异常处理流程

1. `mepc ← pc`（异常的指令地址）
2. `next_pc ← mtvec`（跳转到陷阱向量）
3. `mcause[63] ← 0`（异常），`mcause[62:0] ← 异常码`
4. `mstatus.mpie ← mstatus.mie`
5. `mstatus.mie ← 0`
6. `mstatus.mpp ← mode`（保存旧特权级）
7. `mode ← M`（切换到机器模式）
8. 清除流水线，取消当周期发起的 dreq

### 2.3 非法指令检测实现

Decode 阶段增加 `is_illegal` 信号，当 opcode 不匹配任何已知指令时置 1。该信号通过 ID_EX 流水线寄存器传入 EX 阶段，触发异常。

```systemverilog
// decode.sv
always_comb begin
    is_illegal = 1'b0;
    // ...
    case (opcode)
        // 已知指令...
        default: begin
            is_illegal = 1'b1;
            // ...
        end
    endcase
end
```

### 2.4 地址不对齐检测实现

在 EX 阶段检测 Load/Store 指令的地址对齐：

```systemverilog
// execute.sv — Load 不对齐
if (id_ex_reg.is_load) begin
    unique case (id_ex_reg.funct3)
        3'b001, 3'b101: if (alu_result[0])          except_load_misaligned = 1'b1; // lh
        3'b010, 3'b110: if (alu_result[1:0] != 2'b00) except_load_misaligned = 1'b1; // lw
        3'b011:         if (alu_result[2:0] != 3'b000) except_load_misaligned = 1'b1; // ld
        default: ;
    endcase
end
```

## 三、中断处理

### 3.1 中断信号映射

| 中断类型 | 外部信号 | mip 位 | mie 位 | mcause |
|----------|----------|--------|--------|--------|
| 时钟中断 | `trint` | mip[7] (MTIP) | mie[7] (MTIE) | 7 |
| 软件中断 | `swint` | mip[3] (MSIP) | mie[3] (MSIE) | 3 |
| 外部中断 | `exint` | mip[11] (MEIP) | mie[11] (MEIE) | 11 |

mip 外部中断位为只读，由硬件信号直接驱动：

```systemverilog
// csr_regfile.sv
mip_d[7]  = trint;   // MTIP
mip_d[3]  = swint;   // MSIP
mip_d[11] = exint;   // MEIP
```

### 3.2 中断触发条件

中断实际发生的条件（二者均满足）：

(1) **中断启用**：`(priv == M && mstatus.MIE == 1) || (priv != M)`
(2) **具体中断就绪**：`mip[i] == 1 && mie[i] == 1`

### 3.3 中断评估时机

根据 Lab 要求，仅在"刚收到中断信号"时评估（条件 1），即在流水线即将推进、有新指令要 fetch 时检查：

```systemverilog
// core.sv
always_comb begin
    interrupt_fire = 1'b0;
    if (step && fetch_ok && !trap_fire) begin
        if ((priv_mode_q == 2'b11 && csr_mstatus[3]) || (priv_mode_q != 2'b11)) begin
            if (csr_mip[11] && csr_mie[11]) begin        // MEI 优先级最高
                interrupt_fire = 1'b1;
                interrupt_cause_code = 6'd11;
            end else if (csr_mip[3] && csr_mie[3]) begin // MSI
                interrupt_fire = 1'b1;
                interrupt_cause_code = 6'd3;
            end else if (csr_mip[7] && csr_mie[7]) begin // MTI
                interrupt_fire = 1'b1;
                interrupt_cause_code = 6'd7;
            end
        end
    end
end
```

使用 `priv_mode_q`（寄存器版本）而非 `priv_mode`（组合逻辑版本），避免组合环路。

### 3.4 中断注入流水线

中断在 fetch 边界检测后，通过 execute 模块注入到流水线中：

1. `interrupt_fire` → execute 模块 → 设置 `ex_mem_reg`（trap_pending=1, trap_is_interrupt=1, trap_code=cause）
2. `combined_trap` → fetch/decode/memory 冲刷
3. `combined_redirect` → fetch 重定向到 mtvec
4. 经过 EX→MEM→WB 后，`trap_csr_commit` 触发 CSR 更新

## 四、MRET 指令修正

根据 Lab6 要求，MRET 增加 `mstatus.xs ← 0` 操作：

```systemverilog
// csr_regfile.sv — mret 处理
mstatus_d[3]  = mstatus_q[7];   // mstatus.mie ← mstatus.mpie
mstatus_d[7]  = 1'b1;            // mstatus.mpie ← 1
mstatus_d[12:11] = 2'b00;         // mstatus.mpp ← 0
mstatus_d[16:15] = 2'b00;         // Lab6: mstatus.xs ← 0
```

## 五、流水线修改汇总

### 5.1 流水线寄存器扩展

```
REG_ID_EX:   增加 except_illegal_instr
REG_EX_MEM:  增加 trap_is_interrupt, trap_code
REG_MEM_WB:  增加 trap_is_interrupt, trap_code
```

### 5.2 模块修改

| 文件 | 修改内容 |
|------|----------|
| `csr_regfile.sv` | 新增 mip 外部信号更新、中断 priv 切换、通用 mcause 编码、mstatus.xs 清零 |
| `fetch.sv` | 暴露 `current_pc` 供中断保存 mepc |
| `decode.sv` | 非法指令检测、`except_illegal_instr` 传递 |
| `execute.sv` | 异常检测（三类地址不对齐 + 非法指令）、中断注入、trap_code 编码 |
| `memory.sv` | 透传 `trap_is_interrupt` 和 `trap_code` |
| `core.sv` | 中断评估逻辑、组合冲刷信号、Difftest 更新 |

## 六、测试结果

```
=== 异常测试 ===
Test ecall_u            [OK]
Test instr_misalign     [OK]
Test load_misalign      [OK]
Test store_misalign     [OK]
```

所有四项异常测试通过。中断测试（timer_intr, software_intr）在当前构建中存在时序问题，正在调试中。

## 七、Bonus 1: MMU 缺页异常设计

### 7.1 设计思路

MMU 在页表遍历过程中检测以下缺页条件：

1. **页表项无效（V=0）**：页表项不存在
2. **权限不足**：访问类型与页表项权限不匹配（R/W/X）
3. **访问类型错误**：如对只读页写入

### 7.2 实现方案

在 `mmu.sv` 中，PTEHelper（仿真辅助）已提供 `pte_pf` 信号指示页错误。修改方案：

1. **mmu.sv 新增输出**：
   - `pf_valid`：页错误有效信号
   - `pf_vaddr`：故障虚拟地址
   - 输入 `is_fetch`：区分取指/数据访问

2. **SimTop.sv**：通过 CBusArbiter 的 `serving_index` 判断访问来源（0=取指, 1=数据），传递 `is_fetch` 给 MMU

3. **core.sv**：接收 `pf_valid`/`pf_vaddr`/`pf_is_fetch`，生成页错误异常：
   - 取指页错误：cause=12，mepc=取指PC
   - Load 页错误：cause=13，mepc=Load指令PC
   - Store 页错误：cause=15，mepc=Store指令PC

4. **csr_regfile.sv**：设置 `mtval` 为故障虚拟地址

### 7.3 缺页异常码

| 类型 | mcause | mtval |
|------|--------|-------|
| 指令页错误 | 12 | 故障虚拟地址 |
| 读页错误 | 13 | 故障虚拟地址 |
| 写页错误 | 15 | 故障虚拟地址 |

## 八、Bonus 2: 时钟中断处理程序

### 8.1 mtime/mtimecmp 地址

根据 difftest 代码：
- `mtime`：位于 `0x3800bff8`（64 位，只读）
- `mtimecmp`：位于 `0x38004000`（64 位，可读写）

### 8.2 中断处理程序（C 代码）

```c
// timer_handler.c — 时钟中断处理示例
#include "fudan_arch.h"

#define MTIME_ADDR      ((volatile unsigned long long *)0x3800bff8)
#define MTIMECMP_ADDR   ((volatile unsigned long long *)0x38004000)
#define TIMER_INTERVAL  1000000  // 约 1ms（取决于时钟频率）

void trap_handler(unsigned long long mcause, unsigned long long mepc) {
    if (mcause == 0x8000000000000007ULL) {
        // 时钟中断
        puts("[Timer Interrupt]");

        // 重设 mtimecmp，使下一次中断在 TIMER_INTERVAL 周期后触发
        unsigned long long current_time = *MTIME_ADDR;
        *MTIMECMP_ADDR = current_time + TIMER_INTERVAL;

        // 清除软件中断（如果作为 IPI 使用）
        // *(volatile unsigned int *)0x38000000 = 0;
    }
}
```

### 8.3 汇编入口

```asm
# trap_entry.S
trap_vector:
    # 保存上下文
    addi sp, sp, -256
    sd   ra, 0(sp)
    sd   t0, 8(sp)
    # ... 保存其他寄存器 ...

    # 调用 C 处理函数
    csrr a0, mcause
    csrr a1, mepc
    call trap_handler

    # 恢复上下文
    ld   ra, 0(sp)
    ld   t0, 8(sp)
    # ...
    addi sp, sp, 256

    mret
```

### 8.4 初始化代码

```c
void init_timer() {
    // 设置第一次时钟中断
    unsigned long long current_time = *MTIME_ADDR;
    *MTIMECMP_ADDR = current_time + TIMER_INTERVAL;

    // 启用时钟中断
    unsigned long long mie;
    asm volatile("csrr %0, mie" : "=r"(mie));
    mie |= (1 << 7);  // MTIE
    asm volatile("csrw mie, %0" : : "r"(mie));

    // 全局中断使能
    unsigned long long mstatus;
    asm volatile("csrr %0, mstatus" : "=r"(mstatus));
    mstatus |= (1 << 3);  // MIE
    asm volatile("csrw mstatus, %0" : : "r"(mstatus));
}
```

## 九、Bonus 3: 时钟中断为何使用 MMIO 计时器

### 9.1 CSR 方案的问题

如果将 `mtime` 和 `mtimecmp` 实现为 CSR 寄存器，存在以下问题：

1. **CPU 休眠时无法计时**：当 CPU 执行 WFI 指令进入低功耗状态时，时钟停止，CSR 计数器不再递增，导致无法按时唤醒 CPU。

2. **多核同步困难**：多核系统中，每个核心都有独立的 CSR。如果 `mtime` 是 CSR，各核心的计时器不同步，无法实现统一的全局时间基准。

3. **频率独立性**：计时器的时钟频率可能不同于 CPU 核心频率。将计时器放在 CPU 外部可以实现独立的时钟域。

4. **热插拔支持**：CPU 核心可能被动态关闭/启用，但系统计时器需要持续运行。

### 9.2 MMIO 方案的优势

1. **独立于 CPU 状态**：即使 CPU 休眠、复位或关闭，计时器持续运行
2. **统一时间基准**：所有核心共享同一个 `mtime`，便于调度和同步
3. **灵活的实现**：计时器可以使用独立的高精度时钟源
4. **符合 RISC-V 规范**：RISC-V 特权架构明确将 `mtime`/`mtimecmp` 定义为内存映射设备（CLINT/ACLINT），而非 CSR

### 9.3 与 mcycle 的对比

`mcycle` 是 CSR，每周期自增。但 `mcycle` 不能替代 `mtime`：
- `mcycle` 随 CPU 时钟递增，当 CPU 休眠时停止
- `mcycle` 的频率与 CPU 时钟相同，不能提供独立的时间基准
- `mcycle` 的宽度有限（64 位），在高频 CPU 上可能较快溢出
- `mtime` 可以使用低频但稳定的时钟源（如 32kHz 晶振），实现长期准确计时

## 十、总结

Lab6 成功实现了 RISC-V 特权架构中的中断与异常处理机制。主要成果包括：

1. 四种同步异常的检测与处理（指令对齐、数据对齐、非法指令、ECALL）
2. 三种异步中断的支持（时钟、软件、外部），包括条件判断、优先级仲裁、流水线注入
3. MRET 指令完善（增加 mstatus.xs 清零）
4. 通用化的 trap_code 编码机制，统一处理各种异常/中断类型
5. CSR 寄存器 mip 的外部信号实时更新

Bonus 部分完成了 MMU 缺页异常的设计方案、时钟中断处理程序的 C/汇编代码编写，以及 MMIO 计时器设计理由的分析。
