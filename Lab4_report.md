# Lab 4 实验报告

**姓名**：杨添燚

**学号**：24300240173

## 一、实验目标

CPU 需要支持以下指令并通过测试：

- 实现指令：`CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`

- 实现寄存器：`mstatus`, `mtvec`, `mip`, `mie`, `mscratch`, `mcause`, `mtval`, `mepc`, `mcycle`, `mhartid`, `satp`。这些寄存器均为64位宽。并且需要将这些寄存器对应连接到 `DifftestCSRState`。

## 二、寄存器的作用

参考英文指令集手册，在此次 lab 中各个 csr 寄存器的作用简述如下：

`mstatus` (Machine Status Register): 控制和记录处理器的当前状态，特别是全局中断使能（MIE）以及特权级相关的设置。

`mtvec` (Machine Trap-Vector Base-Address): 存储异常/中断处理入口地址（即陷阱向量表基址）。

`mip` (Machine Interrupt Pending): 指示哪类中断正在等待响应（如外部中断、定时器中断、软件中断等）。

`mie` (Machine Interrupt Enable): 用于使能或屏蔽某一类中断。

`mscratch` (Machine Scratch): 一个机器模式下可快速读写的暂存寄存器，常用于陷阱处理早期交换上下文。

`mcause` (Machine Cause): 记录触发最近一次异常或中断的原因编号，最高位区分是中断还是异常。

`mtval` (Machine Trap Value): 存放异常发生时的附加辅助信息（例如错误地址或非法指令码）。

`mepc` (Machine Exception Program Counter): 记录触发异常的那条指令的地址，用于异常返回时的恢复。

`mcycle` (Machine Cycle Counter): 记录处理器自启动以来经历的时钟周期数。

`mhartid` (Machine Hardware Thread ID): 记录当前硬件线程的ID号。

`satp` (Supervisor Address Translation and Protection): 控制虚实地址转换（即MMU），里面存储着根页表的物理地址和当前地址空间标识。

## 三、实现细节

为完成Lab 4的目标，按照以下步骤实现：添加 CSR 寄存器文件、在译码/执行中接入 CSR 指令，并在写 CSR 时冲刷流水线；将 CSR 状态接到 Difftest。

遇到的问题：EX 阶段的 CSR 写操作在旧指令完成 WB 之前就更新了架构状态，导致 Difftest 比 NEMU 更早看到 `mstatus` 的更新。将写操作移至 WB 后，DifftestCSRState 在时钟上升沿运行，却采样到了旧的触发器输出，因为同一时间步内更新是非阻塞的。

差分测试控制状态寄存器状态在每个时钟上升沿采样，且会在非阻塞更新生效前读取控制状态寄存器触发器，因此获取到的是提交前的旧值。从组合逻辑下一状态（与触发器下一值保持一致）驱动差分测试，可修复该数值不匹配问题。在`csr_regfile.sv`文件中，通过组合逻辑方式计算下一状态，并基于该下一状态驱动调试相关信号，让差分测试在触发器更新前的时钟上升沿进行采样，能够读取到提交后的架构状态值。

推迟到 WB 的 CSR 写操作 —— `csr_pending`、`csr_paddr` 和 `csr_pwdata` 随流水线寄存器 REG_EX_MEM 及 REG_MEM_WB 传递。EX 阶段仅计算是否写及写什么；`csr_regfile.csr_we` 从 WB 驱动：

`core.sv`：

```verilog
// Lab4: csr_we 与 regfile 写回同属 WB；dbg_* 为组合次态（Difftest posedge 对齐 NEMU）csr_regfile csr_regfile_inst(
    .clk(clk),
    .reset(reset),
    .csr_we(step & mem_wb_reg.valid & mem_wb_reg.csr_pending),
    .csr_waddr(mem_wb_reg.csr_paddr),
    .csr_wdata(mem_wb_reg.csr_pwdata),
```

`execute.sv`：移除`csr_we`/`csr_waddr`/`csr_wdata`输出；当阶段前进时将 CSR 提交信息锁存到`ex_mem_reg`。

`memory.sv`：在 step 时将这三个 CSR 字段从`ex_mem_reg`复制到`mem_wb_reg`（并当 reset 时清零）。

`csr_regfile.sv`：在 always_comb 中计算 d 次态，触发器采样 d，而 dbg 由 d 驱动，使得 Difftest 在提交上升沿看到的 CSR 架构值与写入后一致，包括 mcycle 自增与显式写入。

### 刷新流水线保证 CSR 数据与状态的一致性

CSR 作为寄存器，也会有数据冲突。但是，CSR 不应该转发。CSR 的每次改变，都应刷新流水线（普通的写入后，则刷新流水线，从 `pc + 4` 开始继续执行）为什么 CSR 写入指令一定要刷新流水线？原因主要是无法用转发解决 CSR 的数据冒险。

通用寄存器（GPR）之间的写后读冲突可以通过转发（Forwarding）把刚算出的结果直接旁路给下一条指令，无需等待写回。但 CSR 是独立于 GPR 的地址空间，其读/写指令（CSRRW/CSRRS/CSRRC 等）是先读出 CSR 旧值写入 GPR，再把新值写入 CSR。CSR 的新值在写回阶段才会更新到 CSR 寄存器堆。如果后续紧跟着一条读 CSR 的指令（如 CSRRW 或依赖 CSR 的指令），此时新值尚未写入，通过转发也无法直接从一个通用寄存器到 CSR 寄存器堆，这会导致后续指令读到错误的旧 CSR 值。为了避免这种不可转发的数据冒险，最简单且符合规范的方法就是在 CSR 写入后冲刷整条流水线，让后续指令重新从 PC+4 取指，此时 CSR 已经更新完毕。

## 四、仿真测试

使用提供的 Makefile 运行`make test-lab4`进行仿真测试。仿真通过 Difftest 框架对比 CPU 行为与参考模型，输出详细的提交指令轨迹和最终寄存器状态。最终得到`HIT GOOD TRAP`结果：

![image-20260508193201536](C:\Users\23954\AppData\Roaming\Typora\typora-user-images\image-20260508193201536.png)

## 五、实验总结

本次实验完成了 Lab4 的所有目标。`make test-lab4` 以 HIT GOOD TRAP 结束，且 CSR 改动后 `make test-lab3` 依然通过。

在具体实现中，严格遵循了 RISC-V 特权规范中的 M/S 模式行为。通过此次实验，深刻理解了 RISC-V 特权级架构中“状态隔离”与“同步时序”的重要性，为后续实现异常处理与 MMU 提供了坚固的基石。