# Lab5 实验报告：特权架构、MRET/ECALL 与 Sv39 MMU

## 实验目标

根据 [Lab.md](Lab.md) 要求，Lab5 需要 CPU 支持以下功能：

1. **实现指令**：`MRET`（从陷阱返回）、`ECALL`（环境调用/系统调用）
2. **特权级别切换**：M 模式（Machine mode）与 U 模式（User mode）之间的切换
3. **实现 MMU**：支持 Sv39 页表，完成虚拟地址到物理地址的翻译
4. **CSR 寄存器**：在 Lab4 基础上，增加陷阱相关的 CSR 状态更新（mstatus, mepc, mcause, mtvec 等）
5. **测试通过标志**：运行 `make test-lab5` 输出 `Return from init! Test passed`
6. **FPGA 上板测试**：按上板教程在 Basys3 开发板上运行并通过验证

---

## 一、MMU 启用条件分析

### 1.1 SATP 寄存器

SATP（Supervisor Address Translation and Protection）寄存器控制 MMU 的开启和页表基址，布局如下：

```
63       60 59                  44 43                                0
---------------------------------------------------------------------
|   MODE   |         ASID         |                PPN               |
---------------------------------------------------------------------
```

- **MODE[3:0]**：地址翻译模式
- **ASID[15:0]**：地址空间标识符（本实验置零）
- **PPN[43:0]**：根页表物理页号

RISC-V 特权架构规定，当 SXLEN=64 时，MODE 字段的取值含义：

| MODE 值 | 名称 | 含义 |
|---------|------|------|
| 0 | Bare | 不进行地址翻译或保护 |
| 1-7 | — | 保留 |
| **8** | **Sv39** | 基于页的 39 位虚拟地址翻译 |
| 9 | Sv48 | 基于页的 48 位虚拟地址翻译 |
| 10 | Sv57 | 基于页的 57 位虚拟地址翻译 |
| 11 | Sv64 | 基于页的 64 位虚拟地址翻译 |
| 12-15 | — | 保留 |

### 1.2 本项目 MMU 启用条件

MMU 启用的条件是**特权级与 satp.MODE 的联合判断**（[mmu.sv:32](vsrc/src/mmu.sv#L32)）：

```systemverilog
assign mmu_on = (priv_mode != 2'b11) && (satp_v.mode == 4'd8);
```

该条件要求**两个条件同时满足**：

| 条件 | 含义 |
|------|------|
| `priv_mode != 2'b11` | 当前特权级**不是** M 模式（即 U 模式或 S 模式） |
| `satp_v.mode == 4'd8` | SATP 的 MODE 字段**显式设置为 Sv39**（值=8） |

**关键推论**：

- **M 模式下 MMU 始终关闭**：无论 satp.mode 为何值，M 模式总是以物理地址直接访问内存。CPU 上电后初始为 M 模式，确保引导代码能以物理地址正常运行。

- **U/S 模式下并非总是开启 MMU**：如果 `satp.mode == 0`（Bare 模式），即使 CPU 处于 U 模式，MMU 也处于直通模式，不进行地址翻译。操作系统可以选择在适当时机设置 `satp.mode = 8` 来启用分页。

- **仅在显式配置 Sv39 时才翻译**：操作系统必须在设置页表后，通过 CSR 写指令将 `satp.mode` 设为 8，MMU 才对 U/S 模式的访存进行 Sv39 翻译。

### 1.3 复位后的状态

SATP 寄存器在复位时初始化为 0（[csr_regfile.sv:133](vsrc/src/csr_regfile.sv#L133)）：

```systemverilog
if (reset) begin
    satp_d = 64'b0;  // MODE = 0 (Bare), PPN = 0
```

复位后 `satp.mode = 0`（Bare），MMU 不启用。操作系统启动过程中需依次：
1. 构建 Sv39 页表结构
2. 将根页表物理地址写入 `satp.PPN`
3. 将 `satp.mode` 设为 8
4. 执行 `mret` 进入 U 模式

此后 MMU 才对 U 模式代码生效。

---

## 二、整体架构与模块划分

### 2.1 总线结构

采用**方式 2**（MMU 挂载在 CBus Arbiter 之后）：

```
Fetch(ibus) → IBusToCBus ─┐
                           ├─ CBusArbiter ── MMU ── RAM (Verilator)
Memory(dbus)→ DBusToCBus ─┘
```

```
VTop(core) → CBusArbiter ── MMU ── mycpu_top ── cbus_crossbar ─┬─ BRAM
                                                                 └─ Device(UART)
            ←────────────────── Verilator 仿真 ──────────────────→
            ←────────────────── Vivado FPGA ──────────────────────→
```

该方案的优点是无需修改 Core 内部的取指/访存接口，只需将 `priv_mode` 和 `satp` 信号从 Core 引出至 VTop，在 CBus 层面统一做地址翻译。

### 2.2 模块清单

| 模块 | 文件 | 功能 |
|------|------|------|
| `core` | [core.sv](vsrc/src/core.sv) | 5 级流水线顶层，连接所有子模块和 Difftest |
| `csr_regfile` | [csr_regfile.sv](vsrc/src/csr_regfile.sv) | CSR 寄存器读写，陷阱 CSR 状态更新，特权级切换 |
| `decode` | [decode.sv](vsrc/src/decode.sv) | 指令解码（含 SYSTEM 类 ECALL/MRET 识别） |
| `execute` | [execute.sv](vsrc/src/execute.sv) | 陷阱触发检测，流水线冲刷，trap 标记注入 |
| `memory` | [memory.sv](vsrc/src/memory.sv) | 数据访存，流水线传播 trap 标记 |
| `writeback` | [writeback.sv](vsrc/src/writeback.sv) | 寄存器写回，Difftest 提交控制 |
| `mmu` | [mmu.sv](vsrc/src/mmu.sv) | Sv39 地址翻译 FSM，VIVADO 路径恒等映射 |
| `VTop` | [VTop.sv](vsrc/VTop.sv) | 综合顶层（含 core + CBusArbiter + MMU） |
| `mycpu_top` | [mycpu_top.sv](vsrc/mycpu_top.sv) | FPGA AXI 接口封装 |
| `device` | [device.sv](vivado/src/device.sv) | FPGA UART 输出、开关/LED 外设 |

---

## 三、ECALL/MRET 指令实现

### 3.1 指令解码

ECALL（`0x00000073`）和 MRET（`0x30200073`）均属于 SYSTEM 操作码。[decode.sv](vsrc/src/decode.sv#L201-L211) 中通过 funct3 字段区分 CSR 指令与陷阱指令：

```systemverilog
7'b1110011: begin       // SYSTEM
    is_system = 1'b1;
    if (funct3 != 3'b000) begin
        is_csr = 1'b1;  // CSR 读写指令
    end else begin
        // funct3 = 000: ECALL 或 MRET（is_system=1, is_csr=0）
    end
end
```

### 3.2 陷阱触发（Execute 阶段）

[execute.sv](vsrc/src/execute.sv) 通过组合逻辑识别具体陷阱类型：

```systemverilog
is_ecall = id_ex_reg.is_system && !id_ex_reg.is_csr
        && (id_ex_reg.instr == 32'h00000073);
is_mret  = id_ex_reg.is_system && (id_ex_reg.instr == 32'h30200073);

trap_fire = step & id_ex_reg.valid & (is_ecall | is_mret);
```

当 `trap_fire=1` 时并行执行三项操作：

**（1）流水线冲刷与 PC 重定向**：

```systemverilog
redirect_pc = is_mret ? csr_mepc      // MRET: 返回到保存的 PC
                      : csr_mtvec;     // ECALL: 跳转到陷阱向量
```

**（2）流水线标记注入**：在 `ex_mem_reg` 中设置 trap 标记字段：

```systemverilog
ex_mem_reg.trap_pending <= 1'b1;       // 标记为陷阱指令
ex_mem_reg.trap_is_mret <= trap_is_mret; // 陷阱类型
ex_mem_reg.trap_priv     <= priv_mode_q; // 记录旧特权级（用于 mcause）
ex_mem_reg.is_load      <= 1'b0;       // 陷阱指令不产生访存
ex_mem_reg.is_store     <= 1'b0;
ex_mem_reg.csr_pending  <= 1'b0;       // 陷阱指令不写 CSR
```

**（3）陷阱标记随流水线传播**：`trap_pending` 经 MEM → WB 逐级传递，最终在 WB 阶段触发 CSR 状态更新。

### 3.3 特权级与 CSR 状态更新（csr_regfile）

本实验的核心设计挑战在于**特权级的立即生效需求**与 **CSR 状态延迟提交需求**之间的权衡：

- **特权级必须在 EX 阶段立即切换**：MMU 的启用/禁用依赖当前特权级，因此 MRET 降权和 ECALL 升权不能等到 WB。
- **CSR 状态必须在 WB 阶段提交**：为与 NEMU 参考模型保持提交顺序一致，`mcause`、`mepc`、`mstatus` 的变更延迟到 WB。

#### 路径 1：EX 阶段——特权级立即切换

```systemverilog
if (trap_fire_ex) begin
    if (trap_is_mret_ex)
        priv_mode_d = mstatus_q[12:11];  // MRET: 切换到 MPP（如 U-mode）
    else
        priv_mode_d = 2'b11;              // ECALL: 切换到 M-mode
end
```

此块在 `trap_csr_commit` 块之后执行（利用 SystemVerilog always_comb 中后续赋值覆盖前序赋值的语义），确保当 EX 和 WB 同时有陷阱指令时，较新的 EX 陷阱拥有更高优先级。

#### 路径 2：WB 阶段——CSR 状态提交

**ECALL 陷阱处理**：

```systemverilog
// ECALL 在 WB 提交
mepc_d      = trap_pc;                    // 保存当前 PC
priv_mode_d = 2'b11;                       // 升权到 M-mode
mstatus_d[12:11] = trap_priv_wb;          // MPP ← 旧特权级
mstatus_d[7]     = mstatus_q[3];           // MPIE ← MIE
mstatus_d[3]     = 1'b0;                    // MIE ← 0（关中断）
mcause_d = (trap_priv_wb == U) ? 8        // U-mode ecall
         : (trap_priv_wb == S) ? 9        // S-mode ecall
         : 11;                              // M-mode ecall
```

**MRET 陷阱处理**：

```systemverilog
// MRET 在 WB 提交（不修改 mcause）
priv_mode_d = mstatus_q[12:11];           // 降权到 MPP
mstatus_d[3]  = mstatus_q[7];             // MIE ← MPIE
mstatus_d[7]  = 1'b1;                      // MPIE ← 1
mstatus_d[12:11] = 2'b00;                  // MPP ← U-mode
// 注意：MRET 不修改 mcause（符合 RISC-V 特权架构规范）
```

### 3.4 提交抑制

陷阱指令（ECALL）本身不写通用寄存器，不应作为独立的架构状态变更提交到 Difftest：

```systemverilog
// core.sv
assign block_commit = trap_csr_commit & ~mem_wb_reg.trap_is_mret;

// writeback.sv
assign commit_valid = mem_wb_reg.valid & step & ~block_commit;
```

- ECALL：`trap_is_mret=0` → `block_commit=1` → 不提交
- MRET：`trap_is_mret=1` → `block_commit=0` → 正常提交

### 3.5 特权级切换完整流程

以一次典型的系统调用为例：

```
1. U 模式执行 ECALL
   ├─ EX: trap_fire_ex → priv_mode = M     (立即升权)
   ├─ PC 跳转到 mtvec
   ├─ trap 标记随流水线传播
   └─ WB: mepc ← ecall_pc, mcause ← 8, mstatus.MPP ← U, mstatus.MPIE ← MIE, mstatus.MIE ← 0

2. 陷阱处理程序（M 模式）执行
   └─ 读取 mcause，处理系统调用，修改 mepc 指向 ecall+4

3. 陷阱处理程序执行 MRET
   ├─ EX: trap_fire_ex → priv_mode = MPP = U  (立即降权)
   ├─ PC 跳转到 mepc = ecall+4
   └─ WB: mstatus.MIE ← mstatus.MPIE, mstatus.MPIE ← 1, mstatus.MPP ← 0
        (mcause 保持不变，仍为 8)
```

---

## 四、Sv39 MMU 实现

### 4.1 状态机设计

MMU 实现了一个三状态 FSM（[mmu.sv:78-119](vsrc/src/mmu.sv#L78-L119)）：

```
         req_in.valid
ST_IDLE ───────────→ ST_PTE ─(pte_hold)─→ ST_WAIT ─(resp.ready&last)─→ ST_IDLE
```

| 状态 | 功能 |
|------|------|
| `ST_IDLE` | 等待总线请求。收到有效请求后锁存原始地址，进入翻译状态 |
| `ST_PTE` | 等待 PTEHelper（Difftest 提供的页表查询模块）给出翻译结果。`pte_hold` 确保等待一个周期后读取结果 |
| `ST_WAIT` | 输出翻译后的物理地址到总线，等待 RAM 响应。响应到达后返回 IDLE |

### 4.2 地址翻译函数

Sv39 支持最多三级页表，实际叶页表级别可能为 0/1/2 级。PTEHelper 返回叶页表级别 `level` 和页表项 `pte`。[mmu.sv:65-75](vsrc/src/mmu.sv#L65-L75) 的 `sv39_paddr` 函数根据级别拼接物理地址：

```systemverilog
function automatic addr_t sv39_paddr(word_t pte_val, addr_t vaddr, logic [7:0] level);
    unique case (level)
        8'd0: sv39_paddr = {8'b0, pte_val[53:28], vaddr[29:12], vaddr[11:0]};  // 1GB 巨页
        8'd1: sv39_paddr = {8'b0, pte_val[53:19], vaddr[20:12], vaddr[11:0]};  // 2MB 巨页
        default: sv39_paddr = {8'b0, pte_val[53:10], vaddr[11:0]};              // 4KB 普通页
    endcase
endfunction
```

### 4.3 组合逻辑输出

[mmu.sv:121-136](vsrc/src/mmu.sv#L121-L136) 的输出逻辑根据 MMU 状态切换：

- **MMU 关闭**（M 模式或 Bare 模式）：直通 `req_out = req_in`, `resp_out = resp_in`
- **翻译等待中**（ST_IDLE / ST_PTE）：阻止总线请求和响应（`valid=0`, `ready=0`），防止下游看到未翻译的地址
- **翻译完成**（ST_WAIT）：输出翻译后的请求地址，响应直通

### 4.4 VIVADO FPGA 路径

FPGA 上没有 PTEHelper（PTEHelper 是 Difftest 框架的仿真辅助模块），MMU 在 VIVADO 路径下采用**恒等映射**（[mmu.sv:105-106](vsrc/src/mmu.sv#L105-L106)）：

```systemverilog
`else   // VIVADO
    paddr <= saved_req.addr;  // 虚拟地址 = 物理地址
```

这意味着 FPGA 测试程序必须使用**恒等页表映射**（所有虚拟地址等于对应的物理地址，且需 ≥ 0x80000000 以命中 BRAM 地址空间）。

---

## 五、Difftest 连接

### 5.1 DifftestInstrCommit

```systemverilog
.valid   (commit_valid),
.pc      (commit_pc),
.instr   (commit_instr),
.skip    (difftest_skip),     // MMIO 读写跳过比对
.wen     (commit_wen),
.wdest   ({3'b0, commit_wdest}),
.wdata   (commit_wdata)
```

### 5.2 DifftestArchEvent

新增的异常事件接口（[core.sv:395-401](vsrc/src/core.sv#L395-L401)）：

```systemverilog
DifftestArchEvent DifftestArchEvent(
    .clock       (clk),
    .coreid      (csr_mhartid[7:0]),
    .intrNO      (32'b0),
    .cause       (difftest_exc_cause),   // 8/9/11 对应 U/S/M 的 ecall
    .exceptionPC (trap_pc)
);
```

`difftest_exc_cause` 在陷阱提交（`trap_csr_commit && !trap_is_mret`）时给出异常类型，Difftest 框架用它来同步 DUT 与 NEMU 之间的异常处理状态。

### 5.3 DifftestCSRState

```systemverilog
.priviledgeMode (priv_mode_difftest),    // 额外延迟一拍对齐 NEMU 时序
.mstatus        (csr_mstatus),
.mepc           (csr_mepc_dbg),
.mcause         (csr_mcause),
.mtvec          (csr_mtvec_dbg),
.satp           (csr_satp_dbg),
```

所有 CSR dbg 信号均连接为组合次态（`*_d`），确保 Difftest 在 posedge 采样时看到的是下拍将写入的值（与 NEMU 提交后一致）。

---

## 六、FPGA 上板适配

### 6.1 VTop.sv 双路径包含

[VTop.sv](vsrc/VTop.sv) 同时支持两种编译环境：

```systemverilog
`ifdef VERILATOR
`include "include/common.sv"
`include "src/core.sv"
`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"
`include "src/mmu.sv"
`endif

`ifdef VIVADO
`include "include/common.sv"
`include "core.sv"
`include "IBusToCBus.sv"
`include "DBusToCBus.sv"
`include "CBusArbiter.sv"
`include "mmu.sv"
`endif
```

VERILATOR 路径以 `src/`、`util/`、`include/` 为前缀；VIVADO 路径使用与 Vivado 工程搜索路径匹配的相对路径。

### 6.2 device.sv CDC 修复

FPGA 上 CPU 运行在 `cpu_clk`（由 `clk_wiz_0` PLL 产生），UART 外设运行在板载 `clk`（100MHz）。原代码中 `valid`/`addr`/`wdata`（来自 `cpu_clk` 域）直接在 `clk` 域的组合逻辑中使用，存在跨时钟域（CDC）问题：

```verilog
// 原代码：valid 来自 cpu_clk 域，直接在 clk 域使用
assign send = (idx != 0 && finish) || (addr == TX_DATA && valid && wvalid);
```

修复方案：新增 `tx_pending` 锁存器和 `tx_char` 寄存器（[device.sv:134-164](vivado/src/device.sv#L134-L164)）：

```verilog
logic tx_pending;
logic [7:0] tx_char;
always_ff @(posedge clk) begin
    if (addr == TX_DATA && valid && wvalid && txState == RDY) begin
        tx_pending <= 1'b1;           // 锁存写请求
        tx_char    <= wdata[39:32];   // 锁存字符数据
    end else if (txState == LOAD_BIT)
        tx_pending <= 1'b0;           // 字符被加载后清除
end

assign send = (idx != 0 && finish) || tx_pending;  // 用锁存信号替代总线信号
assign char_data = finish ? str[idx] : tx_char;     // 用锁存数据替代总线数据
```

修复原理：`tx_pending` 是持续电平而不是脉冲信号，即使 `clk` 边沿错过了 `valid` 的短暂脉冲，锁存器已将请求保持，直到 UART 状态机确认处理后才清除。

### 6.3 UART 波特率

```verilog
parameter BIT_TMR_MAX = 'b10100010110000;  // = 10416
// 100MHz / (10416 + 1) ≈ 9600 baud
```

串口调试助手需设置为 **9600 波特**。

### 6.4 地址路由

[cbus_crossbar.sv](vivado/src/with_delay/cbus_crossbar.sv) 的地址路由规则：

```verilog
assign rdata = addr[31] ? ram_rdata : device_rdata;
assign ready = addr[31] ? ram_ready : device_ready;
```

- `addr[31] == 1`（addr ≥ 0x80000000）→ BRAM（指令和数据）
- `addr[31] == 0`（addr < 0x80000000）→ Device（UART、开关、LED 等外设）

FPGA 上 MMU 做恒等映射，因此测试程序的页表必须将用户代码映射到 ≥ 0x80000000 的物理地址范围。

---

## 七、调试中修复的关键问题

### 7.1 MRET 错误清零 mcause

**现象**：`Return from init! Test passed` 后出现 `mcause different at pc=0x80001dfc, right=8, wrong=0`

**根因**：RISC-V 特权架构规范规定 **MRET 不修改 `mcause` 寄存器**。原代码在 MRET 的 `trap_csr_commit` 路径中错误地执行了 `mcause_d = 64'b0`，导致每次 MRET 都将 mcause 清零。

**修复**（[csr_regfile.sv:138-143](vsrc/src/csr_regfile.sv#L138-L143)）：删除 MRET 路径中的 `mcause_d = 64'b0`。

### 7.2 always_comb 优先级问题

**现象**：当 EX 阶段有新陷阱同时 WB 阶段有旧陷阱提交时，WB 陷阱可能覆盖 EX 陷阱的 `priv_mode_d` 设置。

**修复**（[csr_regfile.sv:137-163](vsrc/src/csr_regfile.sv#L137-L163)）：将 `trap_csr_commit` 块放在 `trap_fire_ex` 块之前，利用 SystemVerilog always_comb 中后写覆盖先写的语义，确保 EX 阶段陷阱（更新鲜）的优先级高于 WB 阶段陷阱（较旧）。

### 7.3 VTop.sv 缺少 VIVADO 包含路径

**修复**（[VTop.sv:13-19](vsrc/VTop.sv#L13-L19)）：添加 `ifdef VIVADO` 包含块，并修正 VERILATOR 块中 mmu.sv 的路径（`util/mmu.sv` → `src/mmu.sv`）。

### 7.4 mmu.sv 笔误

**修复**（[mmu.sv:127](vsrc/src/mmu.sv#L127)）：将 `else ifx` 修正为 `else if`。

### 7.5 FPGA 串口无输出

**现象**：Vivado 仿真通过，但上板后串口无 CPU 输出（仅有设备默认 "Hello World!"）。

**根因**：`valid`/`wvalid` 总线信号（`cpu_clk` 域）与 UART 状态机（`clk` 域）之间存在跨时钟域问题，`send` 脉冲可能被 `clk` 边沿错过。

**修复**：为 TX_DATA 写请求添加锁存器（第六节详述），确保写请求在 UART 处理之前持续有效。

---

## 八、测试结果

### 8.1 Verilator 仿真

```
$ make test-lab5
[WARNING] difftest store queue overflow
kinit ok
procinit ok
trapinit ok
plicinit ok
userinit ok
Return from init! Test passed
```

输出 `Return from init! Test passed` 后 CPU 进入 `j .` 空闲循环（预期行为）。Difftest 全程无报错。

### 8.2 FPGA 上板

Vivado 流程：Run Simulation → Synthesis → Implementation → Generate Bitstream → Program Device。串口调试助手设置为 9600 波特，可正常接收测试程序输出。
