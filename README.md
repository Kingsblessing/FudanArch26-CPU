# Arch-2026-Spring-Fudan

> 2026 Spring Computer Organization and Architecture(H) Course Code Repository.

Arch-2026-Spring-FDU  
│── build：仿真测试时才会生成的目录  
│── difftest：仿真测试框架  
│── ready-to-run：仿真测试文件目录（包括汇编文件和二进制文件等）  
│── verilate：verilator部分仿真文件目录  
│── vsrc：需要写的CPU代码所在目录  
│　　├── include：头文件目录  
│　　├── src：你将在这个目录下完成CPU的代码编写  
│　　　　　└── core.sv：CPU核主体代码  
│　　├── util：访存接口相关目录  
│　　└── SimTop.sv  
│── Makefile：仿真测试的命令汇总  
└── README.md: 此文件  
# Lab1

## 目标

我们要实现一个 RISC-V 的 CPU 核。它就是一个时序电路。CPU 对外而言是一个黑盒子，我们不关心它内部是怎么实现的，只通过它对外连接的接口观测。包括：

- 时钟信号（clock）：CPU 的时钟信号，控制 CPU 的节奏。
- 复位信号（reset）：当复位信号为高电平时，CPU 会被重置到初始状态。
- 内存总线。

要求 CPU 支持 64 位算术运算。

构建五级流水线 CPU 架构，CPU 需要支持以下指令并通过测试：

算术运算与逻辑运算：

- `addi`, `xori`, `ori`, `andi`
- `add`, `sub`, `and`, `or`, `xor`
- `addiw`, `addw`, `subw`

## 代码规范

Verilator 目前依然有许多不足之处。首先 Verilator 对 SystemVerilog 的语言支持还非常不完整，比如 unpacked 结构体是不支持的。此外 interface、package 这些关键字虽然支持，但是在功能上还不够完善。为了避免你的 SystemVerilog 代码不能通过 Verilator 的综合和不正确的仿真行为，请尽量避免以下事项：

- 不可综合的语法，例如延时。
- `initial` 语句。
- 小端序位标号，如 [0:31]。
- 锁存器。
- logic 类型的 X 状态和高阻抗 Z 状态。
- 使用时钟下降沿触发。
- 异步 reset 和跨时钟域。
- 尝试屏蔽全局时钟信号。

此外，我们建议每个 SystemVerilog 文件只放一个模块，并且文件名和模块名保持一致。例如，SRLatch.sv 里面只放模块 SVLatch 的定义。更详细的内容可以参见 Verilator 手册中的 “语言限制” 一节。

我们建议你使用结构体来组织你的代码，例如在 Fetch 阶段传递给 Decode 阶段的信号，可以定义：

```
typedef struct packed {
    logic valid;
    u64 pc;
    u32 instr;
} REG_IF_ID;
```

这样在你的 Fetch 模块定义的接口中就是

```
output REG_IF_ID moduleOut,
```

## 实现 CPU

你需要在此仓库的 `vsrc` 目录下编写代码，你不应该更改 `vsrc` 目录以外的文件，你的 CPU 核应该呈现在 `vsrc/src/core.sv` 中。因此，你需要在 `core.sv` 中编写代码来实现 CPU 的功能。

> 但是你不应该将所有代码都写在 `core.sv` 中，你应该将代码分成多个模块，并在 `core.sv` 中实例化这些模块。这样可以使代码更清晰，更易于维护。

内存总线的接口如下：

```
/**
 * instruction cache bus
 * addr must be aligned to 4 bytes.
 *
 * basically, ibus_resp_t is the same as dbus_resp_t.
 */
typedef struct packed {
    logic  valid;       // in request?
    addr_t addr;        // target address
} ibus_req_t;

typedef struct packed {
    logic  addr_ok;     // is the address accepted by cache?
    logic  data_ok;     // is the field "data" valid?
    u32 data;           // the data read from cache
} ibus_resp_t;
```


| 字段名称  | 含义         |
| ----- | ---------- |
| valid | 是否发出请求     |
| addr  | 访存地址（起始字节） |


### 内存总线

你的 CPU 就需要连接内存总线（用于从内存中取指令）。

请一定理解，对于你的 CPU 来说，`ibus_req_t` 是一个需要**输出的信号**，你的 CPU 需要输出你现在是否在请求取指令（即 `valid`），以及你要取指令的地址（即 `addr`）。而 `ibus_resp_t` 是一个需要**输入的信号**，你的 CPU 需要根据这个信号来判断是否成功取到了指令（即 `data_ok`），以及取到的指令是什么（即 `data`）。

你**暂时**无需了解这个总线是怎么工作的，你只需要知道：

- 当你需要取指令时，你就把 `valid` 置为 1，并且把你要取指令的地址放在 `addr` 上。
- 当 `data_ok` 变为 1 的时候，你就可以从 `data` 上读取到你要取的指令了。
- 你需要保证在 `data_ok` 变为 1 之前，你的 `valid` 和 `addr` 是不变的。也就是说，在等待取指令的过程中，你不能改变你要取指令的地址了。

一个简单的取指令的例子如下：

此处介绍的是 fetch 模块。我们不限制你怎么写，这只是一个例子，帮助理解如何使用总线取指令：

```
module fetch import common::*;(
    input logic clk, rst,
    input logic step, // 这个信号用来同步整个 CPU 的时序，当其为 1 时，整个 CPU 流水线向前移动一个指令。
    output logic fetch_ok, // 表示当前模块是否已经准备好接受下一条指令了
    // 实际上 step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok; 也就是说，只有当五个阶段都准备好接受下一条指令了，step 才会为 1。
    input ibus_resp_t ibus_resp,
    output ibus_req_t ibus_req,
    ... // 其他信号
);

... // 其他代码

u64 pc; // 当前指令的地址
u32 instr; // 当前指令的内容

always_ff @(posedge clk) begin
    if (rst) begin
        ...
    end else if (step) begin
        fetch_ok <= 0; // 先把 fetch_ok 置为 0，表示我们正在处理当前指令，还没有准备好接受下一条指令了。
        ibus_req.valid <= 1; // 置为 1，表示我们要求取指令了。
        ibus_req.addr <= pc; // 把我们要取指令的地址放在 addr 上。
    end else begin
        // 这里对应：要么我们还没取好指令，要么我们取好指令了，在等其他模块
        if(fetch_ok) begin
            // 在等其他模块
        end else if (ibus_resp.data_ok & ibus_resp.addr_ok) begin
            instr <= ibus_resp.data; // 从 data 上读取到我们要取的指令了。
            fetch_ok <= 1; // 取好指令了，我们把 fetch_ok 置为 1，表示我们已经准备好接受下一条指令了。
            ibus_req.valid <= 0; // 取好指令了，我们把 valid 置为 0，表示我们不再要求取指令了。
            pc <= pc + 4; // 取好指令了，我们把 pc 加 4，准备取下一条指令了。
        end
    end
end
```

## 接线

如何验证自己的代码是否正确呢？我们通过 Verilator 仿真对代码进行测试。

将 CPU 接入 Verilator Difftest 的仿真接口。 需要例化三个模块（所给框架中已例化好，需要接线）。

### 当前周期提交的指令 DifftestInstrCommit

> 说明： 当前周期提交的指令是**写回**的指令（不应该在指令没执行完的时候提交）。关于具体的时序和时钟周期，请看常见问题中的[Difftest 连接](https://github.com/26-Arch/26-Arch/wiki/实验讲解#difftest-连接)。下面的代码是没有连接的状态，需要你去连接你的 cpu 的中的信号。
>
> wdest 是 8 位的，所以我们接入的时候需要写 `.wdest({3'b0, dataM.dst})`

```
DifftestInstrCommit DifftestInstrCommit(
    .clock (clk),
    .coreid (0), // 无需改动
    .index (0), // 无需改动
    .valid (0), // 为0代表无提交
    .pc (0), // 这条指令的 pc
    .instr (0), // 这条指令的内容
    .skip (0), // 暂时无需改动
    .isRVC (0), // 无需改动
    .scFailed (0), // 无需改动
    .wen (0), // 这条指令是否写入通用寄存器（不含CSR），1 bit
    .wdest (0), // 写入哪个通用寄存器
    .wdata (0) // 写入的值
);
```

### 当前周期寄存器状态 DifftestArchIntRegState

```
DifftestArchIntRegState DifftestArchIntRegState (
    .clock (clk),
    .coreid (0),
    .gpr_0 (regfile.regs_nxt[0]),
    // 其他寄存器需要自行链接
);
```

### 当前周期 CSR 寄存器状态 DifftestCSRState

```
DifftestCSRState DifftestCSRState(

);
```

暂时无需理会。

## 测试

请使用例如：make test-lab1 的命令来测试你的代码是否正确。

如果你通过 verilator 仿真测试的话，将会看到 HIT GOOD TRAP，它不在所有输出的最下方，你需要向上翻一下。

Verilator 输出的 Commit Group Trace 和 Commit Instr Trace 是循环队列，并不是严格按顺序输出的。箭头指向的是提交的最后一条指令。上一行则是前一条提交的命令，以此类推，若已经是第一行，那么它的上一条就是最后一行（如果你提交了超过 16 条指令的话，并且最后一行不是箭头的话）。

Commit Instr Trace 更详细一些，你可以看到写使能 wen ，写入的寄存器 dst 和写入的数据 data。

它还会显示在模拟结束时刻，正确的（而不是你的 CPU 的）寄存器值都是多少：

different at pc 这一行指出了你出错的具体指令，你可以在 ready-to-run 文件夹下面找到测试对应的 .S 文件，并根据 pc 找到出错的指令，然后对照波形图 debug。

该部分还输出了仿真运行的周期数 Guest cycle spent: 263，当我们的测试过大时，默认生成的波形图可能不包含你出错的部分，我们可以根据这个周期数截取到出错的波形图（具体指令见下面的生成波形图）

### 生成波形图

查看波形图是我们主要的调试手段，下面介绍如何生成波形图：

需要生成波形图，使用类似 make test-lab1 VOPT="--dump-wave" 的命令来生成波形图，即在原本的测试命令后面加上 VOPT="--dump-wave"。生成的波形图文件在 build 目录下，使用 gtkwave 打开。

默认截取前 10^6个时钟周期。如果需要调整，使用 make test-lab1 VOPT="--dump-wave -b  -e "。

例如：假如某一次出错时提示 Guest cycle spent: 10086000。如果使用默认输出，你会发现波形图是前面的，无法看到错误的地方。你可以使用 make test-lab1 VOPT="--dump-wave -b 10000000 -e 10100000" 来截取出错周期的波形图。

调试信息输出
在开发过程中，合理使用 SystemVerilog 的调试输出功能可以帮助你更好地理解 CPU 的运行状态。推荐使用 $display 和 $monitor 语句来输出调试信息：

```
// 使用 $display 在特定时刻输出信息
$display("Cycle %0d: PC = 0x%h, Instruction = 0x%h", cycle_count, current_pc, current_instruction);

// 使用 $monitor 持续监视信号变化
initial begin
    $monitor("Time %0t: Register x1 = 0x%h, x2 = 0x%h", $time, reg_file[1], reg_file[2]);
end
```

### 常见问题

No rule to make target 'emu'

在代码仓库目录内执行 make init

ERROR: Unexpected CBus request modification.

说明在内存请求时，iresp.data_ok 变为 1 之前修改了 ireq.valid 或者 ireq.addr。我们要求在等待 iresp.data_ok 的过程中，ireq不能变化。

data_ok 变为 1 后的下一个周期，如果 ireq.valid 依然为 1，那么视为发起了一个新的内存请求。

Settle region did not converge.

一般是代码逻辑有问题，使得某个信号的值一直在震荡，无法收敛，例如：

```
assign a = b;
assign b = ~a;
```

请仔细检查报错部分的信号。

各种 Verilator 的报错可以在这里找到解释：[https://verilator.org/guide/latest/warnings.html](https://verilator.org/guide/latest/warnings.html)

### Difftest 连接

保证正确的情况下，传递信号给 difftest 的核心原则只有一个, 在指令提交（即 valid 为 1）的时刻其产生的影响恰好生效（如果寄存器写入比 valid 为 1 的时刻更早，按照下面的讲解，这也是可以接受的，但你必须保证下一条指令的寄存器写入的时刻严格晚于这一条指令 commit 的 valid 为 1 的时刻，这就限制了你一条指令必须要占用至少两个周期。如果你希望处理器的鲁棒性比较强，或者自己考虑不清楚这里的时序关系，请不要使用这种做法）。

为了满足在指令提交的时刻其产生的影响恰好生效的原则, 一些传递给 difftest 的信号需要被延迟一拍或者特殊处理。

实际上，Difftest 内部的代码大概是：

```
always @(posedge clock) begin
    if (DifftestInstrCommit.valid) begin
        // 进行对比
        if (DifftestInstrCommit.pc != ref_cpu.pc || DifftestInstrCommit.wen != ref_cpu.wen || DifftestInstrCommit.wdest != ref_cpu.wdest || DifftestInstrCommit.wdata != ref_cpu.wdata) begin
            $display("different at pc %h", DifftestInstrCommit.pc);
            $finish;
        end
    end
end
```

例子，假如指令 0x80000000 将寄存器 x1 写入了 0x12345678。下一条指令 0x80000004 将寄存器 x1 写入了 0x87654321。我们来看一个正确的做法：

周期  DifftestInstrCommit.valid   DifftestInstrCommit.pc  寄存器 x1 的值   备注
0   0   0x00000000  0x00000000  指令 0x80000000 正在执行，但尚未提交
1   1   0x80000000  0x12345678  指令 0x80000000 提交，写入寄存器 x1
2   1   0x80000004  0x87654321  指令 0x80000004 提交，写入寄存器 x1

发生了什么？

在周期 0->1 的上升沿，我们让寄存器 x1 的值变为 0x12345678，并且在周期 1 的时候将 DifftestInstrCommit.valid 置为 1，pc 置为 0x80000000（其他信号略去）。

这时候 Difftest 不会立刻进行对比。为什么？你看上述代码，当@(posedge clock)时，也就是周期 0->1 的时钟上升沿，if 里面读取到的 DifftestInstrCommit.valid 还是 0（记住，在 posedge 时，读取到的信号时上个周期内的信号），所以不会进行对比。直到周期 1->2 的时钟上升沿，if 内读取到的DifftestInstrCommit.valid 才变为 1，这时候才会进行对比。此时读取到的 DifftestInstrCommit.pc 正好是第 1 周期内的 0x80000000，寄存器 x1 的值读取的也是第 1 周期内的 0x12345678 了，所以对比通过。

这里，“同时发生”就保证了，即使你一个 clock 处理一条指令，仍然是可以保证正确的。

寄存器的连接

寄存器的读取应该是组合逻辑，立即返回；写入应该是时序逻辑，在下一个周期实际写入。 这里就会产生一个问题：如果直接将寄存器数组连接到 Difftest，并在 Writeback 阶段立刻将valid拉高，写入寄存器的内容会在下一个周期才实际写入，Difftest 无法读取到新值。

解决方案有两种：

将valid信号延迟一个周期

在寄存器模块中，定义一个寄存器组的克隆数组，使用组合逻辑对其进行写入，并将这个克隆的寄存器组连接到 Difftest。下面给出一个简单的例子：

```
u64 REG[31:0]; // 主寄存器
u64 next_reg[31:0]; // “下一周期”的寄存器
assign read_data_1 = REG[read_idx_1]; // 读取依然从主寄存器中读取
assign read_data_2 = REG[read_idx_2];

always_comb begin
    for (int i = 0; i < 32; i++) begin
        if (wen && (i[4:0] == write_idx)) begin
            next_reg[i[4:0]] = write_data; // 用组合逻辑向next_reg写入
        end else begin
            next_reg[i[4:0]] = REG[i[4:0]]; // 复制其他没有写入的寄存器
        end
    end
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        for (int i = 0; i < 32; i++) begin
            REG[i[4:0]] <= 64'b0;
        end
    end else begin
        for (int i = 0; i < 32; i++) begin
            REG[i[4:0]] <= next_reg[i[4:0]]; // 用next_reg在下一个周期更新主寄存器
        end
    end
end
```

No instruction commits for 5000 cycles of core 0. Please check the first instruction.

首先检查波形图中 valid 信号是否正常。 如果 valid 正常，请注意向 Difftest 提交的第一条指令必须是 PCINIT，即64'h8000_0000

# Lab2

## Lab2 目标

要求 CPU 支持内存读写。

CPU 需要支持以下指令并通过测试：

```
ld, sd, lb, lh, lw, lbu, lhu, lwu, sb, sh, sw, lui
```

## 内存总线

在 [实验讲解](https://github.com/26-Arch/26-Arch/wiki/实验讲解#内存总线) 中我们简单地介绍了如何使用内存总线*取指*，相当于一个固定的读 4 字节的读内存操作。

实际情况是，在流水线 CPU 中，Fetch 阶段和 Memory 阶段可能会同时发出访存请求，因此我们抽象出了独立的指令访存 `ibus` 和数据访存 `dbus` 接口。你可以了解一下它们是怎么做的，但是如果不想了解也暂时（在做 MMU 之前）没有关系，你只需要知道 `ibus` 是用来取指的，`dbus` 是用来读写数据的，并且它们的接口类似，都是根据 `data_ok` 和 `addr_ok` 信号来判断访存是否完成的。

然而，真实情况是我们并没有独立的“指令内存”和“数据内存”，`ibus` 和 `dbus` 访问的是同一块内存。这就可能会带来内存请求的冲突。为了解决这种冲突，我们使用一个仲裁器（CBusArbiter.sv）来协调 `ibus` 和 `dbus` 对内存的访问。

lab2 中，我们将加入内存读写的相关指令。你需要在 Memory 阶段加入对 `dreq` 和 `dresp` 信号的处理，实现内存的读取和修改。

`dreq` 信号的定义比 `ireq` 复杂一些：


| 字段名称   | 含义                            |
| ------ | ----------------------------- |
| valid  | 是否发出请求                        |
| addr   | 访存地址（起始字节）                    |
| size   | 访存大小（1 字节、2 字节、4 字节、8 字节）     |
| strobe | 字节使能，每一位对应一个字节是否需要写入，读取请保持全 0 |
| data   | 写入的数据                         |


内存在处理 `dreq` 时，会自动忽略 `dreq.addr` 的低 3 位，将其向下对齐到 8 字节。即 `dreq.addr=64'h1F2` 和 `dreq.addr=64'b1F0` 的效果是相同的（但你不应该在给总线的低 3 位设为 0，还是应该尊重指令中原始的地址）。

那么，如何实现向 0x1F2 写入 1 个字节的数据 0xCD 呢？这就需要配合 `data`, `strobe` 和 `size` 字段。

- `addr = 0x1F2`（虽然内存会理解为 0x1F0，但是还是要写 0x1F2）
- `data = 0xCD0000`（由于 addr 减了2， data 也左移2个字节，这样 0xCD 依然在对应的 0x1F2 位置）
- `strobe = 8'b0000_0100`（表示仅 CD 对应的字节有效）
- `size = MSIZE1`（表示访存 1 个字节，不过实际上因为有 strobe 存在，你设置为 MSIZE8 也不影响结果）

如果要读取内存，将 `strobe` 全置 0 即可。

更详细的说明，请参考 common.sv 中的注释

## Lab2 测试

运行 `make test-lab2`，在输出中能看到 HIT GOOD TRAP 即为测试通过

# Lab3

## Lab3 目标

要求 CPU 支持跳转和条件跳转。

CPU 需要支持以下指令并通过测试：

```
`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `slti`, `sltiu`, `slli`, `srli`, `srai`, `sll`, `slt`, `sltu`, `srl`, `sra`, `slliw`, `srliw`, `sraiw`, `sllw`, `srlw`, `sraw` `auipc`, `jalr`, `jal
```

你的 CPU 还需要上板测试。

## Lab3 测试

测试 Lab3 之前，首先要对 `DifftestInstrCommit`（在 core.sv）进行一处修改：

```
     .skip    ((mem & memaddr[31] == 0)),
```

> 原因：我们将“外部设备”（如开发板上的开关、输入输出、时钟）映射到0x0000_0000~0x7FFF_FFFF的内存空间上。Difftest 无法读取到外部设备的状态，因而也就不能模拟这部分内存的数据。因此我们使 Difftest 跳过对外设内存读写指令的判断，认为这条指令执行正确了，并直接从我们的CPU中读取这条指令执行后的状态。

**WARNING** 由于 skip 会完全跳过对这条指令的判断，你必须保证 skip 是正确的（不能一直是 1），否则 Difftest 就完全失去了作用了。

运行 `make test-lab3`，在输出中能看到以下内容和 HIT GOOD TRAP 即为测试通过

你应该能看到有无乘除法状态下你的 CPU 性能的巨大差距。

## 上板

本次 Lab 我们要求上板测试。

如果仿真正常，Vivado仿真/上板不报错但也没输出，考虑：

（1）你有没有改我们提供的代码，尤其是 with_delay 目录下的

（2）你的CPU能否正确处理内存延迟

（3）在 Vivado 中，定义直接用等号是不行的。例如 logic [6:0]  opcode = instr[6:0]; 会导致 opcode 一直为 XX 状态。请改成 logic [6:0] opcode; assign opcode = instr[6:0];

## 自己制作测试

本部分做了也不加分，只是为了后续方便大家自己生成测试和做扩展内容（比如 RV64V、RV64A 等等）。如果你不想做也完全没关系。

自从 Lab 3 的所有功能实现之后，你的 CPU 理论上已经是一个支持 RV64I（+M，如果你实现了乘除法）非特权指令的完整的处理器了。gcc 已经可以编译出可以在你的 CPU 上运行的程序了。你可以自己写一些 C++ 程序来测试你的 CPU 的功能和性能。

请在 [https://github.com/26-Arch/testgen](https://github.com/26-Arch/testgen) 找到空的测试程序模板。确保你的机器上有 riscv64-unknown-elf-g++ 编译器。

编辑 test.cc 文件，编写你自己的测试程序。你可以使用任何 C++ 语言的特性来编写你的测试程序。但不能使用标准库。你需要使用 fudan_arch.h 中提供的函数来进行输入输出。我们提供了：

static inline void memcpy(char *dst, const char *src, unsigned int len);
static inline void putchar(char c);
static inline void puts(const char *s);
template 
static inline void put_i(T x);
static inline unsigned long long uptime_us();
运行 make 以编译测试程序，生成的可执行文件为一个带 extra 的 rv64im 版本和一个不带 extra 的 rv64i 版本的 bin。你可以将它们放到 difftest 运行。记得修改你 cpu 仓库的 Makefile。（仿照 test-lab1 之类的写即可）。

如果你后续实现了更多扩展指令（比如 RV64V、RV64A 等等），你也可以修改 Makefile 让 gcc 生成包含这些扩展指令的测试程序。

# Lab Extra

选做指令： mul, div, divu, rem, remu, mulw, divw, divuw, remw, remuw

如果你要制作选做指令，你需要知道，mul 不能简单地在 SystemVerilog 中使用 * 来实现（同理 div 也不能用 /），因为所有的运算符在综合的时候都会变成组合逻辑，你知道，64 位乘 64 位的结果中，最高的那位会需要通过一个超级长的组合逻辑计算得到（可能有上百个门的路径延迟），这显然在一个周期就要求收敛的话，就必须要把频率降得足够低。

如果降低频率，就会影响其他模块的性能（人家本来高频率下也能工作），降频后它们需要的周期数还是一样的，结果就导致性能下降。

为此，正确的做法是实现一个状态机来分多周期计算乘法和除法的结果。

对于实现了乘除法指令的同学，我们提供了一个含有乘除法的测试版本 make test-lab3-extra

你应该能看到有无乘除法状态下你的 CPU 性能的巨大差距。

# Lab4

## Lab4 目标

CPU 需要支持以下指令并通过测试：

实现指令：`CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`

实现寄存器：`mstatus`, `mtvec`, `mip`, `mie`, `mscratch`, `mcause`, `mtval`, `mepc`, `mcycle`, `mhartid`, `satp`。这些寄存器均为64位宽。

并且需要将这些寄存器对应连接到 `DifftestCSRState`。在 `DifftestCSRState` 中没有的寄存器不需要连接。

- `mcycle` 保存了 CPU 已经运行的时钟周期数，因此你应该将其设置为每周期加一。如果溢出，直接从 0 重新开始；如果写入，用写入的值覆盖。
- `mhartid` 保存了当前CPU核心的编号。我们目前只有一个核心，因此一直设为 0 即可。`mhartid` 不需要考虑写入。实现好后，请你将 `core.sv` 中 `DifftestInstrCommit`、`DifftestArchIntRegState`、`DifftestTrapEvent` 和 `DifftestCSRState` 的 `coreid` 都连接为 `mhartid[7:0]`。

各个 CSR 寄存器的含义可以在英文指令集手册中找到。你也可以参考 `vsrc/include/csr.sv`，其中包含各个 CSR 寄存器的编号。

> **bonus**：参考英文指令集手册，简述一下此次 lab 中各个 csr 寄存器的作用

> **bonus**：实现 `csr.sv` 给定的所有寄存器，包括那些以 `s` 开头的寄存器（如 `stvec` 等等）。

CSR 寄存器是为特权架构服务的，但本次实验只需要支持这些寄存器以及向他们的读写指令即可。

简单来说，我们的 CPU 之前以及这次 Lab 是一直运行在 M 模式（机器模式），可以忠实地执行每一条指令，且没有办法干预 CPU 的运行。通过 CSR 寄存器，我们允许 CPU 进入不同的状态，支持中断和异常处理（比如取指取到了一条不能运行的指令）。

由于本次 lab 还没有实现 `mret` 和 `ecall` 指令，因此我们这个 lab 不会切换 CPU 的状态（CPU 仍然一直在 M 模式），也不会真正地触发中断和异常。但是你需要正确地实现这些寄存器的读写指令，并且将它们连接到 Difftest 中对应的状态上。

### CSR Mask

CSR 寄存器与普通寄存器的一大区别在于，一些 CSR 寄存器并不是每一位都可写的。

例如，`mip` 寄存器有 64 位宽，但是在我们的实验设定下，只有 [0][1][4][5][8][9] 这 6 位允许读写，其它位禁止写入，读取时恒为 0。

我们在 `vsrc/include/csr.sv` 中提供了一些 mask，表示对应寄存器允许写入的位。如果没提供 mask，就说明这个寄存器每一位都能写入。可以这样使用这些 mask：

```
unique case (csr_op)
      WRITE: begin
        unique case (csr_id)
          CSR_MIE: regs.mie = csr_write_data;
          CSR_MIP: regs.mip = csr_write_data & MIP_MASK;
          ......
```

### sstatus

`sstatus` 寄存器是 `mstatus` 寄存器中的某些位抽象出来的一个新寄存器。但是在物理上它并不需要单独保存，而是与mstatus绑定在一起。在DifftestCSRState中，按照提示将sstatus连接为mstatus & SSTATUS_MASK即可。

> The `sstatus` register is a subset of the `mstatus` register. In a straightforward implementation, reading or writing any field in `sstatus` is equivalent to reading or writing the homonymous field in `mstatus`.

### 流水线&转发

很多同学使用了转发来解决数据冒险的问题。

csr 作为寄存器，也会有数据冲突。但是，csr 不应该转发。csr 的每次改变，都应刷新流水线（普通的写入后，则刷新流水线，从 `pc + 4` 开始继续执行）

> hint：对于大多数静态分支预测的同学，你可以认为 csr 指令同时是一个“跳转到 pc+4”的跳转指令，并永远分支预测失败，这样可以复用你跳转指令的气泡/冲刷逻辑。

> bonus：思考为什么一定要刷新流水线？

# Lab5

> 以下 KB、MB、GB 指的均是 1024 进位的 KiB、MiB、GiB。

CPU 需要支持以下指令并通过测试：

实现指令：`MRET`, `ECALL`

> **WARNING**：请先考虑 Lab 6 的中断和异常处理，你的 ECALL 设计当前就应该合并考虑后续的异常处理流程。

实现 MMU，支持 Sv39 页表

## 特权级别切换

你的 CPU 现在应该有一个寄存器用来记录当前 CPU 的特权级别，并连接到 difftest。请注意你的 CPU 的特权级别应当按照 [规范](https://riscv.github.io/riscv-isa-manual/snapshot/spec/#_privilege_levels) 编码。在本次实验中我们只会涉及到 U 和 M 模式。S 模式为 bonus。

你的 CPU 在刚刚上电时应该处于 M 模式。

### 特权级别降低

我们的 CPU 需要从 M 模式进入 U 模式以让用户程序运行。一般而言，这通过 `mret` 完成。表示当前模式为 `m` 时的返回。你需要注意 `mret` **可以但不是一定**导致 CPU 要从 M 模式进入 U 模式。

`mret` 的具体描述请参考 [手册](https://riscv.github.io/riscv-isa-manual/snapshot/spec/#otherpriv) 3.3.2。以及 [手册](https://riscv.github.io/riscv-isa-manual/snapshot/spec/#privstack) 3.1.6.1。

> An MRET or SRET instruction is used to return from a trap in M-mode or S-mode respectively. When executing an xRET instruction, supposing xPP holds the value y, xIE is set to xPIE; the privilege mode is changed to y; xPIE is set to 1; and xPP is set to the least-privileged supported mode (U if U-mode is implemented, else M). If y≠M, xRET also sets MPRV=0.

> 你可能会感到有些困惑，为什么一个“返回”含义的命令用来提供特权级别降低的功能？答案是这与中断和异常处理有关。我们先不考虑开机的时候，我们就考虑 CPU 已经在用户模式运行了，这个时候它接收到一个中断。计算机为了处理这个中断而提升了特权级别。中断处理好后，中断处理程序（一般是操作系统）要*返回*用户程序继续运行。这就是“返回”的来历。

也就是一般而言，当处理 `mret` 你的 CPU 至少需要干如下几件事：

- 跳转到 `MEPC`，冲刷流水线。
- 特权级别设置为 `MPP` 中的值。
- 设置 CSR：`MPIE` 设置为 1，`MIE` 设置为原来的 `MPIE`，`MPP` 设置为 0。

### 特权级别升高

特权级别升高由中断、异常引起。本次实验中的 `ECALL` 相当于手动引发一个异常。

当处理异常的时候，你应该：

- 跳转到 `MTVEC`，冲刷流水线
- 特权级别设置为 M
- 保存当前 PC 到 `MEPC`
- 设置 CSR：`MCAUSE` 参考 [表格](https://riscv.github.io/riscv-isa-manual/snapshot/spec/#norm:mcause_exccode_enc_img) ，我们这里是 8 或 11。
- 设置 CSR：`MPIE` 设置为原来的 `MIE`，`MIE` 设置为 0。`MPP` 设置为当前（执行之前）的特权级别。

## MMU

MMU（Memory Management Unit，内存管理单元）是一种硬件模块，用于在CPU和内存之间实现虚拟内存管理。其主要功能是将虚拟地址转换为物理地址

### satp 寄存器

satp(Supervisor Address Translation and Protection) 寄存器是 RISC-V 指令集中的特权寄存器，专门用于控制内存分页。其具体布局如下：

```
typedef struct packed {
    u4 mode;  // [63:60]
    u16 asid; // [59:44]
    u44 ppn; //  [43:0]
} satp_t;
satp_t satp;
```

```
63       60 59                  44 43                                0
---------------------------------------------------------------------
|   MODE   |         ASID         |                PPN               |
---------------------------------------------------------------------
```

- PPN ：保存根物理页号，实际值为「根页表物理地址右移 12 位」。
- ASID ：暂时不用管，全置零即可。
- MODE ：用于选择分页模式，本次实验仅会为 8 或 0。

当处于 M mode时，不启用 mmu，当 satp 中的 mode 为 0 时，也不应该启用 mmu。

**也就是在本次实验只有当处于 S/U mode 且 satp 中的 mode 为 8 时，你才应该使用地址翻译。**

```
 ----------------------------------------------------------
|  Value  |  Name  |  Description                          |
|----------------------------------------------------------|
|    0    | Bare   | No translation or protection          |
|  1 - 7  | ---    | Reserved for standard use             |
|    8    | Sv39   | Page-based 39 bit virtual addressing  | <-- 我们使用的mode
|    9    | Sv48   | Page-based 48 bit virtual addressing  |
|    10   | Sv57   | Page-based 57 bit virtual addressing  |
|    11   | Sv64   | Page-based 64 bit virtual addressing  |
| 12 - 13 | ---    | Reserved for standard use             |
| 14 - 15 | ---    | Reserved for standard use             |
 -----------------------------------------------------------
```

### 读取的流程

你可能需要写一个状态机![mmu](https://github.com/26-Arch/26-Arch/wiki/Labs/mmu.jpg)

- 第一级页表的基地址是`{satp.ppn, 12'b0}`，其他级页表的基地址是根据页表项中的页号（PPN）得到的`{data[53:10], 12'b0}`
- 需要取页表中的项，根据虚拟地址的[38:30], [29:21], [20:12]位为索引。所以所需页表项的物理地址就是：页表基地址[索引] = 页表基地址 + 索引 * 8
- 最终翻译到的物理地址是最后一级页表项的页号，与虚拟地址中的偏移量位拼接：{data[53:10], vaddr[11:0]}

> bonus: 理论上 Sv39 页表的规定是“最多三级”而非固定三级，我们目前要求大家 MMU 写成固定访问三级页表即可。但实际上，规范中允许第二级页表就是叶子页表（直接映射 2MB 的页）。规范对于 MMU 的实际要求是**强制要求CPU支持第二级、甚至第一级页表就是叶子的情况**。如果你想挑战一下，可以试着实现一下这个功能。在这种状态下，L0 不再应该被当做在第三级页表的偏移，而是与 offset 一起被当做最后放在物理地址的偏移。
>
> 具体请查看 Sv39 规范中每个页表项的 flags 的定义。
>
> 在 Linux 中，这种内存页被称为**巨页（Hugepages）**，在 Windows 中，这种内存页被称为**Large-Page**。在 macOS ……没有这种东西。但 Apple Silicon 使用 16KiB 页。

### MMU 的实现

需要注意的是，你 fetch 和 memory 模块连接的内存总线**都需要经过 MMU 翻译**。由于 **MMU 需要访问完整的 64 位页表项，所以你不要用 ibus 来进行地址翻译**。而我们实际上的内存总线只有一条，所以我们只应该做一个 MMU 来统一地翻译指令和数据的内存地址。

实际上现在的总线是这样走的：

```
ibus -> i_cbus -> | CBus    | -> CBus -> 内存
dbus -> d_cbus -> | Arbiter |
```

对于大家大多数人目前 fetch 使用 ibus，memory 使用 dbus 的做法，我们有以下两种改造方式：

#### 方式 1

```
ibus (deprecated)  --------------------------------------------------> | CBus    | -> CBus -> 内存
your_dbus_to_fetch -> | Your DBus    | -> dbus -> | MMU | -> d_cbus -> | Arbiter | 
your_dbus_to_mem   -> | Arbiter      |
```

弃用 ibus。你需要自己写一个 Arbiter，将现有的 1 条 dbus 分成 2 个，供 fetch 和 memory 使用。你的 Arbiter 设计可以参考我们提供的 `CBusArbiter.sv` 并将你的 MMU 写在原来的那一条 dbus 上。

#### 方式 2

```
ibus -> i_cbus -> | CBus    | -> CBus -> | MMU | -> 内存
dbus -> d_cbus -> | Arbiter |
```

在我们已经经过仲裁器之后那一条 CBus 上做 MMU。

这一方法的问题是：MMU 需要知晓当前的 CPU 特权级别、SATP 寄存器的值。而由于我们当前的模块层级是：

```
         |---------------|
         | SimTop / VTop |
         |---------------|
           |           |
       |------| |-------------|
       | Core | | CBusArbiter |
       |------| |-------------|
```

因此你必须得把这俩信号从 SimTop / VTop 绕一下。

## Lab5 测试

运行 `make test-lab5`，出现`Return from init! Test passed`输出

(最后卡住是正常现象)

# Lab6

支持中断与异常。

需要支持：时钟中断、外部中断、异常（ECALL、非法指令、页错误等）。



参考代码片段：
`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

import common::*;
import csr_pkg::*;

// 前向控制信号
typedef struct packed {
    logic [1:0] forward_a;
    logic [1:0] forward_b;
} forward_ctrl_t;

// 流水线寄存器定义
typedef struct packed {
    logic valid;
    u64 pc;
    u32 instr;
} REG_IF_ID;

typedef struct packed {
    logic valid;
    u64 pc;
    u32 instr;
    u64 rs1_data;
    u64 rs2_data;
    u64 imm;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [6:0] opcode;
    logic is_load;
    logic is_store;
    logic is_branch;
    logic is_jump;
    logic is_alu;
    logic is_aluimm;
    logic is_lui;
    logic is_auipc;
    logic is_system;
    logic is_csr;
    logic [4:0] alu_op;
    logic alu_src;
    logic mem_write;
    logic mem_read;
    logic reg_write;
    logic [1:0] mem_to_reg;
} REG_ID_EX;

typedef struct packed {
    logic valid;
    u64 pc;
    u32 instr;
    u64 alu_result;
    u64 rs2_data;
    u64 imm;
    logic [4:0] rd;
    logic is_load;
    logic is_store;
    logic mem_write;
    logic mem_read;
    logic reg_write;
    logic [1:0] mem_to_reg;
    // Lab4: CSR 写推迟到 WB（与 NEMU 提交顺序一致）
    logic csr_pending;
    u12 csr_paddr;
    word_t csr_pwdata;
    // Lab5: trap CSR 推迟到 WB；EX 仍负责 flush/redirect
    logic trap_pending;
    logic trap_is_mret;
    u2    trap_priv;
} REG_EX_MEM;

typedef struct packed {
    logic valid;
    u64 pc;
    u32 instr;
    u64 alu_result;
    u64 mem_data;
    logic [4:0] rd;
    logic reg_write;
    logic [1:0] mem_to_reg;
    // Lab4: 同上，WB 阶段提交 CSR 写
    logic csr_pending;
    u12 csr_paddr;
    word_t csr_pwdata;
    logic trap_pending;
    logic trap_is_mret;
    u2    trap_priv;
} REG_MEM_WB;

// 包含各个模块
`ifdef VERILATOR
`include "src/csr_regfile.sv"
`include "util/mmu.sv"
`include "src/fetch.sv"
`include "src/decode.sv"
`include "src/execute.sv"
`include "src/memory.sv"
`include "src/writeback.sv"
`include "src/regfile.sv"
`include "src/forward_unit.sv"
`endif 

`ifdef VIVADO
`include "csr_regfile.sv"
`include "fetch.sv"
`include "decode.sv"
`include "execute.sv"
`include "memory.sv"
`include "writeback.sv"
`include "regfile.sv"
`include "forward_unit.sv"
`endif 

module core import common::*;( 
    input  logic       clk, reset, 
    output ibus_req_t  ireq, 
    input  ibus_resp_t iresp, 
    output dbus_req_t  dreq, 
    input  dbus_resp_t dresp, 
    input  logic       trint, swint, exint,
    // Lab5: MMU in SimTop/VTop
    output u2          priv_mode_out,
    output word_t      satp_out
);
    assign priv_mode_out = priv_mode;

    always_ff @(posedge clk) begin
        if (reset)
            priv_mode_difftest <= 2'b11;
        else
            priv_mode_difftest <= priv_mode_q;
    end
    assign satp_out      = csr_satp_mmu;

    word_t mem_forward_data;
    word_t csr_rdata;
    word_t csr_mstatus, csr_mtvec_trap, csr_mtvec_dbg, csr_mip, csr_mie, csr_mscratch;
    word_t csr_mcause, csr_mtval, csr_mepc_trap, csr_mepc_dbg, csr_mcycle, csr_mhartid;
    word_t csr_satp_mmu, csr_satp_dbg;
    word_t csr_mstatus_q_unused, csr_mcause_q_unused, csr_mepc_q_unused, csr_satp_q_unused;
    u2     priv_mode;
    u2     priv_mode_q;
    u2     priv_mode_difftest;
    logic  trap_fire;
    logic  trap_is_mret;
    u12    trap_ecall_imm;
    u64    trap_pc;
    logic  trap_csr_commit;

    // 流水线阶段信号
    logic fetch_ok, decode_ok, execute_ok, mem_ok, writeback_ok;
    logic step;
    logic redirect_valid;
    u64 redirect_pc;
    logic difftest_skip;
    
    // 流水线寄存器
    REG_IF_ID if_id_reg;
    REG_ID_EX id_ex_reg;
    REG_EX_MEM ex_mem_reg;
    REG_MEM_WB mem_wb_reg;
    
    // 前向控制信号
    forward_ctrl_t forward_ctrl;
    
    // 寄存器堆信号
    logic reg_wen;
    u5 reg_waddr;
    word_t reg_wdata;
    word_t reg_rdata1, reg_rdata2;
    
    // Difftest信号
    logic commit_valid;
    u64 commit_pc;
    u32 commit_instr;
    logic commit_wen;
    u5 commit_wdest;
    word_t commit_wdata;
    
    // Lab4: csr_we 与 regfile 写回同属 WB；dbg_* 为组合次态（Difftest posedge 对齐 NEMU）
    csr_regfile csr_regfile_inst(
        .clk(clk),
        .reset(reset),
        .csr_we(step & mem_wb_reg.valid & mem_wb_reg.csr_pending),
        .csr_waddr(mem_wb_reg.csr_paddr),
        .csr_wdata(mem_wb_reg.csr_pwdata),
        .csr_raddr(id_ex_reg.imm[11:0]),
        .csr_rdata(csr_rdata),
        .trap_fire_ex(trap_fire),
        .trap_csr_commit(trap_csr_commit),
        .trap_is_mret_ex(trap_is_mret),
        .trap_is_mret_wb(mem_wb_reg.trap_is_mret),
        .trap_priv_wb(mem_wb_reg.trap_priv),
        .trap_pc(trap_pc),
        .trap_ecall_imm(trap_ecall_imm),
        .priv_mode(priv_mode),
        .priv_mode_q_out(priv_mode_q),
        .mtvec_o(csr_mtvec_trap),
        .mepc_o(csr_mepc_trap),
        .satp_o(csr_satp_mmu),
        .dbg_mstatus(csr_mstatus),
        .dbg_mtvec(csr_mtvec_dbg),
        .dbg_mip(csr_mip),
        .dbg_mie(csr_mie),
        .dbg_mscratch(csr_mscratch),
        .dbg_mcause(csr_mcause),
        .dbg_mtval(csr_mtval),
        .dbg_mepc(csr_mepc_dbg),
        .dbg_mcycle(csr_mcycle),
        .dbg_mhartid(csr_mhartid),
        .dbg_satp(csr_satp_dbg),
        .mstatus_q_out(csr_mstatus_q_unused),
        .mcause_q_out(csr_mcause_q_unused),
        .mepc_q_out(csr_mepc_q_unused),
        .satp_q_out(csr_satp_q_unused)
    );

    // 连接各个模块
    fetch fetch_module(
        .clk(clk),
        .reset(reset),
        .step(step),
        .fetch_ok(fetch_ok),
        .ireq(ireq),
        .iresp(iresp),
        .redirect_valid(redirect_valid),
        .redirect_pc(redirect_pc),
        .trap_fire(trap_fire),
        .if_id_reg(if_id_reg)
    );
    
    decode decode_module(
        .clk(clk),
        .reset(reset),
        .step(step),
        .decode_ok(decode_ok),
        .if_id_reg(if_id_reg),
        .reg_rdata1(reg_rdata1),
        .reg_rdata2(reg_rdata2),
        .flush(redirect_valid | trap_fire),
        .id_ex_reg(id_ex_reg)
    );
    
    execute execute_module(
        .clk(clk),
        .reset(reset),
        .step(step),
        .execute_ok(execute_ok),
        .id_ex_reg(id_ex_reg),
        .forward_ctrl(forward_ctrl),
        .wb_data(reg_wdata), 
        .mem_forward_data(mem_forward_data), // <-- 连入
        .csr_rdata(csr_rdata),
        .csr_mtvec(csr_mtvec_trap),
        .csr_mepc(csr_mepc_trap),
        .priv_mode_q(priv_mode_q),
        .redirect_valid(redirect_valid),
        .redirect_pc(redirect_pc),
        .trap_fire(trap_fire),
        .trap_is_mret(trap_is_mret),
        .trap_ecall_imm(trap_ecall_imm),
        .ex_mem_reg(ex_mem_reg)
    );
    
    memory memory_module(
        .clk(clk),
        .reset(reset),
        .step(step),
        .mem_ok(mem_ok),
        .ex_mem_reg(ex_mem_reg),
        .flush(trap_fire),
        .dreq(dreq),
        .dresp(dresp),
        .mem_wb_reg(mem_wb_reg),
        .mem_forward_data(mem_forward_data) // <-- 引出
    );
    
    forward_unit forward_unit_module(
        .id_ex_rs1(id_ex_reg.rs1),
        .id_ex_rs2(id_ex_reg.rs2),
        .ex_mem_rd(ex_mem_reg.rd),
        .ex_mem_reg_write(ex_mem_reg.reg_write & ex_mem_reg.valid),
        .mem_wb_rd(mem_wb_reg.rd),
        .mem_wb_reg_write(mem_wb_reg.reg_write & mem_wb_reg.valid),
        .forward_ctrl(forward_ctrl)
    );
    
    writeback writeback_module(
        .clk(clk),
        .reset(reset),
        .step(step),
        .block_commit(trap_csr_commit & ~mem_wb_reg.trap_is_mret),
        .writeback_ok(writeback_ok),
        .mem_wb_reg(mem_wb_reg),
        .reg_wen(reg_wen),
        .reg_waddr(reg_waddr),
        .reg_wdata(reg_wdata),
        .commit_valid(commit_valid),
        .commit_pc(commit_pc),
        .commit_instr(commit_instr),
        .commit_wen(commit_wen),
        .commit_wdest(commit_wdest),
        .commit_wdata(commit_wdata)
    );
    
    regfile regfile_module(
        .clk(clk),
        .reset(reset),
        .raddr1(if_id_reg.instr[19:15]),
        .raddr2(if_id_reg.instr[24:20]),
        .wen(reg_wen),
        .waddr(reg_waddr),
        .wdata(reg_wdata),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2)
    );
    
    // 计算step信号
    assign step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok;

    assign difftest_skip = commit_valid
                        && ((commit_instr[6:0] == 7'b0000011) || (commit_instr[6:0] == 7'b0100011))
                        && (mem_wb_reg.alu_result[31] == 1'b0);

`ifdef VERILATOR
    DifftestInstrCommit DifftestInstrCommit(
        .clock              (clk),
        .coreid             (csr_mhartid[7:0]),
        .index              (0),
        .valid              (commit_valid),
        .pc                 (commit_pc),
        .instr              (commit_instr),
        .skip               (difftest_skip),
        .isRVC              (0),
        .scFailed           (0),
        .wen                (commit_wen),
        .wdest              ({3'b0, commit_wdest}),
        .wdata              (commit_wdata)
    );

    DifftestArchIntRegState DifftestArchIntRegState (
        .clock              (clk),
        .coreid             (csr_mhartid[7:0]),
        .gpr_0              (regfile_module.next_reg[0]),
        .gpr_1              (regfile_module.next_reg[1]),
        .gpr_2              (regfile_module.next_reg[2]),
        .gpr_3              (regfile_module.next_reg[3]),
        .gpr_4              (regfile_module.next_reg[4]),
        .gpr_5              (regfile_module.next_reg[5]),
        .gpr_6              (regfile_module.next_reg[6]),
        .gpr_7              (regfile_module.next_reg[7]),
        .gpr_8              (regfile_module.next_reg[8]),
        .gpr_9              (regfile_module.next_reg[9]),
        .gpr_10             (regfile_module.next_reg[10]),
        .gpr_11             (regfile_module.next_reg[11]),
        .gpr_12             (regfile_module.next_reg[12]),
        .gpr_13             (regfile_module.next_reg[13]),
        .gpr_14             (regfile_module.next_reg[14]),
        .gpr_15             (regfile_module.next_reg[15]),
        .gpr_16             (regfile_module.next_reg[16]),
        .gpr_17             (regfile_module.next_reg[17]),
        .gpr_18             (regfile_module.next_reg[18]),
        .gpr_19             (regfile_module.next_reg[19]),
        .gpr_20             (regfile_module.next_reg[20]),
        .gpr_21             (regfile_module.next_reg[21]),
        .gpr_22             (regfile_module.next_reg[22]),
        .gpr_23             (regfile_module.next_reg[23]),
        .gpr_24             (regfile_module.next_reg[24]),
        .gpr_25             (regfile_module.next_reg[25]),
        .gpr_26             (regfile_module.next_reg[26]),
        .gpr_27             (regfile_module.next_reg[27]),
        .gpr_28             (regfile_module.next_reg[28]),
        .gpr_29             (regfile_module.next_reg[29]),
        .gpr_30             (regfile_module.next_reg[30]),
        .gpr_31             (regfile_module.next_reg[31])
    );

    logic [31:0] difftest_exc_cause;
    assign trap_csr_commit = step & mem_wb_reg.valid & mem_wb_reg.trap_pending;
    assign trap_pc         = mem_wb_reg.pc;

    assign difftest_exc_cause = (trap_csr_commit && !mem_wb_reg.trap_is_mret)
        ? ((mem_wb_reg.trap_priv == 2'b00) ? 32'd8
           : (mem_wb_reg.trap_priv == 2'b01) ? 32'd9 : 32'd11)
        : 32'b0;

    DifftestArchEvent DifftestArchEvent(
        .clock              (clk),
        .coreid             (csr_mhartid[7:0]),
        .intrNO             (32'b0),
        .cause              (difftest_exc_cause),
        .exceptionPC        (trap_pc)
    );

    DifftestTrapEvent DifftestTrapEvent(
        .clock              (clk),
        .coreid             (csr_mhartid[7:0]),
        // 将停机指令匹配修改为测试框架自定义的 0x0005006b
        .valid              (commit_valid && (commit_instr == 32'h0005006b)), 
        // 测试程序会在停机前把退出码放到 x10(a0) 寄存器中，0 表示成功
        .code               (regfile_module.next_reg[10][2:0]),
        .pc                 (commit_pc),
        .cycleCnt           (0),
        .instrCnt           (0)
    );

    DifftestCSRState DifftestCSRState(
        .clock              (clk),
        .coreid             (csr_mhartid[7:0]),
        .priviledgeMode     (priv_mode_difftest),
        .mstatus            (csr_mstatus),
        .sstatus            (csr_mstatus & SSTATUS_MASK),
        .mepc               (csr_mepc_dbg),
        .sepc               (64'b0),
        .mtval              (csr_mtval),
        .stval              (64'b0),
        .mtvec              (csr_mtvec_dbg),
        .stvec              (64'b0),
        .mcause             (csr_mcause),
        .scause             (64'b0),
        .satp               (csr_satp_dbg),
        .mip                (csr_mip),
        .mie                (csr_mie),
        .mscratch           (csr_mscratch),
        .sscratch           (64'b0),
        .mideleg            (64'b0),
        .medeleg            (64'b0)
    );
`endif
endmodule

`endif





`ifndef __CSR_REGFILE_SV
`define __CSR_REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`else
`include "common.sv"
`include "csr.sv"
`endif

import common::*;
import csr_pkg::*;

// Lab4：CSR 寄存器与读写（mhartid 只读；mcycle 每周期自增，写覆盖）
// dbg_* 为组合下一拍状态，供 Difftest 在 posedge 采样（与 NEMU 提交后一致）
module csr_regfile import common::*; import csr_pkg::*; (
    input  logic       clk,
    input  logic       reset,
    input  logic       csr_we,
    input  u12         csr_waddr,
    input  word_t      csr_wdata,
    input  u12         csr_raddr,
    output word_t      csr_rdata,
    // Lab5: EX 侧 flush/redirect 用 trap_fire_ex；CSR 陷阱在 WB 提交
    input  logic       trap_fire_ex,
    input  logic       trap_csr_commit,
    input  logic       trap_is_mret_ex,
    input  logic       trap_is_mret_wb,
    input  u2          trap_priv_wb,
    input  u64         trap_pc,
    input  u12         trap_ecall_imm,
    output u2          priv_mode,
    output u2          priv_mode_q_out,
    output word_t      mtvec_o,
    output word_t      mepc_o,
    output word_t      satp_o,
    output word_t      dbg_mstatus,
    output word_t      dbg_mtvec,
    output word_t      dbg_mip,
    output word_t      dbg_mie,
    output word_t      dbg_mscratch,
    output word_t      dbg_mcause,
    output word_t      dbg_mtval,
    output word_t      dbg_mepc,
    output word_t      dbg_mcycle,
    output word_t      dbg_mhartid,
    output word_t      dbg_satp,
    output word_t      mstatus_q_out,
    output word_t      mcause_q_out,
    output word_t      mepc_q_out,
    output word_t      satp_q_out
);
    word_t mstatus_q, mtvec_q, mip_q, mie_q, mscratch_q, mcause_q, mtval_q, mepc_q, mcycle_q, satp_q;
    u2     priv_mode_q;

    word_t mstatus_d, mtvec_d, mip_d, mie_d, mscratch_d, mcause_d, mtval_d, mepc_d, mcycle_d, satp_d;
    u2     priv_mode_d;

    // MMU: ecall/mret 在 EX 周期切换特权级；其余 trap CSR 在 WB 提交
    assign priv_mode        = priv_mode_d;
    assign priv_mode_q_out  = priv_mode_q;
    assign mtvec_o   = mtvec_q;
    assign mepc_o    = mepc_q;
    assign satp_o    = satp_q;

    // dbg_* = *_d: Lab4 CSR write commit timing; trap updates visible same cycle in EX
    assign dbg_mstatus  = mstatus_d;
    assign dbg_mtvec    = mtvec_d;
    assign dbg_mip      = mip_d;
    assign dbg_mie      = mie_d;
    assign dbg_mscratch = mscratch_d;
    assign dbg_mcause   = mcause_d;
    assign dbg_mtval    = mtval_d;
    assign dbg_mepc     = mepc_d;
    assign dbg_mcycle   = mcycle_d;
    assign dbg_mhartid  = 64'd0;
    assign dbg_satp     = satp_d;
    assign mstatus_q_out = mstatus_q;
    assign mcause_q_out  = mcause_q;
    assign mepc_q_out    = mepc_q;
    assign satp_q_out    = satp_q;

    function automatic word_t apply_wmask(word_t wdata, word_t oldv, word_t wmask);
        return (wdata & wmask) | (oldv & ~wmask);
    endfunction

    always_comb begin
        csr_rdata = 64'b0;
        unique case (csr_raddr)
            CSR_MSTATUS:  csr_rdata = mstatus_q;
            CSR_MTVEC:    csr_rdata = mtvec_q;
            CSR_MIP:      csr_rdata = mip_q;
            CSR_MIE:      csr_rdata = mie_q;
            CSR_MSCRATCH: csr_rdata = mscratch_q;
            CSR_MCAUSE:   csr_rdata = mcause_q;
            CSR_MTVAL:    csr_rdata = mtval_q;
            CSR_MEPC:     csr_rdata = mepc_q;
            CSR_MCYCLE:   csr_rdata = mcycle_q;
            CSR_MHARTID:  csr_rdata = 64'd0;
            CSR_SATP:     csr_rdata = satp_q;
            default:      csr_rdata = 64'b0;
        endcase
    end

    always_comb begin
        mstatus_t ms;

        mstatus_d  = mstatus_q;
        mtvec_d    = mtvec_q;
        mip_d      = mip_q;
        mie_d      = mie_q;
        mscratch_d = mscratch_q;
        mcause_d   = mcause_q;
        mtval_d    = mtval_q;
        mepc_d     = mepc_q;
        satp_d     = satp_q;
        mcycle_d   = mcycle_q;
        priv_mode_d = priv_mode_q;

        if (reset) begin
            mstatus_d   = 64'b0;
            mtvec_d     = 64'b0;
            mip_d       = 64'b0;
            mie_d       = 64'b0;
            mscratch_d  = 64'b0;
            mcause_d    = 64'b0;
            mtval_d     = 64'b0;
            mepc_d      = 64'b0;
            mcycle_d    = 64'b0;
            satp_d      = 64'b0;
            priv_mode_d = 2'b11;
        end else begin
            if (trap_fire_ex) begin
                if (trap_is_mret_ex)
                    priv_mode_d = mstatus_q[12:11];
                else
                    priv_mode_d = 2'b11;
            end
            if (trap_csr_commit) begin
                if (trap_is_mret_wb) begin
                    priv_mode_d = mstatus_q[12:11];
                    mstatus_d   = mstatus_q;
                    mstatus_d[3]  = mstatus_q[7];
                    mstatus_d[7]  = 1'b1;
                    mstatus_d[12:11] = 2'b00;
                    mcause_d    = 64'b0;
                end else begin
                    mepc_d      = trap_pc;
                    priv_mode_d = 2'b11;
                    mstatus_d   = mstatus_q;
                    mstatus_d[12:11] = trap_priv_wb;
                    mstatus_d[7]     = mstatus_q[3];
                    mstatus_d[3]     = 1'b0;
                    if (trap_priv_wb == 2'b00)
                        mcause_d = 64'd8;
                    else if (trap_priv_wb == 2'b01)
                        mcause_d = 64'd9;
                    else
                        mcause_d = 64'd11;
                end
            end

            if (csr_we && csr_waddr == CSR_MCYCLE)
                mcycle_d = csr_wdata;
            else
                mcycle_d = mcycle_q + 64'd1;

            if (csr_we && (csr_waddr != CSR_MHARTID) && (csr_waddr != CSR_MCYCLE)) begin
                unique case (csr_waddr)
                    CSR_MSTATUS:  mstatus_d  = apply_wmask(csr_wdata, mstatus_q, MSTATUS_MASK);
                    CSR_MTVEC:    mtvec_d    = apply_wmask(csr_wdata, mtvec_q, MTVEC_MASK);
                    CSR_MIP:      mip_d      = apply_wmask(csr_wdata, mip_q, MIP_MASK);
                    CSR_MIE:      mie_d      = csr_wdata;
                    CSR_MSCRATCH: mscratch_d = csr_wdata;
                    CSR_MCAUSE:   mcause_d   = csr_wdata;
                    CSR_MTVAL:    mtval_d    = csr_wdata;
                    CSR_MEPC:     mepc_d     = csr_wdata;
                    CSR_SATP:     satp_d     = csr_wdata;
                    default:      ;
                endcase
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            mstatus_q   <= 64'b0;
            mtvec_q     <= 64'b0;
            mip_q       <= 64'b0;
            mie_q       <= 64'b0;
            mscratch_q  <= 64'b0;
            mcause_q    <= 64'b0;
            mtval_q     <= 64'b0;
            mepc_q      <= 64'b0;
            mcycle_q    <= 64'b0;
            satp_q      <= 64'b0;
            priv_mode_q <= 2'b11;
        end else begin
            mstatus_q   <= mstatus_d;
            mtvec_q     <= mtvec_d;
            mip_q       <= mip_d;
            mie_q       <= mie_d;
            mscratch_q  <= mscratch_d;
            mcause_q    <= mcause_d;
            mtval_q     <= mtval_d;
            mepc_q      <= mepc_d;
            mcycle_q    <= mcycle_d;
            satp_q      <= satp_d;
            priv_mode_q <= priv_mode_d;
        end
    end
endmodule

`endif







`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module decode import common::*;( 
    input  logic       clk, reset, 
    input  logic       step, 
    output logic       decode_ok, 
    input  REG_IF_ID   if_id_reg, 
    input  word_t      reg_rdata1, reg_rdata2, 
    input  logic       flush,
    output REG_ID_EX   id_ex_reg 
);
    // 指令字段
    u7 opcode;
    u5 rd;
    u3 funct3;
    u5 rs1;
    u5 rs2;
    u7 funct7;
    u12 imm_i;
    u12 imm_s;
    u20 imm_u;
    u13 imm_b;
    logic [20:0] imm_j;
    
    // 控制信号
    logic [4:0] alu_op;
    logic alu_src;
    logic reg_write;
    logic mem_write;
    logic mem_read;
    logic [1:0] mem_to_reg;
    word_t imm;
    logic is_load;
    logic is_store;
    logic is_branch;
    logic is_jump;
    logic is_alu;
    logic is_aluimm;
    logic is_lui;
    logic is_auipc;
    logic is_system;
    logic is_csr;
    
    // 初始化信号在reset时处理
    
    // 指令解码
    always_comb begin
        opcode = if_id_reg.instr[6:0];
        rd = if_id_reg.instr[11:7];
        funct3 = if_id_reg.instr[14:12];
        rs1 = if_id_reg.instr[19:15];
        rs2 = if_id_reg.instr[24:20];
        funct7 = if_id_reg.instr[31:25];
        imm_i = if_id_reg.instr[31:20];
        imm_s = {if_id_reg.instr[31:25], if_id_reg.instr[11:7]};
        imm_u = if_id_reg.instr[31:12];
        imm_b = {if_id_reg.instr[31], if_id_reg.instr[7], if_id_reg.instr[30:25], if_id_reg.instr[11:8], 1'b0};
        imm_j = {if_id_reg.instr[31], if_id_reg.instr[19:12], if_id_reg.instr[20], if_id_reg.instr[30:21], 1'b0};
        
        // 默认值
        alu_op = 5'd0;
        alu_src = 1'b0;
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 2'b00;
        imm = 64'b0;
        is_load = 1'b0;
        is_store = 1'b0;
        is_branch = 1'b0;
        is_jump = 1'b0;
        is_alu = 1'b0;
        is_aluimm = 1'b0;
        is_lui = 1'b0;
        is_auipc = 1'b0;
        is_system = 1'b0;
        is_csr = 1'b0;
        
        case (opcode) 
            7'b0110111: begin // U-type (lui)
                reg_write = 1'b1; alu_src = 1'b1; is_lui = 1'b1;
                imm = {{32{if_id_reg.instr[31]}}, imm_u, 12'b0};
                alu_op = 5'd0;
            end
            7'b0010111: begin // auipc
                reg_write = 1'b1; alu_src = 1'b1; is_auipc = 1'b1;
                imm = {{32{if_id_reg.instr[31]}}, imm_u, 12'b0};
                alu_op = 5'd0;
            end

            7'b0000011: begin // I-type Load (ld, lw, lb, etc)
                reg_write = 1'b1; alu_src = 1'b1; is_load = 1'b1; 
                mem_read = 1'b1; mem_to_reg = 2'b01;
                imm = {{52{imm_i[11]}}, imm_i};
                alu_op = 5'd0;
            end

            7'b0100011: begin // S-type Store (sd, sw, sb, etc)
                mem_write = 1'b1; is_store = 1'b1; alu_src = 1'b1;
                imm = {{52{imm_s[11]}}, imm_s};
                alu_op = 5'd0;
            end

            7'b0010011: begin // I-type ALU
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm = {{52{imm_i[11]}}, imm_i};
                is_aluimm = 1'b1;
                
                case (funct3) 
                    3'b000: alu_op = 5'd0;  // addi
                    3'b001: alu_op = 5'd4;  // slli
                    3'b010: alu_op = 5'd8;  // slti
                    3'b011: alu_op = 5'd9;  // sltiu
                    3'b101: alu_op = funct7[5] ? 5'd7 : 5'd6; // srai/srli
                    3'b100: alu_op = 5'd12; // xori
                    3'b110: alu_op = 5'd11; // ori
                    3'b111: alu_op = 5'd10; // andi
                    default: alu_op = 5'd0;
                endcase
            end
            
            7'b0110011: begin // R-type
                reg_write = 1'b1; alu_src = 1'b0; is_alu = 1'b1;
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_op = 5'd16; // mul
                        3'b100: alu_op = 5'd17; // div
                        3'b101: alu_op = 5'd18; // divu
                        3'b110: alu_op = 5'd19; // rem
                        3'b111: alu_op = 5'd20; // remu
                        default: alu_op = 5'd0;
                    endcase
                end else begin
                    case (funct3)
                        3'b000: alu_op = (funct7 == 7'b0100000) ? 5'd1 : 5'd0;
                        3'b001: alu_op = 5'd4;
                        3'b010: alu_op = 5'd8;
                        3'b011: alu_op = 5'd9;
                        3'b101: alu_op = funct7[5] ? 5'd7 : 5'd6;
                        3'b110: alu_op = 5'd11;
                        3'b111: alu_op = 5'd10;
                        3'b100: alu_op = 5'd12;
                        default: alu_op = 5'd0;
                    endcase
                end
            end
            
            7'b0011011: begin // OP-IMM-32
                reg_write = 1'b1; alu_src = 1'b1; imm = {{52{imm_i[11]}}, imm_i};
                case (funct3)
                    3'b000: alu_op = 5'd2;  // addiw
                    3'b001: alu_op = 5'd13; // slliw
                    3'b101: alu_op = funct7[5] ? 5'd15 : 5'd14; // sraiw/srliw
                    default: alu_op = 5'd2;
                endcase
            end
            
            7'b0111011: begin // OP-32
                reg_write = 1'b1; alu_src = 1'b0;
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_op = 5'd21; // mulw
                        3'b100: alu_op = 5'd22; // divw
                        3'b101: alu_op = 5'd23; // divuw
                        3'b110: alu_op = 5'd24; // remw
                        3'b111: alu_op = 5'd25; // remuw
                        default: alu_op = 5'd2;
                    endcase
                end else begin
                    case (funct3)
                        3'b000: alu_op = (funct7 == 7'b0100000) ? 5'd3 : 5'd2; // subw/addw
                        3'b001: alu_op = 5'd13; // sllw
                        3'b101: alu_op = funct7[5] ? 5'd15 : 5'd14; // sraw/srlw
                        default: alu_op = 5'd2;
                    endcase
                end
            end
            7'b1100011: begin // branch
                is_branch = 1'b1;
                imm = {{51{imm_b[12]}}, imm_b};
            end
            7'b1101111: begin // jal
                is_jump = 1'b1;
                reg_write = 1'b1;
                imm = {{43{imm_j[20]}}, imm_j};
            end
            7'b1100111: begin // jalr
                is_jump = 1'b1;
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm = {{52{imm_i[11]}}, imm_i};
            end
            7'b1110011: begin // SYSTEM：CSR / ecall / mret
                is_system = 1'b1;
                if (funct3 != 3'b000) begin
                    is_csr = 1'b1;
                    reg_write = (rd != 5'b0);
                    alu_src = 1'b0;
                    imm = {52'b0, imm_i};
                end else begin
                    imm = {52'b0, imm_i};
                end
            end
            
            default: begin // 默认情况，所有控制信号设为默认值
                reg_write = 1'b0;
                alu_src = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 2'b00;
                imm = 64'b0;
                is_load = 1'b0;
                is_store = 1'b0;
                is_branch = 1'b0;
                is_jump = 1'b0;
                is_alu = 1'b0;
                is_aluimm = 1'b0;
                is_lui = 1'b0;
                is_auipc = 1'b0;
                is_system = 1'b0;
                is_csr = 1'b0;
                alu_op = 5'd0;
            end
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            decode_ok <= 1'b1;
            id_ex_reg.valid <= 1'b0;
            id_ex_reg.pc <= 64'b0;
            id_ex_reg.instr <= 32'b0;
            id_ex_reg.rs1_data <= 64'b0;
            id_ex_reg.rs2_data <= 64'b0;
            id_ex_reg.imm <= 64'b0;
            id_ex_reg.rd <= 5'b0;
            id_ex_reg.rs1 <= 5'b0;
            id_ex_reg.rs2 <= 5'b0;
            id_ex_reg.funct3 <= 3'b0;
            id_ex_reg.funct7 <= 7'b0;
            id_ex_reg.opcode <= 7'b0;
            id_ex_reg.is_load <= 1'b0;
            id_ex_reg.is_store <= 1'b0;
            id_ex_reg.is_branch <= 1'b0;
            id_ex_reg.is_jump <= 1'b0;
            id_ex_reg.is_alu <= 1'b0;
            id_ex_reg.is_aluimm <= 1'b0;
            id_ex_reg.is_lui <= 1'b0;
            id_ex_reg.is_auipc <= 1'b0;
            id_ex_reg.is_system <= 1'b0;
            id_ex_reg.is_csr <= 1'b0;
            id_ex_reg.alu_op <= 5'b0;
            id_ex_reg.alu_src <= 1'b0;
            id_ex_reg.mem_write <= 1'b0;
            id_ex_reg.mem_read <= 1'b0;
            id_ex_reg.reg_write <= 1'b0;
            id_ex_reg.mem_to_reg <= 2'b0;
        end else if (flush) begin
            id_ex_reg.valid <= 1'b0;
        end else if (step) begin
            // 更新流水线寄存器
            id_ex_reg.valid <= if_id_reg.valid;
            id_ex_reg.pc <= if_id_reg.pc;
            id_ex_reg.instr <= if_id_reg.instr;
            id_ex_reg.rs1 <= rs1;
            id_ex_reg.rs2 <= rs2;
            id_ex_reg.rd <= rd;
            id_ex_reg.rs1_data <= reg_rdata1;
            id_ex_reg.rs2_data <= reg_rdata2;
            id_ex_reg.alu_op <= alu_op;
            id_ex_reg.alu_src <= alu_src;
            id_ex_reg.reg_write <= reg_write;
            id_ex_reg.mem_write <= mem_write;
            id_ex_reg.mem_read <= mem_read;
            id_ex_reg.mem_to_reg <= mem_to_reg;
            id_ex_reg.imm <= imm;
            id_ex_reg.is_load <= is_load;
            id_ex_reg.is_store <= is_store;
            id_ex_reg.is_branch <= is_branch;
            id_ex_reg.is_jump <= is_jump;
            id_ex_reg.is_alu <= is_alu;
            id_ex_reg.is_aluimm <= is_aluimm;
            id_ex_reg.is_lui <= is_lui;
            id_ex_reg.is_auipc <= is_auipc;
            id_ex_reg.is_system <= is_system;
            id_ex_reg.is_csr <= is_csr;
            id_ex_reg.funct3 <= funct3;
            id_ex_reg.funct7 <= funct7;
            id_ex_reg.opcode <= opcode;
        end
    end
endmodule

`endif






`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module execute import common::*;(
    input  logic       clk, reset,
    input  logic       step,
    output logic       execute_ok,
    input  REG_ID_EX   id_ex_reg,
    input  forward_ctrl_t forward_ctrl,
    input  word_t      wb_data,
    input  word_t      mem_forward_data,
    input  word_t      csr_rdata,
    input  word_t      csr_mtvec,
    input  word_t      csr_mepc,
    input  u2          priv_mode_q,
    output logic       redirect_valid,
    output u64         redirect_pc,
    output logic       trap_fire,
    output logic       trap_is_mret,
    output u12         trap_ecall_imm,
    output REG_EX_MEM  ex_mem_reg
);
    localparam logic [4:0] ALU_MUL   = 5'd16;
    localparam logic [4:0] ALU_DIV   = 5'd17;
    localparam logic [4:0] ALU_DIVU  = 5'd18;
    localparam logic [4:0] ALU_REM   = 5'd19;
    localparam logic [4:0] ALU_REMU  = 5'd20;
    localparam logic [4:0] ALU_MULW  = 5'd21;
    localparam logic [4:0] ALU_DIVW  = 5'd22;
    localparam logic [4:0] ALU_DIVUW = 5'd23;
    localparam logic [4:0] ALU_REMW  = 5'd24;
    localparam logic [4:0] ALU_REMUW = 5'd25;

    word_t alu_a, alu_b;
    word_t rs2_val;
    word_t alu_result;
    word_t add_res, sub_res;
    logic [31:0] addw_res, subw_res, sllw_res, srlw_res, sraw_res;
    logic [31:0] mulw_res, divw_res, divuw_res, remw_res, remuw_res;
    logic branch_taken;
    u64 branch_target;
    logic md_busy, md_finishing;
    logic md_result_ready;
    logic [6:0] md_count;
    logic id_is_muldiv;
    logic md_start;

    // 迭代乘除法寄存器
    logic [63:0] iter_acc;
    logic [63:0] iter_quo;
    logic [63:0] iter_divisor;
    logic [63:0] iter_op_a;
    logic [63:0] iter_op_b;
    logic iter_sign_q, iter_sign_r;
    logic iter_is_mul;

    // 最终结果寄存器（完成时锁存）
    logic [63:0] iter_mul_final;
    logic [63:0] iter_quo_final;
    logic [63:0] iter_rem_final;

    assign id_is_muldiv = (id_ex_reg.alu_op >= ALU_MUL);
    assign md_start = id_ex_reg.valid && id_is_muldiv && !md_busy && !md_result_ready;
    // 乘除法在结果 ready 之前一直阻塞，防止 id_ex 被后续指令覆盖
    assign execute_ok = !md_busy && (!id_is_muldiv || md_result_ready);

    logic csr_do_write;
    word_t csr_wval_c;
    logic is_ecall;
    logic is_mret;

    // 前向逻辑
    always_comb begin
        case (forward_ctrl.forward_a)
            2'b00: alu_a = id_ex_reg.rs1_data;
            2'b01: alu_a = ex_mem_reg.is_load ? mem_forward_data : ex_mem_reg.alu_result;
            2'b10: alu_a = wb_data;
            default: alu_a = id_ex_reg.rs1_data;
        endcase

        if (id_ex_reg.is_lui) alu_a = 64'b0;

        case (forward_ctrl.forward_b)
            2'b00: rs2_val = id_ex_reg.rs2_data;
            2'b01: rs2_val = ex_mem_reg.is_load ? mem_forward_data : ex_mem_reg.alu_result;
            2'b10: rs2_val = wb_data;
            default: rs2_val = id_ex_reg.rs2_data;
        endcase

        if (id_ex_reg.alu_src) alu_b = id_ex_reg.imm;
        else alu_b = rs2_val;

        if (id_ex_reg.is_auipc) alu_a = id_ex_reg.pc;

        add_res = alu_a + alu_b;
        sub_res = alu_a - alu_b;
        addw_res = add_res[31:0];
        subw_res = sub_res[31:0];
        sllw_res = alu_a[31:0] << alu_b[4:0];
        srlw_res = alu_a[31:0] >> alu_b[4:0];
        sraw_res = $signed(alu_a[31:0]) >>> alu_b[4:0];
        mulw_res = iter_mul_final[31:0];
        divw_res = iter_quo_final[31:0];
        divuw_res = iter_quo_final[31:0];
        remw_res = iter_rem_final[31:0];
        remuw_res = iter_rem_final[31:0];

        csr_do_write = 1'b0;
        csr_wval_c = 64'b0;
        if (id_ex_reg.is_csr) begin
            unique case (id_ex_reg.funct3)
                3'b001: begin // CSRRW
                    csr_wval_c = alu_a;
                    csr_do_write = 1'b1;
                end
                3'b010: begin // CSRRS
                    csr_wval_c = csr_rdata | alu_a;
                    csr_do_write = (id_ex_reg.rs1 != 5'b0);
                end
                3'b011: begin // CSRRC
                    csr_wval_c = csr_rdata & ~alu_a;
                    csr_do_write = (id_ex_reg.rs1 != 5'b0);
                end
                3'b101: begin // CSRRWI
                    csr_wval_c = {59'b0, id_ex_reg.rs1};
                    csr_do_write = 1'b1;
                end
                3'b110: begin // CSRRSI
                    csr_wval_c = csr_rdata | {59'b0, id_ex_reg.rs1};
                    csr_do_write = (id_ex_reg.rs1 != 5'b0);
                end
                3'b111: begin // CSRRCI
                    csr_wval_c = csr_rdata & ~{59'b0, id_ex_reg.rs1};
                    csr_do_write = (id_ex_reg.rs1 != 5'b0);
                end
                default: begin
                end
            endcase
        end

        case (id_ex_reg.alu_op)
            5'd0:  alu_result = alu_a + alu_b;
            5'd1:  alu_result = alu_a - alu_b;
            5'd2:  alu_result = {{32{addw_res[31]}}, addw_res};
            5'd3:  alu_result = {{32{subw_res[31]}}, subw_res};
            5'd4:  alu_result = alu_a << alu_b[5:0];
            5'd6:  alu_result = alu_a >> alu_b[5:0];
            5'd7:  alu_result = $signed(alu_a) >>> alu_b[5:0];
            5'd8:  alu_result = ($signed(alu_a) < $signed(alu_b)) ? 64'd1 : 64'd0;
            5'd9:  alu_result = (alu_a < alu_b) ? 64'd1 : 64'd0;
            5'd10: alu_result = alu_a & alu_b;
            5'd11: alu_result = alu_a | alu_b;
            5'd12: alu_result = alu_a ^ alu_b;
            5'd13: alu_result = {{32{sllw_res[31]}}, sllw_res};
            5'd14: alu_result = {{32{srlw_res[31]}}, srlw_res};
            5'd15: alu_result = {{32{sraw_res[31]}}, sraw_res};
            5'd16: alu_result = iter_mul_final;
            5'd17: alu_result = (alu_b == 64'd0) ? 64'hffff_ffff_ffff_ffff :
                                ((alu_a == 64'h8000_0000_0000_0000 && alu_b == 64'hffff_ffff_ffff_ffff) ? alu_a :
                                iter_quo_final);
            5'd18: alu_result = (alu_b == 64'd0) ? 64'hffff_ffff_ffff_ffff : iter_quo_final;
            5'd19: alu_result = (alu_b == 64'd0) ? alu_a :
                                ((alu_a == 64'h8000_0000_0000_0000 && alu_b == 64'hffff_ffff_ffff_ffff) ? 64'd0 :
                                iter_rem_final);
            5'd20: alu_result = (alu_b == 64'd0) ? alu_a : iter_rem_final;
            5'd21: alu_result = {{32{mulw_res[31]}}, mulw_res};
            5'd22: begin
                if (alu_b[31:0] == 32'd0) divw_res = 32'hffff_ffff;
                else if (alu_a[31:0] == 32'h8000_0000 && alu_b[31:0] == 32'hffff_ffff) divw_res = 32'h8000_0000;
                alu_result = {{32{divw_res[31]}}, divw_res};
            end
            5'd23: begin
                if (alu_b[31:0] == 32'd0) divuw_res = 32'hffff_ffff;
                alu_result = {{32{divuw_res[31]}}, divuw_res};
            end
            5'd24: begin
                if (alu_b[31:0] == 32'd0) remw_res = alu_a[31:0];
                else if (alu_a[31:0] == 32'h8000_0000 && alu_b[31:0] == 32'hffff_ffff) remw_res = 32'd0;
                alu_result = {{32{remw_res[31]}}, remw_res};
            end
            5'd25: begin
                if (alu_b[31:0] == 32'd0) remuw_res = alu_a[31:0];
                alu_result = {{32{remuw_res[31]}}, remuw_res};
            end
            default: alu_result = 64'b0;
        endcase

        branch_taken = 1'b0;
        branch_target = id_ex_reg.pc + id_ex_reg.imm;
        if (id_ex_reg.is_branch) begin
            case (id_ex_reg.funct3)
                3'b000: branch_taken = (alu_a == rs2_val);
                3'b001: branch_taken = (alu_a != rs2_val);
                3'b100: branch_taken = ($signed(alu_a) < $signed(rs2_val));
                3'b101: branch_taken = ($signed(alu_a) >= $signed(rs2_val));
                3'b110: branch_taken = (alu_a < rs2_val);
                3'b111: branch_taken = (alu_a >= rs2_val);
                default: branch_taken = 1'b0;
            endcase
        end
        if (id_ex_reg.is_jump) begin
            branch_taken = 1'b1;
            if (id_ex_reg.opcode == 7'b1100111) branch_target = (alu_a + id_ex_reg.imm) & ~64'd1;
            alu_result = id_ex_reg.pc + 64'd4;
        end
        if (id_ex_reg.is_csr)
            alu_result = csr_rdata;

        is_ecall = id_ex_reg.is_system && !id_ex_reg.is_csr
                   && (id_ex_reg.instr == 32'h00000073);
        is_mret  = id_ex_reg.is_system && (id_ex_reg.instr == 32'h30200073);
    end

    assign redirect_valid = step & id_ex_reg.valid
                          & (branch_taken | id_ex_reg.is_csr | is_ecall | is_mret);
    assign redirect_pc    = is_mret ? csr_mepc
                          : is_ecall ? csr_mtvec
                          : id_ex_reg.is_csr ? (id_ex_reg.pc + 64'd4)
                          : branch_target;
    assign trap_fire       = step & id_ex_reg.valid & (is_ecall | is_mret);
    assign trap_is_mret    = is_mret;
    assign trap_ecall_imm  = id_ex_reg.imm[11:0];

    // 迭代乘除法用的组合逻辑临时变量
    logic [63:0] init_op_a, init_op_b, init_abs_a, init_abs_b;
    logic init_is_signed;
    logic [63:0] div_shifted, div_trial;
    logic [63:0] rem_corrected;

    always_ff @(posedge clk) begin
        if (reset) begin
            md_busy <= 1'b0;
            md_finishing <= 1'b0;
            md_result_ready <= 1'b0;
            md_count <= 7'd0;
            ex_mem_reg.valid <= 1'b0;
            ex_mem_reg.pc <= 64'b0;
            ex_mem_reg.instr <= 32'b0;
            ex_mem_reg.alu_result <= 64'b0;
            ex_mem_reg.rs2_data <= 64'b0;
            ex_mem_reg.imm <= 64'b0;
            ex_mem_reg.rd <= 5'b0;
            ex_mem_reg.is_load <= 1'b0;
            ex_mem_reg.is_store <= 1'b0;
            ex_mem_reg.mem_write <= 1'b0;
            ex_mem_reg.mem_read <= 1'b0;
            ex_mem_reg.reg_write <= 1'b0;
            ex_mem_reg.mem_to_reg <= 2'b0;
            ex_mem_reg.csr_pending <= 1'b0;
            ex_mem_reg.csr_paddr <= 12'b0;
            ex_mem_reg.csr_pwdata <= 64'b0;
            ex_mem_reg.trap_pending <= 1'b0;
            ex_mem_reg.trap_is_mret <= 1'b0;
            ex_mem_reg.trap_priv     <= 2'b11;
            iter_acc <= 64'd0;
            iter_quo <= 64'd0;
            iter_divisor <= 64'd0;
            iter_op_a <= 64'd0;
            iter_op_b <= 64'd0;
            iter_sign_q <= 1'b0;
            iter_sign_r <= 1'b0;
            iter_is_mul <= 1'b0;
            iter_mul_final <= 64'd0;
            iter_quo_final <= 64'd0;
            iter_rem_final <= 64'd0;
        end else begin
            // 默认清除 md_finishing
            md_finishing <= 1'b0;

            // Lab5: trap 标记进入 MEM/WB 再更新 CSR；EX 仍 flush/redirect
            if (trap_fire) begin
                ex_mem_reg.valid        <= 1'b1;
                ex_mem_reg.pc           <= id_ex_reg.pc;
                ex_mem_reg.instr        <= id_ex_reg.instr;
                ex_mem_reg.trap_pending <= 1'b1;
                ex_mem_reg.trap_is_mret <= trap_is_mret;
                ex_mem_reg.trap_priv     <= priv_mode_q;
                ex_mem_reg.reg_write    <= 1'b0;
                ex_mem_reg.csr_pending  <= 1'b0;
                ex_mem_reg.is_load      <= 1'b0;
                ex_mem_reg.is_store     <= 1'b0;
                ex_mem_reg.mem_write    <= 1'b0;
                ex_mem_reg.mem_read     <= 1'b0;
            end else if (md_start) begin
                md_busy <= 1'b1;
                md_result_ready <= 1'b0;
                iter_is_mul <= (id_ex_reg.alu_op == ALU_MUL) || (id_ex_reg.alu_op == ALU_MULW);

                // 准备操作数（W变体先符号扩展到64位）
                init_op_a = alu_a;
                init_op_b = alu_b;
                if (id_ex_reg.alu_op == ALU_MULW || id_ex_reg.alu_op == ALU_DIVW ||
                    id_ex_reg.alu_op == ALU_REMW) begin
                    init_op_a = {{32{alu_a[31]}}, alu_a[31:0]};
                    init_op_b = {{32{alu_b[31]}}, alu_b[31:0]};
                end else if (id_ex_reg.alu_op == ALU_DIVUW || id_ex_reg.alu_op == ALU_REMUW) begin
                    init_op_a = {32'b0, alu_a[31:0]};
                    init_op_b = {32'b0, alu_b[31:0]};
                end

                if ((id_ex_reg.alu_op == ALU_MUL) || (id_ex_reg.alu_op == ALU_MULW)) begin
                    // 乘法初始化：转无符号，记录结果符号
                    init_abs_a = init_op_a[63] ? (~init_op_a + 64'd1) : init_op_a;
                    init_abs_b = init_op_b[63] ? (~init_op_b + 64'd1) : init_op_b;
                    iter_acc <= 64'd0;
                    iter_op_a <= init_abs_a;
                    iter_op_b <= init_abs_b;
                    iter_sign_q <= init_op_a[63] ^ init_op_b[63];
                    md_count <= (id_ex_reg.alu_op == ALU_MULW) ? 7'd32 : 7'd64;
                end else begin
                    // 除法初始化：转无符号，记录商和余数的符号
                    init_is_signed = (id_ex_reg.alu_op == ALU_DIV) || (id_ex_reg.alu_op == ALU_DIVW) ||
                                     (id_ex_reg.alu_op == ALU_REM) || (id_ex_reg.alu_op == ALU_REMW);
                    init_abs_a = (init_is_signed && init_op_a[63]) ? (~init_op_a + 64'd1) : init_op_a;
                    init_abs_b = (init_is_signed && init_op_b[63]) ? (~init_op_b + 64'd1) : init_op_b;
                    iter_acc <= 64'd0;
                    iter_quo <= 64'd0;
                    iter_divisor <= init_abs_b;
                    iter_op_a <= init_abs_a;
                    iter_sign_q <= init_is_signed ? (init_op_a[63] ^ init_op_b[63]) : 1'b0;
                    iter_sign_r <= init_is_signed ? init_op_a[63] : 1'b0;
                    md_count <= 7'd64;
                end
            end else if (md_busy) begin
                md_count <= md_count - 7'd1;

                if (iter_is_mul) begin
                    // 乘法：每周期检查乘数最低位，条件累加被乘数
                    if (iter_op_b[0]) iter_acc <= iter_acc + iter_op_a;
                    iter_op_a <= iter_op_a << 1;
                    iter_op_b <= iter_op_b >> 1;
                end else begin
                    // 除法：恢复余数法，每周期1位商
                    div_shifted = {iter_acc[62:0], iter_op_a[63]};
                    div_trial = div_shifted - iter_divisor;
                    if (!div_trial[63]) begin
                        iter_acc <= div_trial;
                        iter_quo <= {iter_quo[62:0], 1'b1};
                    end else begin
                        iter_acc <= div_shifted;
                        iter_quo <= {iter_quo[62:0], 1'b0};
                    end
                    iter_op_a <= {iter_op_a[62:0], 1'b0};
                end

                // 最后一步：锁存最终结果，标记完成
                if (md_count == 7'd1) begin
                    md_busy <= 1'b0;
                    md_finishing <= 1'b1;
                    md_result_ready <= 1'b1;
                    if (iter_is_mul) begin
                        // 乘法：结果 = acc + (bit ? op_a : 0)，再修正符号
                        iter_mul_final <= iter_sign_q
                            ? (~(iter_acc + (iter_op_b[0] ? iter_op_a : 64'd0)) + 64'd1)
                            : (iter_acc + (iter_op_b[0] ? iter_op_a : 64'd0));
                    end else begin
                        // 除法：计算最后一步，修正余数和符号
                        div_shifted = {iter_acc[62:0], iter_op_a[63]};
                        div_trial = div_shifted - iter_divisor;
                        if (!div_trial[63]) begin
                            rem_corrected = div_trial;
                            iter_quo_final <= iter_sign_q ? (~{iter_quo[62:0], 1'b1} + 64'd1) : {iter_quo[62:0], 1'b1};
                        end else begin
                            rem_corrected = div_shifted;
                            iter_quo_final <= iter_sign_q ? (~{iter_quo[62:0], 1'b0} + 64'd1) : {iter_quo[62:0], 1'b0};
                        end
                        if (rem_corrected[63]) rem_corrected = rem_corrected + iter_divisor;
                        iter_rem_final <= iter_sign_r ? (~rem_corrected + 64'd1) : rem_corrected;
                    end
                end
            end

            if (step && (!id_is_muldiv || md_result_ready) && !trap_fire) begin
                ex_mem_reg.valid <= id_ex_reg.valid;
                ex_mem_reg.pc <= id_ex_reg.pc;
                ex_mem_reg.instr <= id_ex_reg.instr;
                ex_mem_reg.rd <= id_ex_reg.rd;
                ex_mem_reg.reg_write <= id_ex_reg.reg_write;
                ex_mem_reg.alu_result <= alu_result;
                ex_mem_reg.rs2_data <= rs2_val;
                ex_mem_reg.imm <= id_ex_reg.imm;
                ex_mem_reg.is_load <= id_ex_reg.is_load;
                ex_mem_reg.is_store <= id_ex_reg.is_store;
                ex_mem_reg.mem_write <= id_ex_reg.mem_write;
                ex_mem_reg.mem_read <= id_ex_reg.mem_read;
                ex_mem_reg.mem_to_reg <= id_ex_reg.mem_to_reg;
                ex_mem_reg.trap_pending <= 1'b0;
                ex_mem_reg.trap_is_mret <= 1'b0;
                ex_mem_reg.trap_priv     <= 2'b11;
                // Lab4: EX 只算写数据，真正写入在 WB（见 core csr_we）
                ex_mem_reg.csr_pending <= id_ex_reg.valid & id_ex_reg.is_csr & csr_do_write;
                ex_mem_reg.csr_paddr <= id_ex_reg.imm[11:0];
                ex_mem_reg.csr_pwdata <= csr_wval_c;
                if (id_is_muldiv) md_result_ready <= 1'b0;
            end
        end
    end
endmodule

`endif







`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module fetch import common::*;( 
    input  logic       clk, reset, 
    input  logic       step, 
    output logic       fetch_ok, 
    output ibus_req_t  ireq, 
    input  ibus_resp_t iresp, 
    input  logic       redirect_valid,
    input  u64         redirect_pc,
    input  logic       trap_fire,
    output REG_IF_ID   if_id_reg 
);
    u64 pc;
    u32 instr;
    u64 req_pc;
    logic fetch_in_progress;
    logic redirect_pending;
    u64 pending_redirect_pc;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= PCINIT;
            fetch_ok <= 1'b1;
            fetch_in_progress <= 1'b0;
            redirect_pending <= 1'b0;
            pending_redirect_pc <= 64'b0;
            req_pc <= 64'b0;
            ireq.valid <= 1'b0;
            ireq.addr <= 64'b0;
            if_id_reg.valid <= 1'b0;
            if_id_reg.pc <= 64'b0;
            if_id_reg.instr <= 32'b0;
        end else if (trap_fire) begin
            fetch_ok            <= 1'b1;
            fetch_in_progress   <= 1'b0;
            redirect_pending    <= 1'b0;
            ireq.valid          <= 1'b0;
            if_id_reg.valid     <= 1'b0;
            pc                  <= redirect_pc;
        end else if (redirect_valid) begin
            if_id_reg.valid <= 1'b0;
            if (fetch_in_progress) begin
                redirect_pending <= 1'b1;
                pending_redirect_pc <= redirect_pc;
            end else begin
                pc <= redirect_pc;
            end
        end else if (step && fetch_ok) begin
            // 开始取指令
            fetch_ok <= 1'b0;
            fetch_in_progress <= 1'b1;
            ireq.valid <= 1'b1;
            ireq.addr <= pc;
            req_pc <= pc;
        end else if (!fetch_ok && fetch_in_progress && iresp.data_ok && iresp.addr_ok) begin
            // 取到指令
            fetch_ok <= 1'b1;
            fetch_in_progress <= 1'b0;
            ireq.valid <= 1'b0;
            
            if (redirect_pending) begin
                if_id_reg.valid <= 1'b0;
                pc <= pending_redirect_pc;
                redirect_pending <= 1'b0;
            end else begin
                // 更新流水线寄存器
                if_id_reg.valid <= 1'b1;
                if_id_reg.instr <= iresp.data;
                // 这里必须是 pc，即发起请求时的地址
                if_id_reg.pc    <= req_pc;
                // pc 寄存器更新为下一条，但不能把这个值传给 if_id_reg.pc
                pc <= req_pc + 4;
            end
        end
    end
endmodule

`endif





`ifndef __FORWARD_UNIT_SV
`define __FORWARD_UNIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module forward_unit import common::*;( 
    input  u5          id_ex_rs1, id_ex_rs2, 
    input  u5          ex_mem_rd, 
    input  logic       ex_mem_reg_write,
    input  u5          mem_wb_rd, 
    input  logic       mem_wb_reg_write, 
    output forward_ctrl_t forward_ctrl 
);
    always_comb begin
        // 处理 rs1 的前向 (注意：我们去掉了对 Load 的屏蔽)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_ctrl.forward_a = 2'b01;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_ctrl.forward_a = 2'b10;
        end else begin
            forward_ctrl.forward_a = 2'b00;
        end
        
        // 处理 rs2 的前向 (注意：我们去掉了对 Load 的屏蔽)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_ctrl.forward_b = 2'b01;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_ctrl.forward_b = 2'b10;
        end else begin
            forward_ctrl.forward_b = 2'b00;
        end
    end
endmodule

`endif





`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module memory import common::*;( 
    input  logic       clk, reset, 
    input  logic       step, 
    output logic       mem_ok, 
    input  REG_EX_MEM  ex_mem_reg,
    input  logic       flush,
    output dbus_req_t  dreq, 
    input  dbus_resp_t dresp, 
    output REG_MEM_WB  mem_wb_reg,
    output word_t      mem_forward_data // 组合逻辑前向输出
);
    logic mem_in_progress;
    logic req_completed; // 标记当前 ex_mem_reg 中的请求已处理完成
    word_t saved_rdata;  // 新增：用于暂存从总线读回的数据
    
    // 组合逻辑提取子字段
    u3 funct3;
    u3 offset;
    u6 shift_amt;
    word_t rdata_shifted;
    word_t final_rdata;

    assign funct3 = ex_mem_reg.instr[14:12];
    assign offset = ex_mem_reg.alu_result[2:0];
    assign shift_amt = {offset, 3'b000};
    assign mem_forward_data = saved_rdata;
    
    // 对读上来的数据统一做对齐和符号截断操作
    assign rdata_shifted = dresp.data >> shift_amt;
    always_comb begin
        case (funct3)
            3'b000: final_rdata = {{56{rdata_shifted[7]}}, rdata_shifted[7:0]};   // lb
            3'b001: final_rdata = {{48{rdata_shifted[15]}}, rdata_shifted[15:0]}; // lh
            3'b010: final_rdata = {{32{rdata_shifted[31]}}, rdata_shifted[31:0]}; // lw
            3'b011: final_rdata = rdata_shifted;                                  // ld
            3'b100: final_rdata = {56'b0, rdata_shifted[7:0]};                    // lbu
            3'b101: final_rdata = {48'b0, rdata_shifted[15:0]};                   // lhu
            3'b110: final_rdata = {32'b0, rdata_shifted[31:0]};                   // lwu
            default: final_rdata = 64'b0;
        endcase
    end

    // 只要 EX_MEM 中有未完成的访存指令，立刻（0 延迟）拉低阻塞全局 step
    assign mem_ok = ~(ex_mem_reg.valid && (ex_mem_reg.is_load || ex_mem_reg.is_store) && !req_completed);

    always_ff @(posedge clk) begin
        if (reset) begin
            mem_in_progress <= 1'b0;
            req_completed <= 1'b0;
            saved_rdata <= 64'b0;
            dreq.valid <= 1'b0;
            dreq.addr <= 64'b0;
            dreq.size <= MSIZE4;
            dreq.strobe <= 8'b0;
            dreq.data <= 64'b0;
            mem_wb_reg.valid <= 1'b0;
            mem_wb_reg.pc <= 64'b0;
            mem_wb_reg.instr <= 32'b0;
            mem_wb_reg.alu_result <= 64'b0;
            mem_wb_reg.mem_data <= 64'b0;
            mem_wb_reg.rd <= 5'b0;
            mem_wb_reg.reg_write <= 1'b0;
            mem_wb_reg.mem_to_reg <= 2'b0;
            mem_wb_reg.csr_pending <= 1'b0;
            mem_wb_reg.csr_paddr <= 12'b0;
            mem_wb_reg.csr_pwdata <= 64'b0;
            mem_wb_reg.trap_pending <= 1'b0;
            mem_wb_reg.trap_is_mret <= 1'b0;
            mem_wb_reg.trap_priv     <= 2'b11;
            
        end else begin
            if (flush && mem_in_progress) begin
                // Lab5/6: trap 时取消未完成的访存，但保留 EX/MEM 中可提交的指令
                mem_in_progress <= 1'b0;
                dreq.valid      <= 1'b0;
            end
            if (step) begin
                // 当 step 为 1 时，意味着流水线推进。将 EX_MEM 正式送入 MEM_WB
                req_completed <= 1'b0;
                mem_wb_reg.valid <= ex_mem_reg.valid;
                mem_wb_reg.pc <= ex_mem_reg.pc;
                mem_wb_reg.instr <= ex_mem_reg.instr;
                mem_wb_reg.rd <= ex_mem_reg.rd;
                mem_wb_reg.reg_write <= ex_mem_reg.reg_write;
                mem_wb_reg.alu_result <= ex_mem_reg.alu_result;
                mem_wb_reg.mem_data <= ex_mem_reg.is_load ? saved_rdata : ex_mem_reg.alu_result;
                mem_wb_reg.mem_to_reg <= ex_mem_reg.mem_to_reg;
                mem_wb_reg.csr_pending <= ex_mem_reg.csr_pending;
                mem_wb_reg.csr_paddr <= ex_mem_reg.csr_paddr;
                mem_wb_reg.csr_pwdata <= ex_mem_reg.csr_pwdata;
                mem_wb_reg.trap_pending <= ex_mem_reg.trap_pending;
                mem_wb_reg.trap_is_mret <= ex_mem_reg.trap_is_mret;
                mem_wb_reg.trap_priv     <= ex_mem_reg.trap_priv;
            end
            if (!mem_in_progress && ex_mem_reg.valid && (ex_mem_reg.is_load || ex_mem_reg.is_store) && !req_completed) begin
            // 发现需要访存的指令，发起内存总线请求（此时 step 为 0，前序指令安全停留在 mem_wb_reg）
            mem_in_progress <= 1'b1;
            dreq.valid <= 1'b1;
            dreq.addr <= ex_mem_reg.alu_result; 
            
            if (ex_mem_reg.is_store) begin
                case (funct3)
                    3'b000: begin dreq.strobe <= 8'b0000_0001 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE1; end
                    3'b001: begin dreq.strobe <= 8'b0000_0011 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE2; end
                    3'b010: begin dreq.strobe <= 8'b0000_1111 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE4; end
                    3'b011: begin dreq.strobe <= 8'hFF;                  dreq.data <= ex_mem_reg.rs2_data;              dreq.size <= MSIZE8; end
                    default:begin dreq.strobe <= 8'b0;                   dreq.data <= 64'b0;                            dreq.size <= MSIZE8; end
                endcase
            end else begin // Load
                dreq.strobe <= 8'b0;
                dreq.data <= 64'b0;
                case (funct3)
                    3'b000, 3'b100: dreq.size <= MSIZE1;
                    3'b001, 3'b101: dreq.size <= MSIZE2;
                    3'b010, 3'b110: dreq.size <= MSIZE4;
                    3'b011:         dreq.size <= MSIZE8;
                    default:        dreq.size <= MSIZE8;
                endcase
            end
            
            end
            if (mem_in_progress && dresp.data_ok && dresp.addr_ok) begin
                mem_in_progress <= 1'b0;
                dreq.valid <= 1'b0;
                req_completed <= 1'b1;
                saved_rdata <= final_rdata;
            end
        end
    end
endmodule

`endif





`ifndef __REGFILE_SV
`define __REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module regfile import common::*;( 
    input  logic       clk, reset, 
    input  u5          raddr1, raddr2, 
    input  logic       wen, 
    input  u5          waddr, 
    input  word_t      wdata, 
    output word_t      rdata1, rdata2 
);
    word_t REG[31:0];
    word_t next_reg[31:0];
    
    // 读取操作：组合逻辑内部前向机制，解决 WB 到 ID 的数据冒险
    always_comb begin
        if (raddr1 == 5'b0) rdata1 = 64'b0;
        else if (wen && (raddr1 == waddr)) rdata1 = wdata; // WB 阶段前向
        else rdata1 = REG[raddr1];

        if (raddr2 == 5'b0) rdata2 = 64'b0;
        else if (wen && (raddr2 == waddr)) rdata2 = wdata;
        else rdata2 = REG[raddr2];
    end
    
    // 为 Difftest 计算 next_reg 时，强制 next_reg[0] 为 0
    always_comb begin
        next_reg[0] = 64'b0;
        for (int i = 1; i < 32; i++) begin
            if (wen && (u5'(i) == waddr)) next_reg[i] = wdata;
            else next_reg[i] = REG[i];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) REG[i] <= 64'b0;
        end else if (wen && (waddr != 5'b0)) begin // 禁止写入 x0
            REG[waddr] <= wdata;
        end
    end
endmodule

`endif





`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module writeback import common::*;( 
    input  logic       clk, reset, 
    input  logic       step,
    input  logic       block_commit,
    output logic       writeback_ok, 
    input  REG_MEM_WB  mem_wb_reg, 
    output logic       reg_wen, 
    output u5          reg_waddr, 
    output word_t      reg_wdata, 
    output logic       commit_valid, 
    output u64         commit_pc, 
    output u32         commit_instr, 
    output logic       commit_wen, 
    output u5          commit_wdest, 
    output word_t      commit_wdata 
);
    // Writeback 永远处于 ready 状态
    assign writeback_ok = 1'b1;

    // 只有 rd != 0 时才真正写回
    assign reg_wen = mem_wb_reg.valid & mem_wb_reg.reg_write & (mem_wb_reg.rd != 5'b0) & step;
    assign reg_waddr = mem_wb_reg.rd;
    // 根据控制信号选择写回数据 (0: ALU, 1: Memory)
    assign reg_wdata = (mem_wb_reg.mem_to_reg == 2'b01) ? mem_wb_reg.mem_data : mem_wb_reg.alu_result;

    // Difftest 提交信号
    // block_commit: only suppress WB on ecall (mret still commits for difftest)
    assign commit_valid = mem_wb_reg.valid & step & ~block_commit;
    assign commit_pc    = mem_wb_reg.pc;
    assign commit_instr = mem_wb_reg.instr;
    assign commit_wen   = reg_wen; 
    assign commit_wdest = reg_waddr;
    assign commit_wdata = reg_wdata;

endmodule

`endif







`ifndef __MMU_SV
`define __MMU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`else
`include "common.sv"
`include "csr.sv"
`endif

import common::*;
import csr_pkg::*;

// Sv39 MMU on CBus (after arbiter). Enabled in U/S when satp.mode == 8.
module mmu import common::*; import csr_pkg::*; (
    input  logic       clk,
    input  logic       reset,
    input  u2          priv_mode,
    input  word_t      satp,
    input  cbus_req_t  req_in,
    output cbus_req_t  req_out,
    input  cbus_resp_t resp_in,
    output cbus_resp_t resp_out
);
    satp_t satp_v;
    assign satp_v = satp_t'(satp);

    logic mmu_on;
    assign mmu_on = (priv_mode != 2'b11) && (satp_v.mode == 4'd8);

    typedef enum logic [1:0] {
        ST_IDLE  = 2'd0,
        ST_PTE   = 2'd1,
        ST_WAIT  = 2'd2
    } state_t;

    state_t state;
    cbus_req_t saved_req;
    addr_t    paddr;
    logic     pte_hold;

`ifdef VERILATOR
    logic        pte_en;
    addr_t       pte_vaddr;
    logic [63:0] pte;
    logic [7:0]  pte_level;
    logic [7:0]  pte_pf;

    assign pte_vaddr = (state == ST_IDLE) ? req_in.addr : saved_req.addr;
    assign pte_en    = (state == ST_IDLE) && req_in.valid && mmu_on;

    PTEHelper pte_helper_inst(
        .clock(clk),
        .enable(pte_en),
        .satp(satp),
        .vpn({{37'b0}, pte_vaddr[38:12]}),
        .pte(pte),
        .level(pte_level),
        .pf(pte_pf)
    );

    function automatic addr_t sv39_paddr(
        input word_t pte_val,
        input addr_t vaddr,
        input logic [7:0] level
    );
        unique case (level)
            8'd0: sv39_paddr = {{8'b0}, pte_val[53:28], vaddr[29:12], vaddr[11:0]};
            8'd1: sv39_paddr = {{8'b0}, pte_val[53:19], vaddr[20:12], vaddr[11:0]};
            default: sv39_paddr = {{8'b0}, pte_val[53:10], vaddr[11:0]};
        endcase
    endfunction
`endif

    always_ff @(posedge clk) begin
        if (reset) begin
            state     <= ST_IDLE;
            saved_req <= '0;
            paddr     <= 64'b0;
            pte_hold  <= 1'b0;
        end else if (!mmu_on) begin
            state     <= ST_IDLE;
            pte_hold  <= 1'b0;
        end else begin
            unique case (state)
                ST_IDLE: begin
                    pte_hold <= 1'b0;
                    if (req_in.valid) begin
                        saved_req <= req_in;
                        state     <= ST_PTE;
                    end
                end
                ST_PTE: begin
                    if (!pte_hold) begin
                        pte_hold <= 1'b1;
                    end else begin
`ifdef VERILATOR
                        if (pte_pf == 8'b0)
                            paddr <= sv39_paddr(pte, saved_req.addr, pte_level);
                        else
                            paddr <= 64'b0;
`else
                        paddr <= saved_req.addr;
`endif
                        pte_hold <= 1'b0;
                        state    <= ST_WAIT;
                    end
                end
                ST_WAIT: begin
                    if (resp_in.ready && resp_in.last)
                        state <= ST_IDLE;
                end
                default: state <= ST_IDLE;
            endcase
        end
    end

    always_comb begin
        req_out  = req_in;
        resp_out = resp_in;

        if (!mmu_on) begin
            // passthrough
        end else if (state == ST_WAIT) begin
            req_out       = saved_req;
            req_out.valid = 1'b1;
            req_out.addr  = paddr;
        end else begin
            req_out.valid  = 1'b0;
            resp_out.ready = 1'b0;
            resp_out.last  = 1'b0;
            resp_out.data  = 64'b0;
        end
    end

endmodule

`endif


