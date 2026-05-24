
build/kernel.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00002117          	auipc	sp,0x2
    80000004:	22010113          	addi	sp,sp,544 # 80002220 <stack0>
    80000008:	00001537          	lui	a0,0x1
    8000000c:	00250133          	add	sp,a0,sp
    80000010:	4a8000ef          	jal	ra,800004b8 <main>

0000000080000014 <spin>:
    80000014:	0000006f          	j	80000014 <spin>

0000000080000018 <divide>:
// kernel/intops.c

int divide(int dividend, int divisor) {
    80000018:	ff010113          	addi	sp,sp,-16
    8000001c:	00813423          	sd	s0,8(sp)
    80000020:	01010413          	addi	s0,sp,16
    if (divisor == 0)
    80000024:	06058463          	beqz	a1,8000008c <divide+0x74>
    80000028:	00050793          	mv	a5,a0
        return 0;  // avoid divide by zero

    int quotient = 0;
    int positive = 1;

    if (dividend < 0) {
    8000002c:	02054e63          	bltz	a0,80000068 <divide+0x50>
        dividend = -dividend;
        positive = -positive;
    }
    if (divisor < 0) {
    80000030:	0405c863          	bltz	a1,80000080 <divide+0x68>
    int positive = 1;
    80000034:	00100693          	li	a3,1
        divisor = -divisor;
        positive = -positive;
    }

    while (dividend >= divisor) {
    80000038:	04b54a63          	blt	a0,a1,8000008c <divide+0x74>
        positive = -positive;
    8000003c:	00000513          	li	a0,0
        dividend -= divisor;
    80000040:	40b787bb          	subw	a5,a5,a1
        ++quotient;
    80000044:	00050713          	mv	a4,a0
    80000048:	0015051b          	addiw	a0,a0,1 # 1001 <_entry-0x7fffefff>
    while (dividend >= divisor) {
    8000004c:	feb7dae3          	bge	a5,a1,80000040 <divide+0x28>
    }

    return positive > 0 ? quotient : -quotient;
    80000050:	00100793          	li	a5,1
    80000054:	00f68463          	beq	a3,a5,8000005c <divide+0x44>
    80000058:	fff74513          	not	a0,a4
}
    8000005c:	00813403          	ld	s0,8(sp)
    80000060:	01010113          	addi	sp,sp,16
    80000064:	00008067          	ret
        dividend = -dividend;
    80000068:	40a0073b          	negw	a4,a0
    if (divisor < 0) {
    8000006c:	0205c863          	bltz	a1,8000009c <divide+0x84>
    while (dividend >= divisor) {
    80000070:	00b74e63          	blt	a4,a1,8000008c <divide+0x74>
    80000074:	00070793          	mv	a5,a4
        positive = -positive;
    80000078:	fff00693          	li	a3,-1
    8000007c:	fc1ff06f          	j	8000003c <divide+0x24>
        divisor = -divisor;
    80000080:	40b005bb          	negw	a1,a1
        positive = -positive;
    80000084:	fff00693          	li	a3,-1
    while (dividend >= divisor) {
    80000088:	fab55ae3          	bge	a0,a1,8000003c <divide+0x24>
}
    8000008c:	00813403          	ld	s0,8(sp)
        return 0;  // avoid divide by zero
    80000090:	00000513          	li	a0,0
}
    80000094:	01010113          	addi	sp,sp,16
    80000098:	00008067          	ret
        divisor = -divisor;
    8000009c:	40b006bb          	negw	a3,a1
    while (dividend >= divisor) {
    800000a0:	fea5c6e3          	blt	a1,a0,8000008c <divide+0x74>
        divisor = -divisor;
    800000a4:	00068593          	mv	a1,a3
        dividend = -dividend;
    800000a8:	00070793          	mv	a5,a4
        positive = -positive;
    800000ac:	00100693          	li	a3,1
    800000b0:	f8dff06f          	j	8000003c <divide+0x24>

00000000800000b4 <modulo>:

int modulo(int dividend, int divisor) {
    800000b4:	ff010113          	addi	sp,sp,-16
    800000b8:	00813423          	sd	s0,8(sp)
    800000bc:	01010413          	addi	s0,sp,16
    if (divisor == 0)
    800000c0:	04058c63          	beqz	a1,80000118 <modulo+0x64>
        return 0;  // avoid divide by zero

    int positive = 1;
    if (dividend < 0) {
    800000c4:	41f5d79b          	sraiw	a5,a1,0x1f
    800000c8:	00f5c5b3          	xor	a1,a1,a5
    800000cc:	40f587bb          	subw	a5,a1,a5
    800000d0:	00078593          	mv	a1,a5
    800000d4:	02054863          	bltz	a0,80000104 <modulo+0x50>
    int positive = 1;
    800000d8:	00100693          	li	a3,1
    }
    if (divisor < 0) {
        divisor = -divisor;
    }

    while (dividend >= divisor) {
    800000dc:	00f54e63          	blt	a0,a5,800000f8 <modulo+0x44>
        dividend -= divisor;
    800000e0:	00050713          	mv	a4,a0
    800000e4:	40f5053b          	subw	a0,a0,a5
    while (dividend >= divisor) {
    800000e8:	fef55ce3          	bge	a0,a5,800000e0 <modulo+0x2c>
    }

    return positive > 0 ? dividend : -dividend;
    800000ec:	00100793          	li	a5,1
    800000f0:	00f68463          	beq	a3,a5,800000f8 <modulo+0x44>
    800000f4:	40e5853b          	subw	a0,a1,a4
}
    800000f8:	00813403          	ld	s0,8(sp)
    800000fc:	01010113          	addi	sp,sp,16
    80000100:	00008067          	ret
        dividend = -dividend;
    80000104:	40a0073b          	negw	a4,a0
    while (dividend >= divisor) {
    80000108:	fef748e3          	blt	a4,a5,800000f8 <modulo+0x44>
    8000010c:	00070513          	mv	a0,a4
        positive = -positive;
    80000110:	fff00693          	li	a3,-1
    80000114:	fcdff06f          	j	800000e0 <modulo+0x2c>
}
    80000118:	00813403          	ld	s0,8(sp)
        return 0;  // avoid divide by zero
    8000011c:	00000513          	li	a0,0
}
    80000120:	01010113          	addi	sp,sp,16
    80000124:	00008067          	ret

0000000080000128 <printint.constprop.0>:
        uartputc(c);
    }
}

static void
printint(int xx, int base, int sign)
    80000128:	fa010113          	addi	sp,sp,-96
    8000012c:	41f5579b          	sraiw	a5,a0,0x1f
    80000130:	04813823          	sd	s0,80(sp)
    80000134:	04913423          	sd	s1,72(sp)
    80000138:	03313c23          	sd	s3,56(sp)
    8000013c:	03413823          	sd	s4,48(sp)
    80000140:	03513423          	sd	s5,40(sp)
    80000144:	03613023          	sd	s6,32(sp)
    80000148:	01713c23          	sd	s7,24(sp)
    8000014c:	06010413          	addi	s0,sp,96
    80000150:	04113c23          	sd	ra,88(sp)
    80000154:	05213023          	sd	s2,64(sp)
    80000158:	00f544b3          	xor	s1,a0,a5
    8000015c:	00050b13          	mv	s6,a0
    80000160:	00058a13          	mv	s4,a1
    80000164:	40f484bb          	subw	s1,s1,a5
    80000168:	fa040993          	addi	s3,s0,-96
    if (sign && (sign = xx < 0))
        x = -xx;
    else
        x = xx;

    i = 0;
    8000016c:	00000a93          	li	s5,0
    80000170:	00002b97          	auipc	s7,0x2
    80000174:	ea0b8b93          	addi	s7,s7,-352 # 80002010 <digits>
    do
    {
        buf[i++] = digits[modulo(x, base)];
    80000178:	000a0593          	mv	a1,s4
    8000017c:	00048513          	mv	a0,s1
    80000180:	00000097          	auipc	ra,0x0
    80000184:	f34080e7          	jalr	-204(ra) # 800000b4 <modulo>
    80000188:	00ab8533          	add	a0,s7,a0
    8000018c:	00054903          	lbu	s2,0(a0)
    } while ((x = divide(x, base)) != 0);
    80000190:	000a0593          	mv	a1,s4
    80000194:	00048513          	mv	a0,s1
        buf[i++] = digits[modulo(x, base)];
    80000198:	01298023          	sb	s2,0(s3)
    } while ((x = divide(x, base)) != 0);
    8000019c:	00000097          	auipc	ra,0x0
    800001a0:	e7c080e7          	jalr	-388(ra) # 80000018 <divide>
    800001a4:	000a8793          	mv	a5,s5
    800001a8:	00050493          	mv	s1,a0
        buf[i++] = digits[modulo(x, base)];
    800001ac:	001a8a9b          	addiw	s5,s5,1
    } while ((x = divide(x, base)) != 0);
    800001b0:	00198993          	addi	s3,s3,1
    800001b4:	fc0512e3          	bnez	a0,80000178 <printint.constprop.0+0x50>

    if (sign)
    800001b8:	000b5e63          	bgez	s6,800001d4 <printint.constprop.0+0xac>
        buf[i++] = '-';
    800001bc:	fb0a8793          	addi	a5,s5,-80
    800001c0:	008787b3          	add	a5,a5,s0
    800001c4:	02d00713          	li	a4,45
    800001c8:	fee78823          	sb	a4,-16(a5)
    800001cc:	02d00913          	li	s2,45
        buf[i++] = digits[modulo(x, base)];
    800001d0:	000a8793          	mv	a5,s5

    while (--i >= 0)
    800001d4:	fa040713          	addi	a4,s0,-96
    800001d8:	00f704b3          	add	s1,a4,a5
    800001dc:	00070993          	mv	s3,a4
    800001e0:	00c0006f          	j	800001ec <printint.constprop.0+0xc4>
        consputc(buf[i]);
    800001e4:	fff4c903          	lbu	s2,-1(s1)
    800001e8:	fff48493          	addi	s1,s1,-1
        uartputc(c);
    800001ec:	00090513          	mv	a0,s2
    800001f0:	00000097          	auipc	ra,0x0
    800001f4:	374080e7          	jalr	884(ra) # 80000564 <uartputc>
    while (--i >= 0)
    800001f8:	ff3496e3          	bne	s1,s3,800001e4 <printint.constprop.0+0xbc>
}
    800001fc:	05813083          	ld	ra,88(sp)
    80000200:	05013403          	ld	s0,80(sp)
    80000204:	04813483          	ld	s1,72(sp)
    80000208:	04013903          	ld	s2,64(sp)
    8000020c:	03813983          	ld	s3,56(sp)
    80000210:	03013a03          	ld	s4,48(sp)
    80000214:	02813a83          	ld	s5,40(sp)
    80000218:	02013b03          	ld	s6,32(sp)
    8000021c:	01813b83          	ld	s7,24(sp)
    80000220:	06010113          	addi	sp,sp,96
    80000224:	00008067          	ret

0000000080000228 <consputc>:
    if (c == BACKSPACE)
    80000228:	10000793          	li	a5,256
    8000022c:	00f50863          	beq	a0,a5,8000023c <consputc+0x14>
        uartputc(c);
    80000230:	0ff57513          	zext.b	a0,a0
    80000234:	00000317          	auipc	t1,0x0
    80000238:	33030067          	jr	816(t1) # 80000564 <uartputc>
{
    8000023c:	ff010113          	addi	sp,sp,-16
    80000240:	00113423          	sd	ra,8(sp)
    80000244:	00813023          	sd	s0,0(sp)
    80000248:	01010413          	addi	s0,sp,16
        uartputc('\b');
    8000024c:	00800513          	li	a0,8
    80000250:	00000097          	auipc	ra,0x0
    80000254:	314080e7          	jalr	788(ra) # 80000564 <uartputc>
        uartputc(' ');
    80000258:	02000513          	li	a0,32
    8000025c:	00000097          	auipc	ra,0x0
    80000260:	308080e7          	jalr	776(ra) # 80000564 <uartputc>
}
    80000264:	00013403          	ld	s0,0(sp)
    80000268:	00813083          	ld	ra,8(sp)
        uartputc('\b');
    8000026c:	00800513          	li	a0,8
}
    80000270:	01010113          	addi	sp,sp,16
        uartputc('\b');
    80000274:	00000317          	auipc	t1,0x0
    80000278:	2f030067          	jr	752(t1) # 80000564 <uartputc>

000000008000027c <printf>:
        consputc(digits[x >> (sizeof(uint64_t) * 8 - 4)]);
}

// Print to the console. only understands %d, %x, %p, %s.
void printf(char *fmt, ...)
{
    8000027c:	f5010113          	addi	sp,sp,-176
    80000280:	06813023          	sd	s0,96(sp)
    80000284:	05313423          	sd	s3,72(sp)
    80000288:	07010413          	addi	s0,sp,112
    8000028c:	06113423          	sd	ra,104(sp)
    80000290:	04913c23          	sd	s1,88(sp)
    80000294:	05213823          	sd	s2,80(sp)
    80000298:	05413023          	sd	s4,64(sp)
    8000029c:	03513c23          	sd	s5,56(sp)
    800002a0:	03613823          	sd	s6,48(sp)
    800002a4:	03713423          	sd	s7,40(sp)
    800002a8:	03813023          	sd	s8,32(sp)
    800002ac:	01913c23          	sd	s9,24(sp)
    800002b0:	00050993          	mv	s3,a0
    va_list ap;
    int i, c;
    char *s;

    va_start(ap, fmt);
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800002b4:	00054503          	lbu	a0,0(a0)
{
    800002b8:	02f43423          	sd	a5,40(s0)
    va_start(ap, fmt);
    800002bc:	00840793          	addi	a5,s0,8
{
    800002c0:	00b43423          	sd	a1,8(s0)
    800002c4:	00c43823          	sd	a2,16(s0)
    800002c8:	00d43c23          	sd	a3,24(s0)
    800002cc:	02e43023          	sd	a4,32(s0)
    800002d0:	03043823          	sd	a6,48(s0)
    800002d4:	03143c23          	sd	a7,56(s0)
    va_start(ap, fmt);
    800002d8:	f8f43c23          	sd	a5,-104(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800002dc:	06050c63          	beqz	a0,80000354 <printf+0xd8>
    800002e0:	0005079b          	sext.w	a5,a0
    800002e4:	00000913          	li	s2,0
    {
        if (c != '%')
    800002e8:	02500a93          	li	s5,37
            continue;
        }
        c = fmt[++i] & 0xff;
        if (c == 0)
            break;
        switch (c)
    800002ec:	07000b13          	li	s6,112
    800002f0:	00002a17          	auipc	s4,0x2
    800002f4:	d20a0a13          	addi	s4,s4,-736 # 80002010 <digits>
    800002f8:	07300c13          	li	s8,115
    800002fc:	06400b93          	li	s7,100
        if (c != '%')
    80000300:	0d579263          	bne	a5,s5,800003c4 <printf+0x148>
        c = fmt[++i] & 0xff;
    80000304:	0019091b          	addiw	s2,s2,1
    80000308:	012987b3          	add	a5,s3,s2
    8000030c:	0007c483          	lbu	s1,0(a5)
        if (c == 0)
    80000310:	04048263          	beqz	s1,80000354 <printf+0xd8>
        switch (c)
    80000314:	0d648663          	beq	s1,s6,800003e0 <printf+0x164>
    80000318:	069b6863          	bltu	s6,s1,80000388 <printf+0x10c>
    8000031c:	0b548a63          	beq	s1,s5,800003d0 <printf+0x154>
    80000320:	09749a63          	bne	s1,s7,800003b4 <printf+0x138>
        {
        case 'd':
            printint(va_arg(ap, int), 10, 1);
    80000324:	f9843783          	ld	a5,-104(s0)
    80000328:	00a00593          	li	a1,10
    8000032c:	0007a503          	lw	a0,0(a5)
    80000330:	00878793          	addi	a5,a5,8
    80000334:	f8f43c23          	sd	a5,-104(s0)
    80000338:	00000097          	auipc	ra,0x0
    8000033c:	df0080e7          	jalr	-528(ra) # 80000128 <printint.constprop.0>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000340:	0019091b          	addiw	s2,s2,1
    80000344:	012987b3          	add	a5,s3,s2
    80000348:	0007c503          	lbu	a0,0(a5)
    8000034c:	0005079b          	sext.w	a5,a0
    80000350:	fa0518e3          	bnez	a0,80000300 <printf+0x84>
            consputc(c);
            break;
        }
    }
    va_end(ap);
}
    80000354:	06813083          	ld	ra,104(sp)
    80000358:	06013403          	ld	s0,96(sp)
    8000035c:	05813483          	ld	s1,88(sp)
    80000360:	05013903          	ld	s2,80(sp)
    80000364:	04813983          	ld	s3,72(sp)
    80000368:	04013a03          	ld	s4,64(sp)
    8000036c:	03813a83          	ld	s5,56(sp)
    80000370:	03013b03          	ld	s6,48(sp)
    80000374:	02813b83          	ld	s7,40(sp)
    80000378:	02013c03          	ld	s8,32(sp)
    8000037c:	01813c83          	ld	s9,24(sp)
    80000380:	0b010113          	addi	sp,sp,176
    80000384:	00008067          	ret
        switch (c)
    80000388:	0b848463          	beq	s1,s8,80000430 <printf+0x1b4>
    8000038c:	07800793          	li	a5,120
    80000390:	02f49263          	bne	s1,a5,800003b4 <printf+0x138>
            printint(va_arg(ap, int), 16, 1);
    80000394:	f9843783          	ld	a5,-104(s0)
    80000398:	01000593          	li	a1,16
    8000039c:	0007a503          	lw	a0,0(a5)
    800003a0:	00878793          	addi	a5,a5,8
    800003a4:	f8f43c23          	sd	a5,-104(s0)
    800003a8:	00000097          	auipc	ra,0x0
    800003ac:	d80080e7          	jalr	-640(ra) # 80000128 <printint.constprop.0>
            break;
    800003b0:	f91ff06f          	j	80000340 <printf+0xc4>
        uartputc(c);
    800003b4:	02500513          	li	a0,37
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	1ac080e7          	jalr	428(ra) # 80000564 <uartputc>
    800003c0:	00048513          	mv	a0,s1
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	1a0080e7          	jalr	416(ra) # 80000564 <uartputc>
    800003cc:	f75ff06f          	j	80000340 <printf+0xc4>
    800003d0:	02500513          	li	a0,37
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	190080e7          	jalr	400(ra) # 80000564 <uartputc>
}
    800003dc:	f65ff06f          	j	80000340 <printf+0xc4>
            printptr(va_arg(ap, uint64_t));
    800003e0:	f9843783          	ld	a5,-104(s0)
        uartputc(c);
    800003e4:	03000513          	li	a0,48
    800003e8:	01000c93          	li	s9,16
            printptr(va_arg(ap, uint64_t));
    800003ec:	00878713          	addi	a4,a5,8
    800003f0:	0007b483          	ld	s1,0(a5)
    800003f4:	f8e43c23          	sd	a4,-104(s0)
        uartputc(c);
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	16c080e7          	jalr	364(ra) # 80000564 <uartputc>
    80000400:	07800513          	li	a0,120
    80000404:	00000097          	auipc	ra,0x0
    80000408:	160080e7          	jalr	352(ra) # 80000564 <uartputc>
        consputc(digits[x >> (sizeof(uint64_t) * 8 - 4)]);
    8000040c:	03c4d793          	srli	a5,s1,0x3c
    80000410:	00fa07b3          	add	a5,s4,a5
        uartputc(c);
    80000414:	0007c503          	lbu	a0,0(a5)
    for (i = 0; i < (sizeof(uint64_t) * 2); i++, x <<= 4)
    80000418:	fffc8c9b          	addiw	s9,s9,-1
    8000041c:	00449493          	slli	s1,s1,0x4
        uartputc(c);
    80000420:	00000097          	auipc	ra,0x0
    80000424:	144080e7          	jalr	324(ra) # 80000564 <uartputc>
    for (i = 0; i < (sizeof(uint64_t) * 2); i++, x <<= 4)
    80000428:	fe0c92e3          	bnez	s9,8000040c <printf+0x190>
    8000042c:	f15ff06f          	j	80000340 <printf+0xc4>
            if ((s = va_arg(ap, char *)) == 0)
    80000430:	f9843783          	ld	a5,-104(s0)
    80000434:	0007b483          	ld	s1,0(a5)
    80000438:	00878793          	addi	a5,a5,8
    8000043c:	f8f43c23          	sd	a5,-104(s0)
    80000440:	00049a63          	bnez	s1,80000454 <printf+0x1d8>
    80000444:	01c0006f          	j	80000460 <printf+0x1e4>
            for (; *s; s++)
    80000448:	00148493          	addi	s1,s1,1
        uartputc(c);
    8000044c:	00000097          	auipc	ra,0x0
    80000450:	118080e7          	jalr	280(ra) # 80000564 <uartputc>
            for (; *s; s++)
    80000454:	0004c503          	lbu	a0,0(s1)
    80000458:	fe0518e3          	bnez	a0,80000448 <printf+0x1cc>
    8000045c:	ee5ff06f          	j	80000340 <printf+0xc4>
                s = "(null)";
    80000460:	00002497          	auipc	s1,0x2
    80000464:	ba048493          	addi	s1,s1,-1120 # 80002000 <syscall+0xa0>
            for (; *s; s++)
    80000468:	02800513          	li	a0,40
    8000046c:	fddff06f          	j	80000448 <printf+0x1cc>

0000000080000470 <panic>:

void panic(char *s)
{
    80000470:	fe010113          	addi	sp,sp,-32
    80000474:	00113c23          	sd	ra,24(sp)
    80000478:	00813823          	sd	s0,16(sp)
    8000047c:	00913423          	sd	s1,8(sp)
    80000480:	02010413          	addi	s0,sp,32
    80000484:	00050493          	mv	s1,a0
    printf("panic: ");
    80000488:	00002517          	auipc	a0,0x2
    8000048c:	b8050513          	addi	a0,a0,-1152 # 80002008 <syscall+0xa8>
    80000490:	00000097          	auipc	ra,0x0
    80000494:	dec080e7          	jalr	-532(ra) # 8000027c <printf>
    printf(s);
    80000498:	00048513          	mv	a0,s1
    8000049c:	00000097          	auipc	ra,0x0
    800004a0:	de0080e7          	jalr	-544(ra) # 8000027c <printf>
    printf("\n");
    800004a4:	00002517          	auipc	a0,0x2
    800004a8:	ba450513          	addi	a0,a0,-1116 # 80002048 <digits+0x38>
    800004ac:	00000097          	auipc	ra,0x0
    800004b0:	dd0080e7          	jalr	-560(ra) # 8000027c <printf>
    for (;;)
    800004b4:	0000006f          	j	800004b4 <panic+0x44>

00000000800004b8 <main>:
extern void userinit(); // Init process (pid 1)
extern void scheduler(); // Start scheduling

char stack0[4096];
void main()
{
    800004b8:	ff010113          	addi	sp,sp,-16
    800004bc:	00113423          	sd	ra,8(sp)
    800004c0:	00813023          	sd	s0,0(sp)
    800004c4:	01010413          	addi	s0,sp,16
    printf("xv6 kernel is booting\n");
    800004c8:	00002517          	auipc	a0,0x2
    800004cc:	b6050513          	addi	a0,a0,-1184 # 80002028 <digits+0x18>
    800004d0:	00000097          	auipc	ra,0x0
    800004d4:	dac080e7          	jalr	-596(ra) # 8000027c <printf>
    kinit();
    800004d8:	00000097          	auipc	ra,0x0
    800004dc:	0bc080e7          	jalr	188(ra) # 80000594 <kinit>
    printf("kinit ok\n");
    800004e0:	00002517          	auipc	a0,0x2
    800004e4:	b6050513          	addi	a0,a0,-1184 # 80002040 <digits+0x30>
    800004e8:	00000097          	auipc	ra,0x0
    800004ec:	d94080e7          	jalr	-620(ra) # 8000027c <printf>
    procinit();
    800004f0:	00001097          	auipc	ra,0x1
    800004f4:	3dc080e7          	jalr	988(ra) # 800018cc <procinit>
    printf("procinit ok\n");
    800004f8:	00002517          	auipc	a0,0x2
    800004fc:	b5850513          	addi	a0,a0,-1192 # 80002050 <digits+0x40>
    80000500:	00000097          	auipc	ra,0x0
    80000504:	d7c080e7          	jalr	-644(ra) # 8000027c <printf>
    trapinit();
    80000508:	00002097          	auipc	ra,0x2
    8000050c:	8f8080e7          	jalr	-1800(ra) # 80001e00 <trapinit>
    printf("trapinit ok\n");
    80000510:	00002517          	auipc	a0,0x2
    80000514:	b5050513          	addi	a0,a0,-1200 # 80002060 <digits+0x50>
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d64080e7          	jalr	-668(ra) # 8000027c <printf>
    plicinit();
    80000520:	00002097          	auipc	ra,0x2
    80000524:	a14080e7          	jalr	-1516(ra) # 80001f34 <plicinit>
    printf("plicinit ok\n");
    80000528:	00002517          	auipc	a0,0x2
    8000052c:	b4850513          	addi	a0,a0,-1208 # 80002070 <digits+0x60>
    80000530:	00000097          	auipc	ra,0x0
    80000534:	d4c080e7          	jalr	-692(ra) # 8000027c <printf>
    userinit();
    80000538:	00001097          	auipc	ra,0x1
    8000053c:	654080e7          	jalr	1620(ra) # 80001b8c <userinit>
    printf("userinit ok\n");
    80000540:	00002517          	auipc	a0,0x2
    80000544:	b4050513          	addi	a0,a0,-1216 # 80002080 <digits+0x70>
    80000548:	00000097          	auipc	ra,0x0
    8000054c:	d34080e7          	jalr	-716(ra) # 8000027c <printf>
    scheduler();
    80000550:	00013403          	ld	s0,0(sp)
    80000554:	00813083          	ld	ra,8(sp)
    80000558:	01010113          	addi	sp,sp,16
    scheduler();
    8000055c:	00001317          	auipc	t1,0x1
    80000560:	52c30067          	jr	1324(t1) # 80001a88 <scheduler>

0000000080000564 <uartputc>:
#include "board.h"
#include "types.h"

void uartputc(uint8_t c)
{
    80000564:	ff010113          	addi	sp,sp,-16
    80000568:	00813423          	sd	s0,8(sp)
    8000056c:	01010413          	addi	s0,sp,16
    while ((*(uint8_t *) TX_READY) & 0x8) ;
    80000570:	406007b7          	lui	a5,0x40600
    80000574:	0087c783          	lbu	a5,8(a5) # 40600008 <_entry-0x3f9ffff8>
    80000578:	0087f793          	andi	a5,a5,8
    8000057c:	00079063          	bnez	a5,8000057c <uartputc+0x18>
    *(uint8_t *)TX_DATA = c;
    80000580:	406007b7          	lui	a5,0x40600
    80000584:	00a78223          	sb	a0,4(a5) # 40600004 <_entry-0x3f9ffffc>
    80000588:	00813403          	ld	s0,8(sp)
    8000058c:	01010113          	addi	sp,sp,16
    80000590:	00008067          	ret

0000000080000594 <kinit>:

struct run *freelist;

void
kinit()
{
    80000594:	fc010113          	addi	sp,sp,-64
    80000598:	02913423          	sd	s1,40(sp)

void
freerange(void *pa_start, void *pa_end)
{
    char *p;
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    8000059c:	fffff7b7          	lui	a5,0xfffff
    800005a0:	00004497          	auipc	s1,0x4
    800005a4:	f8f48493          	addi	s1,s1,-113 # 8000452f <end+0xfff>
{
    800005a8:	02813823          	sd	s0,48(sp)
    800005ac:	01313c23          	sd	s3,24(sp)
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    800005b0:	00f4f4b3          	and	s1,s1,a5
{
    800005b4:	02113c23          	sd	ra,56(sp)
    800005b8:	03213023          	sd	s2,32(sp)
    800005bc:	01413823          	sd	s4,16(sp)
    800005c0:	01513423          	sd	s5,8(sp)
    800005c4:	04010413          	addi	s0,sp,64
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800005c8:	000017b7          	lui	a5,0x1
    800005cc:	080019b7          	lui	s3,0x8001
    800005d0:	00f487b3          	add	a5,s1,a5
    800005d4:	00499993          	slli	s3,s3,0x4
    800005d8:	04f9ee63          	bltu	s3,a5,80000634 <kinit+0xa0>
    800005dc:	00003a97          	auipc	s5,0x3
    800005e0:	f54a8a93          	addi	s5,s5,-172 # 80003530 <end>
    800005e4:	00002917          	auipc	s2,0x2
    800005e8:	c2c90913          	addi	s2,s2,-980 # 80002210 <freelist>
kfree(void *pa)
{
    struct run *r;

    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
        panic("kfree");
    800005ec:	00002a17          	auipc	s4,0x2
    800005f0:	aa4a0a13          	addi	s4,s4,-1372 # 80002090 <digits+0x80>
    800005f4:	000a0513          	mv	a0,s4
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    800005f8:	0154e463          	bltu	s1,s5,80000600 <kinit+0x6c>
    800005fc:	0134e663          	bltu	s1,s3,80000608 <kinit+0x74>
        panic("kfree");
    80000600:	00000097          	auipc	ra,0x0
    80000604:	e70080e7          	jalr	-400(ra) # 80000470 <panic>

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000608:	00048513          	mv	a0,s1
    8000060c:	00001637          	lui	a2,0x1
    80000610:	00100593          	li	a1,1
    80000614:	00000097          	auipc	ra,0x0
    80000618:	204080e7          	jalr	516(ra) # 80000818 <memset>

    r = (struct run*)pa;

    r->next = freelist;
    8000061c:	00093783          	ld	a5,0(s2)
    80000620:	00f4b023          	sd	a5,0(s1)
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000624:	000017b7          	lui	a5,0x1
    freelist = r;
    80000628:	00993023          	sd	s1,0(s2)
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000062c:	00f484b3          	add	s1,s1,a5
    80000630:	fd3492e3          	bne	s1,s3,800005f4 <kinit+0x60>
}
    80000634:	03813083          	ld	ra,56(sp)
    80000638:	03013403          	ld	s0,48(sp)
    8000063c:	02813483          	ld	s1,40(sp)
    80000640:	02013903          	ld	s2,32(sp)
    80000644:	01813983          	ld	s3,24(sp)
    80000648:	01013a03          	ld	s4,16(sp)
    8000064c:	00813a83          	ld	s5,8(sp)
    80000650:	04010113          	addi	sp,sp,64
    80000654:	00008067          	ret

0000000080000658 <freerange>:
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    80000658:	000017b7          	lui	a5,0x1
{
    8000065c:	fb010113          	addi	sp,sp,-80
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    80000660:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
{
    80000664:	02913c23          	sd	s1,56(sp)
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    80000668:	00e504b3          	add	s1,a0,a4
    8000066c:	fffff737          	lui	a4,0xfffff
{
    80000670:	04813023          	sd	s0,64(sp)
    80000674:	04113423          	sd	ra,72(sp)
    80000678:	03213823          	sd	s2,48(sp)
    8000067c:	03313423          	sd	s3,40(sp)
    80000680:	03413023          	sd	s4,32(sp)
    80000684:	01513c23          	sd	s5,24(sp)
    80000688:	01613823          	sd	s6,16(sp)
    8000068c:	01713423          	sd	s7,8(sp)
    80000690:	05010413          	addi	s0,sp,80
    p = (char*)PGROUNDUP((uint64_t)pa_start);
    80000694:	00e4f4b3          	and	s1,s1,a4
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000698:	00f487b3          	add	a5,s1,a5
    8000069c:	06f5e863          	bltu	a1,a5,8000070c <freerange+0xb4>
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    800006a0:	08001bb7          	lui	s7,0x8001
    800006a4:	00058993          	mv	s3,a1
    800006a8:	00003b17          	auipc	s6,0x3
    800006ac:	e88b0b13          	addi	s6,s6,-376 # 80003530 <end>
    800006b0:	00002917          	auipc	s2,0x2
    800006b4:	b6090913          	addi	s2,s2,-1184 # 80002210 <freelist>
        panic("kfree");
    800006b8:	00002a97          	auipc	s5,0x2
    800006bc:	9d8a8a93          	addi	s5,s5,-1576 # 80002090 <digits+0x80>
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    800006c0:	004b9b93          	slli	s7,s7,0x4
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800006c4:	00002a37          	lui	s4,0x2
        panic("kfree");
    800006c8:	000a8513          	mv	a0,s5
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    800006cc:	0164e463          	bltu	s1,s6,800006d4 <freerange+0x7c>
    800006d0:	0174e663          	bltu	s1,s7,800006dc <freerange+0x84>
        panic("kfree");
    800006d4:	00000097          	auipc	ra,0x0
    800006d8:	d9c080e7          	jalr	-612(ra) # 80000470 <panic>
    memset(pa, 1, PGSIZE);
    800006dc:	00048513          	mv	a0,s1
    800006e0:	00001637          	lui	a2,0x1
    800006e4:	00100593          	li	a1,1
    800006e8:	00000097          	auipc	ra,0x0
    800006ec:	130080e7          	jalr	304(ra) # 80000818 <memset>
    r->next = freelist;
    800006f0:	00093703          	ld	a4,0(s2)
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800006f4:	014487b3          	add	a5,s1,s4
    r->next = freelist;
    800006f8:	00e4b023          	sd	a4,0(s1)
    freelist = r;
    800006fc:	00993023          	sd	s1,0(s2)
    for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000700:	00001737          	lui	a4,0x1
    80000704:	00e484b3          	add	s1,s1,a4
    80000708:	fcf9f0e3          	bgeu	s3,a5,800006c8 <freerange+0x70>
}
    8000070c:	04813083          	ld	ra,72(sp)
    80000710:	04013403          	ld	s0,64(sp)
    80000714:	03813483          	ld	s1,56(sp)
    80000718:	03013903          	ld	s2,48(sp)
    8000071c:	02813983          	ld	s3,40(sp)
    80000720:	02013a03          	ld	s4,32(sp)
    80000724:	01813a83          	ld	s5,24(sp)
    80000728:	01013b03          	ld	s6,16(sp)
    8000072c:	00813b83          	ld	s7,8(sp)
    80000730:	05010113          	addi	sp,sp,80
    80000734:	00008067          	ret

0000000080000738 <kfree>:
{
    80000738:	fe010113          	addi	sp,sp,-32
    8000073c:	00813823          	sd	s0,16(sp)
    80000740:	00913423          	sd	s1,8(sp)
    80000744:	00113c23          	sd	ra,24(sp)
    80000748:	02010413          	addi	s0,sp,32
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    8000074c:	03451793          	slli	a5,a0,0x34
{
    80000750:	00050493          	mv	s1,a0
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    80000754:	00079863          	bnez	a5,80000764 <kfree+0x2c>
    80000758:	00003797          	auipc	a5,0x3
    8000075c:	dd878793          	addi	a5,a5,-552 # 80003530 <end>
    80000760:	04f57863          	bgeu	a0,a5,800007b0 <kfree+0x78>
        panic("kfree");
    80000764:	00002517          	auipc	a0,0x2
    80000768:	92c50513          	addi	a0,a0,-1748 # 80002090 <digits+0x80>
    8000076c:	00000097          	auipc	ra,0x0
    80000770:	d04080e7          	jalr	-764(ra) # 80000470 <panic>
    memset(pa, 1, PGSIZE);
    80000774:	00048513          	mv	a0,s1
    80000778:	00001637          	lui	a2,0x1
    8000077c:	00100593          	li	a1,1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	098080e7          	jalr	152(ra) # 80000818 <memset>
    r->next = freelist;
    80000788:	00002797          	auipc	a5,0x2
    8000078c:	a8878793          	addi	a5,a5,-1400 # 80002210 <freelist>
    80000790:	0007b703          	ld	a4,0(a5)
}
    80000794:	01813083          	ld	ra,24(sp)
    80000798:	01013403          	ld	s0,16(sp)
    r->next = freelist;
    8000079c:	00e4b023          	sd	a4,0(s1)
    freelist = r;
    800007a0:	0097b023          	sd	s1,0(a5)
}
    800007a4:	00813483          	ld	s1,8(sp)
    800007a8:	02010113          	addi	sp,sp,32
    800007ac:	00008067          	ret
    if(((uint64_t)pa % PGSIZE) != 0 || (char*)pa < end || (uint64_t)pa >= PHYSTOP)
    800007b0:	080017b7          	lui	a5,0x8001
    800007b4:	00479793          	slli	a5,a5,0x4
    800007b8:	faf56ee3          	bltu	a0,a5,80000774 <kfree+0x3c>
    800007bc:	fa9ff06f          	j	80000764 <kfree+0x2c>

00000000800007c0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800007c0:	fe010113          	addi	sp,sp,-32
    800007c4:	00813823          	sd	s0,16(sp)
    800007c8:	00913423          	sd	s1,8(sp)
    800007cc:	00113c23          	sd	ra,24(sp)
    800007d0:	02010413          	addi	s0,sp,32
    struct run *r;

    r = freelist;
    800007d4:	00002797          	auipc	a5,0x2
    800007d8:	a3c78793          	addi	a5,a5,-1476 # 80002210 <freelist>
    800007dc:	0007b483          	ld	s1,0(a5)
    if(r)
    800007e0:	02048063          	beqz	s1,80000800 <kalloc+0x40>
        freelist = r->next;
    800007e4:	0004b703          	ld	a4,0(s1)

    if(r)
        memset((char*)r, 5, PGSIZE); // fill with junk
    800007e8:	00001637          	lui	a2,0x1
    800007ec:	00500593          	li	a1,5
    800007f0:	00048513          	mv	a0,s1
        freelist = r->next;
    800007f4:	00e7b023          	sd	a4,0(a5)
        memset((char*)r, 5, PGSIZE); // fill with junk
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	020080e7          	jalr	32(ra) # 80000818 <memset>
    return (void*)r;
    80000800:	01813083          	ld	ra,24(sp)
    80000804:	01013403          	ld	s0,16(sp)
    80000808:	00048513          	mv	a0,s1
    8000080c:	00813483          	ld	s1,8(sp)
    80000810:	02010113          	addi	sp,sp,32
    80000814:	00008067          	ret

0000000080000818 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint32_t n)
{
    80000818:	ff010113          	addi	sp,sp,-16
    8000081c:	00813423          	sd	s0,8(sp)
    80000820:	01010413          	addi	s0,sp,16
    char *cdst = (char *) dst;
    int i;
    for(i = 0; i < n; i++){
    80000824:	02060263          	beqz	a2,80000848 <memset+0x30>
    80000828:	02061613          	slli	a2,a2,0x20
    8000082c:	02065613          	srli	a2,a2,0x20
        cdst[i] = c;
    80000830:	0ff5f593          	zext.b	a1,a1
    80000834:	00050793          	mv	a5,a0
    80000838:	00a60733          	add	a4,a2,a0
    8000083c:	00b78023          	sb	a1,0(a5)
    for(i = 0; i < n; i++){
    80000840:	00178793          	addi	a5,a5,1
    80000844:	fee79ce3          	bne	a5,a4,8000083c <memset+0x24>
    }
    return dst;
}
    80000848:	00813403          	ld	s0,8(sp)
    8000084c:	01010113          	addi	sp,sp,16
    80000850:	00008067          	ret

0000000080000854 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32_t n)
{
    80000854:	ff010113          	addi	sp,sp,-16
    80000858:	00813423          	sd	s0,8(sp)
    8000085c:	01010413          	addi	s0,sp,16
    const uint8_t *s1, *s2;

    s1 = v1;
    s2 = v2;
    while(n-- > 0){
    80000860:	02060e63          	beqz	a2,8000089c <memcmp+0x48>
    80000864:	02061613          	slli	a2,a2,0x20
    80000868:	02065613          	srli	a2,a2,0x20
    8000086c:	00c586b3          	add	a3,a1,a2
    80000870:	0080006f          	j	80000878 <memcmp+0x24>
    80000874:	02b68463          	beq	a3,a1,8000089c <memcmp+0x48>
        if(*s1 != *s2)
    80000878:	00054783          	lbu	a5,0(a0)
    8000087c:	0005c703          	lbu	a4,0(a1)
        return *s1 - *s2;
        s1++, s2++;
    80000880:	00150513          	addi	a0,a0,1
    80000884:	00158593          	addi	a1,a1,1
        if(*s1 != *s2)
    80000888:	fee786e3          	beq	a5,a4,80000874 <memcmp+0x20>
    }

    return 0;
}
    8000088c:	00813403          	ld	s0,8(sp)
        return *s1 - *s2;
    80000890:	40e7853b          	subw	a0,a5,a4
}
    80000894:	01010113          	addi	sp,sp,16
    80000898:	00008067          	ret
    8000089c:	00813403          	ld	s0,8(sp)
    return 0;
    800008a0:	00000513          	li	a0,0
}
    800008a4:	01010113          	addi	sp,sp,16
    800008a8:	00008067          	ret

00000000800008ac <memmove>:

void*
memmove(void *dst, const void *src, uint32_t n)
{
    800008ac:	ff010113          	addi	sp,sp,-16
    800008b0:	00813423          	sd	s0,8(sp)
    800008b4:	01010413          	addi	s0,sp,16
    const char *s;
    char *d;

    if(n == 0)
    800008b8:	02060863          	beqz	a2,800008e8 <memmove+0x3c>
        return dst;
    
    s = src;
    d = dst;
    if(s < d && s + n > d){
    800008bc:	02061793          	slli	a5,a2,0x20
        s += n;
        d += n;
        while(n-- > 0)
        *--d = *--s;
    } else
        while(n-- > 0)
    800008c0:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    if(s < d && s + n > d){
    800008c4:	0207d793          	srli	a5,a5,0x20
    800008c8:	02a5e663          	bltu	a1,a0,800008f4 <memmove+0x48>
    800008cc:	00f587b3          	add	a5,a1,a5
{
    800008d0:	00050713          	mv	a4,a0
        *d++ = *s++;
    800008d4:	0005c683          	lbu	a3,0(a1)
    800008d8:	00158593          	addi	a1,a1,1
    800008dc:	00170713          	addi	a4,a4,1 # 1001 <_entry-0x7fffefff>
    800008e0:	fed70fa3          	sb	a3,-1(a4)
        while(n-- > 0)
    800008e4:	fef598e3          	bne	a1,a5,800008d4 <memmove+0x28>

    return dst;
}
    800008e8:	00813403          	ld	s0,8(sp)
    800008ec:	01010113          	addi	sp,sp,16
    800008f0:	00008067          	ret
    if(s < d && s + n > d){
    800008f4:	00f58733          	add	a4,a1,a5
    800008f8:	fce57ae3          	bgeu	a0,a4,800008cc <memmove+0x20>
        d += n;
    800008fc:	02069693          	slli	a3,a3,0x20
    80000900:	0206d693          	srli	a3,a3,0x20
    80000904:	fff6c693          	not	a3,a3
    80000908:	00f507b3          	add	a5,a0,a5
        while(n-- > 0)
    8000090c:	00d706b3          	add	a3,a4,a3
        *--d = *--s;
    80000910:	fff74603          	lbu	a2,-1(a4)
    80000914:	fff70713          	addi	a4,a4,-1
    80000918:	fff78793          	addi	a5,a5,-1
    8000091c:	00c78023          	sb	a2,0(a5)
        while(n-- > 0)
    80000920:	fee698e3          	bne	a3,a4,80000910 <memmove+0x64>
}
    80000924:	00813403          	ld	s0,8(sp)
    80000928:	01010113          	addi	sp,sp,16
    8000092c:	00008067          	ret

0000000080000930 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint32_t n)
{
    80000930:	ff010113          	addi	sp,sp,-16
    80000934:	00813423          	sd	s0,8(sp)
    80000938:	01010413          	addi	s0,sp,16
    return memmove(dst, src, n);
}
    8000093c:	00813403          	ld	s0,8(sp)
    80000940:	01010113          	addi	sp,sp,16
    return memmove(dst, src, n);
    80000944:	00000317          	auipc	t1,0x0
    80000948:	f6830067          	jr	-152(t1) # 800008ac <memmove>

000000008000094c <strncmp>:

int
strncmp(const char *p, const char *q, uint32_t n)
{
    8000094c:	ff010113          	addi	sp,sp,-16
    80000950:	00813423          	sd	s0,8(sp)
    80000954:	01010413          	addi	s0,sp,16
    while(n > 0 && *p && *p == *q)
    80000958:	04060063          	beqz	a2,80000998 <strncmp+0x4c>
    8000095c:	02061613          	slli	a2,a2,0x20
    80000960:	02065613          	srli	a2,a2,0x20
    80000964:	00c586b3          	add	a3,a1,a2
    80000968:	0100006f          	j	80000978 <strncmp+0x2c>
        n--, p++, q++;
    8000096c:	00150513          	addi	a0,a0,1
    while(n > 0 && *p && *p == *q)
    80000970:	00e79c63          	bne	a5,a4,80000988 <strncmp+0x3c>
    80000974:	02d58263          	beq	a1,a3,80000998 <strncmp+0x4c>
    80000978:	00054783          	lbu	a5,0(a0)
        n--, p++, q++;
    8000097c:	00158593          	addi	a1,a1,1
    while(n > 0 && *p && *p == *q)
    80000980:	fff5c703          	lbu	a4,-1(a1)
    80000984:	fe0794e3          	bnez	a5,8000096c <strncmp+0x20>
    if(n == 0)
        return 0;
    return (uint8_t)*p - (uint8_t)*q;
}
    80000988:	00813403          	ld	s0,8(sp)
    return (uint8_t)*p - (uint8_t)*q;
    8000098c:	40e7853b          	subw	a0,a5,a4
}
    80000990:	01010113          	addi	sp,sp,16
    80000994:	00008067          	ret
    80000998:	00813403          	ld	s0,8(sp)
        return 0;
    8000099c:	00000513          	li	a0,0
}
    800009a0:	01010113          	addi	sp,sp,16
    800009a4:	00008067          	ret

00000000800009a8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800009a8:	ff010113          	addi	sp,sp,-16
    800009ac:	00813423          	sd	s0,8(sp)
    800009b0:	01010413          	addi	s0,sp,16
    char *os;

    os = s;
    while(n-- > 0 && (*s++ = *t++) != 0)
    800009b4:	00050713          	mv	a4,a0
    800009b8:	0180006f          	j	800009d0 <strncpy+0x28>
    800009bc:	0005c783          	lbu	a5,0(a1)
    800009c0:	00170713          	addi	a4,a4,1
    800009c4:	00158593          	addi	a1,a1,1
    800009c8:	fef70fa3          	sb	a5,-1(a4)
    800009cc:	00078863          	beqz	a5,800009dc <strncpy+0x34>
    800009d0:	00060813          	mv	a6,a2
    800009d4:	fff6061b          	addiw	a2,a2,-1
    800009d8:	ff0042e3          	bgtz	a6,800009bc <strncpy+0x14>
        ;
    while(n-- > 0)
    800009dc:	00070693          	mv	a3,a4
    800009e0:	00c05e63          	blez	a2,800009fc <strncpy+0x54>
        *s++ = 0;
    800009e4:	00168693          	addi	a3,a3,1
    800009e8:	40d707bb          	subw	a5,a4,a3
    800009ec:	fff7879b          	addiw	a5,a5,-1
    while(n-- > 0)
    800009f0:	010787bb          	addw	a5,a5,a6
        *s++ = 0;
    800009f4:	fe068fa3          	sb	zero,-1(a3)
    while(n-- > 0)
    800009f8:	fef046e3          	bgtz	a5,800009e4 <strncpy+0x3c>
    return os;
}
    800009fc:	00813403          	ld	s0,8(sp)
    80000a00:	01010113          	addi	sp,sp,16
    80000a04:	00008067          	ret

0000000080000a08 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000a08:	ff010113          	addi	sp,sp,-16
    80000a0c:	00813423          	sd	s0,8(sp)
    80000a10:	01010413          	addi	s0,sp,16
    char *os;

    os = s;
    if(n <= 0)
    80000a14:	02c05a63          	blez	a2,80000a48 <safestrcpy+0x40>
    80000a18:	fff6069b          	addiw	a3,a2,-1
    80000a1c:	02069693          	slli	a3,a3,0x20
    80000a20:	0206d693          	srli	a3,a3,0x20
    80000a24:	00d586b3          	add	a3,a1,a3
    80000a28:	00050793          	mv	a5,a0
        return os;
    while(--n > 0 && (*s++ = *t++) != 0)
    80000a2c:	00d58c63          	beq	a1,a3,80000a44 <safestrcpy+0x3c>
    80000a30:	0005c703          	lbu	a4,0(a1)
    80000a34:	00178793          	addi	a5,a5,1
    80000a38:	00158593          	addi	a1,a1,1
    80000a3c:	fee78fa3          	sb	a4,-1(a5)
    80000a40:	fe0716e3          	bnez	a4,80000a2c <safestrcpy+0x24>
        ;
    *s = 0;
    80000a44:	00078023          	sb	zero,0(a5)
    return os;
}
    80000a48:	00813403          	ld	s0,8(sp)
    80000a4c:	01010113          	addi	sp,sp,16
    80000a50:	00008067          	ret

0000000080000a54 <strlen>:

int
strlen(const char *s)
{
    80000a54:	ff010113          	addi	sp,sp,-16
    80000a58:	00813423          	sd	s0,8(sp)
    80000a5c:	01010413          	addi	s0,sp,16
    int n;

    for(n = 0; s[n]; n++)
    80000a60:	00054783          	lbu	a5,0(a0)
    80000a64:	02078463          	beqz	a5,80000a8c <strlen+0x38>
    80000a68:	00150793          	addi	a5,a0,1
    80000a6c:	40a006bb          	negw	a3,a0
    80000a70:	0007c703          	lbu	a4,0(a5)
    80000a74:	00f6853b          	addw	a0,a3,a5
    80000a78:	00178793          	addi	a5,a5,1
    80000a7c:	fe071ae3          	bnez	a4,80000a70 <strlen+0x1c>
        ;
    return n;
}
    80000a80:	00813403          	ld	s0,8(sp)
    80000a84:	01010113          	addi	sp,sp,16
    80000a88:	00008067          	ret
    80000a8c:	00813403          	ld	s0,8(sp)
    for(n = 0; s[n]; n++)
    80000a90:	00000513          	li	a0,0
}
    80000a94:	01010113          	addi	sp,sp,16
    80000a98:	00008067          	ret

0000000080000a9c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64_t va, int alloc)
{
    80000a9c:	fc010113          	addi	sp,sp,-64
    80000aa0:	02813823          	sd	s0,48(sp)
    80000aa4:	03213023          	sd	s2,32(sp)
    80000aa8:	01313c23          	sd	s3,24(sp)
    80000aac:	01513423          	sd	s5,8(sp)
    80000ab0:	02113c23          	sd	ra,56(sp)
    80000ab4:	02913423          	sd	s1,40(sp)
    80000ab8:	01413823          	sd	s4,16(sp)
    80000abc:	01613023          	sd	s6,0(sp)
    80000ac0:	04010413          	addi	s0,sp,64
    if (va >= MAXVA)
    80000ac4:	fff00793          	li	a5,-1
    80000ac8:	01a7d793          	srli	a5,a5,0x1a
{
    80000acc:	00058a93          	mv	s5,a1
    80000ad0:	00050913          	mv	s2,a0
    80000ad4:	00060993          	mv	s3,a2
    if (va >= MAXVA)
    80000ad8:	0ab7ee63          	bltu	a5,a1,80000b94 <walk+0xf8>
{
    80000adc:	00200b13          	li	s6,2
    80000ae0:	00200793          	li	a5,2
        panic("walk");

    for (int level = 2; level > 0; level--)
    80000ae4:	00100a13          	li	s4,1
    {
        pte_t *pte = &pagetable[PX(level, va)];
    80000ae8:	0037949b          	slliw	s1,a5,0x3
    80000aec:	00f484bb          	addw	s1,s1,a5
    80000af0:	00c4849b          	addiw	s1,s1,12
    80000af4:	009ad4b3          	srl	s1,s5,s1
    80000af8:	1ff4f493          	andi	s1,s1,511
    80000afc:	00349493          	slli	s1,s1,0x3
    80000b00:	009904b3          	add	s1,s2,s1
        if (*pte & PTE_V)
    80000b04:	0004b903          	ld	s2,0(s1)
    80000b08:	00197793          	andi	a5,s2,1
        {
            pagetable = (pagetable_t)PTE2PA(*pte);
    80000b0c:	00a95913          	srli	s2,s2,0xa
    80000b10:	00c91913          	slli	s2,s2,0xc
        if (*pte & PTE_V)
    80000b14:	02079c63          	bnez	a5,80000b4c <walk+0xb0>
        }
        else
        {
            if (!alloc || (pagetable = (uint64_t *)kalloc()) == 0)
    80000b18:	08098863          	beqz	s3,80000ba8 <walk+0x10c>
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	ca4080e7          	jalr	-860(ra) # 800007c0 <kalloc>
                return 0;
            memset(pagetable, 0, PGSIZE);
    80000b24:	00001637          	lui	a2,0x1
    80000b28:	00000593          	li	a1,0
            if (!alloc || (pagetable = (uint64_t *)kalloc()) == 0)
    80000b2c:	00050913          	mv	s2,a0
    80000b30:	06050c63          	beqz	a0,80000ba8 <walk+0x10c>
            memset(pagetable, 0, PGSIZE);
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	ce4080e7          	jalr	-796(ra) # 80000818 <memset>
            *pte = PA2PTE(pagetable) | PTE_V;
    80000b3c:	00c95793          	srli	a5,s2,0xc
    80000b40:	00a79793          	slli	a5,a5,0xa
    80000b44:	0017e793          	ori	a5,a5,1
    80000b48:	00f4b023          	sd	a5,0(s1)
    for (int level = 2; level > 0; level--)
    80000b4c:	00100793          	li	a5,1
    80000b50:	034b1e63          	bne	s6,s4,80000b8c <walk+0xf0>
        }
    }
    return &pagetable[PX(0, va)];
    80000b54:	00cada93          	srli	s5,s5,0xc
    80000b58:	1ffafa93          	andi	s5,s5,511
    80000b5c:	003a9a93          	slli	s5,s5,0x3
    80000b60:	01590533          	add	a0,s2,s5
}
    80000b64:	03813083          	ld	ra,56(sp)
    80000b68:	03013403          	ld	s0,48(sp)
    80000b6c:	02813483          	ld	s1,40(sp)
    80000b70:	02013903          	ld	s2,32(sp)
    80000b74:	01813983          	ld	s3,24(sp)
    80000b78:	01013a03          	ld	s4,16(sp)
    80000b7c:	00813a83          	ld	s5,8(sp)
    80000b80:	00013b03          	ld	s6,0(sp)
    80000b84:	04010113          	addi	sp,sp,64
    80000b88:	00008067          	ret
    80000b8c:	00100b13          	li	s6,1
    80000b90:	f59ff06f          	j	80000ae8 <walk+0x4c>
        panic("walk");
    80000b94:	00001517          	auipc	a0,0x1
    80000b98:	50450513          	addi	a0,a0,1284 # 80002098 <digits+0x88>
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	8d4080e7          	jalr	-1836(ra) # 80000470 <panic>
    80000ba4:	f39ff06f          	j	80000adc <walk+0x40>
                return 0;
    80000ba8:	00000513          	li	a0,0
    80000bac:	fb9ff06f          	j	80000b64 <walk+0xc8>

0000000080000bb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64_t va)
{
    pte_t *pte;
    uint64_t pa;

    if (va >= MAXVA)
    80000bb0:	fff00793          	li	a5,-1
    80000bb4:	01a7d793          	srli	a5,a5,0x1a
    80000bb8:	00b7f663          	bgeu	a5,a1,80000bc4 <walkaddr+0x14>
        return 0;
    80000bbc:	00000513          	li	a0,0
        return 0;
    if ((*pte & PTE_U) == 0)
        return 0;
    pa = PTE2PA(*pte);
    return pa;
}
    80000bc0:	00008067          	ret
{
    80000bc4:	ff010113          	addi	sp,sp,-16
    80000bc8:	00813023          	sd	s0,0(sp)
    80000bcc:	00113423          	sd	ra,8(sp)
    80000bd0:	01010413          	addi	s0,sp,16
    pte = walk(pagetable, va, 0);
    80000bd4:	00000613          	li	a2,0
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	ec4080e7          	jalr	-316(ra) # 80000a9c <walk>
    if (pte == 0)
    80000be0:	00050a63          	beqz	a0,80000bf4 <walkaddr+0x44>
    if ((*pte & PTE_V) == 0)
    80000be4:	00053503          	ld	a0,0(a0)
    if ((*pte & PTE_U) == 0)
    80000be8:	01100793          	li	a5,17
    80000bec:	01157713          	andi	a4,a0,17
    80000bf0:	00f70c63          	beq	a4,a5,80000c08 <walkaddr+0x58>
}
    80000bf4:	00813083          	ld	ra,8(sp)
    80000bf8:	00013403          	ld	s0,0(sp)
        return 0;
    80000bfc:	00000513          	li	a0,0
}
    80000c00:	01010113          	addi	sp,sp,16
    80000c04:	00008067          	ret
    80000c08:	00813083          	ld	ra,8(sp)
    80000c0c:	00013403          	ld	s0,0(sp)
    pa = PTE2PA(*pte);
    80000c10:	00a55513          	srli	a0,a0,0xa
    80000c14:	00c51513          	slli	a0,a0,0xc
}
    80000c18:	01010113          	addi	sp,sp,16
    80000c1c:	00008067          	ret

0000000080000c20 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64_t va, uint64_t size, uint64_t pa, int perm)
{
    80000c20:	fa010113          	addi	sp,sp,-96
    80000c24:	04813823          	sd	s0,80(sp)
    80000c28:	04913423          	sd	s1,72(sp)
    80000c2c:	05213023          	sd	s2,64(sp)
    80000c30:	03413823          	sd	s4,48(sp)
    80000c34:	03513423          	sd	s5,40(sp)
    80000c38:	01913423          	sd	s9,8(sp)
    80000c3c:	04113c23          	sd	ra,88(sp)
    80000c40:	03313c23          	sd	s3,56(sp)
    80000c44:	03613023          	sd	s6,32(sp)
    80000c48:	01713c23          	sd	s7,24(sp)
    80000c4c:	01813823          	sd	s8,16(sp)
    80000c50:	06010413          	addi	s0,sp,96
    80000c54:	00060493          	mv	s1,a2
    80000c58:	00050a13          	mv	s4,a0
    80000c5c:	00058c93          	mv	s9,a1
    80000c60:	00068913          	mv	s2,a3
    80000c64:	00070a93          	mv	s5,a4
    uint64_t a, last;
    pte_t *pte;

    if (size == 0)
    80000c68:	0c060c63          	beqz	a2,80000d40 <mappages+0x120>
        panic("mappages: size");

    a = PGROUNDDOWN(va);
    80000c6c:	fffff7b7          	lui	a5,0xfffff
    last = PGROUNDDOWN(va + size - 1);
    80000c70:	fffc8993          	addi	s3,s9,-1
    80000c74:	009989b3          	add	s3,s3,s1
    a = PGROUNDDOWN(va);
    80000c78:	00fcfcb3          	and	s9,s9,a5
    last = PGROUNDDOWN(va + size - 1);
    80000c7c:	00f9f9b3          	and	s3,s3,a5
    80000c80:	41990933          	sub	s2,s2,s9
    for (;;)
    {
        if ((pte = walk(pagetable, a, 1)) == 0)
            return -1;
        if (*pte & PTE_V)
            panic("mappages: remap");
    80000c84:	00001b97          	auipc	s7,0x1
    80000c88:	42cb8b93          	addi	s7,s7,1068 # 800020b0 <digits+0xa0>
        *pte = PA2PTE(pa) | perm | PTE_V;
        if (a == last)
            break;
        a += PGSIZE;
    80000c8c:	00001b37          	lui	s6,0x1
    80000c90:	0200006f          	j	80000cb0 <mappages+0x90>
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000c94:	00c4d493          	srli	s1,s1,0xc
    80000c98:	00a49493          	slli	s1,s1,0xa
    80000c9c:	0154e4b3          	or	s1,s1,s5
    80000ca0:	0014e493          	ori	s1,s1,1
    80000ca4:	009c3023          	sd	s1,0(s8)
        if (a == last)
    80000ca8:	053c8c63          	beq	s9,s3,80000d00 <mappages+0xe0>
        a += PGSIZE;
    80000cac:	016c8cb3          	add	s9,s9,s6
        if ((pte = walk(pagetable, a, 1)) == 0)
    80000cb0:	000c8593          	mv	a1,s9
    80000cb4:	00100613          	li	a2,1
    80000cb8:	000a0513          	mv	a0,s4
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	de0080e7          	jalr	-544(ra) # 80000a9c <walk>
    80000cc4:	00050c13          	mv	s8,a0
    80000cc8:	019904b3          	add	s1,s2,s9
    80000ccc:	02050e63          	beqz	a0,80000d08 <mappages+0xe8>
        if (*pte & PTE_V)
    80000cd0:	00053783          	ld	a5,0(a0)
    80000cd4:	0017f793          	andi	a5,a5,1
    80000cd8:	fa078ee3          	beqz	a5,80000c94 <mappages+0x74>
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000cdc:	00c4d493          	srli	s1,s1,0xc
    80000ce0:	00a49493          	slli	s1,s1,0xa
    80000ce4:	0154e4b3          	or	s1,s1,s5
            panic("mappages: remap");
    80000ce8:	000b8513          	mv	a0,s7
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000cec:	0014e493          	ori	s1,s1,1
            panic("mappages: remap");
    80000cf0:	fffff097          	auipc	ra,0xfffff
    80000cf4:	780080e7          	jalr	1920(ra) # 80000470 <panic>
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000cf8:	009c3023          	sd	s1,0(s8)
        if (a == last)
    80000cfc:	fb3c98e3          	bne	s9,s3,80000cac <mappages+0x8c>
        pa += PGSIZE;
    }
    return 0;
    80000d00:	00000513          	li	a0,0
    80000d04:	0080006f          	j	80000d0c <mappages+0xec>
            return -1;
    80000d08:	fff00513          	li	a0,-1
}
    80000d0c:	05813083          	ld	ra,88(sp)
    80000d10:	05013403          	ld	s0,80(sp)
    80000d14:	04813483          	ld	s1,72(sp)
    80000d18:	04013903          	ld	s2,64(sp)
    80000d1c:	03813983          	ld	s3,56(sp)
    80000d20:	03013a03          	ld	s4,48(sp)
    80000d24:	02813a83          	ld	s5,40(sp)
    80000d28:	02013b03          	ld	s6,32(sp)
    80000d2c:	01813b83          	ld	s7,24(sp)
    80000d30:	01013c03          	ld	s8,16(sp)
    80000d34:	00813c83          	ld	s9,8(sp)
    80000d38:	06010113          	addi	sp,sp,96
    80000d3c:	00008067          	ret
        panic("mappages: size");
    80000d40:	00001517          	auipc	a0,0x1
    80000d44:	36050513          	addi	a0,a0,864 # 800020a0 <digits+0x90>
    80000d48:	fffff097          	auipc	ra,0xfffff
    80000d4c:	728080e7          	jalr	1832(ra) # 80000470 <panic>
    80000d50:	f1dff06f          	j	80000c6c <mappages+0x4c>

0000000080000d54 <kvmmap>:
{
    80000d54:	ff010113          	addi	sp,sp,-16
    80000d58:	00813023          	sd	s0,0(sp)
    80000d5c:	00113423          	sd	ra,8(sp)
    80000d60:	01010413          	addi	s0,sp,16
    80000d64:	00060793          	mv	a5,a2
    if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000d68:	00068613          	mv	a2,a3
    80000d6c:	00078693          	mv	a3,a5
    80000d70:	00000097          	auipc	ra,0x0
    80000d74:	eb0080e7          	jalr	-336(ra) # 80000c20 <mappages>
    80000d78:	00051a63          	bnez	a0,80000d8c <kvmmap+0x38>
}
    80000d7c:	00813083          	ld	ra,8(sp)
    80000d80:	00013403          	ld	s0,0(sp)
    80000d84:	01010113          	addi	sp,sp,16
    80000d88:	00008067          	ret
    80000d8c:	00013403          	ld	s0,0(sp)
    80000d90:	00813083          	ld	ra,8(sp)
        panic("kvmmap");
    80000d94:	00001517          	auipc	a0,0x1
    80000d98:	32c50513          	addi	a0,a0,812 # 800020c0 <digits+0xb0>
}
    80000d9c:	01010113          	addi	sp,sp,16
        panic("kvmmap");
    80000da0:	fffff317          	auipc	t1,0xfffff
    80000da4:	6d030067          	jr	1744(t1) # 80000470 <panic>

0000000080000da8 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64_t va, uint64_t npages, int do_free)
{
    80000da8:	fa010113          	addi	sp,sp,-96
    80000dac:	04813823          	sd	s0,80(sp)
    80000db0:	05213023          	sd	s2,64(sp)
    80000db4:	03313c23          	sd	s3,56(sp)
    80000db8:	03413823          	sd	s4,48(sp)
    80000dbc:	01a13023          	sd	s10,0(sp)
    80000dc0:	04113c23          	sd	ra,88(sp)
    80000dc4:	04913423          	sd	s1,72(sp)
    80000dc8:	03513423          	sd	s5,40(sp)
    80000dcc:	03613023          	sd	s6,32(sp)
    80000dd0:	01713c23          	sd	s7,24(sp)
    80000dd4:	01813823          	sd	s8,16(sp)
    80000dd8:	01913423          	sd	s9,8(sp)
    80000ddc:	06010413          	addi	s0,sp,96
    uint64_t a;
    pte_t *pte;

    if ((va % PGSIZE) != 0)
    80000de0:	03459793          	slli	a5,a1,0x34
{
    80000de4:	00058d13          	mv	s10,a1
    80000de8:	00050993          	mv	s3,a0
    80000dec:	00060913          	mv	s2,a2
    80000df0:	00068a13          	mv	s4,a3
    if ((va % PGSIZE) != 0)
    80000df4:	0e079a63          	bnez	a5,80000ee8 <uvmunmap+0x140>
        panic("uvmunmap: not aligned");

    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80000df8:	00c91913          	slli	s2,s2,0xc
    80000dfc:	01a90933          	add	s2,s2,s10
    80000e00:	072d7263          	bgeu	s10,s2,80000e64 <uvmunmap+0xbc>
    {
        if ((pte = walk(pagetable, a, 0)) == 0)
            panic("uvmunmap: walk");
    80000e04:	00001c97          	auipc	s9,0x1
    80000e08:	2dcc8c93          	addi	s9,s9,732 # 800020e0 <digits+0xd0>
        if ((*pte & PTE_V) == 0)
            panic("uvmunmap: not mapped");
    80000e0c:	00001b97          	auipc	s7,0x1
    80000e10:	2e4b8b93          	addi	s7,s7,740 # 800020f0 <digits+0xe0>
        if (PTE_FLAGS(*pte) == PTE_V)
    80000e14:	00100b13          	li	s6,1
            panic("uvmunmap: not a leaf");
    80000e18:	00001c17          	auipc	s8,0x1
    80000e1c:	2f0c0c13          	addi	s8,s8,752 # 80002108 <digits+0xf8>
    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80000e20:	00001ab7          	lui	s5,0x1
        if ((pte = walk(pagetable, a, 0)) == 0)
    80000e24:	000d0593          	mv	a1,s10
    80000e28:	00000613          	li	a2,0
    80000e2c:	00098513          	mv	a0,s3
    80000e30:	00000097          	auipc	ra,0x0
    80000e34:	c6c080e7          	jalr	-916(ra) # 80000a9c <walk>
    80000e38:	00050493          	mv	s1,a0
    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80000e3c:	015d0d33          	add	s10,s10,s5
        if ((pte = walk(pagetable, a, 0)) == 0)
    80000e40:	08050c63          	beqz	a0,80000ed8 <uvmunmap+0x130>
        if ((*pte & PTE_V) == 0)
    80000e44:	0004b783          	ld	a5,0(s1)
    80000e48:	0017f713          	andi	a4,a5,1
    80000e4c:	06070c63          	beqz	a4,80000ec4 <uvmunmap+0x11c>
        if (PTE_FLAGS(*pte) == PTE_V)
    80000e50:	3ff7f793          	andi	a5,a5,1023
    80000e54:	05678463          	beq	a5,s6,80000e9c <uvmunmap+0xf4>
        if (do_free)
    80000e58:	040a1a63          	bnez	s4,80000eac <uvmunmap+0x104>
        {
            uint64_t pa = PTE2PA(*pte);
            kfree((void *)pa);
        }
        *pte = 0;
    80000e5c:	0004b023          	sd	zero,0(s1)
    for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80000e60:	fd2d62e3          	bltu	s10,s2,80000e24 <uvmunmap+0x7c>
    }
}
    80000e64:	05813083          	ld	ra,88(sp)
    80000e68:	05013403          	ld	s0,80(sp)
    80000e6c:	04813483          	ld	s1,72(sp)
    80000e70:	04013903          	ld	s2,64(sp)
    80000e74:	03813983          	ld	s3,56(sp)
    80000e78:	03013a03          	ld	s4,48(sp)
    80000e7c:	02813a83          	ld	s5,40(sp)
    80000e80:	02013b03          	ld	s6,32(sp)
    80000e84:	01813b83          	ld	s7,24(sp)
    80000e88:	01013c03          	ld	s8,16(sp)
    80000e8c:	00813c83          	ld	s9,8(sp)
    80000e90:	00013d03          	ld	s10,0(sp)
    80000e94:	06010113          	addi	sp,sp,96
    80000e98:	00008067          	ret
            panic("uvmunmap: not a leaf");
    80000e9c:	000c0513          	mv	a0,s8
    80000ea0:	fffff097          	auipc	ra,0xfffff
    80000ea4:	5d0080e7          	jalr	1488(ra) # 80000470 <panic>
        if (do_free)
    80000ea8:	fa0a0ae3          	beqz	s4,80000e5c <uvmunmap+0xb4>
            uint64_t pa = PTE2PA(*pte);
    80000eac:	0004b503          	ld	a0,0(s1)
    80000eb0:	00a55513          	srli	a0,a0,0xa
            kfree((void *)pa);
    80000eb4:	00c51513          	slli	a0,a0,0xc
    80000eb8:	00000097          	auipc	ra,0x0
    80000ebc:	880080e7          	jalr	-1920(ra) # 80000738 <kfree>
    80000ec0:	f9dff06f          	j	80000e5c <uvmunmap+0xb4>
            panic("uvmunmap: not mapped");
    80000ec4:	000b8513          	mv	a0,s7
    80000ec8:	fffff097          	auipc	ra,0xfffff
    80000ecc:	5a8080e7          	jalr	1448(ra) # 80000470 <panic>
        if (PTE_FLAGS(*pte) == PTE_V)
    80000ed0:	0004b783          	ld	a5,0(s1)
    80000ed4:	f7dff06f          	j	80000e50 <uvmunmap+0xa8>
            panic("uvmunmap: walk");
    80000ed8:	000c8513          	mv	a0,s9
    80000edc:	fffff097          	auipc	ra,0xfffff
    80000ee0:	594080e7          	jalr	1428(ra) # 80000470 <panic>
    80000ee4:	f61ff06f          	j	80000e44 <uvmunmap+0x9c>
        panic("uvmunmap: not aligned");
    80000ee8:	00001517          	auipc	a0,0x1
    80000eec:	1e050513          	addi	a0,a0,480 # 800020c8 <digits+0xb8>
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	580080e7          	jalr	1408(ra) # 80000470 <panic>
    80000ef8:	f01ff06f          	j	80000df8 <uvmunmap+0x50>

0000000080000efc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000efc:	fe010113          	addi	sp,sp,-32
    80000f00:	00813823          	sd	s0,16(sp)
    80000f04:	00913423          	sd	s1,8(sp)
    80000f08:	00113c23          	sd	ra,24(sp)
    80000f0c:	02010413          	addi	s0,sp,32
    pagetable_t pagetable;
    pagetable = (pagetable_t)kalloc();
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	8b0080e7          	jalr	-1872(ra) # 800007c0 <kalloc>
    80000f18:	00050493          	mv	s1,a0
    if (pagetable == 0)
    80000f1c:	00050a63          	beqz	a0,80000f30 <uvmcreate+0x34>
        return 0;
    memset(pagetable, 0, PGSIZE);
    80000f20:	00001637          	lui	a2,0x1
    80000f24:	00000593          	li	a1,0
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	8f0080e7          	jalr	-1808(ra) # 80000818 <memset>
    return pagetable;
}
    80000f30:	01813083          	ld	ra,24(sp)
    80000f34:	01013403          	ld	s0,16(sp)
    80000f38:	00048513          	mv	a0,s1
    80000f3c:	00813483          	ld	s1,8(sp)
    80000f40:	02010113          	addi	sp,sp,32
    80000f44:	00008067          	ret

0000000080000f48 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, char *src, uint32_t sz)
{
    80000f48:	fd010113          	addi	sp,sp,-48
    80000f4c:	02813023          	sd	s0,32(sp)
    80000f50:	01213823          	sd	s2,16(sp)
    80000f54:	01313423          	sd	s3,8(sp)
    80000f58:	01413023          	sd	s4,0(sp)
    80000f5c:	02113423          	sd	ra,40(sp)
    80000f60:	00913c23          	sd	s1,24(sp)
    80000f64:	03010413          	addi	s0,sp,48
    char *mem;

    if (sz >= PGSIZE)
    80000f68:	000017b7          	lui	a5,0x1
{
    80000f6c:	00060913          	mv	s2,a2
    80000f70:	00050a13          	mv	s4,a0
    80000f74:	00058993          	mv	s3,a1
    if (sz >= PGSIZE)
    80000f78:	06f67663          	bgeu	a2,a5,80000fe4 <uvmfirst+0x9c>
        panic("uvmfirst: more than a page");
    mem = kalloc();
    80000f7c:	00000097          	auipc	ra,0x0
    80000f80:	844080e7          	jalr	-1980(ra) # 800007c0 <kalloc>
    memset(mem, 0, PGSIZE);
    80000f84:	00001637          	lui	a2,0x1
    80000f88:	00000593          	li	a1,0
    mem = kalloc();
    80000f8c:	00050493          	mv	s1,a0
    memset(mem, 0, PGSIZE);
    80000f90:	00000097          	auipc	ra,0x0
    80000f94:	888080e7          	jalr	-1912(ra) # 80000818 <memset>
    mappages(pagetable, 0, PGSIZE, (uint64_t)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80000f98:	00048693          	mv	a3,s1
    80000f9c:	00001637          	lui	a2,0x1
    80000fa0:	00000593          	li	a1,0
    80000fa4:	000a0513          	mv	a0,s4
    80000fa8:	01e00713          	li	a4,30
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	c74080e7          	jalr	-908(ra) # 80000c20 <mappages>
    memmove(mem, src, sz);
}
    80000fb4:	02013403          	ld	s0,32(sp)
    80000fb8:	02813083          	ld	ra,40(sp)
    80000fbc:	00013a03          	ld	s4,0(sp)
    memmove(mem, src, sz);
    80000fc0:	00090613          	mv	a2,s2
    80000fc4:	00098593          	mv	a1,s3
}
    80000fc8:	01013903          	ld	s2,16(sp)
    80000fcc:	00813983          	ld	s3,8(sp)
    memmove(mem, src, sz);
    80000fd0:	00048513          	mv	a0,s1
}
    80000fd4:	01813483          	ld	s1,24(sp)
    80000fd8:	03010113          	addi	sp,sp,48
    memmove(mem, src, sz);
    80000fdc:	00000317          	auipc	t1,0x0
    80000fe0:	8d030067          	jr	-1840(t1) # 800008ac <memmove>
        panic("uvmfirst: more than a page");
    80000fe4:	00001517          	auipc	a0,0x1
    80000fe8:	13c50513          	addi	a0,a0,316 # 80002120 <digits+0x110>
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	484080e7          	jalr	1156(ra) # 80000470 <panic>
    80000ff4:	f89ff06f          	j	80000f7c <uvmfirst+0x34>

0000000080000ff8 <uvmalloc>:
uvmalloc(pagetable_t pagetable, uint64_t oldsz, uint64_t newsz, int xperm)
{
    char *mem;
    uint64_t a;

    if (newsz < oldsz)
    80000ff8:	0eb66a63          	bltu	a2,a1,800010ec <uvmalloc+0xf4>
        return oldsz;

    oldsz = PGROUNDUP(oldsz);
    80000ffc:	000017b7          	lui	a5,0x1
{
    80001000:	fc010113          	addi	sp,sp,-64
    oldsz = PGROUNDUP(oldsz);
    80001004:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
{
    80001008:	02813823          	sd	s0,48(sp)
    8000100c:	03213023          	sd	s2,32(sp)
    80001010:	01313c23          	sd	s3,24(sp)
    80001014:	01413823          	sd	s4,16(sp)
    80001018:	01513423          	sd	s5,8(sp)
    8000101c:	01613023          	sd	s6,0(sp)
    oldsz = PGROUNDUP(oldsz);
    80001020:	00f585b3          	add	a1,a1,a5
{
    80001024:	02113c23          	sd	ra,56(sp)
    80001028:	02913423          	sd	s1,40(sp)
    8000102c:	04010413          	addi	s0,sp,64
    oldsz = PGROUNDUP(oldsz);
    80001030:	fffff7b7          	lui	a5,0xfffff
    80001034:	00f5fb33          	and	s6,a1,a5
{
    80001038:	00060a93          	mv	s5,a2
    8000103c:	00050a13          	mv	s4,a0
    for (a = oldsz; a < newsz; a += PGSIZE)
    80001040:	000b0913          	mv	s2,s6
        {
            uvmdealloc(pagetable, a, oldsz);
            return 0;
        }
        memset(mem, 0, PGSIZE);
        if (mappages(pagetable, a, PGSIZE, (uint64_t)mem, PTE_R | PTE_U | xperm) != 0)
    80001044:	0126e993          	ori	s3,a3,18
    for (a = oldsz; a < newsz; a += PGSIZE)
    80001048:	02cb6e63          	bltu	s6,a2,80001084 <uvmalloc+0x8c>
    8000104c:	0a80006f          	j	800010f4 <uvmalloc+0xfc>
        memset(mem, 0, PGSIZE);
    80001050:	fffff097          	auipc	ra,0xfffff
    80001054:	7c8080e7          	jalr	1992(ra) # 80000818 <memset>
        if (mappages(pagetable, a, PGSIZE, (uint64_t)mem, PTE_R | PTE_U | xperm) != 0)
    80001058:	00098713          	mv	a4,s3
    8000105c:	00048693          	mv	a3,s1
    80001060:	00090593          	mv	a1,s2
    80001064:	00001637          	lui	a2,0x1
    80001068:	000a0513          	mv	a0,s4
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	bb4080e7          	jalr	-1100(ra) # 80000c20 <mappages>
    80001074:	08051463          	bnez	a0,800010fc <uvmalloc+0x104>
    for (a = oldsz; a < newsz; a += PGSIZE)
    80001078:	000017b7          	lui	a5,0x1
    8000107c:	00f90933          	add	s2,s2,a5
    80001080:	07597a63          	bgeu	s2,s5,800010f4 <uvmalloc+0xfc>
        mem = kalloc();
    80001084:	fffff097          	auipc	ra,0xfffff
    80001088:	73c080e7          	jalr	1852(ra) # 800007c0 <kalloc>
        memset(mem, 0, PGSIZE);
    8000108c:	00001637          	lui	a2,0x1
    80001090:	00000593          	li	a1,0
        mem = kalloc();
    80001094:	00050493          	mv	s1,a0
        if (mem == 0)
    80001098:	fa051ce3          	bnez	a0,80001050 <uvmalloc+0x58>
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64_t
uvmdealloc(pagetable_t pagetable, uint64_t oldsz, uint64_t newsz)
{
    if (newsz >= oldsz)
    8000109c:	032b7263          	bgeu	s6,s2,800010c0 <uvmalloc+0xc8>
        return oldsz;

    if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800010a0:	000017b7          	lui	a5,0x1
    800010a4:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800010a8:	fffff737          	lui	a4,0xfffff
    800010ac:	00fb05b3          	add	a1,s6,a5
    800010b0:	00f907b3          	add	a5,s2,a5
    800010b4:	00e5f5b3          	and	a1,a1,a4
    800010b8:	00e7f7b3          	and	a5,a5,a4
    800010bc:	06f5ee63          	bltu	a1,a5,80001138 <uvmalloc+0x140>
            return 0;
    800010c0:	00000513          	li	a0,0
}
    800010c4:	03813083          	ld	ra,56(sp)
    800010c8:	03013403          	ld	s0,48(sp)
    800010cc:	02813483          	ld	s1,40(sp)
    800010d0:	02013903          	ld	s2,32(sp)
    800010d4:	01813983          	ld	s3,24(sp)
    800010d8:	01013a03          	ld	s4,16(sp)
    800010dc:	00813a83          	ld	s5,8(sp)
    800010e0:	00013b03          	ld	s6,0(sp)
    800010e4:	04010113          	addi	sp,sp,64
    800010e8:	00008067          	ret
    800010ec:	00058513          	mv	a0,a1
    800010f0:	00008067          	ret
            return 0;
    800010f4:	000a8513          	mv	a0,s5
    800010f8:	fcdff06f          	j	800010c4 <uvmalloc+0xcc>
            kfree(mem);
    800010fc:	00048513          	mv	a0,s1
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	638080e7          	jalr	1592(ra) # 80000738 <kfree>
    if (newsz >= oldsz)
    80001108:	fb2b7ce3          	bgeu	s6,s2,800010c0 <uvmalloc+0xc8>
    if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    8000110c:	000017b7          	lui	a5,0x1
    80001110:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001114:	fffff737          	lui	a4,0xfffff
    80001118:	00fb05b3          	add	a1,s6,a5
    8000111c:	00f90933          	add	s2,s2,a5
    80001120:	00e5f5b3          	and	a1,a1,a4
    80001124:	00e97933          	and	s2,s2,a4
    80001128:	f925fce3          	bgeu	a1,s2,800010c0 <uvmalloc+0xc8>
    {
        int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000112c:	40b90633          	sub	a2,s2,a1
    80001130:	00c65613          	srli	a2,a2,0xc
    80001134:	00c0006f          	j	80001140 <uvmalloc+0x148>
    80001138:	40b787b3          	sub	a5,a5,a1
    8000113c:	00c7d613          	srli	a2,a5,0xc
        uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001140:	00100693          	li	a3,1
    80001144:	0006061b          	sext.w	a2,a2
    80001148:	000a0513          	mv	a0,s4
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	c5c080e7          	jalr	-932(ra) # 80000da8 <uvmunmap>
    80001154:	f6dff06f          	j	800010c0 <uvmalloc+0xc8>

0000000080001158 <uvmdealloc>:
{
    80001158:	fe010113          	addi	sp,sp,-32
    8000115c:	00813823          	sd	s0,16(sp)
    80001160:	00913423          	sd	s1,8(sp)
    80001164:	00113c23          	sd	ra,24(sp)
    80001168:	02010413          	addi	s0,sp,32
    8000116c:	00058493          	mv	s1,a1
    if (newsz >= oldsz)
    80001170:	02b67463          	bgeu	a2,a1,80001198 <uvmdealloc+0x40>
    if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80001174:	000017b7          	lui	a5,0x1
    80001178:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000117c:	fffff6b7          	lui	a3,0xfffff
    80001180:	00f60733          	add	a4,a2,a5
    80001184:	00f587b3          	add	a5,a1,a5
    80001188:	00d7f7b3          	and	a5,a5,a3
    8000118c:	00d775b3          	and	a1,a4,a3
    80001190:	00060493          	mv	s1,a2
    80001194:	00f5ee63          	bltu	a1,a5,800011b0 <uvmdealloc+0x58>
    }

    return newsz;
}
    80001198:	01813083          	ld	ra,24(sp)
    8000119c:	01013403          	ld	s0,16(sp)
    800011a0:	00048513          	mv	a0,s1
    800011a4:	00813483          	ld	s1,8(sp)
    800011a8:	02010113          	addi	sp,sp,32
    800011ac:	00008067          	ret
        int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800011b0:	40b787b3          	sub	a5,a5,a1
    800011b4:	00c7d793          	srli	a5,a5,0xc
        uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800011b8:	00100693          	li	a3,1
    800011bc:	0007861b          	sext.w	a2,a5
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	be8080e7          	jalr	-1048(ra) # 80000da8 <uvmunmap>
}
    800011c8:	01813083          	ld	ra,24(sp)
    800011cc:	01013403          	ld	s0,16(sp)
    800011d0:	00048513          	mv	a0,s1
    800011d4:	00813483          	ld	s1,8(sp)
    800011d8:	02010113          	addi	sp,sp,32
    800011dc:	00008067          	ret

00000000800011e0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800011e0:	fc010113          	addi	sp,sp,-64
    800011e4:	02813823          	sd	s0,48(sp)
    800011e8:	02913423          	sd	s1,40(sp)
    800011ec:	03213023          	sd	s2,32(sp)
    800011f0:	01313c23          	sd	s3,24(sp)
    800011f4:	01413823          	sd	s4,16(sp)
    800011f8:	01513423          	sd	s5,8(sp)
    800011fc:	02113c23          	sd	ra,56(sp)
    80001200:	04010413          	addi	s0,sp,64
    80001204:	00001937          	lui	s2,0x1
    80001208:	00050a93          	mv	s5,a0
    8000120c:	00050493          	mv	s1,a0
    80001210:	01250933          	add	s2,a0,s2
    // there are 2^9 = 512 PTEs in a page table.
    for (int i = 0; i < 512; i++)
    {
        pte_t pte = pagetable[i];
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001214:	00100993          	li	s3,1
            freewalk((pagetable_t)child);
            pagetable[i] = 0;
        }
        else if (pte & PTE_V)
        {
            panic("freewalk: leaf");
    80001218:	00001a17          	auipc	s4,0x1
    8000121c:	f28a0a13          	addi	s4,s4,-216 # 80002140 <digits+0x130>
    80001220:	00c0006f          	j	8000122c <freewalk+0x4c>
    for (int i = 0; i < 512; i++)
    80001224:	00848493          	addi	s1,s1,8
    80001228:	03248663          	beq	s1,s2,80001254 <freewalk+0x74>
        pte_t pte = pagetable[i];
    8000122c:	0004b783          	ld	a5,0(s1)
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001230:	00f7f713          	andi	a4,a5,15
        else if (pte & PTE_V)
    80001234:	0017f693          	andi	a3,a5,1
        if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80001238:	05370463          	beq	a4,s3,80001280 <freewalk+0xa0>
        else if (pte & PTE_V)
    8000123c:	fe0684e3          	beqz	a3,80001224 <freewalk+0x44>
            panic("freewalk: leaf");
    80001240:	000a0513          	mv	a0,s4
    for (int i = 0; i < 512; i++)
    80001244:	00848493          	addi	s1,s1,8
            panic("freewalk: leaf");
    80001248:	fffff097          	auipc	ra,0xfffff
    8000124c:	228080e7          	jalr	552(ra) # 80000470 <panic>
    for (int i = 0; i < 512; i++)
    80001250:	fd249ee3          	bne	s1,s2,8000122c <freewalk+0x4c>
        }
    }
    kfree((void *)pagetable);
}
    80001254:	03013403          	ld	s0,48(sp)
    80001258:	03813083          	ld	ra,56(sp)
    8000125c:	02813483          	ld	s1,40(sp)
    80001260:	02013903          	ld	s2,32(sp)
    80001264:	01813983          	ld	s3,24(sp)
    80001268:	01013a03          	ld	s4,16(sp)
    kfree((void *)pagetable);
    8000126c:	000a8513          	mv	a0,s5
}
    80001270:	00813a83          	ld	s5,8(sp)
    80001274:	04010113          	addi	sp,sp,64
    kfree((void *)pagetable);
    80001278:	fffff317          	auipc	t1,0xfffff
    8000127c:	4c030067          	jr	1216(t1) # 80000738 <kfree>
            uint64_t child = PTE2PA(pte);
    80001280:	00a7d793          	srli	a5,a5,0xa
            freewalk((pagetable_t)child);
    80001284:	00c79513          	slli	a0,a5,0xc
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	f58080e7          	jalr	-168(ra) # 800011e0 <freewalk>
            pagetable[i] = 0;
    80001290:	0004b023          	sd	zero,0(s1)
    80001294:	f91ff06f          	j	80001224 <freewalk+0x44>

0000000080001298 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64_t sz)
{
    80001298:	fe010113          	addi	sp,sp,-32
    8000129c:	00813823          	sd	s0,16(sp)
    800012a0:	00913423          	sd	s1,8(sp)
    800012a4:	00113c23          	sd	ra,24(sp)
    800012a8:	02010413          	addi	s0,sp,32
    800012ac:	00050493          	mv	s1,a0
    if (sz > 0)
    800012b0:	02059063          	bnez	a1,800012d0 <uvmfree+0x38>
        uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    freewalk(pagetable);
}
    800012b4:	01013403          	ld	s0,16(sp)
    800012b8:	01813083          	ld	ra,24(sp)
    freewalk(pagetable);
    800012bc:	00048513          	mv	a0,s1
}
    800012c0:	00813483          	ld	s1,8(sp)
    800012c4:	02010113          	addi	sp,sp,32
    freewalk(pagetable);
    800012c8:	00000317          	auipc	t1,0x0
    800012cc:	f1830067          	jr	-232(t1) # 800011e0 <freewalk>
        uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800012d0:	000017b7          	lui	a5,0x1
    800012d4:	fff78793          	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012d8:	00f585b3          	add	a1,a1,a5
    800012dc:	00c5d613          	srli	a2,a1,0xc
    800012e0:	00100693          	li	a3,1
    800012e4:	00000593          	li	a1,0
    800012e8:	00000097          	auipc	ra,0x0
    800012ec:	ac0080e7          	jalr	-1344(ra) # 80000da8 <uvmunmap>
}
    800012f0:	01013403          	ld	s0,16(sp)
    800012f4:	01813083          	ld	ra,24(sp)
    freewalk(pagetable);
    800012f8:	00048513          	mv	a0,s1
}
    800012fc:	00813483          	ld	s1,8(sp)
    80001300:	02010113          	addi	sp,sp,32
    freewalk(pagetable);
    80001304:	00000317          	auipc	t1,0x0
    80001308:	edc30067          	jr	-292(t1) # 800011e0 <freewalk>

000000008000130c <uvmcopy>:
    pte_t *pte;
    uint64_t pa, i;
    uint32_t flags;
    char *mem;

    for (i = 0; i < sz; i += PGSIZE)
    8000130c:	14060e63          	beqz	a2,80001468 <uvmcopy+0x15c>
{
    80001310:	fb010113          	addi	sp,sp,-80
    80001314:	04813023          	sd	s0,64(sp)
    80001318:	03313423          	sd	s3,40(sp)
    8000131c:	03413023          	sd	s4,32(sp)
    80001320:	01513c23          	sd	s5,24(sp)
    80001324:	01613823          	sd	s6,16(sp)
    80001328:	01713423          	sd	s7,8(sp)
    8000132c:	01813023          	sd	s8,0(sp)
    80001330:	04113423          	sd	ra,72(sp)
    80001334:	02913c23          	sd	s1,56(sp)
    80001338:	03213823          	sd	s2,48(sp)
    8000133c:	05010413          	addi	s0,sp,80
    80001340:	00060a13          	mv	s4,a2
    80001344:	00050b13          	mv	s6,a0
    80001348:	00058a93          	mv	s5,a1
    8000134c:	00000993          	li	s3,0
    80001350:	00001c17          	auipc	s8,0x1
    80001354:	e00c0c13          	addi	s8,s8,-512 # 80002150 <digits+0x140>
    80001358:	00001b97          	auipc	s7,0x1
    8000135c:	e18b8b93          	addi	s7,s7,-488 # 80002170 <digits+0x160>
    80001360:	05c0006f          	j	800013bc <uvmcopy+0xb0>
    {
        if ((pte = walk(old, i, 0)) == 0)
            panic("uvmcopy: pte should exist");
        if ((*pte & PTE_V) == 0)
            panic("uvmcopy: page not present");
        pa = PTE2PA(*pte);
    80001364:	00a75913          	srli	s2,a4,0xa
    80001368:	00c91913          	slli	s2,s2,0xc
        flags = PTE_FLAGS(*pte);
    8000136c:	3ff77493          	andi	s1,a4,1023
        if ((mem = kalloc()) == 0)
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	450080e7          	jalr	1104(ra) # 800007c0 <kalloc>
            goto err;
        memmove(mem, (char *)pa, PGSIZE);
    80001378:	00090593          	mv	a1,s2
    8000137c:	00001637          	lui	a2,0x1
        if ((mem = kalloc()) == 0)
    80001380:	00050913          	mv	s2,a0
    80001384:	08050863          	beqz	a0,80001414 <uvmcopy+0x108>
        memmove(mem, (char *)pa, PGSIZE);
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	524080e7          	jalr	1316(ra) # 800008ac <memmove>
        if (mappages(new, i, PGSIZE, (uint64_t)mem, flags) != 0)
    80001390:	00048713          	mv	a4,s1
    80001394:	00090693          	mv	a3,s2
    80001398:	00098593          	mv	a1,s3
    8000139c:	00001637          	lui	a2,0x1
    800013a0:	000a8513          	mv	a0,s5
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	87c080e7          	jalr	-1924(ra) # 80000c20 <mappages>
    800013ac:	04051e63          	bnez	a0,80001408 <uvmcopy+0xfc>
    for (i = 0; i < sz; i += PGSIZE)
    800013b0:	000017b7          	lui	a5,0x1
    800013b4:	00f989b3          	add	s3,s3,a5
    800013b8:	0b49f463          	bgeu	s3,s4,80001460 <uvmcopy+0x154>
        if ((pte = walk(old, i, 0)) == 0)
    800013bc:	00098593          	mv	a1,s3
    800013c0:	00000613          	li	a2,0
    800013c4:	000b0513          	mv	a0,s6
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	6d4080e7          	jalr	1748(ra) # 80000a9c <walk>
    800013d0:	00050493          	mv	s1,a0
    800013d4:	02050263          	beqz	a0,800013f8 <uvmcopy+0xec>
        if ((*pte & PTE_V) == 0)
    800013d8:	0004b703          	ld	a4,0(s1)
    800013dc:	00177793          	andi	a5,a4,1
    800013e0:	f80792e3          	bnez	a5,80001364 <uvmcopy+0x58>
            panic("uvmcopy: page not present");
    800013e4:	000b8513          	mv	a0,s7
    800013e8:	fffff097          	auipc	ra,0xfffff
    800013ec:	088080e7          	jalr	136(ra) # 80000470 <panic>
        pa = PTE2PA(*pte);
    800013f0:	0004b703          	ld	a4,0(s1)
    800013f4:	f71ff06f          	j	80001364 <uvmcopy+0x58>
            panic("uvmcopy: pte should exist");
    800013f8:	000c0513          	mv	a0,s8
    800013fc:	fffff097          	auipc	ra,0xfffff
    80001400:	074080e7          	jalr	116(ra) # 80000470 <panic>
    80001404:	fd5ff06f          	j	800013d8 <uvmcopy+0xcc>
        {
            kfree(mem);
    80001408:	00090513          	mv	a0,s2
    8000140c:	fffff097          	auipc	ra,0xfffff
    80001410:	32c080e7          	jalr	812(ra) # 80000738 <kfree>
        }
    }
    return 0;

err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    80001414:	000a8513          	mv	a0,s5
    80001418:	00100693          	li	a3,1
    8000141c:	00c9d613          	srli	a2,s3,0xc
    80001420:	00000593          	li	a1,0
    80001424:	00000097          	auipc	ra,0x0
    80001428:	984080e7          	jalr	-1660(ra) # 80000da8 <uvmunmap>
    return -1;
    8000142c:	fff00513          	li	a0,-1
}
    80001430:	04813083          	ld	ra,72(sp)
    80001434:	04013403          	ld	s0,64(sp)
    80001438:	03813483          	ld	s1,56(sp)
    8000143c:	03013903          	ld	s2,48(sp)
    80001440:	02813983          	ld	s3,40(sp)
    80001444:	02013a03          	ld	s4,32(sp)
    80001448:	01813a83          	ld	s5,24(sp)
    8000144c:	01013b03          	ld	s6,16(sp)
    80001450:	00813b83          	ld	s7,8(sp)
    80001454:	00013c03          	ld	s8,0(sp)
    80001458:	05010113          	addi	sp,sp,80
    8000145c:	00008067          	ret
    return 0;
    80001460:	00000513          	li	a0,0
    80001464:	fcdff06f          	j	80001430 <uvmcopy+0x124>
    80001468:	00000513          	li	a0,0
}
    8000146c:	00008067          	ret

0000000080001470 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64_t va)
{
    80001470:	fe010113          	addi	sp,sp,-32
    80001474:	00813823          	sd	s0,16(sp)
    80001478:	00913423          	sd	s1,8(sp)
    8000147c:	00113c23          	sd	ra,24(sp)
    80001480:	02010413          	addi	s0,sp,32
    pte_t *pte;

    pte = walk(pagetable, va, 0);
    80001484:	00000613          	li	a2,0
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	614080e7          	jalr	1556(ra) # 80000a9c <walk>
    80001490:	00050493          	mv	s1,a0
    if (pte == 0)
    80001494:	02050263          	beqz	a0,800014b8 <uvmclear+0x48>
        panic("uvmclear");
    *pte &= ~PTE_U;
    80001498:	0004b783          	ld	a5,0(s1)
}
    8000149c:	01813083          	ld	ra,24(sp)
    800014a0:	01013403          	ld	s0,16(sp)
    *pte &= ~PTE_U;
    800014a4:	fef7f793          	andi	a5,a5,-17
    800014a8:	00f4b023          	sd	a5,0(s1)
}
    800014ac:	00813483          	ld	s1,8(sp)
    800014b0:	02010113          	addi	sp,sp,32
    800014b4:	00008067          	ret
        panic("uvmclear");
    800014b8:	00001517          	auipc	a0,0x1
    800014bc:	cd850513          	addi	a0,a0,-808 # 80002190 <digits+0x180>
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	fb0080e7          	jalr	-80(ra) # 80000470 <panic>
    *pte &= ~PTE_U;
    800014c8:	0004b783          	ld	a5,0(s1)
}
    800014cc:	01813083          	ld	ra,24(sp)
    800014d0:	01013403          	ld	s0,16(sp)
    *pte &= ~PTE_U;
    800014d4:	fef7f793          	andi	a5,a5,-17
    800014d8:	00f4b023          	sd	a5,0(s1)
}
    800014dc:	00813483          	ld	s1,8(sp)
    800014e0:	02010113          	addi	sp,sp,32
    800014e4:	00008067          	ret

00000000800014e8 <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64_t dstva, char *src, uint64_t len)
{
    uint64_t n, va0, pa0;

    while (len > 0)
    800014e8:	12068a63          	beqz	a3,8000161c <copyout+0x134>
{
    800014ec:	fa010113          	addi	sp,sp,-96
    800014f0:	04813823          	sd	s0,80(sp)
    800014f4:	04913423          	sd	s1,72(sp)
    800014f8:	05213023          	sd	s2,64(sp)
    800014fc:	04113c23          	sd	ra,88(sp)
    80001500:	03313c23          	sd	s3,56(sp)
    80001504:	03413823          	sd	s4,48(sp)
    80001508:	03513423          	sd	s5,40(sp)
    8000150c:	03613023          	sd	s6,32(sp)
    80001510:	01713c23          	sd	s7,24(sp)
    80001514:	01813823          	sd	s8,16(sp)
    80001518:	01913423          	sd	s9,8(sp)
    8000151c:	06010413          	addi	s0,sp,96
    {
        va0 = PGROUNDDOWN(dstva);
    80001520:	fffff937          	lui	s2,0xfffff
    if (va >= MAXVA)
    80001524:	fff00793          	li	a5,-1
        va0 = PGROUNDDOWN(dstva);
    80001528:	0125f933          	and	s2,a1,s2
    if (va >= MAXVA)
    8000152c:	01a7d793          	srli	a5,a5,0x1a
    80001530:	00058493          	mv	s1,a1
    80001534:	0327fe63          	bgeu	a5,s2,80001570 <copyout+0x88>
        pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0)
            return -1;
    80001538:	fff00513          	li	a0,-1
        len -= n;
        src += n;
        dstva = va0 + PGSIZE;
    }
    return 0;
}
    8000153c:	05813083          	ld	ra,88(sp)
    80001540:	05013403          	ld	s0,80(sp)
    80001544:	04813483          	ld	s1,72(sp)
    80001548:	04013903          	ld	s2,64(sp)
    8000154c:	03813983          	ld	s3,56(sp)
    80001550:	03013a03          	ld	s4,48(sp)
    80001554:	02813a83          	ld	s5,40(sp)
    80001558:	02013b03          	ld	s6,32(sp)
    8000155c:	01813b83          	ld	s7,24(sp)
    80001560:	01013c03          	ld	s8,16(sp)
    80001564:	00813c83          	ld	s9,8(sp)
    80001568:	06010113          	addi	sp,sp,96
    8000156c:	00008067          	ret
    80001570:	00050a93          	mv	s5,a0
    80001574:	00060a13          	mv	s4,a2
    pte = walk(pagetable, va, 0);
    80001578:	00090593          	mv	a1,s2
    8000157c:	00000613          	li	a2,0
    80001580:	000a8513          	mv	a0,s5
    80001584:	00068993          	mv	s3,a3
    if ((*pte & PTE_U) == 0)
    80001588:	01100c13          	li	s8,17
    8000158c:	00001bb7          	lui	s7,0x1
    if (va >= MAXVA)
    80001590:	00078b13          	mv	s6,a5
    pte = walk(pagetable, va, 0);
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	508080e7          	jalr	1288(ra) # 80000a9c <walk>
    if (pte == 0)
    8000159c:	f8050ee3          	beqz	a0,80001538 <copyout+0x50>
    if ((*pte & PTE_V) == 0)
    800015a0:	00053783          	ld	a5,0(a0)
    if ((*pte & PTE_U) == 0)
    800015a4:	01790cb3          	add	s9,s2,s7
        memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015a8:	41248933          	sub	s2,s1,s2
    pa = PTE2PA(*pte);
    800015ac:	00a7d713          	srli	a4,a5,0xa
    800015b0:	00c71713          	slli	a4,a4,0xc
    if ((*pte & PTE_U) == 0)
    800015b4:	0117f793          	andi	a5,a5,17
        n = PGSIZE - (dstva - va0);
    800015b8:	409c84b3          	sub	s1,s9,s1
        memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	000a0593          	mv	a1,s4
    800015c0:	00e90533          	add	a0,s2,a4
    if ((*pte & PTE_U) == 0)
    800015c4:	f7879ae3          	bne	a5,s8,80001538 <copyout+0x50>
    800015c8:	000c8913          	mv	s2,s9
        if (pa0 == 0)
    800015cc:	f60706e3          	beqz	a4,80001538 <copyout+0x50>
    800015d0:	0099f463          	bgeu	s3,s1,800015d8 <copyout+0xf0>
    800015d4:	00098493          	mv	s1,s3
        memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015d8:	0004861b          	sext.w	a2,s1
        len -= n;
    800015dc:	409989b3          	sub	s3,s3,s1
        memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	2cc080e7          	jalr	716(ra) # 800008ac <memmove>
        src += n;
    800015e8:	009a0a33          	add	s4,s4,s1
    while (len > 0)
    800015ec:	02098463          	beqz	s3,80001614 <copyout+0x12c>
    if (va >= MAXVA)
    800015f0:	f59b64e3          	bltu	s6,s9,80001538 <copyout+0x50>
    pte = walk(pagetable, va, 0);
    800015f4:	00090593          	mv	a1,s2
    800015f8:	00000613          	li	a2,0
    800015fc:	000a8513          	mv	a0,s5
    80001600:	00090493          	mv	s1,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	498080e7          	jalr	1176(ra) # 80000a9c <walk>
    if (pte == 0)
    8000160c:	f8051ae3          	bnez	a0,800015a0 <copyout+0xb8>
    80001610:	f29ff06f          	j	80001538 <copyout+0x50>
    return 0;
    80001614:	00000513          	li	a0,0
    80001618:	f25ff06f          	j	8000153c <copyout+0x54>
    8000161c:	00000513          	li	a0,0
}
    80001620:	00008067          	ret

0000000080001624 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64_t srcva, uint64_t len)
{
    uint64_t n, va0, pa0;

    while (len > 0)
    80001624:	12068a63          	beqz	a3,80001758 <copyin+0x134>
{
    80001628:	fa010113          	addi	sp,sp,-96
    8000162c:	04813823          	sd	s0,80(sp)
    80001630:	04913423          	sd	s1,72(sp)
    80001634:	05213023          	sd	s2,64(sp)
    80001638:	04113c23          	sd	ra,88(sp)
    8000163c:	03313c23          	sd	s3,56(sp)
    80001640:	03413823          	sd	s4,48(sp)
    80001644:	03513423          	sd	s5,40(sp)
    80001648:	03613023          	sd	s6,32(sp)
    8000164c:	01713c23          	sd	s7,24(sp)
    80001650:	01813823          	sd	s8,16(sp)
    80001654:	01913423          	sd	s9,8(sp)
    80001658:	06010413          	addi	s0,sp,96
    {
        va0 = PGROUNDDOWN(srcva);
    8000165c:	fffff937          	lui	s2,0xfffff
    if (va >= MAXVA)
    80001660:	fff00793          	li	a5,-1
        va0 = PGROUNDDOWN(srcva);
    80001664:	01267933          	and	s2,a2,s2
    if (va >= MAXVA)
    80001668:	01a7d793          	srli	a5,a5,0x1a
    8000166c:	00060493          	mv	s1,a2
    80001670:	0327fe63          	bgeu	a5,s2,800016ac <copyin+0x88>
        pa0 = walkaddr(pagetable, va0);
        if (pa0 == 0)
            return -1;
    80001674:	fff00513          	li	a0,-1
        len -= n;
        dst += n;
        srcva = va0 + PGSIZE;
    }
    return 0;
}
    80001678:	05813083          	ld	ra,88(sp)
    8000167c:	05013403          	ld	s0,80(sp)
    80001680:	04813483          	ld	s1,72(sp)
    80001684:	04013903          	ld	s2,64(sp)
    80001688:	03813983          	ld	s3,56(sp)
    8000168c:	03013a03          	ld	s4,48(sp)
    80001690:	02813a83          	ld	s5,40(sp)
    80001694:	02013b03          	ld	s6,32(sp)
    80001698:	01813b83          	ld	s7,24(sp)
    8000169c:	01013c03          	ld	s8,16(sp)
    800016a0:	00813c83          	ld	s9,8(sp)
    800016a4:	06010113          	addi	sp,sp,96
    800016a8:	00008067          	ret
    800016ac:	00050a93          	mv	s5,a0
    800016b0:	00058a13          	mv	s4,a1
    pte = walk(pagetable, va, 0);
    800016b4:	00000613          	li	a2,0
    800016b8:	00090593          	mv	a1,s2
    800016bc:	000a8513          	mv	a0,s5
    800016c0:	00068993          	mv	s3,a3
    if ((*pte & PTE_U) == 0)
    800016c4:	01100c13          	li	s8,17
    800016c8:	00001bb7          	lui	s7,0x1
    if (va >= MAXVA)
    800016cc:	00078b13          	mv	s6,a5
    pte = walk(pagetable, va, 0);
    800016d0:	fffff097          	auipc	ra,0xfffff
    800016d4:	3cc080e7          	jalr	972(ra) # 80000a9c <walk>
    if (pte == 0)
    800016d8:	f8050ee3          	beqz	a0,80001674 <copyin+0x50>
    if ((*pte & PTE_V) == 0)
    800016dc:	00053783          	ld	a5,0(a0)
    if ((*pte & PTE_U) == 0)
    800016e0:	01790cb3          	add	s9,s2,s7
        memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016e4:	41248933          	sub	s2,s1,s2
    pa = PTE2PA(*pte);
    800016e8:	00a7d713          	srli	a4,a5,0xa
    800016ec:	00c71713          	slli	a4,a4,0xc
    if ((*pte & PTE_U) == 0)
    800016f0:	0117f793          	andi	a5,a5,17
        n = PGSIZE - (srcva - va0);
    800016f4:	409c84b3          	sub	s1,s9,s1
        memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f8:	000a0513          	mv	a0,s4
    800016fc:	00e905b3          	add	a1,s2,a4
    if ((*pte & PTE_U) == 0)
    80001700:	f7879ae3          	bne	a5,s8,80001674 <copyin+0x50>
    80001704:	000c8913          	mv	s2,s9
        if (pa0 == 0)
    80001708:	f60706e3          	beqz	a4,80001674 <copyin+0x50>
    8000170c:	0099f463          	bgeu	s3,s1,80001714 <copyin+0xf0>
    80001710:	00098493          	mv	s1,s3
        memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001714:	0004861b          	sext.w	a2,s1
        len -= n;
    80001718:	409989b3          	sub	s3,s3,s1
        memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	190080e7          	jalr	400(ra) # 800008ac <memmove>
        dst += n;
    80001724:	009a0a33          	add	s4,s4,s1
    while (len > 0)
    80001728:	02098463          	beqz	s3,80001750 <copyin+0x12c>
    if (va >= MAXVA)
    8000172c:	f59b64e3          	bltu	s6,s9,80001674 <copyin+0x50>
    pte = walk(pagetable, va, 0);
    80001730:	00090593          	mv	a1,s2
    80001734:	00000613          	li	a2,0
    80001738:	000a8513          	mv	a0,s5
    8000173c:	00090493          	mv	s1,s2
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	35c080e7          	jalr	860(ra) # 80000a9c <walk>
    if (pte == 0)
    80001748:	f8051ae3          	bnez	a0,800016dc <copyin+0xb8>
    8000174c:	f29ff06f          	j	80001674 <copyin+0x50>
    return 0;
    80001750:	00000513          	li	a0,0
    80001754:	f25ff06f          	j	80001678 <copyin+0x54>
    80001758:	00000513          	li	a0,0
}
    8000175c:	00008067          	ret

0000000080001760 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64_t srcva, uint64_t max)
{
    uint64_t n, va0, pa0;
    int got_null = 0;

    while (got_null == 0 && max > 0)
    80001760:	14068463          	beqz	a3,800018a8 <copyinstr+0x148>
{
    80001764:	fb010113          	addi	sp,sp,-80
    80001768:	04813023          	sd	s0,64(sp)
    8000176c:	03213823          	sd	s2,48(sp)
    80001770:	03313423          	sd	s3,40(sp)
    80001774:	01713423          	sd	s7,8(sp)
    80001778:	04113423          	sd	ra,72(sp)
    8000177c:	02913c23          	sd	s1,56(sp)
    80001780:	03413023          	sd	s4,32(sp)
    80001784:	01513c23          	sd	s5,24(sp)
    80001788:	01613823          	sd	s6,16(sp)
    8000178c:	01813023          	sd	s8,0(sp)
    80001790:	05010413          	addi	s0,sp,80
    {
        va0 = PGROUNDDOWN(srcva);
    80001794:	fffffbb7          	lui	s7,0xfffff
    if (va >= MAXVA)
    80001798:	fff00993          	li	s3,-1
        va0 = PGROUNDDOWN(srcva);
    8000179c:	01767bb3          	and	s7,a2,s7
    if (va >= MAXVA)
    800017a0:	01a9d993          	srli	s3,s3,0x1a
    800017a4:	00060913          	mv	s2,a2
    800017a8:	0379fc63          	bgeu	s3,s7,800017e0 <copyinstr+0x80>
    {
        return 0;
    }
    else
    {
        return -1;
    800017ac:	fff00513          	li	a0,-1
    }
}
    800017b0:	04813083          	ld	ra,72(sp)
    800017b4:	04013403          	ld	s0,64(sp)
    800017b8:	03813483          	ld	s1,56(sp)
    800017bc:	03013903          	ld	s2,48(sp)
    800017c0:	02813983          	ld	s3,40(sp)
    800017c4:	02013a03          	ld	s4,32(sp)
    800017c8:	01813a83          	ld	s5,24(sp)
    800017cc:	01013b03          	ld	s6,16(sp)
    800017d0:	00813b83          	ld	s7,8(sp)
    800017d4:	00013c03          	ld	s8,0(sp)
    800017d8:	05010113          	addi	sp,sp,80
    800017dc:	00008067          	ret
    800017e0:	00068b13          	mv	s6,a3
    800017e4:	00050c13          	mv	s8,a0
    800017e8:	00058493          	mv	s1,a1
    if ((*pte & PTE_U) == 0)
    800017ec:	01100a93          	li	s5,17
    800017f0:	00001a37          	lui	s4,0x1
    pte = walk(pagetable, va, 0);
    800017f4:	00000613          	li	a2,0
    800017f8:	000b8593          	mv	a1,s7
    800017fc:	000c0513          	mv	a0,s8
    80001800:	fffff097          	auipc	ra,0xfffff
    80001804:	29c080e7          	jalr	668(ra) # 80000a9c <walk>
    if (pte == 0)
    80001808:	fa0502e3          	beqz	a0,800017ac <copyinstr+0x4c>
    if ((*pte & PTE_V) == 0)
    8000180c:	00053783          	ld	a5,0(a0)
    if ((*pte & PTE_U) == 0)
    80001810:	0117f713          	andi	a4,a5,17
    80001814:	f9571ce3          	bne	a4,s5,800017ac <copyinstr+0x4c>
    pa = PTE2PA(*pte);
    80001818:	00a7d793          	srli	a5,a5,0xa
    8000181c:	00c79793          	slli	a5,a5,0xc
        if (pa0 == 0)
    80001820:	f80786e3          	beqz	a5,800017ac <copyinstr+0x4c>
        n = PGSIZE - (srcva - va0);
    80001824:	014b8533          	add	a0,s7,s4
    80001828:	41250633          	sub	a2,a0,s2
    8000182c:	00cb7463          	bgeu	s6,a2,80001834 <copyinstr+0xd4>
    80001830:	000b0613          	mv	a2,s6
        char *p = (char *)(pa0 + (srcva - va0));
    80001834:	41790933          	sub	s2,s2,s7
    80001838:	00f90933          	add	s2,s2,a5
        while (n > 0)
    8000183c:	06060063          	beqz	a2,8000189c <copyinstr+0x13c>
    80001840:	fffb0813          	addi	a6,s6,-1 # fff <_entry-0x7ffff001>
    80001844:	00048593          	mv	a1,s1
    80001848:	40990733          	sub	a4,s2,s1
    8000184c:	00980833          	add	a6,a6,s1
    80001850:	00960633          	add	a2,a2,s1
    80001854:	0100006f          	j	80001864 <copyinstr+0x104>
                *dst = *p;
    80001858:	00f58023          	sb	a5,0(a1)
            dst++;
    8000185c:	00158593          	addi	a1,a1,1
        while (n > 0)
    80001860:	02c58063          	beq	a1,a2,80001880 <copyinstr+0x120>
            if (*p == '\0')
    80001864:	00e587b3          	add	a5,a1,a4
    80001868:	0007c783          	lbu	a5,0(a5) # 1000 <_entry-0x7ffff000>
    8000186c:	40b806b3          	sub	a3,a6,a1
    80001870:	fe0794e3          	bnez	a5,80001858 <copyinstr+0xf8>
                *dst = '\0';
    80001874:	00058023          	sb	zero,0(a1)
        return 0;
    80001878:	00000513          	li	a0,0
    8000187c:	f35ff06f          	j	800017b0 <copyinstr+0x50>
    while (got_null == 0 && max > 0)
    80001880:	f20686e3          	beqz	a3,800017ac <copyinstr+0x4c>
    if (va >= MAXVA)
    80001884:	f2a9e4e3          	bltu	s3,a0,800017ac <copyinstr+0x4c>
    80001888:	00050913          	mv	s2,a0
    8000188c:	00068b13          	mv	s6,a3
    80001890:	00058493          	mv	s1,a1
    80001894:	00050b93          	mv	s7,a0
    80001898:	f5dff06f          	j	800017f4 <copyinstr+0x94>
        while (n > 0)
    8000189c:	000b0693          	mv	a3,s6
    800018a0:	00048593          	mv	a1,s1
    800018a4:	fe1ff06f          	j	80001884 <copyinstr+0x124>
        return -1;
    800018a8:	fff00513          	li	a0,-1
}
    800018ac:	00008067          	ret

00000000800018b0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800018b0:	ff010113          	addi	sp,sp,-16
    800018b4:	00813423          	sd	s0,8(sp)
    800018b8:	01010413          	addi	s0,sp,16
    usertrapret();
}
    800018bc:	00813403          	ld	s0,8(sp)
    800018c0:	01010113          	addi	sp,sp,16
    usertrapret();
    800018c4:	00000317          	auipc	t1,0x0
    800018c8:	60430067          	jr	1540(t1) # 80001ec8 <usertrapret>

00000000800018cc <procinit>:
{
    800018cc:	ff010113          	addi	sp,sp,-16
    800018d0:	00813423          	sd	s0,8(sp)
    800018d4:	01010413          	addi	s0,sp,16
}
    800018d8:	00813403          	ld	s0,8(sp)
        p->state = UNUSED;
    800018dc:	00002797          	auipc	a5,0x2
    800018e0:	94478793          	addi	a5,a5,-1724 # 80003220 <proc>
    800018e4:	0007a023          	sw	zero,0(a5)
    800018e8:	0a07a423          	sw	zero,168(a5)
    800018ec:	1407a823          	sw	zero,336(a5)
    800018f0:	1e07ac23          	sw	zero,504(a5)
}
    800018f4:	01010113          	addi	sp,sp,16
    800018f8:	00008067          	ret

00000000800018fc <allocpid>:
{
    800018fc:	ff010113          	addi	sp,sp,-16
    80001900:	00813423          	sd	s0,8(sp)
    80001904:	01010413          	addi	s0,sp,16
    pid = nextpid;
    80001908:	00001797          	auipc	a5,0x1
    8000190c:	8f878793          	addi	a5,a5,-1800 # 80002200 <nextpid>
    80001910:	0007a503          	lw	a0,0(a5)
}
    80001914:	00813403          	ld	s0,8(sp)
    nextpid = nextpid + 1;
    80001918:	0015071b          	addiw	a4,a0,1
    8000191c:	00e7a023          	sw	a4,0(a5)
}
    80001920:	01010113          	addi	sp,sp,16
    80001924:	00008067          	ret

0000000080001928 <allocproc>:
{
    80001928:	fe010113          	addi	sp,sp,-32
    8000192c:	00813823          	sd	s0,16(sp)
    80001930:	00913423          	sd	s1,8(sp)
    80001934:	00113c23          	sd	ra,24(sp)
    80001938:	02010413          	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    8000193c:	00002497          	auipc	s1,0x2
    80001940:	8e448493          	addi	s1,s1,-1820 # 80003220 <proc>
    80001944:	00002717          	auipc	a4,0x2
    80001948:	b7c70713          	addi	a4,a4,-1156 # 800034c0 <sc>
        if (p->state == UNUSED)
    8000194c:	0004a783          	lw	a5,0(s1)
    80001950:	02078463          	beqz	a5,80001978 <allocproc+0x50>
    for (p = proc; p < &proc[NPROC]; p++)
    80001954:	0a848493          	addi	s1,s1,168
    80001958:	fee49ae3          	bne	s1,a4,8000194c <allocproc+0x24>
}
    8000195c:	01813083          	ld	ra,24(sp)
    80001960:	01013403          	ld	s0,16(sp)
        return 0;
    80001964:	00000493          	li	s1,0
}
    80001968:	00048513          	mv	a0,s1
    8000196c:	00813483          	ld	s1,8(sp)
    80001970:	02010113          	addi	sp,sp,32
    80001974:	00008067          	ret
    pid = nextpid;
    80001978:	00001797          	auipc	a5,0x1
    8000197c:	88878793          	addi	a5,a5,-1912 # 80002200 <nextpid>
    80001980:	0007a703          	lw	a4,0(a5)
    p->state = USED;
    80001984:	00100693          	li	a3,1
    80001988:	00d4a023          	sw	a3,0(s1)
    p->pid = allocpid();
    8000198c:	00e4a223          	sw	a4,4(s1)
    nextpid = nextpid + 1;
    80001990:	0017069b          	addiw	a3,a4,1
    80001994:	00d7a023          	sw	a3,0(a5)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	e28080e7          	jalr	-472(ra) # 800007c0 <kalloc>
    800019a0:	02a4b023          	sd	a0,32(s1)
    800019a4:	06050263          	beqz	a0,80001a08 <allocproc+0xe0>
    pagetable = uvmcreate();
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	554080e7          	jalr	1364(ra) # 80000efc <uvmcreate>
    if (pagetable == 0)
    800019b0:	06050e63          	beqz	a0,80001a2c <allocproc+0x104>
    p->pagetable = proc_pagetable(p);
    800019b4:	00a4bc23          	sd	a0,24(s1)
    memset(&p->context, 0, sizeof(p->context));
    800019b8:	07000613          	li	a2,112
    800019bc:	00000593          	li	a1,0
    800019c0:	02848513          	addi	a0,s1,40
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	e54080e7          	jalr	-428(ra) # 80000818 <memset>
    p->context.ra = (uint64_t)forkret;
    800019cc:	00000797          	auipc	a5,0x0
    800019d0:	ee478793          	addi	a5,a5,-284 # 800018b0 <forkret>
    800019d4:	02f4b423          	sd	a5,40(s1)
    p->kstack = (uint64_t)(kalloc() + PGSIZE);
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	de8080e7          	jalr	-536(ra) # 800007c0 <kalloc>
}
    800019e0:	01813083          	ld	ra,24(sp)
    800019e4:	01013403          	ld	s0,16(sp)
    p->kstack = (uint64_t)(kalloc() + PGSIZE);
    800019e8:	000017b7          	lui	a5,0x1
    800019ec:	00f50533          	add	a0,a0,a5
    800019f0:	00a4b423          	sd	a0,8(s1)
    p->context.sp = p->kstack;
    800019f4:	02a4b823          	sd	a0,48(s1)
}
    800019f8:	00048513          	mv	a0,s1
    800019fc:	00813483          	ld	s1,8(sp)
    80001a00:	02010113          	addi	sp,sp,32
    80001a04:	00008067          	ret
    if (p->pagetable)
    80001a08:	0184b503          	ld	a0,24(s1)
    80001a0c:	00050863          	beqz	a0,80001a1c <allocproc+0xf4>
    uvmfree(pagetable, sz);
    80001a10:	0104b583          	ld	a1,16(s1)
    80001a14:	00000097          	auipc	ra,0x0
    80001a18:	884080e7          	jalr	-1916(ra) # 80001298 <uvmfree>
    p->pagetable = 0;
    80001a1c:	0004bc23          	sd	zero,24(s1)
    p->name[0] = 0;
    80001a20:	08048c23          	sb	zero,152(s1)
    p->state = UNUSED;
    80001a24:	0004b023          	sd	zero,0(s1)
    80001a28:	f35ff06f          	j	8000195c <allocproc+0x34>
    if (p->trapframe)
    80001a2c:	0204b503          	ld	a0,32(s1)
    p->pagetable = proc_pagetable(p);
    80001a30:	0004bc23          	sd	zero,24(s1)
    if (p->trapframe)
    80001a34:	fe0504e3          	beqz	a0,80001a1c <allocproc+0xf4>
        kfree((void *)p->trapframe);
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	d00080e7          	jalr	-768(ra) # 80000738 <kfree>
    if (p->pagetable)
    80001a40:	0184b503          	ld	a0,24(s1)
    p->trapframe = 0;
    80001a44:	0204b023          	sd	zero,32(s1)
    if (p->pagetable)
    80001a48:	fc0514e3          	bnez	a0,80001a10 <allocproc+0xe8>
    80001a4c:	fd1ff06f          	j	80001a1c <allocproc+0xf4>

0000000080001a50 <proc_pagetable>:
{
    80001a50:	ff010113          	addi	sp,sp,-16
    80001a54:	00813423          	sd	s0,8(sp)
    80001a58:	01010413          	addi	s0,sp,16
}
    80001a5c:	00813403          	ld	s0,8(sp)
    80001a60:	01010113          	addi	sp,sp,16
    pagetable = uvmcreate();
    80001a64:	fffff317          	auipc	t1,0xfffff
    80001a68:	49830067          	jr	1176(t1) # 80000efc <uvmcreate>

0000000080001a6c <proc_freepagetable>:
{
    80001a6c:	ff010113          	addi	sp,sp,-16
    80001a70:	00813423          	sd	s0,8(sp)
    80001a74:	01010413          	addi	s0,sp,16
}
    80001a78:	00813403          	ld	s0,8(sp)
    80001a7c:	01010113          	addi	sp,sp,16
    uvmfree(pagetable, sz);
    80001a80:	00000317          	auipc	t1,0x0
    80001a84:	81830067          	jr	-2024(t1) # 80001298 <uvmfree>

0000000080001a88 <scheduler>:
{
    80001a88:	fc010113          	addi	sp,sp,-64
    80001a8c:	02813823          	sd	s0,48(sp)
    80001a90:	03213023          	sd	s2,32(sp)
    80001a94:	01313c23          	sd	s3,24(sp)
    80001a98:	01413823          	sd	s4,16(sp)
    80001a9c:	01513423          	sd	s5,8(sp)
    80001aa0:	01613023          	sd	s6,0(sp)
    80001aa4:	02113c23          	sd	ra,56(sp)
    80001aa8:	02913423          	sd	s1,40(sp)
    80001aac:	04010413          	addi	s0,sp,64
                w_satp(MAKE_SATP(p->pagetable));
    80001ab0:	fff00a13          	li	s4,-1
{
    80001ab4:	00000b17          	auipc	s6,0x0
    80001ab8:	764b0b13          	addi	s6,s6,1892 # 80002218 <cur_proc>
    80001abc:	00002917          	auipc	s2,0x2
    80001ac0:	a0490913          	addi	s2,s2,-1532 # 800034c0 <sc>
            if (p->state == RUNNABLE)
    80001ac4:	00300993          	li	s3,3
                p->state = RUNNING;
    80001ac8:	00400a93          	li	s5,4
                w_satp(MAKE_SATP(p->pagetable));
    80001acc:	03fa1a13          	slli	s4,s4,0x3f
        for (p = proc; p < &proc[NPROC]; p++)
    80001ad0:	00001497          	auipc	s1,0x1
    80001ad4:	75048493          	addi	s1,s1,1872 # 80003220 <proc>
            if (p->state == RUNNABLE)
    80001ad8:	0004a783          	lw	a5,0(s1)
    80001adc:	01378a63          	beq	a5,s3,80001af0 <scheduler+0x68>
        for (p = proc; p < &proc[NPROC]; p++)
    80001ae0:	0a848493          	addi	s1,s1,168
    80001ae4:	ff2486e3          	beq	s1,s2,80001ad0 <scheduler+0x48>
            if (p->state == RUNNABLE)
    80001ae8:	0004a783          	lw	a5,0(s1)
    80001aec:	ff379ae3          	bne	a5,s3,80001ae0 <scheduler+0x58>
                w_satp(MAKE_SATP(p->pagetable));
    80001af0:	0184b783          	ld	a5,24(s1)
                p->state = RUNNING;
    80001af4:	0154a023          	sw	s5,0(s1)
                myproc() = p;
    80001af8:	009b3023          	sd	s1,0(s6)
                w_satp(MAKE_SATP(p->pagetable));
    80001afc:	00c7d793          	srli	a5,a5,0xc
    80001b00:	0147e7b3          	or	a5,a5,s4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64_t x)
{
    asm volatile("csrw satp, %0" : : "r" (x));
    80001b04:	18079073          	csrw	satp,a5
}

static inline void 
w_mscratch(uint64_t x)
{
    asm volatile("csrw mscratch, %0" : : "r" (x));
    80001b08:	0204b783          	ld	a5,32(s1)
    80001b0c:	34079073          	csrw	mscratch,a5
                swtch(&sc, &p->context);
    80001b10:	02848593          	addi	a1,s1,40
    80001b14:	00090513          	mv	a0,s2
    80001b18:	00000097          	auipc	ra,0x0
    80001b1c:	138080e7          	jalr	312(ra) # 80001c50 <swtch>
    80001b20:	fc1ff06f          	j	80001ae0 <scheduler+0x58>

0000000080001b24 <sched>:
{
    80001b24:	ff010113          	addi	sp,sp,-16
    80001b28:	00813423          	sd	s0,8(sp)
    80001b2c:	01010413          	addi	s0,sp,16
}
    80001b30:	00813403          	ld	s0,8(sp)
    swtch(&p->context, &sc);
    80001b34:	00000517          	auipc	a0,0x0
    80001b38:	6e453503          	ld	a0,1764(a0) # 80002218 <cur_proc>
    80001b3c:	00002597          	auipc	a1,0x2
    80001b40:	98458593          	addi	a1,a1,-1660 # 800034c0 <sc>
    80001b44:	02850513          	addi	a0,a0,40
}
    80001b48:	01010113          	addi	sp,sp,16
    swtch(&p->context, &sc);
    80001b4c:	00000317          	auipc	t1,0x0
    80001b50:	10430067          	jr	260(t1) # 80001c50 <swtch>

0000000080001b54 <yield>:
{
    80001b54:	ff010113          	addi	sp,sp,-16
    80001b58:	00813423          	sd	s0,8(sp)
    80001b5c:	01010413          	addi	s0,sp,16
}
    80001b60:	00813403          	ld	s0,8(sp)
    struct proc *p = myproc();
    80001b64:	00000517          	auipc	a0,0x0
    80001b68:	6b453503          	ld	a0,1716(a0) # 80002218 <cur_proc>
    p->state = RUNNABLE;
    80001b6c:	00300793          	li	a5,3
    80001b70:	00f52023          	sw	a5,0(a0)
    swtch(&p->context, &sc);
    80001b74:	00002597          	auipc	a1,0x2
    80001b78:	94c58593          	addi	a1,a1,-1716 # 800034c0 <sc>
    80001b7c:	02850513          	addi	a0,a0,40
}
    80001b80:	01010113          	addi	sp,sp,16
    swtch(&p->context, &sc);
    80001b84:	00000317          	auipc	t1,0x0
    80001b88:	0cc30067          	jr	204(t1) # 80001c50 <swtch>

0000000080001b8c <userinit>:

extern char initcode[], initend[];
void userinit(void)
{
    80001b8c:	fd010113          	addi	sp,sp,-48
    80001b90:	02813023          	sd	s0,32(sp)
    80001b94:	00913c23          	sd	s1,24(sp)
    80001b98:	02113423          	sd	ra,40(sp)
    80001b9c:	01213823          	sd	s2,16(sp)
    80001ba0:	01313423          	sd	s3,8(sp)
    80001ba4:	03010413          	addi	s0,sp,48
    struct proc *p = allocproc();
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	d80080e7          	jalr	-640(ra) # 80001928 <allocproc>
    p->state = RUNNABLE;
    80001bb0:	00300793          	li	a5,3
    80001bb4:	00f52023          	sw	a5,0(a0)
    struct proc *p = allocproc();
    80001bb8:	00050493          	mv	s1,a0

    char *code = kalloc();
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	c04080e7          	jalr	-1020(ra) # 800007c0 <kalloc>
    if (code == 0) {
    80001bc4:	06050663          	beqz	a0,80001c30 <userinit+0xa4>
        printf("No enough memory");
        while (1);
    }

    memmove(code, initcode, initend - initcode);
    80001bc8:	00000597          	auipc	a1,0x0
    80001bcc:	38458593          	addi	a1,a1,900 # 80001f4c <initcode>
    80001bd0:	00000617          	auipc	a2,0x0
    80001bd4:	38c60613          	addi	a2,a2,908 # 80001f5c <initend>
    80001bd8:	40b6063b          	subw	a2,a2,a1
    80001bdc:	00050913          	mv	s2,a0
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	ccc080e7          	jalr	-820(ra) # 800008ac <memmove>
    mappages(p->pagetable, 0x7ffff0000ul, PGSIZE, (uint64_t)code, PTE_W|PTE_R|PTE_X|PTE_U);
    80001be8:	0184b503          	ld	a0,24(s1)
    80001bec:	7ffff9b7          	lui	s3,0x7ffff
    80001bf0:	00090693          	mv	a3,s2
    80001bf4:	00499593          	slli	a1,s3,0x4
    80001bf8:	01e00713          	li	a4,30
    80001bfc:	00001637          	lui	a2,0x1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	020080e7          	jalr	32(ra) # 80000c20 <mappages>
    p->trapframe->epc = 0x7ffff0000ul;
    80001c08:	0204b783          	ld	a5,32(s1)
    80001c0c:	02813083          	ld	ra,40(sp)
    80001c10:	02013403          	ld	s0,32(sp)
    p->trapframe->epc = 0x7ffff0000ul;
    80001c14:	00499993          	slli	s3,s3,0x4
    80001c18:	0137b423          	sd	s3,8(a5) # 1008 <_entry-0x7fffeff8>
    80001c1c:	01813483          	ld	s1,24(sp)
    80001c20:	01013903          	ld	s2,16(sp)
    80001c24:	00813983          	ld	s3,8(sp)
    80001c28:	03010113          	addi	sp,sp,48
    80001c2c:	00008067          	ret
        printf("No enough memory");
    80001c30:	00000517          	auipc	a0,0x0
    80001c34:	57050513          	addi	a0,a0,1392 # 800021a0 <digits+0x190>
    80001c38:	ffffe097          	auipc	ra,0xffffe
    80001c3c:	644080e7          	jalr	1604(ra) # 8000027c <printf>
        while (1);
    80001c40:	0000006f          	j	80001c40 <userinit+0xb4>
	...

0000000080001c50 <swtch>:
.globl swtch
.align 4
swtch:
    sd ra, 0(a0)
    80001c50:	00153023          	sd	ra,0(a0)
    sd sp, 8(a0)
    80001c54:	00253423          	sd	sp,8(a0)
    sd s0, 16(a0)
    80001c58:	00853823          	sd	s0,16(a0)
    sd s1, 24(a0)
    80001c5c:	00953c23          	sd	s1,24(a0)
    sd s2, 32(a0)
    80001c60:	03253023          	sd	s2,32(a0)
    sd s3, 40(a0)
    80001c64:	03353423          	sd	s3,40(a0)
    sd s4, 48(a0)
    80001c68:	03453823          	sd	s4,48(a0)
    sd s5, 56(a0)
    80001c6c:	03553c23          	sd	s5,56(a0)
    sd s6, 64(a0)
    80001c70:	05653023          	sd	s6,64(a0)
    sd s7, 72(a0)
    80001c74:	05753423          	sd	s7,72(a0)
    sd s8, 80(a0)
    80001c78:	05853823          	sd	s8,80(a0)
    sd s9, 88(a0)
    80001c7c:	05953c23          	sd	s9,88(a0)
    sd s10, 96(a0)
    80001c80:	07a53023          	sd	s10,96(a0)
    sd s11, 104(a0)
    80001c84:	07b53423          	sd	s11,104(a0)

    ld ra, 0(a1)
    80001c88:	0005b083          	ld	ra,0(a1)
    ld sp, 8(a1)
    80001c8c:	0085b103          	ld	sp,8(a1)
    ld s0, 16(a1)
    80001c90:	0105b403          	ld	s0,16(a1)
    ld s1, 24(a1)
    80001c94:	0185b483          	ld	s1,24(a1)
    ld s2, 32(a1)
    80001c98:	0205b903          	ld	s2,32(a1)
    ld s3, 40(a1)
    80001c9c:	0285b983          	ld	s3,40(a1)
    ld s4, 48(a1)
    80001ca0:	0305ba03          	ld	s4,48(a1)
    ld s5, 56(a1)
    80001ca4:	0385ba83          	ld	s5,56(a1)
    ld s6, 64(a1)
    80001ca8:	0405bb03          	ld	s6,64(a1)
    ld s7, 72(a1)
    80001cac:	0485bb83          	ld	s7,72(a1)
    ld s8, 80(a1)
    80001cb0:	0505bc03          	ld	s8,80(a1)
    ld s9, 88(a1)
    80001cb4:	0585bc83          	ld	s9,88(a1)
    ld s10, 96(a1)
    80001cb8:	0605bd03          	ld	s10,96(a1)
    ld s11, 104(a1)
    80001cbc:	0685bd83          	ld	s11,104(a1)
    
    ret
    80001cc0:	00008067          	ret

0000000080001cc4 <trapvec>:

.globl trapvec
.globl trap
trapvec:
    csrrw a0, mscratch, a0
    80001cc4:	34051573          	csrrw	a0,mscratch,a0
    # Copied from xv6
    addi a0, a0, -24
    80001cc8:	fe850513          	addi	a0,a0,-24
    sd ra, 40(a0)
    80001ccc:	02153423          	sd	ra,40(a0)
    sd sp, 48(a0)
    80001cd0:	02253823          	sd	sp,48(a0)
    sd gp, 56(a0)
    80001cd4:	02353c23          	sd	gp,56(a0)
    sd tp, 64(a0)
    80001cd8:	04453023          	sd	tp,64(a0)
    sd t0, 72(a0)
    80001cdc:	04553423          	sd	t0,72(a0)
    sd t1, 80(a0)
    80001ce0:	04653823          	sd	t1,80(a0)
    sd t2, 88(a0)
    80001ce4:	04753c23          	sd	t2,88(a0)
    sd s0, 96(a0)
    80001ce8:	06853023          	sd	s0,96(a0)
    sd s1, 104(a0)
    80001cec:	06953423          	sd	s1,104(a0)
    sd a1, 120(a0)
    80001cf0:	06b53c23          	sd	a1,120(a0)
    sd a2, 128(a0)
    80001cf4:	08c53023          	sd	a2,128(a0)
    sd a3, 136(a0)
    80001cf8:	08d53423          	sd	a3,136(a0)
    sd a4, 144(a0)
    80001cfc:	08e53823          	sd	a4,144(a0)
    sd a5, 152(a0)
    80001d00:	08f53c23          	sd	a5,152(a0)
    sd a6, 160(a0)
    80001d04:	0b053023          	sd	a6,160(a0)
    sd a7, 168(a0)
    80001d08:	0b153423          	sd	a7,168(a0)
    sd s2, 176(a0)
    80001d0c:	0b253823          	sd	s2,176(a0)
    sd s3, 184(a0)
    80001d10:	0b353c23          	sd	s3,184(a0)
    sd s4, 192(a0)
    80001d14:	0d453023          	sd	s4,192(a0)
    sd s5, 200(a0)
    80001d18:	0d553423          	sd	s5,200(a0)
    sd s6, 208(a0)
    80001d1c:	0d653823          	sd	s6,208(a0)
    sd s7, 216(a0)
    80001d20:	0d753c23          	sd	s7,216(a0)
    sd s8, 224(a0)
    80001d24:	0f853023          	sd	s8,224(a0)
    sd s9, 232(a0)
    80001d28:	0f953423          	sd	s9,232(a0)
    sd s10, 240(a0)
    80001d2c:	0fa53823          	sd	s10,240(a0)
    sd s11, 248(a0)
    80001d30:	0fb53c23          	sd	s11,248(a0)
    sd t3, 256(a0)
    80001d34:	11c53023          	sd	t3,256(a0)
    sd t4, 264(a0)
    80001d38:	11d53423          	sd	t4,264(a0)
    sd t5, 272(a0)
    80001d3c:	11e53823          	sd	t5,272(a0)
    sd t6, 280(a0)
    80001d40:	11f53c23          	sd	t6,280(a0)

    csrr t0, mscratch
    80001d44:	340022f3          	csrr	t0,mscratch
    sd t0, 112(a0)
    80001d48:	06553823          	sd	t0,112(a0)

    addi a0, a0, 24
    80001d4c:	01850513          	addi	a0,a0,24

    # initialize kernel stack pointer, from p->trapframe->kernel_sp
    ld sp, 0(a0)
    80001d50:	00053103          	ld	sp,0(a0)
    csrr t0, mepc
    80001d54:	341022f3          	csrr	t0,mepc
    sd t0, 8(a0)
    80001d58:	00553423          	sd	t0,8(a0)

    csrw mscratch, a0 
    80001d5c:	34051073          	csrw	mscratch,a0

    sfence.vma zero, zero
    80001d60:	12000073          	sfence.vma

    call trap
    80001d64:	0c0000ef          	jal	ra,80001e24 <trap>

0000000080001d68 <trapret>:

.globl trapret
trapret:
    csrrw a0, mscratch, a0
    80001d68:	34051573          	csrrw	a0,mscratch,a0
    sd sp, 0(a0)
    80001d6c:	00253023          	sd	sp,0(a0)
    ld t0, 8(a0)
    80001d70:	00853283          	ld	t0,8(a0)
    csrw mepc, t0
    80001d74:	34129073          	csrw	mepc,t0

    addi a0, a0, -24
    80001d78:	fe850513          	addi	a0,a0,-24
    # a0 is trapframe
    ld ra, 40(a0)
    80001d7c:	02853083          	ld	ra,40(a0)
    ld sp, 48(a0)
    80001d80:	03053103          	ld	sp,48(a0)
    ld gp, 56(a0)
    80001d84:	03853183          	ld	gp,56(a0)
    ld tp, 64(a0)
    80001d88:	04053203          	ld	tp,64(a0)
    ld t0, 72(a0)
    80001d8c:	04853283          	ld	t0,72(a0)
    ld t1, 80(a0)
    80001d90:	05053303          	ld	t1,80(a0)
    ld t2, 88(a0)
    80001d94:	05853383          	ld	t2,88(a0)
    ld s0, 96(a0)
    80001d98:	06053403          	ld	s0,96(a0)
    ld s1, 104(a0)
    80001d9c:	06853483          	ld	s1,104(a0)
    ld a1, 120(a0)
    80001da0:	07853583          	ld	a1,120(a0)
    ld a2, 128(a0)
    80001da4:	08053603          	ld	a2,128(a0)
    ld a3, 136(a0)
    80001da8:	08853683          	ld	a3,136(a0)
    ld a4, 144(a0)
    80001dac:	09053703          	ld	a4,144(a0)
    ld a5, 152(a0)
    80001db0:	09853783          	ld	a5,152(a0)
    ld a6, 160(a0)
    80001db4:	0a053803          	ld	a6,160(a0)
    ld a7, 168(a0)
    80001db8:	0a853883          	ld	a7,168(a0)
    ld s2, 176(a0)
    80001dbc:	0b053903          	ld	s2,176(a0)
    ld s3, 184(a0)
    80001dc0:	0b853983          	ld	s3,184(a0)
    ld s4, 192(a0)
    80001dc4:	0c053a03          	ld	s4,192(a0)
    ld s5, 200(a0)
    80001dc8:	0c853a83          	ld	s5,200(a0)
    ld s6, 208(a0)
    80001dcc:	0d053b03          	ld	s6,208(a0)
    ld s7, 216(a0)
    80001dd0:	0d853b83          	ld	s7,216(a0)
    ld s8, 224(a0)
    80001dd4:	0e053c03          	ld	s8,224(a0)
    ld s9, 232(a0)
    80001dd8:	0e853c83          	ld	s9,232(a0)
    ld s10, 240(a0)
    80001ddc:	0f053d03          	ld	s10,240(a0)
    ld s11, 248(a0)
    80001de0:	0f853d83          	ld	s11,248(a0)
    ld t3, 256(a0)
    80001de4:	10053e03          	ld	t3,256(a0)
    ld t4, 264(a0)
    80001de8:	10853e83          	ld	t4,264(a0)
    ld t5, 272(a0)
    80001dec:	11053f03          	ld	t5,272(a0)
    ld t6, 280(a0)
    80001df0:	11853f83          	ld	t6,280(a0)
    # Write trapframe pointer to mscratch
    addi a0, a0, 24
    80001df4:	01850513          	addi	a0,a0,24
    csrrw a0, mscratch, a0
    80001df8:	34051573          	csrrw	a0,mscratch,a0

    80001dfc:	30200073          	mret

0000000080001e00 <trapinit>:
extern void panic(char *);

extern unsigned long syscall(unsigned long);
void
trapinit(void)
{
    80001e00:	ff010113          	addi	sp,sp,-16
    80001e04:	00813423          	sd	s0,8(sp)
    80001e08:	01010413          	addi	s0,sp,16
    asm volatile("csrw mtvec, %0" : : "r" (x));
    80001e0c:	00000797          	auipc	a5,0x0
    80001e10:	eb878793          	addi	a5,a5,-328 # 80001cc4 <trapvec>
    80001e14:	30579073          	csrw	mtvec,a5
    w_mtvec((uint64_t)trapvec);
}
    80001e18:	00813403          	ld	s0,8(sp)
    80001e1c:	01010113          	addi	sp,sp,16
    80001e20:	00008067          	ret

0000000080001e24 <trap>:

void trap()
{
    80001e24:	fe010113          	addi	sp,sp,-32
    80001e28:	00813823          	sd	s0,16(sp)
    80001e2c:	00113c23          	sd	ra,24(sp)
    80001e30:	00913423          	sd	s1,8(sp)
    80001e34:	02010413          	addi	s0,sp,32
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80001e38:	300027f3          	csrr	a5,mstatus
    if((r_mstatus() & MSTATUS_MPP_S) != 0)
    80001e3c:	00b7d793          	srli	a5,a5,0xb
    80001e40:	0017f793          	andi	a5,a5,1
    80001e44:	02079663          	bnez	a5,80001e70 <trap+0x4c>

static inline uint64_t
r_mcause()
{
    uint64_t x;
    asm volatile("csrr %0, mcause" : "=r" (x) );
    80001e48:	342027f3          	csrr	a5,mcause
        panic("usertrap: not from user mode");

    uint64_t mcause = r_mcause();
    if (mcause >> 31 == 0) {
    80001e4c:	01f7d713          	srli	a4,a5,0x1f
    80001e50:	00071663          	bnez	a4,80001e5c <trap+0x38>
        switch (mcause)
    80001e54:	00800713          	li	a4,8
    80001e58:	02e78663          	beq	a5,a4,80001e84 <trap+0x60>
        
        default:
            break;
        }
    }
}
    80001e5c:	01813083          	ld	ra,24(sp)
    80001e60:	01013403          	ld	s0,16(sp)
    80001e64:	00813483          	ld	s1,8(sp)
    80001e68:	02010113          	addi	sp,sp,32
    80001e6c:	00008067          	ret
        panic("usertrap: not from user mode");
    80001e70:	00000517          	auipc	a0,0x0
    80001e74:	34850513          	addi	a0,a0,840 # 800021b8 <digits+0x1a8>
    80001e78:	ffffe097          	auipc	ra,0xffffe
    80001e7c:	5f8080e7          	jalr	1528(ra) # 80000470 <panic>
    80001e80:	fc9ff06f          	j	80001e48 <trap+0x24>
            syscall(myproc()->trapframe->a7);
    80001e84:	00000497          	auipc	s1,0x0
    80001e88:	39448493          	addi	s1,s1,916 # 80002218 <cur_proc>
    80001e8c:	0004b783          	ld	a5,0(s1)
    80001e90:	0207b783          	ld	a5,32(a5)
    80001e94:	0907b503          	ld	a0,144(a5)
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	0c8080e7          	jalr	200(ra) # 80001f60 <syscall>
            myproc()->trapframe->epc += 4;
    80001ea0:	0004b783          	ld	a5,0(s1)
}
    80001ea4:	01813083          	ld	ra,24(sp)
    80001ea8:	01013403          	ld	s0,16(sp)
            myproc()->trapframe->epc += 4;
    80001eac:	0207b703          	ld	a4,32(a5)
}
    80001eb0:	00813483          	ld	s1,8(sp)
            myproc()->trapframe->epc += 4;
    80001eb4:	00873783          	ld	a5,8(a4)
    80001eb8:	00478793          	addi	a5,a5,4
    80001ebc:	00f73423          	sd	a5,8(a4)
}
    80001ec0:	02010113          	addi	sp,sp,32
    80001ec4:	00008067          	ret

0000000080001ec8 <usertrapret>:

void
usertrapret(void)
{
    80001ec8:	ff010113          	addi	sp,sp,-16
    80001ecc:	00813023          	sd	s0,0(sp)
    80001ed0:	00113423          	sd	ra,8(sp)
    80001ed4:	01010413          	addi	s0,sp,16
    struct proc *p = myproc();
    80001ed8:	00000717          	auipc	a4,0x0
    80001edc:	34073703          	ld	a4,832(a4) # 80002218 <cur_proc>
    w_mepc(p->trapframe->epc);
    80001ee0:	02073783          	ld	a5,32(a4)
    asm volatile("csrw mepc, %0" : : "r" (x));
    80001ee4:	0087b783          	ld	a5,8(a5)
    80001ee8:	34179073          	csrw	mepc,a5
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    80001eec:	300027f3          	csrr	a5,mstatus
    // trapret();

    unsigned long x = r_mstatus();
    x &= ~MSTATUS_MPP_U; // clear SPP to 0 for user mode
    x |= MSTATUS_MPIE; // enable interrupts in user mode
    80001ef0:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80001ef4:	30079073          	csrw	mstatus,a5
    w_mstatus(x);
    w_satp((uint64_t)MAKE_SATP(p->pagetable));
    80001ef8:	01873783          	ld	a5,24(a4)
    80001efc:	fff00713          	li	a4,-1
    80001f00:	03f71713          	slli	a4,a4,0x3f
    80001f04:	00c7d793          	srli	a5,a5,0xc
    80001f08:	00e7e7b3          	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r" (x));
    80001f0c:	18079073          	csrw	satp,a5
    trapret();
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	e58080e7          	jalr	-424(ra) # 80001d68 <trapret>

    panic("");
    80001f18:	00013403          	ld	s0,0(sp)
    80001f1c:	00813083          	ld	ra,8(sp)
    panic("");
    80001f20:	00000517          	auipc	a0,0x0
    80001f24:	27850513          	addi	a0,a0,632 # 80002198 <digits+0x188>
    80001f28:	01010113          	addi	sp,sp,16
    panic("");
    80001f2c:	ffffe317          	auipc	t1,0xffffe
    80001f30:	54430067          	jr	1348(t1) # 80000470 <panic>

0000000080001f34 <plicinit>:
void
plicinit(void)
{
    80001f34:	ff010113          	addi	sp,sp,-16
    80001f38:	00813423          	sd	s0,8(sp)
    80001f3c:	01010413          	addi	s0,sp,16

    80001f40:	00813403          	ld	s0,8(sp)
    80001f44:	01010113          	addi	sp,sp,16
    80001f48:	00008067          	ret

0000000080001f4c <initcode>:

.global initcode
.global initend

initcode:
    li a7, SYS_INIT
    80001f4c:	000018b7          	lui	a7,0x1
    80001f50:	abc8889b          	addiw	a7,a7,-1348 # abc <_entry-0x7ffff544>
    ecall
    80001f54:	00000073          	ecall

0000000080001f58 <loop>:
loop:
    j loop
    80001f58:	0000006f          	j	80001f58 <loop>

0000000080001f5c <initend>:
    80001f5c:	04                	.byte	0x04
    80001f5d:	0000                	.2byte	0x0
	...

0000000080001f60 <syscall>:
#include "util.h"
#include "board.h"

uint64_t syscall(unsigned long x)
{
    switch (x)
    80001f60:	000017b7          	lui	a5,0x1
    80001f64:	abc78793          	addi	a5,a5,-1348 # abc <_entry-0x7ffff544>
    80001f68:	00f50663          	beq	a0,a5,80001f74 <syscall+0x14>
        return 0;
    
    default:
        break;
    }
    return -1;
    80001f6c:	fff00513          	li	a0,-1
    80001f70:	00008067          	ret
{
    80001f74:	ff010113          	addi	sp,sp,-16
    80001f78:	00813023          	sd	s0,0(sp)
    80001f7c:	00113423          	sd	ra,8(sp)
    80001f80:	01010413          	addi	s0,sp,16
        printf("Return from init! Test passed\n");
    80001f84:	00000517          	auipc	a0,0x0
    80001f88:	25450513          	addi	a0,a0,596 # 800021d8 <digits+0x1c8>
    80001f8c:	ffffe097          	auipc	ra,0xffffe
    80001f90:	2f0080e7          	jalr	752(ra) # 8000027c <printf>
    80001f94:	00813083          	ld	ra,8(sp)
    80001f98:	00013403          	ld	s0,0(sp)
        return 0;
    80001f9c:	00000513          	li	a0,0
    80001fa0:	01010113          	addi	sp,sp,16
    80001fa4:	00008067          	ret
	...
