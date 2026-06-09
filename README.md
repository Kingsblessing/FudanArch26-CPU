# RISC-V RV64I 五级流水线 CPU 设计与实现 — 综合实验报告

**姓名**：杨添燚

**学号**：24300240173

**课程**：复旦大学 2026 年春《计算机组成与体系结构（H）》

---

## 目录

1. [项目概述](#1-项目概述)
2. [项目结构与模块划分](#2-项目结构与模块划分)
3. [总线架构与内存模型](#3-总线架构与内存模型)
4. [五级流水线架构](#4-五级流水线架构)
5. [Lab1 — 基础算术流水线](#5-lab1--基础算术流水线)
6. [Lab2 — 内存读写](#6-lab2--内存读写)
7. [Lab3 — 分支、跳转与移位](#7-lab3--分支跳转与移位)
8. [Lab3 Extra — 乘除法指令](#8-lab3-extra--乘除法指令)
9. [Lab4 — CSR 寄存器与指令](#9-lab4--csr-寄存器与指令)
10. [Lab5 — 特权级切换与 MMU](#10-lab5--特权级切换与-mmu)
11. [Lab6 — 中断与异常](#11-lab6--中断与异常)
12. [Difftest 差分测试框架](#12-difftest-差分测试框架)
13. [FPGA 上板测试](#13-fpga-上板测试)
14. [调试方法与经验](#14-调试方法与经验)
15. [Bonus 完成情况](#15-bonus-完成情况)
16. [总结与展望](#16-总结与展望)

---

## 1. 项目概述

### 1.1 项目背景

本项目是复旦大学《计算机组成与体系结构（H）》课程的实验部分，目标是从零开始设计和实现一个支持 RISC-V RV64I 指令集的五级流水线 CPU。整个项目分为六个递进式实验（Lab1–Lab6），从最基础的算术运算指令到完整的中断异常处理，逐步构建一个功能完备的处理器。

### 1.2 开发环境

| 组件 | 工具/版本 |
|------|----------|
| 硬件描述语言 | SystemVerilog (Verilator 兼容子集) |
| 仿真器 | Verilator (开源高性能仿真) |
| 差分测试框架 | Difftest (与 NEMU 参考模型对比) |
| 波形查看器 | GTKWave |
| FPGA 综合 | Xilinx Vivado 2018.3 / 2019.2 |
| 开发板 | Basys-3 (Xilinx Artix-7) |
| 构建系统 | Makefile |

### 1.3 指令集支持

本 CPU 最终支持 RISC-V RV64I 整数基础指令集、M 扩展（乘除法）与部分特权架构指令：

| 指令类别 | 具体指令 |
|----------|---------|
| 算术运算 | `add`, `sub`, `addi`, `addw`, `subw`, `addiw` |
| 逻辑运算 | `and`, `or`, `xor`, `andi`, `ori`, `xori` |
| 移位指令 | `sll`, `srl`, `sra`, `slli`, `srli`, `srai`, `sllw`, `srlw`, `sraw`, `slliw`, `srliw`, `sraiw` |
| 比较指令 | `slt`, `sltu`, `slti`, `sltiu` |
| 加载指令 | `ld`, `lw`, `lh`, `lb`, `lwu`, `lhu`, `lbu` |
| 存储指令 | `sd`, `sw`, `sh`, `sb` |
| 立即数 | `lui`, `auipc` |
| 分支指令 | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` |
| 跳转指令 | `jal`, `jalr` |
| CSR 指令 | `CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI` |
| 特权指令 | `ECALL`, `MRET` |
| 乘除法(M) | `mul`, `div`, `divu`, `rem`, `remu`, `mulw`, `divw`, `divuw`, `remw`, `remuw` |

### 1.4 各 Lab 测试通过情况

| Lab | 测试命令 | 通过标志 | 状态 |
|-----|---------|---------|------|
| Lab1 | `make test-lab1` | `HIT GOOD TRAP` | ✅ |
| Lab2 | `make test-lab2` | `HIT GOOD TRAP` | ✅ |
| Lab3 | `make test-lab3` | `HIT GOOD TRAP` | ✅ |
| Lab3 Extra | `make test-lab3-extra` | `HIT GOOD TRAP` | ✅ |
| Lab4 | `make test-lab4` | `HIT GOOD TRAP` | ✅ |
| Lab5 | `make test-lab5` | `Return from init! Test passed` | ✅ |
| Lab6 | `make test-lab6` | `Privileged test finished.` | ✅ |

---

## 2. 项目结构与模块划分

### 2.1 目录结构

```
26-Arch/
├── vsrc/                         # 所有可修改的源代码
│   ├── include/                  # 头文件与类型定义
│   │   ├── common.sv             # 公共类型、总线结构体、参数
│   │   ├── csr.sv                # CSR 寄存器地址、位掩码、结构体
│   │   └── config.sv             # 配置参数
│   └── src/                      # CPU 核心模块
│       ├── core.sv               # CPU 顶层模块，实例化所有子模块
│       ├── fetch.sv              # 取指阶段
│       ├── decode.sv             # 译码阶段
│       ├── execute.sv            # 执行阶段
│       ├── memory.sv             # 访存阶段
│       ├── writeback.sv          # 写回阶段
│       ├── regfile.sv            # 通用寄存器文件 (32×64-bit)
│       ├── csr_regfile.sv        # CSR 寄存器文件
│       ├── forward_unit.sv       # 前向单元（解决数据冒险）
│       └── mmu.sv                # 内存管理单元 (Sv39)
├── Makefile                      # 构建与测试脚本
├── CLAUDE.md                     # 项目文档
└── Lab.md                        # 实验讲解
```

### 2.2 模块层次结构

```
Core (core.sv)
├── fetch.sv          — 取指阶段，驱动 ibus
├── decode.sv         — 译码阶段，生成控制信号
├── execute.sv        — 执行阶段，ALU + 分支 + CSR + 异常检测 + 乘除法
├── memory.sv         — 访存阶段，驱动 dbus
├── writeback.sv      — 写回阶段，寄存器写入 + Difftest 提交
├── regfile.sv        — 通用寄存器文件 (GPR)
├── csr_regfile.sv    — CSR 寄存器文件
├── forward_unit.sv   — 数据转发控制
└── (Difftest 连接)   — 差分测试接口
```

### 2.3 代码规范

本项目遵循 Verilator 兼容的 SystemVerilog 编码规范：

- **禁止语法**：`initial` 语句、延时 `#N`、锁存器、X/Z 状态、`negedge` 触发、异步复位、跨时钟域
- **命名规范**：每个文件一个模块，文件名与模块名一致
- **结构体组织**：使用 `packed struct` 定义流水线寄存器（如 `REG_IF_ID`, `REG_ID_EX`），保持代码清晰
- **变量声明**：使用 `logic [6:0] opcode; assign opcode = ...;` 而非 `logic [6:0] opcode = ...;`（兼容 Vivado）
- **宏隔离**：`ifdef VERILATOR` / `ifdef VIVADO` 分别处理仿真与 FPGA 综合路径

---

## 3. 总线架构与内存模型

### 3.1 三级总线体系

本 CPU 采用分层总线架构，将指令访问与数据访问统一到一条物理内存总线：

```
取指(Fetch) → ibus (ibus_req/resp_t)
                 │
                 ▼
            IBusToCBus  ─┐
                          ├─ CBusArbiter（优先级仲裁: ibus > dbus）
            DBusToCBus  ─┘
                 ▲
                 │
访存(Memory)→ dbus (dbus_req/resp_t)
                 │
                 ▼
              MMU (Sv39 地址翻译，U/S 模式启用)
                 │
                 ▼
              RAM/AXI (物理内存)
```

### 3.2 总线接口定义

**指令总线 (ibus)**：用于取指，固定读取 4 字节，`addr` 必须 4 字节对齐。

| 信号 | 方向 | 宽度 | 含义 |
|------|------|------|------|
| `ibus_req.valid` | CPU→总线 | 1 | 取指请求有效 |
| `ibus_req.addr` | CPU→总线 | 64 | 取指地址 |
| `ibus_resp.addr_ok` | 总线→CPU | 1 | 地址已接受 |
| `ibus_resp.data_ok` | 总线→CPU | 1 | 数据有效 |
| `ibus_resp.data` | 总线→CPU | 32 | 指令字 |

**数据总线 (dbus)**：用于 Load/Store，支持 1/2/4/8 字节访问。`strobe`（字节使能）指明哪些字节有效。内存自动将 `addr` 向下对齐到 8 字节，因此写入数据需要配合 `strobe` 进行字节级定位。

| 信号 | 方向 | 宽度 | 含义 |
|------|------|------|------|
| `dbus_req.valid` | CPU→总线 | 1 | 访存请求有效 |
| `dbus_req.addr` | CPU→总线 | 64 | 访存地址 |
| `dbus_req.size` | CPU→总线 | 3 | 访存大小 (MSIZE1/2/4/8) |
| `dbus_req.strobe` | CPU→总线 | 8 | 字节使能（写时指示哪些字节有效） |
| `dbus_req.data` | CPU→总线 | 64 | 写入的数据 |
| `dbus_resp.addr_ok` | 总线→CPU | 1 | 地址已接受 |
| `dbus_resp.data_ok` | 总线→CPU | 1 | 数据有效 |
| `dbus_resp.data` | 总线→CPU | 64 | 读回的数据 |

### 3.3 总线握手协议

总线采用 valid/data_ok 握手协议：
1. CPU 拉高 `valid` 并发起请求（`addr` 等信号需在 `data_ok` 返回前保持不变）
2. 总线返回 `addr_ok` 表示地址被接受
3. 总线返回 `data_ok` 表示数据就绪
4. `data_ok` 返回的下一个周期若 `valid` 仍为 1，视为新请求

---

## 4. 五级流水线架构

### 4.1 流水线阶段

本 CPU 采用经典的五级顺序流水线架构：

```
Fetch ──→ Decode ──→ Execute ──→ Memory ──→ Writeback
  │         │           │           │            │
  │    REG_IF_ID    REG_ID_EX   REG_EX_MEM   REG_MEM_WB
  │    (流水线寄存器) (流水线寄存器)  (流水线寄存器)  (流水线寄存器)
```

各阶段之间的流水线寄存器使用 `packed struct` 定义在 `core.sv` 中：

- **REG_IF_ID**：(valid, pc, instr) — 取指到译码
- **REG_ID_EX**：(valid, pc, instr, 控制信号, 寄存器数据, 立即数, 异常标记等) — 译码到执行
- **REG_EX_MEM**：(valid, pc, instr, alu_result, 访存控制, CSR 写信息, trap 信息等) — 执行到访存
- **REG_MEM_WB**：(valid, pc, instr, alu_result, mem_data, CSR 写信息, trap 信息等) — 访存到写回

### 4.2 全局步进同步

```
step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok
```

流水线采用全局 `step` 信号同步推进——仅当所有五个阶段都处于 `ready` 状态时，指令才能前进。这确保了各阶段之间的严格同步，同时也实现了自动的流水线停顿：

- **Fetch 阻塞**：正在取指时（等待 `data_ok`）`fetch_ok = 0`
- **Execute 阻塞**：乘除法运算中 `execute_ok = 0`
- **Memory 阻塞**：正在访存时（等待 `data_ok`）`mem_ok = 0`
- **Writeback**：始终 ready (`writeback_ok = 1`)

### 4.3 数据冒险解决

本 CPU 通过**前向转发 (Forwarding)** 解决数据冒险：

```
forward_unit.sv:
  - 比较 EX 阶段 rs1/rs2 与 EX/MEM 的 rd → forward = 01 (最新数据)
  - 比较 EX 阶段 rs1/rs2 与 MEM/WB 的 rd → forward = 10 (次新数据)
  - 否则 → forward = 00 (从寄存器文件读取)
```

寄存器文件内部也实现了 WB-to-ID 的组合逻辑转发（在 `regfile.sv` 的 `always_comb` 中），使得同周期写入的数据能被立即读出。

**Load-use 冒险**：当 Load 指令后紧跟使用该数据的指令时，前向转发无法解决（Load 的数据在 Memory 阶段才就绪），此时流水线通过 `mem_ok = 0` 自然阻塞。

### 4.4 控制冒险解决

**分支指令**在 EX 阶段解析，采用**静态不跳转 (Static Not-Taken)** 预测：
- 分支未跳转：流水线照常前进
- 分支跳转：通过 `redirect_valid` / `redirect_pc` 冲刷 Fetch 和 Decode 阶段的指令
- CSR 写入：统一冲刷流水线（视作"跳转到 pc+4"的跳转 + 预测失败）

**流水线冲刷机制**：

```
combined_redirect_valid = redirect_valid | interrupt_fire   — 冲刷 Fetch/Decode
combined_trap           = trap_fire | interrupt_fire         — 额外取消未完成 dreq
```

### 4.5 特权级与陷阱流水线

陷阱（异常/中断/MRET）的处理跨越多个流水线阶段：

```
EX 阶段：异常检测 + trap_fire 触发 → 注入 trap 气泡 (trap_pending=1)
         priv_mode 立即组合逻辑切换（MMU 立即感知）

MEM 阶段：trap_pending 透传，trap 时取消未完成 dreq

WB 阶段：trap_csr_commit → CSR 更新 (mepc, mcause, mstatus)
         block_commit → 阻止 ecall 本身的 Difftest 提交
```

---

## 5. Lab1 — 基础算术流水线

### 5.1 实验目标

构建支持 RV64I 基础算术/逻辑指令的五级流水线 CPU，并通过 Verilator + Difftest 仿真。

**支持指令**：`addi`, `xori`, `ori`, `andi`, `add`, `sub`, `and`, `or`, `xor`, `addiw`, `addw`, `subw`

### 5.2 实现要点

#### Fetch 模块 ([fetch.sv](vsrc/src/fetch.sv))

取指阶段的核心状态机：

```
状态转换：
  reset → pc = PCINIT (0x80000000), fetch_ok = 1
  step & fetch_ok → 发请求 (valid=1, addr=pc), fetch_ok=0
  收到 data_ok → 锁存指令, pc+=4, fetch_ok=1
```

关键细节：传递给 `if_id_reg.pc` 的值必须是**请求时的 PC** (`req_pc`)，而非 `pc+4` 后的新值。这是因为后续阶段需要知道该指令对应的地址。

#### Decode 模块 ([decode.sv](vsrc/src/decode.sv))

全组合逻辑译码，解析以下字段：
- `opcode` (instr[6:0])：识别指令类型
- `funct3` (instr[14:12])：细化操作类型
- `funct7` (instr[31:25])：区分 ADD/SUB、SRL/SRA 等变体
- `rd`, `rs1`, `rs2`：寄存器操作数
- 立即数字段：I-type (instr[31:20])、U-type (instr[31:12])

生成的微操作控制信号：
- `alu_op`：ALU 操作码
- `alu_src`：ALU 第二操作数选择（0=寄存器，1=立即数）
- `reg_write`, `mem_write`, `mem_read`, `mem_to_reg`

#### Execute 模块 ([execute.sv](vsrc/src/execute.sv))

执行阶段的核心功能：

1. **操作数选择**：通过前向单元选择 `alu_a` 和 `alu_b`
   - LUI 强制 `alu_a = 0`
   - ALU 立即数指令选择 `imm` 作为 `alu_b`
   - AUIPC 选择 `pc` 作为 `alu_a`

2. **ALU 运算**：组合逻辑实现所有运算

ALU_OP 编码表（Lab1 部分）：

| ALU_OP | 操作 | 实现 |
|--------|------|------|
| 0 | ADD | `alu_a + alu_b` |
| 1 | SUB | `alu_a - alu_b` |
| 2 | ADDW | `{{32{addw_res[31]}}, addw_res}`（符号扩展） |
| 3 | SUBW | `{{32{subw_res[31]}}, subw_res}` |
| 10 | AND | `alu_a & alu_b` |
| 11 | OR  | `alu_a \| alu_b` |
| 12 | XOR | `alu_a ^ alu_b` |

#### Writeback 模块 ([writeback.sv](vsrc/src/writeback.sv))

写回阶段：`writeback_ok` 始终为 1。根据 `mem_to_reg` 选择 ALU 结果或内存数据写入寄存器。只写回 `rd != 0` 的指令（RISC-V 规范：x0 硬连线为 0）。

### 5.3 寄存器文件设计 ([regfile.sv](vsrc/src/regfile.sv))

采用**双数组设计**解决 Difftest 时序问题：

```
REG[31:0]      — 主寄存器（时序写入）
next_reg[31:0] — "下一状态"寄存器（组合逻辑写入）
```

- **读取**：从 `REG` 读取，但若 `wen && raddr == waddr` 则直接返回 `wdata`（WB-to-ID 转发）
- **写入**：`next_reg` 组合逻辑即时反映写入结果，Difftest 读取 `next_reg` 而非 `REG`
- **时序**：posedge 时 `REG <= next_reg`，Difftest 在下一个 posedge 采样时看到的就是正确的新值

`x0` 始终硬连线为 0，禁止写入。

### 5.4 Difftest 连接

三个 Difftest 模块：

1. **DifftestInstrCommit** — 每周期提交的指令
   - 首条指令必须在 PCINIT（0x80000000）
   - valid 信号来自 WB 阶段
   - pc 必须是对应指令的地址

2. **DifftestArchIntRegState** — 全部 32 个 GPR 状态
   - 连接 `next_reg` 数组（组合逻辑），确保 Difftest 采样时读到最新值

3. **DifftestTrapEvent** — 陷阱事件
   - 检测 halt 指令 (0x0005006b)

### 5.5 仿真结果

```
$ make test-lab1
...
HIT GOOD TRAP
```

---

## 6. Lab2 — 内存读写

### 6.1 实验目标

在 Memory 阶段添加 dbus 接口，支持 Load/Store 指令。

**支持指令**：`ld`, `sd`, `lb`, `lh`, `lw`, `lbu`, `lhu`, `lwu`, `sb`, `sh`, `sw`, `lui`

### 6.2 Memory 模块实现 ([memory.sv](vsrc/src/memory.sv))

Memory 阶段负责驱动 `dbus_req_t` 并消费 `dbus_resp_t`：

**状态管理**：

```
mem_in_progress  — 正在等待总线响应
req_completed    — 当前指令的访存请求已完成
mem_ok = ~(valid && (is_load || is_store) && !req_completed)
```

**Store 操作**：根据 `funct3` 和地址偏移生成 strobe 和数据：
- `strobe` = 字节使能掩码左移 offset 位
- `data` = rs2_data 左移（offset × 8）位

示例：向 0x1F2 写 1 字节 0xCD：
- `addr = 0x1F2`, `data = 0x00CD0000`, `strobe = 0b0000_0100`

**Load 操作**：读出数据后根据 `funct3` 进行移位和符号/零扩展：
- 移位：`rdata >> (offset * 8)`
- lb：符号扩展第 7 位到 64 位
- lh：符号扩展第 15 位到 64 位
- lw：符号扩展第 31 位到 64 位
- lbu/lhu/lwu：零扩展
- ld：直接使用 64 位

**Load 转发**：`saved_rdata` 存储读出的数据，以组合逻辑 `mem_forward_data` 输出，供 EX 阶段的 Load-use 冒险转发使用。

### 6.3 仿真结果

```
$ make test-lab2
...
HIT GOOD TRAP
```

---

## 7. Lab3 — 分支、跳转与移位

### 7.1 实验目标

支持控制流（分支、跳转）和移位指令，并完成 FPGA 上板测试。

**支持指令**：`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `slti`, `sltiu`, `slli`, `srli`, `srai`, `sll`, `slt`, `sltu`, `srl`, `sra`, `slliw`, `srliw`, `sraiw`, `sllw`, `srlw`, `sraw`, `auipc`, `jalr`, `jal`

### 7.2 Decode 阶段修改

新增立即数格式解析：

| 指令类型 | 立即数格式 | 位拼接 |
|---------|-----------|--------|
| B-type (分支) | `imm_b[12:1]` | `{instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}` |
| J-type (jal) | `imm_j[20:1]` | `{instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}` |
| I-type (jalr) | `imm_i[11:0]` | `instr[31:20]` |

符号扩展策略：
- B-type: `{{51{imm_b[12]}}, imm_b}` — bit 0 强制为 0
- J-type: `{{43{imm_j[20]}}, imm_j}` — bit 0 强制为 0
- I-type: `{{52{imm_i[11]}}, imm_i}`

### 7.3 Execute 阶段修改

**分支条件判断**（组合逻辑）：

```
beq:  alu_a == rs2_val
bne:  alu_a != rs2_val
blt:  $signed(alu_a) < $signed(rs2_val)
bge:  $signed(alu_a) >= $signed(rs2_val)
bltu: alu_a < rs2_val
bgeu: alu_a >= rs2_val
```

**跳转目标计算**：
- JAL：`target = pc + imm`
- JALR：`target = (rs1 + imm) & ~1`（最低位清零）

**流水线冲刷**：

```systemverilog
redirect_valid = step & id_ex_reg.valid & (branch_taken | is_jump | is_csr | ...)
redirect_pc    = branch_target | jump_target | (pc+4 for CSR) | ...
```

**Fetch 模块重定向处理**：

Fetch 阶段需要在取指过程中（`fetch_in_progress=1`）收到重定向时做特殊处理：
1. 若正在取指中：标记 `redirect_pending=1`，等待当前取指完成后应用
2. 若未在取指：直接更新 PC

这确保了不会因为中途修改 `ireq.addr` 而违反总线协议。

### 7.4 Difftest skip 逻辑

Lab3 要求添加 `skip` 信号，跳过对外设地址的访存指令检查：

```systemverilog
difftest_skip = commit_valid
              & ((commit_instr[6:0] == LOAD) | (commit_instr[6:0] == STORE))
              & (mem_wb_reg.alu_result[31] == 0);
```

原理：地址高 32 位为 0（即 0x00000000–0x7FFFFFFF）被映射为外设空间，Difftest 无法模拟外设状态，因此跳过对比。

### 7.5 关键 Bug 修复

**问题**：`beq` 指令在 `step=0` 时被冲刷。

**根因**：`redirect_valid` 信号未加 `step` 条件，导致流水线停顿周期（`step=0`）中 Decode 阶段仍将 EX 阶段的 beq 清除。

**修复**：在 `execute.sv` 中为 `redirect_valid` 增加 `step` 条件：

```systemverilog
assign redirect_valid = step & id_ex_reg.valid & (branch_taken | ...);
```

### 7.6 仿真结果

```
$ make test-lab3
...
HIT GOOD TRAP
it/s=3952    (无乘除法版本)
```

---

## 8. Lab3 Extra — 乘除法指令

### 8.1 设计挑战

直接使用 `*` 或 `/` 运算符实现 64 位乘除法会导致数百门延迟的组合逻辑路径，严重限制时钟频率。正确做法是实现**多周期迭代状态机**。

### 8.2 指令解码 (decode.sv)

M 扩展指令通过 `funct7 == 7'b0000001` 区分于标准 R-type：

```
opcode=0110011 (R-type) or 0111011 (OP-32)
funct7=0000001:
  funct3=000 → mul/mulw
  funct3=100 → div/divw
  funct3=101 → divu/divuw
  funct3=110 → rem/remw
  funct3=111 → remu/remuw
```

ALU_OP 映射为 16-25。

### 8.3 乘除法状态机 (execute.sv)

**状态定义**：

```
idle → md_start → md_busy（多周期迭代）→ md_finishing → md_result_ready
```

**乘法算法（移位加）**：

```
for i in 0..63:
    if op_b[0]: acc += op_a
    op_a <<= 1; op_b >>= 1
```

处理有符号数：操作数转为绝对值计算，最后根据符号位修正结果。

**除法算法（恢复余数法）**：

```
for i in 0..63:
    shifted = {acc[62:0], op_a[63]}
    trial = shifted - divisor
    if !trial[63]: acc = trial; quo = {quo[62:0], 1}
    else:          acc = shifted; quo = {quo[62:0], 0}
    op_a = {op_a[62:0], 0}
```

**周期数设置**：
- 64 位乘法：64 周期
- 32 位乘法 (mulw)：32 周期
- 除法/取余：64 周期

**边界条件处理**（符合 RISC-V 规范）：
- 除零 → 商 = 全 1，余 = 被除数
- 溢出 (MIN_INT / -1) → 商 = MIN_INT，余 = 0

**流水线阻塞**：

```systemverilog
execute_ok = !md_busy && (!id_is_muldiv || md_result_ready)
```

### 8.4 仿真结果

```
$ make test-lab3-extra
...
HIT GOOD TRAP
it/s=83333    (乘除法版本，因状态机等待周期，IPC 降低)
```

无乘除法版本的 `it/s=3952` 显著高于乘除法版本的 `it/s=83333`（越小越快），因为乘除法版本引入了 32-64 周期的流水线阻塞。

---

## 9. Lab4 — CSR 寄存器与指令

### 9.1 实验目标

实现 CSR 寄存器文件与六条 CSR 读写指令。

**支持指令**：`CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`

**实现寄存器**：`mstatus`, `mtvec`, `mip`, `mie`, `mscratch`, `mcause`, `mtval`, `mepc`, `mcycle`, `mhartid`, `satp`

### 9.2 CSR 寄存器功能说明

| 寄存器 | 地址 | 功能 |
|--------|------|------|
| `mstatus` | 0x300 | 机器状态：全局中断使能 (MIE)、特权级栈 (MPP/MPIE) |
| `mtvec` | 0x305 | 陷阱向量基址：异常/中断跳转入口 |
| `mip` | 0x344 | 中断等待位：标识哪些中断正在等待响应 |
| `mie` | 0x304 | 中断使能位：控制各类中断的开关 |
| `mscratch` | 0x340 | 机器暂存器：陷阱处理中交换上下文 |
| `mcause` | 0x342 | 陷阱原因：最高位区分中断/异常，低位为原因码 |
| `mtval` | 0x343 | 陷阱附加值：如出错地址或非法指令码 |
| `mepc` | 0x341 | 异常 PC：保存触发异常的指令地址 |
| `mcycle` | 0xB00 | 周期计数器：每周期自增 |
| `mhartid` | 0xF14 | 硬件线程 ID：本设计固定为 0 |
| `satp` | 0x180 | 地址翻译控制：mode + ASID + 根页表 PPN |

### 9.3 CSR 寄存器文件设计 ([csr_regfile.sv](vsrc/src/csr_regfile.sv))

**双层组合/时序设计**：

```
*_d (always_comb 计算) → *_q (always_ff 采样) → 外部接口
```

- `*_d`：组合逻辑计算的下一状态
- `*_q`：时序逻辑保存的当前状态
- Difftest 的 `dbg_*` 输出由 `*_d` 驱动，而非 `*_q`

**为什么 Difftest 用 `*_d` 而非 `*_q`**：Difftest 在 `posedge clk` 时采样——此时 `*_q` 尚未更新（非阻塞赋值）。若直接连 `*_q`，Difftest 会看到提交前的旧值。改用 `*_d` 后，Difftest 读到的是本周期即将写入的新值，与 WB 阶段的 CSR 写保持同步。

**CSR 写入掩码**：

```systemverilog
function automatic word_t apply_wmask(word_t wdata, word_t oldv, word_t wmask);
    return (wdata & wmask) | (oldv & ~wmask);
endfunction
```

| 寄存器 | 掩码 | 含义 |
|--------|------|------|
| mstatus | `MSTATUS_MASK` (0x7e79bb) | 仅允许规范定义的位可写 |
| mtvec | `MTVEC_MASK` (~0x2) | bit 1 不可写 |
| mip | `MIP_MASK` (0x333) | 仅 bit[0,1,4,5,8,9] 可写 |

**sstatus** 是 mstatus 的子集视图：`sstatus = mstatus & SSTATUS_MASK`，无需单独物理寄存器。

**特殊寄存器行为**：
- `mcycle`：每周期 +1；CSR 写入时覆盖
- `mhartid`：只读，硬连线为 0
- `satp`：全 64 位可写

### 9.4 CSR 指令实现

**CSR 指令编码** (SYSTEM opcode, funct3 解码)：

```
CSRRW  (001): csr_wval = rs1             → 无条件写入
CSRRS  (010): csr_wval = csr_rdata | rs1 → rs1≠0 时写入
CSRRC  (011): csr_wval = csr_rdata & ~rs1→ rs1≠0 时写入
CSRRWI (101): csr_wval = zimm            → 无条件写入
CSRRSI (110): csr_wval = csr_rdata | zimm→ zimm≠0 时写入
CSRRCI (111): csr_wval = csr_rdata & ~zimm→ zimm≠0 时写入
```

所有 CSR 指令的 ALU 结果（写入 GPR 的值）为 CSR 旧值 `csr_rdata`。

### 9.5 CSR 流水线处理

**关键设计决策**：CSR 写操作延期到 WB 提交（与 Difftest 保持一致），且 CSR 写入后必须冲刷流水线。

**为什么 CSR 必须冲刷流水线**：

CSR 是独立于 GPR 的地址空间。CSR 写后紧跟 CSR 读时，新值在 WB 才更新到 CSR 寄存器堆，而转发机制无法跨 GPR-CSR 地址空间工作。冲刷流水线（跳转到 pc+4 重新取指）是最简单可靠的解决方案。

**实现**：

```systemverilog
// execute.sv: CSR 写入视为"跳转到 pc+4，无条件跳转，预测失败"
redirect_valid |= id_ex_reg.is_csr & csr_do_write;
redirect_pc = id_ex_reg.pc + 64'd4;  // CSR 写时

// 通过 REG_EX_MEM → REG_MEM_WB 传递 csr_pending/csr_paddr/csr_pwdata
// WB 阶段: csr_we = step & mem_wb_reg.valid & mem_wb_reg.csr_pending
```

### 9.6 仿真结果

```
$ make test-lab4
...
HIT GOOD TRAP
```

---

## 10. Lab5 — 特权级切换与 MMU

### 10.1 实验目标

实现特权级别切换（ECALL/MRET）和 Sv39 虚拟内存翻译 (MMU)，完成上板测试。

### 10.2 特权级切换

#### 10.2.1 特权模式编码

| 编码 | 模式 | 说明 |
|------|------|------|
| 2'b11 | M (Machine) | 机器模式，最高权限 |
| 2'b01 | S (Supervisor) | 监管者模式（本实验预留） |
| 2'b00 | U (User) | 用户模式 |

CPU 上电后处于 M 模式。

#### 10.2.2 ECALL — 特权级升高

触发异常进入 M 模式：

```
1. mepc ← ecall 的 PC
2. pc ← mtvec（跳转到陷阱处理程序）
3. mcause[63] ← 0, mcause[5:0] ← 8 (U), 9 (S), 或 11 (M)
4. mstatus.MPP ← 当前特权级
5. mstatus.MPIE ← mstatus.MIE
6. mstatus.MIE ← 0
7. priv_mode ← M
```

#### 10.2.3 MRET — 特权级降低

从 M 模式返回到用户程序：

```
1. pc ← mepc（恢复到之前保存的 PC）
2. priv_mode ← mstatus.MPP
3. mstatus.MIE ← mstatus.MPIE
4. mstatus.MPIE ← 1
5. mstatus.MPP ← 0 (U, 最低支持特权级)
6. mstatus.XS ← 0
```

**注意**：MRET 不修改 mcause 寄存器。这是 RISC-V 规范明确规定的——返回指令不改变 mcause。

#### 10.2.4 特权级立即生效设计

一个核心设计挑战：特权级必须在 EX 阶段立即生效（MMU 依赖 `priv_mode` 判断是否启用），但 CSR 状态必须在 WB 提交（与 Difftest 一致）。解决方案：

```systemverilog
// csr_regfile.sv
always_comb begin
    ...
    // WB 阶段的 CSR 提交（先写，低优先级）
    if (trap_csr_commit) begin
        if (trap_is_mret_wb) priv_mode_d = mstatus_q[12:11];  // MRET 降权
        else                 priv_mode_d = 2'b11;               // ECALL/异常 升权
    end
    // EX 阶段的特权级切换（后写，高优先级）
    if (trap_fire_ex) begin
        if (trap_is_mret_ex) priv_mode_d = mstatus_q[12:11];
        else                 priv_mode_d = 2'b11;
    end
end
```

利用 SystemVerilog `always_comb` 中后写覆盖先写的语义，确保 EX 阶段的新陷阱优先级高于 WB 阶段的旧陷阱提交。

### 10.3 MMU — Sv39 页表翻译

#### 10.3.1 启用条件

MMU 仅在同时满足以下条件时启用：

```systemverilog
assign mmu_on = (priv_mode != 2'b11) && (satp.mode == 4'd8);
```

即：非 M 模式且 satp 配置为 Sv39 模式。

#### 10.3.2 SATP 寄存器结构

```
63       60 59                  44 43                                0
---------------------------------------------------------------------
|   MODE   |         ASID         |                PPN               |
---------------------------------------------------------------------
  4 bits         16 bits                       44 bits
```

| 字段 | 说明 |
|------|------|
| MODE | 8 = Sv39（39 位虚拟地址翻译），0 = Bare（不翻译） |
| ASID | 地址空间标识符（本实验为 0） |
| PPN | 根页表物理地址 >> 12 |

#### 10.3.3 Sv39 地址翻译流程

虚拟地址分解（39 位有效）：

```
38      30 29      21 20      12 11         0
-----------------------------------------------
|  VPN[2]  |  VPN[1]  |  VPN[0]  |   OFFSET   |
-----------------------------------------------
  9 bits     9 bits     9 bits      12 bits
```

三级页表遍历：

1. **Level 0**：基地址 = `{satp.PPN, 12'b0}`，索引 = `vaddr[38:30]` → 读取 L0 PTE
2. **Level 1**：基地址 = `{L0_PTE.PPN, 12'b0}`，索引 = `vaddr[29:21]` → 读取 L1 PTE
3. **Level 2**：基地址 = `{L1_PTE.PPN, 12'b0}`，索引 = `vaddr[20:12]` → 读取 L2 PTE
4. 物理地址 = `{L2_PTE.PPN, vaddr[11:0]}`

#### 10.3.4 MMU 状态机

```
ST_IDLE ──(req_in.valid)──→ ST_PTE ──(pte_hold)──→ ST_WAIT ──(resp.ready & last)──→ ST_IDLE
```

| 状态 | 功能 |
|------|------|
| ST_IDLE | 等待总线请求，收到后锁存原始地址 |
| ST_PTE | 等待 PTEHelper（Difftest 提供的仿真辅助）返回页表项 |
| ST_WAIT | 输出翻译后的物理地址，等待 RAM 响应，响应完成返回 IDLE |

**组合逻辑输出控制**：

- MMU 关闭：直通 `req_out = req_in`
- 翻译等待中（ST_IDLE/ST_PTE）：阻止总线请求和响应（防止下游看到未翻译地址）
- 翻译完成（ST_WAIT）：输出翻译后的请求

#### 10.3.5 Bonus: 巨页支持

Sv39 规范允许非叶子 PTE 作为叶子页表项，实现大于 4KB 的页面映射：

```systemverilog
function automatic addr_t sv39_paddr(word_t pte_val, addr_t vaddr, logic [7:0] level);
    unique case (level)
        8'd0: sv39_paddr = {8'b0, pte_val[53:28], vaddr[29:0]};   // 1GB 巨页
        8'd1: sv39_paddr = {8'b0, pte_val[53:19], vaddr[20:0]};   // 2MB 巨页
        default: sv39_paddr = {8'b0, pte_val[53:10], vaddr[11:0]}; // 4KB 普通页
    endcase
endfunction
```

#### 10.3.6 FPGA 路径

FPGA 上没有 PTEHelper（Difftest 仿真辅助模块），MMU 在 VIVADO 路径下采用恒等映射：

```systemverilog
`ifdef VERILATOR
    if (pte_pf == 8'b0) paddr <= sv39_paddr(pte, saved_req.addr, pte_level);
`else  // VIVADO
    paddr <= saved_req.addr;  // 虚拟地址 = 物理地址（恒等映射）
`endif
```

FPGA 测试程序须保证页表为恒等映射。

### 10.4 系统调用流程示例

```
1. U 模式执行 ECALL
   ├─ EX: trap_fire_ex → priv_mode 立即升为 M
   ├─ PC → mtvec（跳转陷阱处理程序）
   ├─ trap 气泡随流水线传播
   └─ WB: mepc ← ecall_pc, mcause ← 8, mstatus.MPP ← U, MIE ← 0

2. M 模式陷阱处理程序执行
   └─ 读 mcause，处理系统调用，mepc ← ecall+4

3. 陷阱处理程序末尾 MRET
   ├─ EX: trap_fire_ex → priv_mode 立即降为 U
   ├─ PC → mepc（= ecall+4）
   └─ WB: MIE ← MPIE, MPIE ← 1, MPP ← 0
```

### 10.5 关键问题与修复

#### 问题 1：MRET 错误清零 mcause

**现象**：`Return from init! Test passed` 后出现 `mcause different at pc=0x80001dfc, right=8, wrong=0`

**原因**：MRET 路径中错误执行了 `mcause_d = 64'b0`。RISC-V 规范规定 MRET 不修改 mcause。

**修复**：删除 MRET 的 `trap_csr_commit` 路径中 `mcause_d` 的赋值。

#### 问题 2：always_comb 优先级

**现象**：EX 新陷阱与 WB 旧陷阱同时存在时，WB 陷阱可能覆盖 EX 陷阱的 `priv_mode_d`。

**修复**：将 `trap_csr_commit` 块放在 `trap_fire_ex` 块之前，利用后写覆盖先写的语义，确保 EX 阶段陷阱优先级更高。

#### 问题 3：FPGA 跨时钟域

**现象**：Vivado 仿真通过，但上板后串口无输出。

**原因**：CPU 运行在 `cpu_clk`（由 PLL 产生），UART 运行在板载 `clk` (100MHz)。原代码中 `valid`/`addr`/`wdata` 在 `clk` 域的组合逻辑中使用 `cpu_clk` 域信号，存在跨时钟域问题。

**修复**：加入 CDC（跨时钟域）同步逻辑。

### 10.6 仿真结果

```
$ make test-lab5
...
Return from init! Test passed
```

（之后 CPU 进入空闲循环，卡住是预期行为。）

---

## 11. Lab6 — 中断与异常

### 11.1 实验目标

实现完整的异常处理与中断处理，这是 RISC-V 特权架构的核心。

### 11.2 异常处理

#### 11.2.1 异常类型与检测

| 异常 | mcause | 检测阶段 | 条件 |
|------|--------|----------|------|
| 指令地址不对齐 | 0 | EX | 分支/JALR 目标 `[1:0] ≠ 0` |
| 非法指令 | 2 | Decode | opcode 不在支持列表 |
| Load 地址不对齐 | 4 | EX | addr 与 load size 不对齐 |
| Store 地址不对齐 | 6 | EX | addr 与 store size 不对齐 |
| ECALL (U-mode) | 8 | EX | ecall 且 mode=U |
| ECALL (S-mode) | 9 | EX | ecall 且 mode=S |
| ECALL (M-mode) | 11 | EX | ecall 且 mode=M |

#### 11.2.2 异常检测实现 ([execute.sv](vsrc/src/execute.sv))

```systemverilog
// 指令地址不对齐
if (id_ex_reg.is_branch && branch_taken && (branch_target[1:0] != 2'b00))
    except_instr_misaligned = 1;
if (id_ex_reg.is_jump && opcode == JALR && (jalr_raw_addr[1:0] != 2'b00))
    except_instr_misaligned = 1;

// Load/Store 地址不对齐（按 size 检查对齐）
if (id_ex_reg.is_load)
    case (funct3)
        3'b001,3'b101: if (alu_result[0]) except_load_misaligned = 1;       // 半字
        3'b010,3'b110: if (alu_result[1:0] != 0) except_load_misaligned = 1;// 字
        3'b011: if (alu_result[2:0] != 0) except_load_misaligned = 1;       // 双字
    endcase

// 非法指令：Decode 阶段检测
// decode.sv: default case → is_illegal = 1'b1
```

#### 11.2.3 异常处理流程

```
1. mepc ← 异常指令 PC
2. pc ← mtvec（跳转陷阱向量）
3. mcause[63] ← 0（异常），mcause[5:0] ← 异常码
4. mstatus.MPIE ← mstatus.MIE, MIE ← 0
5. mstatus.MPP ← 当前特权级
6. priv_mode ← M
7. 冲刷流水线，取消未完成的 dreq
```

### 11.3 中断处理

#### 11.3.1 中断源

| 中断 | 外部信号 | mip 位 | mcause |
|------|----------|--------|--------|
| 时钟中断 (MTI) | `trint` | [7] | 7 |
| 软件中断 (MSI) | `swint` | [3] | 3 |
| 外部中断 (MEI) | `exint` | [11] | 11 |

`mip` 的对应位由外部信号组合逻辑直接驱动（`mip_d[7] = trint` 等），中断是持续的电平信号而非边沿。

#### 11.3.2 中断触发条件

需同时满足两个条件：

1. **全局/特权使能**：`(priv == M && mstatus.MIE == 1) || (priv != M)`
2. **局部使能**：`mip[i] == 1 && mie[i] == 1`

#### 11.3.3 中断评估时机（[core.sv](vsrc/src/core.sv)）

```systemverilog
if (step && fetch_ok && !trap_fire && !trap_csr_commit && !trap_in_progress) begin
    if ((priv_mode_q == M && csr_mstatus[3]) || (priv_mode_q != M)) begin
        if      (exint && csr_mie_q[11]) interrupt_fire = 1;  // MEI 优先
        else if (swint && csr_mie_q[3])  interrupt_fire = 1;  // MSI
        else if (trint && csr_mie_q[7])  interrupt_fire = 1;  // MTI
    end
end
```

**关键设计要点**：

1. **`priv_mode_q`（寄存器值）** 用于特权级判断：避免 `priv_mode → interrupt_fire → trap_fire → priv_mode` 组合环路
2. **M 模式用 `mstatus_d[3]`**（组合下一态）：使 `csrsi mstatus, 8` 写入 MIE 的同周期就能响应 M 模式定时中断
3. **`!trap_csr_commit`**：防止 MRET 提交周期误触发中断（此时 `mstatus_d.MIE` 已为 1 但 `priv_mode_q` 仍为 M）
4. **`!trap_in_progress`**：防止陷阱气泡在流水线中尚未提交时嵌套响应新中断
5. **优先级**：MEI > MSI > MTI

#### 11.3.4 mepc 保存策略

对于中断，`mepc` 应保存**下一条待取指的指令 PC**（而非已完成指令的 PC）：

```systemverilog
assign interrupt_save_pc = ex_mem_reg.valid ? ex_mem_reg.pc :
                           id_ex_reg.valid  ? id_ex_reg.pc  : fetch_current_pc;
```

采用**流水线最前有效段**的 PC，原因：M 模式 MIE 窗口极窄（`csrsi`/`csrci` 之间），若仅取 IF/ID 的 PC，会在 `csrci` 已进入 EX/MEM 时保存错误地址。

#### 11.3.5 中断注入

中断信号通过 execute 模块注入为一个陷阱气泡：

```systemverilog
if (interrupt_fire) begin
    ex_mem_reg.trap_pending <= 1'b1;
    ex_mem_reg.trap_is_interrupt <= 1'b1;
    ex_mem_reg.trap_code <= interrupt_cause_code;
    ex_mem_reg.pc <= interrupt_pc;
end
```

`combined_trap` 同时冲刷 Fetch/Decode/Memory，取消未完成 dreq。

### 11.4 MRET 更新 (Lab6 增强)

```
mstatus.MIE ← mstatus.MPIE
mstatus.MPIE ← 1
priv_mode ← mstatus.MPP
mstatus.MPP ← 0
mstatus.XS ← 0  (Lab6 新增)
```

### 11.5 关键 Bug 修复

#### 问题 1：U 模式定时中断 `Unexpected M-mode trap`

**原因**：MRET 提交周期 `mstatus_d.MIE = 1` 但 `priv_mode_q` 仍为 M，中断评估条件 `priv_mode_q != M` 为假但 `priv_mode_q == M && mstatus[3]` 为真，误触发 M 模式中断。

**修复**：加 `!trap_csr_commit` 屏蔽 MRET 提交周期的中断评估。

#### 问题 2：`m_trap_test` 仅成功数次后失败

**原因**：M 模式 MIE 窗口极窄（`csrsi` 写 MIE 和 `csrci` 关 MIE 之间仅有几条指令），若 `mepc` 保存错误则后续测试失败。

**修复**：
1. 用 `mstatus_d[3]` 使 `csrsi` 同周期生效 MIE
2. 用 `ex_mem_reg.pc` 作为 mepc（管道最前段）

### 11.6 中断与异常对比

| 特性 | 异常 (Exception) | 中断 (Interrupt) |
|------|-----------------|-----------------|
| 触发源 | 指令执行（同步） | 外部信号（异步） |
| mcause[63] | 0 | 1 |
| mepc 指向 | 触发异常的指令 | 下一条待取指令 |
| 可屏蔽性 | 不可屏蔽 | 可通过 mstatus.MIE / mie 屏蔽 |
| 检测位置 | Decode / Execute | core.sv 组合逻辑评估 |

### 11.7 仿真结果

```
$ make test-lab6
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
Timer interrupt in test_trap, this should happen 50 times.
...
Test m_trap [OK]
Privileged test finished.
```

---

## 12. Difftest 差分测试框架

### 12.1 框架原理

Difftest 将 CPU 的每一条提交指令与 NEMU（参考模型）进行逐条对比。在 `posedge clk` 时，若 `DifftestInstrCommit.valid = 1`，Difftest 对比 pc、wen、wdest、wdata 等字段。任何不匹配都会导致仿真停止并报告 `different at pc`。

### 12.2 时序对齐

Difftest 的核心时序要求：

| 周期 | DifftestInstrCommit.valid | 寄存器值 | 行为 |
|------|--------------------------|---------|------|
| N | 0 | 旧值 | 指令正在执行 |
| N→N+1 posedge | (未采样) | REG 更新 | 寄存器写入生效 |
| N+1 | 1（提交信号） | 新值 | Difftest 在 N+1→N+2 posedge 读取 |
| N+1→N+2 posedge | 采样 valid=1 | 读到新值 | 对比通过 ✅ |

### 12.3 关键连接

```systemverilog
// 指令提交
DifftestInstrCommit(..., .valid(commit_valid), .pc(commit_pc), .instr(commit_instr),
    .skip(difftest_skip), .wen(commit_wen), .wdest({3'b0, commit_wdest}), .wdata(commit_wdata));

// GPR 状态
DifftestArchIntRegState(..., .gpr_0(regfile_module.next_reg[0]), ...);

// CSR 状态
DifftestCSRState(..., .priviledgeMode(priv_mode_difftest), .mstatus(dbg_mstatus), ...);

// 陷阱事件
DifftestTrapEvent(..., .valid(commit_valid && (commit_instr == 32'h0005006b)), ...);
```

- `coreid` 统一连接 `mhartid[7:0]`（即 0）
- `skip`：MMIO 地址（addr[31]==0）的 load/store 跳过对比
- `block_commit`：ecall 的 WB 提交被阻止（mret 仍正常提交）

---

## 13. FPGA 上板测试

### 13.1 开发环境

| 项目 | 内容 |
|------|------|
| 开发板 | Basys-3 (Xilinx Artix-7 XC7A35T-1CPG236C) |
| 综合工具 | Vivado 2018.3 / 2019.2 |
| 顶层模块 | `VTop.sv`（综合顶层）→ `mycpu_top.sv`（AXI 封装） |
| 通信 | UART 串口（9600 波特） |

### 13.2 上板流程

```
1. 代码导入 Vivado 工程
2. 更新 IP 核 (clk_wiz)
3. Run Synthesis → 检查 Warnings
4. Run Implementation → 检查 Timing
5. Generate Bitstream
6. Program Device → 下载到 Basys-3
7. 串口调试助手验证输出
```

### 13.3 Verilator vs Vivado 差异处理

| 差异 | Verilator | Vivado |
|------|-----------|--------|
| 变量初始化 | `logic x = val` 可用 | 必须 `logic x; assign x = val` |
| 头文件路径 | `"include/common.sv"` | `"../include/common.sv"` |
| Difftest | 完整连接 | 不存在 |
| MMU PTEHelper | 可用 | 恒等映射（`paddr = vaddr`） |
| string 参数 | 支持 | 不支持（使用宏） |
| 条件编译 | `ifdef VERILATOR` | `ifdef VIVADO` |

### 13.4 上板问题与解决

**Vivado IP 核更新失败**：`IPUserFilesDir` 路径错误。解决方法是在其他 Vivado 版本（2019.2）上重新创建工程。

**串口无输出**：跨时钟域（CDC）问题——CPU 运行在 `cpu_clk`，UART 运行在 100MHz `clk`。需加入 CDC 同步逻辑。

---

## 14. 调试方法与经验

### 14.1 调试流程

```
编写代码 → make test → 错误？
  ├─ 看控制台输出（不同 at pc... → 查 .S 文件）
  ├─ 生成波形图（VOPT="--dump-wave -b <start> -e <end>"）
  ├─ GTKWave 打开波形，对照 .S 文件分析信号时序
  └─ $display 插入调试输出
```

### 14.2 波形图分析技巧

1. **定位问题周期**：从 `Guest cycle spent: N` 获取总周期数，截取出错时刻前后波形
2. **追踪数据流**：从 PC → if_id_reg → id_ex_reg → ex_mem_reg → mem_wb_reg 逐级检查数据传递
3. **检查 control signals**：valid、step、fetch_ok、mem_ok 是流水线心跳
4. **前向转发验证**：检查 forward_a/b 是否在需要时选择了正确的数据源
5. **CSR 时序验证**：确认 csr_we 在 WB 阶段正确触发，Difftest 的 dbg_* 信号与参考一致

### 14.3 常见问题排查

| 错误信息 | 可能原因 | 排查方向 |
|----------|---------|---------|
| `No instruction commits for 5000 cycles` | 首条指令不在 PCINIT | 检查 fetch 模块的 PC 初始化和第一条 commit |
| `Unexpected CBus request modification` | 在 data_ok 前修改了 ireq/dreq | 检查 valid/addr 是否在 data_ok 前保持稳定 |
| `Settle region did not converge` | 组合逻辑环路 | 检查信号依赖链 |
| `different at pc ...` | 指令执行结果与 NEMU 不一致 | 查 .S 文件对应 PC 的指令，追踪数据流 |
| Vivado `X` 状态 | 内联初始化语法不兼容 | 改用 `logic x; assign x = val;` |

### 14.4 组合环路 (Combinational Loop) 防范

组合环路是本项目中最隐蔽的一类 Bug。以下是实际遇到的案例：

**priv_mode 环路**：

```
priv_mode → interrupt_fire → trap_fire → priv_mode
```

修复方案：中断评估使用 `priv_mode_q`（时序逻辑/寄存器值），而 `priv_mode`（组合逻辑输出）仅用于 MMU 等外部模块。

### 14.5 各 Lab 调试记录

| Lab | 主要问题 | 解决方法 |
|-----|---------|---------|
| Lab1 | Difftest valid 时序 | next_reg 组合逻辑数组 |
| Lab3 | beq 被 step=0 时冲刷 | redirect_valid 加 step 条件 |
| Lab4 | CSR Difftest 不匹配 | 使用 `*_d` 组合逻辑驱动 dbg 输出 |
| Lab5 | MRET 错误清零 mcause | 删除 MRET 路径的 mcause_d 赋值 |
| Lab5 | always_comb 优先级覆盖 | 调整块顺序：先 trap_csr_commit 后 trap_fire_ex |
| Lab5 | FPGA 串口无输出 | 跨时钟域同步 |
| Lab6 | Unexpected M-mode trap | 加 `!trap_csr_commit` 屏蔽 |
| Lab6 | m_trap_test 失败 | mstatus_d 同周期生效 + ex_mem_reg.pc 作 mepc |

---

## 15. Bonus 完成情况

### 15.1 Lab3 Extra — 乘除法指令 ✅

实现了 10 条 M 扩展指令（mul/div/divu/rem/remu 及对应 W 版本），通过迭代状态机实现多周期运算，避免了长组合逻辑路径。通过 `make test-lab3-extra` 测试。

### 15.2 Lab5 Bonus — 巨页支持 ✅

MMU 支持 SV39 规范中的可变级页表（巨页）：

- Level 0 叶子：1GB 页面
- Level 1 叶子：2MB 页面
- Level 2 叶子：4KB 普通页面

### 15.3 Lab6 Bonus — 时钟中断处理程序

以下为 M 模式下的时钟中断处理程序示例：

```c
#define MTIME_ADDR    ((volatile unsigned long long *)0x3800bff8ULL)
#define MTIMECMP_ADDR ((volatile unsigned long long *)0x38004000ULL)
#define INTERVAL      1000000ULL  // 约 1ms（取决于 mtime 频率）

void handle_timer(void) {
    puts("[Timer Interrupt]\n");
    unsigned long long now = *MTIME_ADDR;
    *MTIMECMP_ADDR = now + INTERVAL;
}
```

汇编入口 (mtvec 处)：

```asm
trap_entry:
    # 保存上下文
    addi sp, sp, -256
    sd   ra, 0(sp)
    sd   t0, 8(sp)
    # ... 保存其他寄存器 ...

    # 读 mcause 判断中断类型
    csrr t0, mcause
    srli t1, t0, 63
    beqz t1, handle_exception   # mcause[63]=0 → 异常
    andi t1, t0, 0x7f
    li   t2, 7
    beq  t1, t2, handle_timer    # mcause=7 → 时钟中断
    # ... 处理其他中断 ...

    # 恢复上下文，返回
    ld   ra, 0(sp)
    # ...
    addi sp, sp, 256
    mret
```

### 15.4 Lab6 Bonus — 为什么时钟中断使用 MMIO 计时器

而非将 `mtime`/`mtimecmp` 实现为 CSR 寄存器，也非使用已有的 CSR `mcycle`：

1. **独立时钟域**：MMIO 计时器可使用独立于 CPU 核心的时钟源运行，CPU 休眠（WFI）时计时器仍继续工作。CSR `mcycle` 在核心停钟时也会停止。

2. **多核共享时间基准**：`mtime` 是全局唯一的 MMIO 寄存器，所有 hart（硬件线程）共享同一时间源，便于操作系统统一调度和核间中断（IPI）。

3. **频率解耦**：计时器可使用更稳定、更高精度的外部时钟源（如 TCXO），不受 CPU DVFS（动态调频调压）影响。

4. **热插拔支持**：计时器独立于任何 CPU 核心，单个核心的复位或掉电不影响全局时间基准。

5. **RISC-V 规范符合性**：ACLINT/CLINT 规范将 `mtime`/`mtimecmp` 定义为内存映射设备，属于平台级中断控制器的一部分，而非 per-hart CSR。

### 15.5 未完成 Bonus

| 项目 | 状态 | 说明 |
|------|------|------|
| Lab4 S 模式 CSR | 未完成 | 未实现 stvec/sepc/scause 等物理寄存器 |
| Lab6 MMU 缺页异常 | 未完成 | MMU 已检测 `pte_pf` 但未向 core 上报陷阱 |

---

## 16. 总结与展望

### 16.1 实验总结

通过 Lab1–Lab6 的递进式实验，本 CPU 从零开始逐步完善，最终实现了一个功能完备的 RISC-V RV64I 五级流水线处理器。回顾整个过程：

1. **Lab1–2** 建立了流水线的骨架结构，理解了取指、译码、执行、访存、写回五个阶段的协作机制，以及内存总线的握手协议。

2. **Lab3** 深入理解了控制冒险与数据冒险，掌握了前向转发、流水线冲刷、静态分支预测等关键技术，是流水线设计的分水岭。

3. **Lab4** 打开了特权架构的大门，理解了 CSR 寄存器作为"CPU 的配置接口"的角色，以及为什么 CSR 写入需要特殊的流水线处理。

4. **Lab5** 实现了完整的特权级切换与虚拟内存，将前几个 Lab 的成果整合为可运行操作系统的处理器。理解"为什么需要特权级"和"虚拟地址如何变成物理地址"是本次实验最大的收获。

5. **Lab6** 完成了中断与异常处理，使 CPU 具备了响应外部事件的能力——这是"计算机"与"计算器"的分野。

### 16.2 技术收获

- **硬件描述语言的工程实践**：掌握 SystemVerilog 的可综合子集，理解组合逻辑与时序逻辑的本质区别
- **计算机体系结构的直观理解**：从零构建 CPU 的过程将"流水线""转发""页表""中断"等课本概念转化为可运行的电路
- **差分测试方法论**：理解了逐条指令比对的验证思想及其时序约束
- **FPGA 开发全流程**：从 Verilator 仿真到 Vivado 综合实现，再到上板测试的完整硬件开发流程
- **调试思维**：形成了"仿真定位逻辑错误 → 波形分析信号时序 → 综合排查语法问题 → 上板验证硬件功能"的系统化调试思路

### 16.3 未来扩展方向

- 实现 S 模式 CSR 寄存器与完整的 Supervisor 模式支持
- 实现 MMU 缺页异常（page fault）的硬件检测与上报
- 支持更多 RISC-V 扩展（A 扩展原子操作、V 扩展向量运算、F/D 扩展浮点）
- 添加指令缓存和数据缓存
- 实现分支预测器（如 BTB + 两位饱和计数器）
- 实现超标量或乱序执行
- 移植一个小型操作系统（如 xv6-riscv）

---

*本报告涵盖了复旦大学 2026 年春《计算机组成与体系结构（H）》课程实验的全过程，包括项目架构、模块实现、调试经验与心得体会。*
