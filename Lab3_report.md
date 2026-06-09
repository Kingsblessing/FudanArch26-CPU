# Lab 3 实验报告

**姓名**：杨添燚

**学号**：24300240173

## 一、实验目标

要求 CPU 支持跳转和条件跳转。

CPU 需要支持以下指令并通过测试：

`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `slti`, `sltiu`, `slli`, `srli`, `srai`, `sll`, `slt`, `sltu`, `srl`, `sra`, `slliw`, `srliw`, `sraiw`, `sllw`, `srlw`, `sraw` `auipc`, `jalr`, `jal`

CPU 还需要上板测试。

>  Extra：本次实验同时初步实现了乘除法选做指令，并能够通过Verilator仿真。
>
> 选做指令： `mul`, `div`, `divu`, `rem`, `remu`, `mulw`, `divw`, `divuw`, `remw`, `remuw`

## 二、实现思路

### 跳转和条件跳转指令实现

原代码基于五级流水线（Fetch→Decode→Execute→Memory→Writeback）架构展开，各阶段分工如下：

> Fetch 阶段：根据 PC 从内存取指，接收 Execute 阶段的重定向信号更新 PC，实现流水线冲刷；
>
> Decode 阶段：解析指令的操作码、寄存器地址、立即数（B 型、J 型、I 型等），识别分支 / 跳转指令并标记；
>
> Execute 阶段：完成 ALU 运算（含移位、比较）、分支条件判断、跳转目标地址计算，生成 PC 重定向信号；
>
> Memory/Writeback 阶段：完成访存（Lab2 基础）和寄存器写回，配合 Difftest 完成指令提交验证。

本次实验主要修改`core.sv`、`decode.sv`、`execute.sv`、`fetch.sv`四个文件，核心修改如下：

1.`core.sv`中新增`redirect_valid`（重定向有效）、`redirect_pc`（重定向目标 PC）、`difftest_skip`（Difftest 跳过标志）信号；实现`difftest_skip`逻辑：对访存类指令（加载/存储，opcode 为 0000011/0100011）且访存地址高 32 位为 0 的指令，标记为跳过对比，避免 Difftest 仿真错误。

2.`decode.sv`中扩展立即数解析逻辑，新增 B 型（分支）、J 型（jal 跳转）立即数拼接；识别分支 / 跳转指令并设置标志位，完成立即数符号扩展。

3.`execute.sv`中扩展 ALU 运算逻辑，支持移位`sll`/`srl`/`sra`及 w 版本、比较`slt`/`sltu`指令，实现分支条件判断与跳转目标计算；修正重定向信号生成条件，仅在流水线推进`step=1`时生效。

4.`fetch.sv`中处理重定向信号，若存在有效重定向且流水线未处于取指中，直接更新 PC；若取指中则标记重定向挂起，待取指完成后更新。

初始实现后执行`make test-lab3`，仿真报错且`beq`指令（0x80000018）未被提交，直接跳转到 0x80000fa8。通过波形图和代码逻辑排查，发现`redirect_valid`信号生成过早：在`step=0`（全局流水线停顿）时，`redirect_valid`仍被拉高，导致 Decode 阶段的流水线冲刷逻辑将当前 Execute 阶段的`beq`指令清除，指令无法进入后续阶段提交。在`execute.sv`中为`redirect_valid`增加`step`条件，仅当流水线推进`step=1`时才允许触发重定向，避免停顿周期冲刷有效指令。

### 乘除法指令实现

在 `decode.sv` 模块中，通过解析 RISC-V 的标准指令字格式来识别乘除法指令，并将其映射为内部的 ALU 操作码`alu_op`。乘除法指令与普通的 R 型算术指令共享 `opcode`（64位为 `7'b0110011`，32位操作为 `7'b0111011`），但通过特定的 `funct7 == 7'b0000001` 来区分它们是 M 扩展指令 。在确认是 M 扩展指令后，根据 `funct3` 的值，将 ALU 操作码`alu_op`分别映射为处理器内部定义的值 。对于W指令，则映射为 21~25 之间的操作码 。此类指令均为寄存器-寄存器操作，因此将 `alu_src` 设为 0（表示第二个操作数来源于寄存器 rs2 而非立即数），并使能寄存器写回 `reg_write = 1'b1` 。

在 `execute.sv` 模块中，通过组合逻辑实现了具体的乘法、除法和取余运算，并严格遵循了 RISC-V 规范中对于特殊情况的处理。运算直接利用 Verilog 自带的乘法（`*`）、除法（`/`）和取余（`%`）运算符实现 。为了正确处理带符号和无符号数，代码提前准备了无符号操作数 `alu_a/b` 和带符号操作数 `s_alu_a/b` 。 对于带有 W 后缀的指令，代码先截取输入操作数的低 32 位进行计算 。得到 32 位结果后，统一进行符号扩展至 64 位，然后写入最终的 `alu_result` 。

特殊边界情况：除零（Divide by Zero）：当除数 `alu_b == 0` 时，若是除法操作（`DIV`/`DIVU`），结果强制设为全 1；若是取余操作（`REM`/`REMU`），则结果直接返回被除数 `alu_a` 。溢出（Overflow）： 仅在有符号除法中发生。此时，除法结果强制设为被除数 `alu_a` 本身 ；取余结果则强制设为 `0` 。这些均在 `always_comb` 的分支逻辑中予以实现。

真实的乘除法器通常需要多个时钟周期才能完成计算，为了模拟这一硬件行为，`execute.sv` 中设计了一个基于计数器的状态机，用于挂起流水线。通过 `id_is_muldiv` 信号判断识别当前进入执行阶段的是否为乘除法指令 。设置了 `md_busy` 寄存器。一旦乘除法开始计算，拉高 `md_busy` 。执行阶段的完成握手信号 `execute_ok` 被定义为 `!md_busy` 。这意味着只要乘除法还在计算，`execute_ok` 就会维持为 0，从而使全局 `step` 信号无效，阻止译码阶段指令进入和执行阶段指令流出，实现流水线停顿。计数器 `md_count` 根据运算复杂度设置了不同的延迟。对于乘法`MUL`/`MULW`，初始计数值设为 8 周期；对于除法和取余指令，设为 16 周期 。在后续时钟周期中，如果处于忙碌状态，计数器递减 。当 `md_count == 1` 时，清除 `md_busy` 状态 ，`execute_ok` 重新变为有效，运算结果随着恢复的 `step` 信号送入访存阶段的寄存器中 。

## 三、仿真测试

使用提供的 Makefile 运行`make test-lab3 VOPT="--dump-wave"`进行仿真测试。仿真通过 Difftest 框架对比 CPU 行为与参考模型，输出详细的提交指令轨迹和最终寄存器状态。最终得到`HIT GOOD TRAP`结果：

![image-20260420185828286](C:\Users\23954\AppData\Roaming\Typora\typora-user-images\image-20260420185828286.png)

其中，`it/s=3952` 代表了 cpu 运行的性能。

对于乘除法指令版本仿真测试，使用提供的 Makefile 运行`make test-lab3-extra VOPT="--dump-wave"`测试。最终得到`HIT GOOD TRAP`结果：

![image-20260420190222253](C:\Users\23954\AppData\Roaming\Typora\typora-user-images\image-20260420190222253.png)

其中`it/s=83333`。

## 四、上板

根据上板教程实现了上板测试。在导入各个模块中使用 `ifdef VERILATOR` 宏来为 Vivado 和 Verilator 分别实现不同的导入规则。

在 Vivado 中进行仿真测试，`Run Simulation`-`Run behavioral simulation` 然后检查下波形图：确认到 pc 正常在走。

![image-20260420192211214](C:\Users\23954\AppData\Roaming\Typora\typora-user-images\image-20260420192211214.png)

接下来的步骤中，使用我的电脑Vivado 2018.3，在执行更新`IP Sources`时遇到了问题。两个IP核无法生成正确的中间文件。错误信息是：

> [filemgmt 56-2] IPUserFilesDir: Could not find the directory 'D:/FudanCoding/repo/26-Arch/vivado/test-cpu/project/project_1.ip_user_files', nor could it be found using path 'D:/home/tanyifan/Desktop/Arch-2022Spring/vivado/test3/project/project_1.ip_user_files'. 
>
> [IP_Flow 19-4067] Ignoring invalid widget type specified checkbox.Providing a default widget

查找日志文件，发现报错 `TclStackFree: incorrect freePtr. Call out of sequence?`，这可能是 Vivado 软件环境或 Tcl 解释器崩溃导致的内存管理错误。在解决未果后，猜测是电脑环境或软件问题，借用其他同学的电脑（Vivado 2019.2）完成上板。

然后就成功地完成 Vivado 环境下的代码导入、IP 核更新、综合实现与比特流生成，成功将 CPU 程序下载至开发板。在进行`Run Synthesis`、`Run Implementation`、`Generate Bitstream`，没有遇到其他的`Error`, `Critical Warning`和非助教提供的框架代码外的`Warning`。在串口调试助手中连接开发板，在 Vivado 中 `Program Device`。能看到test-lab3 的测试程序开始运行，并在串口调试助手中输出。

![556bcf418c222d4afebd50fa388e3f29](D:\QQFiles\Tencent Files\2672228437\nt_qq\nt_data\Pic\2026-04\Ori\556bcf418c222d4afebd50fa388e3f29.png)

程序运行到最后且正常退出，说明测试通过。

## 五、实验总结

通过本次 Lab 3，我掌握了以下技能：

1. **对流水线 CPU 架构的理解深化**：跳转指令的实现让我深刻认识到流水线冒险的本质，理解了“冲刷流水线”“分支预判” 等解决策略的工程价值，体会到理论架构与实际硬件实现的差异。

2. **硬件开发流程的工程认知**：掌握了“Verilator 仿真→Vivado 综合实现→上板测试”的完整硬件开发流程，理解了 Verilator与 Vivado的语法差异，学会了利用宏定义兼容不同工具的语法要求。

3. **硬件调试能力的提升**：熟练使用波形图分析信号时序、通过 Vivado 的 Messages 和 Timing 界面定位语法错误与时序问题、利用串口调试助手观测硬件运行状态，形成了“仿真定位逻辑错误→综合排查语法/时序问题→上板验证硬件功能”的调试思路。

本次 Lab3 实验围绕实现支持跳转与条件跳转类 RISC-V 指令的五级流水线 CPU 展开，完成了指令集扩展、仿真验证与硬件上板测试全流程，不仅深化了对流水线 CPU 架构的理解，也积累了硬件开发从仿真到物理实现的工程实践经验。
