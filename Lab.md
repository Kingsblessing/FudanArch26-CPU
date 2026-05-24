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

本次 Lab 我们要求上板测试。

# Lab6

支持中断与异常。

需要支持：时钟中断、外部中断、异常（ECALL、非法指令、页错误等）。

你必须先阅读**特权架构**

## 实验细节

### 准备工作

实际上在 Lab 5 我们已经讲了一遍特权级切换。请查看 lab 5，实现 mode 寄存器并连接到 difftest。

### 异常

实现下列异常：
• 指令地址不对齐
• 数据地址不对齐
• 非法指令
• ecall

> Bonus：实现MMU的缺页异常

发生异常时，要进行下列操作：

1. mepc ← pc
2. next_pc ← mtvec
3. mcause[63] ← 0 表示异常（而不是中断），mcause[62:0] ← 对应的异常类型
4. mstatus.mpie ← mstatus.mie
5. mstatus.mie ← 0
6. mstatus.mpp ← mode
7. mode ← 2'b11
8. 清除流水线。取消当周期发起的 dreq.valid。已发起的 dreq 保留，等到 data_ok 后再清除流水线。

### 中断

实现时钟中断、外部中断、软件中断

我们提供的 trint, exint, swint 分别表示三种中断信号。

与异常不同，中断的处理是有条件的。

>An interrupt i will trap to M-mode (causing the privilege mode to change to Mmode) if all of the following are true: (a)either the current privilege mode is M and the MIE bit in the mstatus register is set,or the current privilege mode has less privilege than M-mode;(b)bit i is set in both mip and mie. These conditions for an interrupt trap to occur must be evaluated in a bounded amount of time from when an interrupt becomes, or ceases to be, pending in mip, and must also be evaluated immediately following the execution of an xRET instruction or an explicit write to a CSR on which these interrupt trap conditions expressly depend(including mip, mie, mstatus)

省流：中断处理实际发生的条件是以下二者均满足：

• (1) 中断是否启用：【如果当前是 M Mode，要求 mstatus.mie=1】 或者 【当前不是 M Mode】
• (2) mip[i]=1 且 mie[i]=1

需要进行中断处理 evaluate（即进行上面的检查，来确定要不要跳转到中断向量）的条件可以总结为满足下面之一（只有这三种条件才会产生新的中断）

• (1) 刚收到一个中断信号
• (2) 刚执行过mret
• (3) mip, mie, mstatus刚被CSR写入修改过。

本次Lab我们只要求在 (1) 刚收到一个中断信号 时执行中断 evaluate

>hint（非 bonus）思考：每次流水线前进，有新的指令要 fetch 时，在 fetch 模块进行 evaluate 是否有合理性？
>hint: 由于理论上中断并不与 CPU 时钟同步。你不应该检测中断信号的 posedge/negedge。

中断时，除了第三步要将 mcause[63] 赋值为 1 外，其他进行的操作与异常处理相同。

### mret

• mstatus.mie ← mstatus.mpie
• mstatus.mpie ← 1
• mode ← mstatus.mpp
• mstatus.mpp ← 0
• mstatus.xs ← 0

>Bonus: 观察 difftest 代码，你会发现 mtimecmp 在 0x38004000，mtime 在 0x3800bff8。请利用给出的测试程序构建框架，利用这两个寄存器，编写中断处理程序，在时钟中断时打印一些内容，并重设 mtimecmp。你需要在报告中额外包含 c/cpp/汇编 代码，不需要提供文件。

## Lab6 测试

运行 make test-lab6，出现以下输出

本次测试暂时没有 Difftest，能看到 Privileged test finished. 输出就算正确。

后面循环输出 m_trap_test [X] ---TEST FAILED---是正常的，Ctrl+C退出即可。

# 特权架构

> 特权架构可能会给大家产生一些困惑，因此我专门来写一个文档来解释这件事情（实际上如果你上课听的话也可以理解这些内容）。

特权架构是一个**非常笼统**的，对于*一套*东西的叫法。这套东西干的事情就是：我们除了按 PC+4 和跳转控制严格执行之外，让 CPU 在一定程度不按照这个套路运行。

**先记住，计算机科学其实是来自于工程的。我没办法从 0 告诉你演化过程，只能说目前的现状如此，我就这样讲。**

我们在 Lab 1～3 做了一个能算数、能跳转、能内存读写的 CPU，大家回忆 ICS 当中的内容，是不是基本上能对应当时做 Bomb lab 的时候遇到的大多数指令了？（虽然那里是 x86）我们似乎做了一个功能完备，理论上可以干任何事情的 CPU。

————正确！他的确理论上可以用来进行任何的计算。它是图灵完备的。

问题在何处？

**我们的电脑不是一个计算盒子。它不是你给定输入数据和程序就开始忠实地计算，然后吐出结果来。**

一个电脑要能恰当地、正确地处理各种外界正在实时产生的数据；要能处理多个程序同时运行（至少是看起来同时运行）；要有一定的鲁棒性，不能有一个错误的程序就让整个电脑挂掉。

这里就让我们的 CPU 不再像以前那样靠谱地运行了，要引入一些其他东西。那么我们还是要让 CPU 能干之前的事，也能干这种新任务，因此我们要用一些东西对 CPU 进行设置。这就跟你要设置软件一样，现在要求你对 CPU 进行一些设置。这些“设置”实际上就是 CSR 寄存器。

## 异常

软件/硬件难免会出错。例如：

- 数组越界，你写的程序访问了不该访问的内存
- 程序被病毒感染了，(x86 CPU)指令被修改为 HLT，直接把 CPU 关掉
- 程序被病毒感染了，指令被修改为 RISC-V 指令集里面不存在的一条指令
- 内存的某些单元损坏了

这时，计算机系统应该如何应对？对于前两种情况，或许存在一些软件层面的办法。例如一些高级语言(Java)能够监测数组越界；操作系统或者杀毒软件能够检查软件中的恶意代码。但是很显然这些办法会带来额外的性能开销。更麻烦的是后两种情况。在软件层面上，这些问题是难以被检测到的。这种“异常”需要在 CPU 实际执行这条指令时才会被发现。上面列举的四情况实际上都属于 CPU 意义上的“异常”。具体来说，异常可以包括：

- 非法内存访问（非法地址、地址没有对齐等）
- 非法指令
- 越权指令

既然我们确定了“异常”需要在 CPU 执行时被检测，随之而来的问题就是，遇到异常后 CPU 应该如何处理。直接忽略异常显然是不行的。那么如何让用户知道异常发生了，并进行修复呢？我们可以回想 python 等编程语言中的办法：

```
try: 
    do_something() 
except KeyError: 
    fix_key_error() 
except ValueError: 
    fix_value_error() 
except Exception as e: 
    print(f"Uncaught error: {e}")
```

我们预先将可能发生的异常定义出来，然后对于每一种异常，指定对应的处理代码。

类似地，在 CPU 中我们也能这么做！回想一下，CPU 只是一个能不断从内存取指令然后执行的机器。我们可以预先在内存的一部分区域保存好处理某种异常的代码，然后告诉 CPU“异常类型对应 handle 代码的内存地址”的映射关系。当 CPU 遇到异常时，首先判断异常对应的类型，然后跳转到对应的内存地址开始执行我们的异常处理代码。这就是CPU中的异常处理机制。异常处理的过程中，CPU 的特权级别会相应地提升，以便操作系统进行一些需要特权的操作。在异常处理返回后，特权级别会再下降到之前的级别。

> 上述是 x86 的想法。

异常并非都是程序出了问题，也可以用于用户主动切换到操作系统内核态请求服务。举例来说，print 的实际实现是相当复杂的。程序需要知道屏幕的光标位置、处理对应的显卡绘制逻辑，并且在不同的硬件上，这一系列操作都不相同。与各种显卡驱动交互的操作逻辑显然不应该集成在每一个 `print("Hello World")` 的程序里，而是由操作系统暴露出一个抽象的资源接口，供程序直接调用。在这种情况下，用户程序可以通过执行一个特殊的指令 `ecall` 主动引发“异常”，跳转到操作系统预留好的接口，请求服务。这个过程又称为系统调用(System Call)。

## 中断

中断与异常类似，都是通过某种信号，强制 CPU 跳转到另一段代码执行。区别在于，异常的信号是同步（由指令产生）的，而中断的信号是异步（由外界产生）的。发生中断时，也需要短暂跳转到更高的特权等级，由操作系统处理。

### 时钟中断

即使在单核CPU上，一个操作系统也能够“同时”运行 QQ、微信，播放音乐，浏览网页。这实际上是很神奇的一件事情。这种“同时”运行多个程序的能力实际上是操作系统通过调度机制营造出的假象。具体来说，操作系统使用了“时间片轮转”的技术（你们会在操作系统课具体学习），将 CPU 时间切割为毫秒级别的片段。每个程序轮流获得一个时间片执行。时间满后当前程序暂停，切换回操作系统，再指定下一个程序执行。由于切换时间非常快，用户会感觉所有程序在同时运行。

这里的问题在于某个用户程序执行到规定时间后，如何将控制权切换回操作系统，以便执行下一条指令。我们能够想到下面两个办法：

1. 通过“君子约定”，要求每个程序内部都包含下面的逻辑：每隔一段时间，将控制权还给操作系统
2. 通过某种外部的方式强制打断运行

第一种方法有着很大的问题：暂且不提程序会不会遵守这种约定，如果程序陷入了死循环，根本无法执行到“切换”部分，那么操作系统就无计可施了。

因此，我们引入了“时钟中断”机制。在之前的 lab 中，我们实现了每个周期自增的 mcycle 寄存器。但时钟中断并不使用 mcycle 寄存器。

时钟中断使用的是一个位于 CPU 外部的计时器，CPU 可以通过类似读写内存（MMIO）的方式读写当前时钟周期数 `mtime`，以及写一个地址（`mtimecmp`，下次中断时间），当前时钟周期数是由外部操作递增的，一旦 `mtime`>=`mtimecmp`，就会向 CPU 的时钟中断线（在这里是 `trint`）发送信号。

- `mtime`：当前计时值，由外部硬件持续递增
- `mtimecmp`：下一次触发时钟中断的目标时间

> bonus: 思考为什么要这样设计，而不是让 CPU 自己把 `mtime` 与 `mtimecmp` 作为两个 CSR。另外，为什么不使用已有的 `mcycle` CSR 进行比较呢？ hint: 思考现代 CPU 的一些设计。

### 外部中断、软件中断

计组课程上讲到过“中断”与“轮询”的区别。外部中断正是实现了这里的“中断”机制。

在 RISC-V 中，“键盘输入”这种外设信号会被中断处理器处理，然后作为中断信号发送给 CPU。当程序需要等待这类耗时不确定的外部信号时，不需要占用 CPU 时间反复轮询检查，而是只需要将自己注册为“键盘输入”这个中断信号的 handler，等待信号到来时被唤醒。软件中断的概念与之类似，只不过信号来自于内部软件，而不是外部设备。

### 实现细节

根据上面的思考，我们大概理解了中断和异常的原理：在特定情况下，CPU 暂停当前的指令执行，跳转到预先定义好的另一段代码进行处理。

我们来考虑一些细节：

#### 不同的中断异常类型需要不同的处理代码，CPU如何知道跳转到哪里？

一种办法是在 CPU 中维护一个寄存器组，按照中断异常类型的下标来取对应的地址。但是 RISC-V 里面有超过 64 种中断异常类型，这个寄存器组会非常庞大而昂贵。CPU 设计是 money-performance trade-off 的艺术。RISC-V 选择的办法是在 CPU 中只维护一个跳转地址 mtvec(Machine Trap-Vector Base-Address Register)，指向的地址作为一个统一的入口，再根据中断异常类型跳转到不同的实际处理代码。

#### 如何告诉处理程序中断异常的细节？我们需要一系列信息：

最后执行的的PC地址和中断异常的类型分别保存到 `mepc`(Machine Exception Program Counter)和 `mcause`，其他琐碎的信息（出错的特权等级类型等）保存到 `mstatus`。

```
try:
    do_something()
except Exception as e:
    mcause = get_exception_code(e)   # 类比 CSR: mcause
    trap_handler(mcause, e) # 对于任何异常这两行都是一样的

def trap_handler(mcause, e): # 这玩意是具体程序要做的。不需要 CPU 操心。
    if mcause == 2:
        handle_illegal_instruction(e)
    elif mcause == 5:
        handle_load_access_fault(e)
    elif mcause == 8:
        handle_ecall_from_u_mode(e)
    else:
        panic(mcause)
```

#### 处理之后，CPU如何跳转回去？

我们之前将 PC 保存到了 `mepc`，只需要取出来重新执行即可。同时将 `mstatus` 保存的各种信息复原。这一系列操作由 `mret` 指令实现。

#### 中断信息如何保存？

CPU可能会同时收到多个中断信息，或者在一个中断处理没结束时收到另一个中断信息。因此我们需要提供一种方式，将中断信息保存下来，等待方便时处理。

`mip`(Machine Interrupt Pending)寄存器的每一位代表了一类中断信息。当收到中断时，我们将对应的位置 1，等待后续处理。

注意：在本次实验中（以及大多数现代 CPU 中），中断是一个持续的信号，而不是一个短暂的上升沿。因此你可以直接用`=`对 `mip` 的对应位进行赋值。并且在中断处理结束后不需要手动清空 `mip`，中断信号会自行停止。（实际上是中断处理程序告诉外界停止发送信号）

#### CPU需要处理所有中断吗？

在某些场景下，我们不希望 CPU 处理中断（例如，我们已经在中断异常处理过程中，或者正在进行对性能要求很高的计算）。RISC-V 提供了一系列寄存器来控制 CPU 当前是否需要相应中断。`mstatus.mie` 是全局中断控制位。在 `mstatus.mie=1` 的情况下，`mie`(Machine Interrupt Enable)某位为 1，表示CPU会处理对应类型的中断，否则不会理会这个中断。

## 内存隔离

目前非常常用的是页式内存管理。我们从前因后果说一下这玩意在 RISC-V 上是怎么实现的。

先说一个最关键的问题：为什么 CPU 要分模式？因为如果所有程序都能完整访问一台电脑上的所有资源，那太吓人了，那一个程序写坏/读另一个程序的数据就太容易了。你可以把这理解成“大家都住在同一间屋子里，但每个人都能随便翻别人的抽屉”，这显然不行。

所以 RISC-V 把 CPU 分成了不同的特权模式。我们这里最先关心的是 M 模式、S 模式和 U 模式（还有一个 H 模式给虚拟机用，但不太成熟）：

- M 模式是机器模式，权限最高，通常是固件或者最底层的管理代码在跑。M 模式有 CPU 完整的访问权，且是 CPU 必选项。
- S 模式是监管者模式，一般是操作系统内核所在。
- U 模式是用户模式，通常是用户代码运行的地方。

在这个体系里，页表这件事主要是给 S/U 模式用的。也就是说，程序真正看到的不是物理地址，而是虚拟地址；至于这个虚拟地址到底映射到哪一块物理内存，要靠页表翻译。这样每个程序都可以“以为”自己拥有一整片连续的内存，但实际上它们背后对应的是不同的物理页面。

这就引出了 `satp`。`satp` 是用来告诉 CPU：现在要不要做地址翻译，以及页表根地址在哪里。只要 `satp` 里打开了分页，CPU 在取指或者访存时就不能直接把虚拟地址当物理地址用了，而是要先经过地址转换。

这里我们用的是 Sv39。名字里这个 39，指的是虚拟地址里真正参与翻译的高位部分一共 39 位。RISC-V 会把一个虚拟地址拆成三段页表索引，再加上页内偏移：

1. VPN[2]
2. VPN[1]
3. VPN[0]
4. page offset

你可以把它想成三层目录。最上面一层先根据 VPN[2] 找到第二层页表在哪；第二层再根据 VPN[1] 找到第三层页表在哪；第三层再根据 VPN[0] 找到最终对应的物理页框。最后再把 page offset 拼上去，得到真正的物理地址。

所以 Sv39 的核心思想其实很朴素：不是一次把整个大地址映射掉，而是通过三级查表，一层一层缩小范围，最后再定位到具体的物理页上。这样操作系统就可以很灵活地给不同程序分配不同的地址空间。

这里还要注意一个 CPU 模式的问题：分页不是“CPU 一开机就自动全局生效”的东西。它是有前提的。CPU 只有在相应的特权模式下，才会按照 `satp` 去做地址翻译；而更高权限的 M 模式一般仍然可以直接看到物理内存，作为系统最底层的管理者存在。换句话说，页表不是为了把 CPU 变复杂，而是为了让操作系统能控制“谁能看见哪块内存”。

这样就能解释内存隔离到底在隔离什么了。两个程序的虚拟地址可以完全一样，比如它们都从 `0x1000` 开始运行，但它们背后映射到的物理页面完全不同。于是程序 A 写自己的 `0x1000`，不会影响程序 B 的 `0x1000`。操作系统靠页表把“看起来一样”的地址，变成“实际上不同”的物理地址，这就是内存隔离。

如果你把这个过程再压缩一下，它其实就是：

虚拟地址 -> 查页表 -> 物理地址 -> 访问内存。

但是这里马上会出现一个新问题：如果查页表的时候发现这块虚拟地址根本没有被映射（比如发现页表这一项是不存在的），或者虽然映射了但权限不够，那 CPU 该怎么办？答案是：不能硬着头皮继续访问，而是要触发*缺页异常*，也就是页错误（page fault）。

缺页异常本质上还是一种 trap，只不过它不是外设主动打断你，也不是程序主动执行了 `ecall`，而是 CPU 在做地址翻译时自己发现“这次访问不成立”。比如：

1. 这页根本不在页表里。
2. 这页在页表里，但当前模式没有权限访问。
3. 这页在页表里，但访问类型不对，比如不该写却去写了。

这时候 CPU 通常会把出问题的地址记到 `mtval` 里，把原因记到 `mcause` 里，然后跳到 `mtvec` 指向的缺页处理程序。操作系统收到这个 trap 之后，可以选择去把对应页面调入内存、补好映射，再让程序继续跑；如果这个地址本来就是非法的，那就只能直接报错或者杀掉这个进程。

所以你可以把缺页中断理解成：分页系统为了让内存隔离真正生效，额外加出来的一道“门禁”。程序平时看见的是一个连续的虚拟地址空间，但每次真正访问时，CPU 都要先过页表这一关；过不去，就交给缺页处理程序来决定下一步怎么办。