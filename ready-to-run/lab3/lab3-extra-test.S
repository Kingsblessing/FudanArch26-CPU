
lab3-extra-test.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_start>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	68010113          	addi	sp,sp,1664 # 80009680 <_stack_top>
    80000008:	00001297          	auipc	t0,0x1
    8000000c:	67828293          	addi	t0,t0,1656 # 80001680 <__bss_end>
    80000010:	00001317          	auipc	t1,0x1
    80000014:	67030313          	addi	t1,t1,1648 # 80001680 <__bss_end>
    80000018:	00628863          	beq	t0,t1,80000028 <_start+0x28>
    8000001c:	0002b023          	sd	zero,0(t0)
    80000020:	00828293          	addi	t0,t0,8
    80000024:	fe62ece3          	bltu	t0,t1,8000001c <_start+0x1c>
    80000028:	599000ef          	jal	80000dc0 <main>
    8000002c:	00000513          	li	a0,0
    80000030:	0005006b          	.insn	4, 0x0005006b
    80000034:	3f8002b7          	lui	t0,0x3f800
    80000038:	f00280d3          	.insn	4, 0xf00280d3
    8000003c:	40400337          	lui	t1,0x40400
    80000040:	f0030153          	.insn	4, 0xf0030153
    80000044:	1820f053          	.insn	4, 0x1820f053
    80000048:	fedff06f          	j	80000034 <_start+0x34>

000000008000004c <_Z5put_iIyEvT_>:
    8000004c:	fe010113          	addi	sp,sp,-32
    80000050:	00810613          	addi	a2,sp,8
    80000054:	00000693          	li	a3,0
    80000058:	00a00593          	li	a1,10
    8000005c:	00900893          	li	a7,9
    80000060:	02b57733          	remu	a4,a0,a1
    80000064:	00160613          	addi	a2,a2,1
    80000068:	00050813          	mv	a6,a0
    8000006c:	00068793          	mv	a5,a3
    80000070:	0016869b          	addiw	a3,a3,1
    80000074:	0307071b          	addiw	a4,a4,48
    80000078:	fee60fa3          	sb	a4,-1(a2)
    8000007c:	02b55533          	divu	a0,a0,a1
    80000080:	ff08e0e3          	bltu	a7,a6,80000060 <_Z5put_iIyEvT_+0x14>
    80000084:	00810713          	addi	a4,sp,8
    80000088:	40600637          	lui	a2,0x40600
    8000008c:	00f707b3          	add	a5,a4,a5
    80000090:	fff70693          	addi	a3,a4,-1
    80000094:	00460613          	addi	a2,a2,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000098:	0007c703          	lbu	a4,0(a5)
    8000009c:	fff78793          	addi	a5,a5,-1
    800000a0:	00e60023          	sb	a4,0(a2)
    800000a4:	fed79ae3          	bne	a5,a3,80000098 <_Z5put_iIyEvT_+0x4c>
    800000a8:	02010113          	addi	sp,sp,32
    800000ac:	00008067          	ret

00000000800000b0 <_Z14loadStateArrayPA4_cPKc>:
    800000b0:	00458593          	addi	a1,a1,4
    800000b4:	00450613          	addi	a2,a0,4
    800000b8:	ffc58793          	addi	a5,a1,-4
    800000bc:	00050713          	mv	a4,a0
    800000c0:	0007c683          	lbu	a3,0(a5)
    800000c4:	00178793          	addi	a5,a5,1
    800000c8:	00470713          	addi	a4,a4,4
    800000cc:	fed70e23          	sb	a3,-4(a4)
    800000d0:	feb798e3          	bne	a5,a1,800000c0 <_Z14loadStateArrayPA4_cPKc+0x10>
    800000d4:	00150513          	addi	a0,a0,1
    800000d8:	00478593          	addi	a1,a5,4
    800000dc:	fcc51ee3          	bne	a0,a2,800000b8 <_Z14loadStateArrayPA4_cPKc+0x8>
    800000e0:	00000513          	li	a0,0
    800000e4:	00008067          	ret

00000000800000e8 <_Z15storeStateArrayPA4_cPc>:
    800000e8:	00458593          	addi	a1,a1,4
    800000ec:	00450613          	addi	a2,a0,4
    800000f0:	ffc58793          	addi	a5,a1,-4
    800000f4:	00050713          	mv	a4,a0
    800000f8:	00074683          	lbu	a3,0(a4)
    800000fc:	00178793          	addi	a5,a5,1
    80000100:	00470713          	addi	a4,a4,4
    80000104:	fed78fa3          	sb	a3,-1(a5)
    80000108:	feb798e3          	bne	a5,a1,800000f8 <_Z15storeStateArrayPA4_cPc+0x10>
    8000010c:	00150513          	addi	a0,a0,1
    80000110:	00478593          	addi	a1,a5,4
    80000114:	fcc51ee3          	bne	a0,a2,800000f0 <_Z15storeStateArrayPA4_cPc+0x8>
    80000118:	00000513          	li	a0,0
    8000011c:	00008067          	ret

0000000080000120 <_Z12keyExpansionPKcjP6AesKey>:
    80000120:	14050663          	beqz	a0,8000026c <_Z12keyExpansionPKcjP6AesKey+0x14c>
    80000124:	14060463          	beqz	a2,8000026c <_Z12keyExpansionPKcjP6AesKey+0x14c>
    80000128:	01000793          	li	a5,16
    8000012c:	14f59063          	bne	a1,a5,8000026c <_Z12keyExpansionPKcjP6AesKey+0x14c>
    80000130:	01050893          	addi	a7,a0,16
    80000134:	00060593          	mv	a1,a2
    80000138:	00054783          	lbu	a5,0(a0)
    8000013c:	00154683          	lbu	a3,1(a0)
    80000140:	00354803          	lbu	a6,3(a0)
    80000144:	00254703          	lbu	a4,2(a0)
    80000148:	0187979b          	slliw	a5,a5,0x18
    8000014c:	0106969b          	slliw	a3,a3,0x10
    80000150:	00d7e7b3          	or	a5,a5,a3
    80000154:	0107e7b3          	or	a5,a5,a6
    80000158:	0087171b          	slliw	a4,a4,0x8
    8000015c:	00e7e7b3          	or	a5,a5,a4
    80000160:	00f5a023          	sw	a5,0(a1)
    80000164:	00450513          	addi	a0,a0,4
    80000168:	00458593          	addi	a1,a1,4
    8000016c:	fca896e3          	bne	a7,a0,80000138 <_Z12keyExpansionPKcjP6AesKey+0x18>
    80000170:	00862583          	lw	a1,8(a2)
    80000174:	00462e83          	lw	t4,4(a2)
    80000178:	00c62703          	lw	a4,12(a2)
    8000017c:	00062e03          	lw	t3,0(a2)
    80000180:	01060693          	addi	a3,a2,16
    80000184:	00001317          	auipc	t1,0x1
    80000188:	28430313          	addi	t1,t1,644 # 80001408 <_ZL4rcon>
    8000018c:	00001f97          	auipc	t6,0x1
    80000190:	2a4f8f93          	addi	t6,t6,676 # 80001430 <_ZZL20runCorrectnessChecksvE2pt>
    80000194:	00001897          	auipc	a7,0x1
    80000198:	2ec88893          	addi	a7,a7,748 # 80001480 <S>
    8000019c:	0ff77793          	zext.b	a5,a4
    800001a0:	0107581b          	srliw	a6,a4,0x10
    800001a4:	01875f1b          	srliw	t5,a4,0x18
    800001a8:	0087551b          	srliw	a0,a4,0x8
    800001ac:	00f887b3          	add	a5,a7,a5
    800001b0:	0ff87813          	zext.b	a6,a6
    800001b4:	0007c783          	lbu	a5,0(a5)
    800001b8:	01e88f33          	add	t5,a7,t5
    800001bc:	01088833          	add	a6,a7,a6
    800001c0:	0ff57513          	zext.b	a0,a0
    800001c4:	000f4283          	lbu	t0,0(t5)
    800001c8:	00084803          	lbu	a6,0(a6)
    800001cc:	00a88533          	add	a0,a7,a0
    800001d0:	00054503          	lbu	a0,0(a0)
    800001d4:	0087979b          	slliw	a5,a5,0x8
    800001d8:	00032f03          	lw	t5,0(t1)
    800001dc:	0057c7b3          	xor	a5,a5,t0
    800001e0:	0188181b          	slliw	a6,a6,0x18
    800001e4:	0107c7b3          	xor	a5,a5,a6
    800001e8:	0105151b          	slliw	a0,a0,0x10
    800001ec:	00a7c7b3          	xor	a5,a5,a0
    800001f0:	01e7c7b3          	xor	a5,a5,t5
    800001f4:	01c7c7b3          	xor	a5,a5,t3
    800001f8:	00078e1b          	sext.w	t3,a5
    800001fc:	01de4eb3          	xor	t4,t3,t4
    80000200:	00bec5b3          	xor	a1,t4,a1
    80000204:	0005859b          	sext.w	a1,a1
    80000208:	00b74733          	xor	a4,a4,a1
    8000020c:	01c6a023          	sw	t3,0(a3)
    80000210:	01d6a223          	sw	t4,4(a3)
    80000214:	00b6a423          	sw	a1,8(a3)
    80000218:	00e6a623          	sw	a4,12(a3)
    8000021c:	00430313          	addi	t1,t1,4
    80000220:	01068693          	addi	a3,a3,16
    80000224:	f66f9ce3          	bne	t6,t1,8000019c <_Z12keyExpansionPKcjP6AesKey+0x7c>
    80000228:	00161893          	slli	a7,a2,0x1
    8000022c:	0a060713          	addi	a4,a2,160
    80000230:	15088893          	addi	a7,a7,336
    80000234:	ff060613          	addi	a2,a2,-16
    80000238:	01000813          	li	a6,16
    8000023c:	40e88533          	sub	a0,a7,a4
    80000240:	00000793          	li	a5,0
    80000244:	00f706b3          	add	a3,a4,a5
    80000248:	0006a583          	lw	a1,0(a3)
    8000024c:	00f506b3          	add	a3,a0,a5
    80000250:	00478793          	addi	a5,a5,4
    80000254:	00b6a023          	sw	a1,0(a3)
    80000258:	ff0796e3          	bne	a5,a6,80000244 <_Z12keyExpansionPKcjP6AesKey+0x124>
    8000025c:	ff070713          	addi	a4,a4,-16
    80000260:	fcc71ee3          	bne	a4,a2,8000023c <_Z12keyExpansionPKcjP6AesKey+0x11c>
    80000264:	00000513          	li	a0,0
    80000268:	00008067          	ret
    8000026c:	fff00513          	li	a0,-1
    80000270:	00008067          	ret

0000000080000274 <_Z11addRoundKeyPA4_cPKj>:
    80000274:	01800313          	li	t1,24
    80000278:	01058893          	addi	a7,a1,16
    8000027c:	ff800e13          	li	t3,-8
    80000280:	0003081b          	sext.w	a6,t1
    80000284:	00058713          	mv	a4,a1
    80000288:	00050793          	mv	a5,a0
    8000028c:	00072603          	lw	a2,0(a4)
    80000290:	0007c683          	lbu	a3,0(a5)
    80000294:	00470713          	addi	a4,a4,4
    80000298:	0106563b          	srlw	a2,a2,a6
    8000029c:	00c6c6b3          	xor	a3,a3,a2
    800002a0:	00d78023          	sb	a3,0(a5)
    800002a4:	00178793          	addi	a5,a5,1
    800002a8:	fee892e3          	bne	a7,a4,8000028c <_Z11addRoundKeyPA4_cPKj+0x18>
    800002ac:	ff83031b          	addiw	t1,t1,-8
    800002b0:	00450513          	addi	a0,a0,4
    800002b4:	fdc316e3          	bne	t1,t3,80000280 <_Z11addRoundKeyPA4_cPKj+0xc>
    800002b8:	00000513          	li	a0,0
    800002bc:	00008067          	ret

00000000800002c0 <_Z8subBytesPA4_c>:
    800002c0:	00450693          	addi	a3,a0,4
    800002c4:	01450593          	addi	a1,a0,20
    800002c8:	00001617          	auipc	a2,0x1
    800002cc:	1b860613          	addi	a2,a2,440 # 80001480 <S>
    800002d0:	ffc68793          	addi	a5,a3,-4
    800002d4:	0007c703          	lbu	a4,0(a5)
    800002d8:	00178793          	addi	a5,a5,1
    800002dc:	00e60733          	add	a4,a2,a4
    800002e0:	00074703          	lbu	a4,0(a4)
    800002e4:	fee78fa3          	sb	a4,-1(a5)
    800002e8:	fed796e3          	bne	a5,a3,800002d4 <_Z8subBytesPA4_c+0x14>
    800002ec:	00478693          	addi	a3,a5,4
    800002f0:	feb690e3          	bne	a3,a1,800002d0 <_Z8subBytesPA4_c+0x10>
    800002f4:	00000513          	li	a0,0
    800002f8:	00008067          	ret

00000000800002fc <_Z11invSubBytesPA4_c>:
    800002fc:	00450693          	addi	a3,a0,4
    80000300:	01450593          	addi	a1,a0,20
    80000304:	00001617          	auipc	a2,0x1
    80000308:	17c60613          	addi	a2,a2,380 # 80001480 <S>
    8000030c:	ffc68793          	addi	a5,a3,-4
    80000310:	0007c703          	lbu	a4,0(a5)
    80000314:	00178793          	addi	a5,a5,1
    80000318:	00e60733          	add	a4,a2,a4
    8000031c:	10074703          	lbu	a4,256(a4)
    80000320:	fee78fa3          	sb	a4,-1(a5)
    80000324:	fed796e3          	bne	a5,a3,80000310 <_Z11invSubBytesPA4_c+0x14>
    80000328:	00478693          	addi	a3,a5,4
    8000032c:	feb690e3          	bne	a3,a1,8000030c <_Z11invSubBytesPA4_c+0x10>
    80000330:	00000513          	li	a0,0
    80000334:	00008067          	ret

0000000080000338 <_Z9shiftRowsPA4_c>:
    80000338:	02000693          	li	a3,32
    8000033c:	00054783          	lbu	a5,0(a0)
    80000340:	00154603          	lbu	a2,1(a0)
    80000344:	00354583          	lbu	a1,3(a0)
    80000348:	00254703          	lbu	a4,2(a0)
    8000034c:	0106161b          	slliw	a2,a2,0x10
    80000350:	0187979b          	slliw	a5,a5,0x18
    80000354:	00c7e7b3          	or	a5,a5,a2
    80000358:	00b7e7b3          	or	a5,a5,a1
    8000035c:	0087171b          	slliw	a4,a4,0x8
    80000360:	40d0063b          	negw	a2,a3
    80000364:	00e7e7b3          	or	a5,a5,a4
    80000368:	00d7d73b          	srlw	a4,a5,a3
    8000036c:	00c797bb          	sllw	a5,a5,a2
    80000370:	00f767b3          	or	a5,a4,a5
    80000374:	0187d59b          	srliw	a1,a5,0x18
    80000378:	0107d61b          	srliw	a2,a5,0x10
    8000037c:	0087d71b          	srliw	a4,a5,0x8
    80000380:	00b50023          	sb	a1,0(a0)
    80000384:	00c500a3          	sb	a2,1(a0)
    80000388:	00e50123          	sb	a4,2(a0)
    8000038c:	00f501a3          	sb	a5,3(a0)
    80000390:	ff86869b          	addiw	a3,a3,-8
    80000394:	00450513          	addi	a0,a0,4
    80000398:	fa0692e3          	bnez	a3,8000033c <_Z9shiftRowsPA4_c+0x4>
    8000039c:	00000513          	li	a0,0
    800003a0:	00008067          	ret

00000000800003a4 <_Z12invShiftRowsPA4_c>:
    800003a4:	02000693          	li	a3,32
    800003a8:	00054783          	lbu	a5,0(a0)
    800003ac:	00154603          	lbu	a2,1(a0)
    800003b0:	00354583          	lbu	a1,3(a0)
    800003b4:	00254703          	lbu	a4,2(a0)
    800003b8:	0106161b          	slliw	a2,a2,0x10
    800003bc:	0187979b          	slliw	a5,a5,0x18
    800003c0:	00c7e7b3          	or	a5,a5,a2
    800003c4:	00b7e7b3          	or	a5,a5,a1
    800003c8:	0087171b          	slliw	a4,a4,0x8
    800003cc:	40d0063b          	negw	a2,a3
    800003d0:	00e7e7b3          	or	a5,a5,a4
    800003d4:	00d7973b          	sllw	a4,a5,a3
    800003d8:	00c7d7bb          	srlw	a5,a5,a2
    800003dc:	00f767b3          	or	a5,a4,a5
    800003e0:	0187d59b          	srliw	a1,a5,0x18
    800003e4:	0107d61b          	srliw	a2,a5,0x10
    800003e8:	0087d71b          	srliw	a4,a5,0x8
    800003ec:	00b50023          	sb	a1,0(a0)
    800003f0:	00c500a3          	sb	a2,1(a0)
    800003f4:	00e50123          	sb	a4,2(a0)
    800003f8:	00f501a3          	sb	a5,3(a0)
    800003fc:	ff86869b          	addiw	a3,a3,-8
    80000400:	00450513          	addi	a0,a0,4
    80000404:	fa0692e3          	bnez	a3,800003a8 <_Z12invShiftRowsPA4_c+0x4>
    80000408:	00000513          	li	a0,0
    8000040c:	00008067          	ret

0000000080000410 <_Z4GMulcc>:
    80000410:	00050713          	mv	a4,a0
    80000414:	00800693          	li	a3,8
    80000418:	00000513          	li	a0,0
    8000041c:	00177793          	andi	a5,a4,1
    80000420:	0185961b          	slliw	a2,a1,0x18
    80000424:	40f007bb          	negw	a5,a5
    80000428:	00f5f7b3          	and	a5,a1,a5
    8000042c:	0015981b          	slliw	a6,a1,0x1
    80000430:	4186561b          	sraiw	a2,a2,0x18
    80000434:	fff6869b          	addiw	a3,a3,-1
    80000438:	0fe87593          	andi	a1,a6,254
    8000043c:	00f54533          	xor	a0,a0,a5
    80000440:	00065463          	bgez	a2,80000448 <_Z4GMulcc+0x38>
    80000444:	01b5c593          	xori	a1,a1,27
    80000448:	00175713          	srli	a4,a4,0x1
    8000044c:	fc0698e3          	bnez	a3,8000041c <_Z4GMulcc+0xc>
    80000450:	00008067          	ret

0000000080000454 <_Z10mixColumnsPA4_c>:
    80000454:	fc010113          	addi	sp,sp,-64
    80000458:	00001797          	auipc	a5,0x1
    8000045c:	0087b783          	ld	a5,8(a5) # 80001460 <_ZZL20runCorrectnessChecksvE10expectedCt+0x10>
    80000460:	00f13823          	sd	a5,16(sp)
    80000464:	010008b7          	lui	a7,0x1000
    80000468:	00001797          	auipc	a5,0x1
    8000046c:	0007b783          	ld	a5,0(a5) # 80001468 <_ZZL20runCorrectnessChecksvE10expectedCt+0x18>
    80000470:	02813c23          	sd	s0,56(sp)
    80000474:	02913823          	sd	s1,48(sp)
    80000478:	03213423          	sd	s2,40(sp)
    8000047c:	00f13c23          	sd	a5,24(sp)
    80000480:	01050313          	addi	t1,a0,16
    80000484:	00010813          	mv	a6,sp
    80000488:	00050713          	mv	a4,a0
    8000048c:	fff88893          	addi	a7,a7,-1 # ffffff <STACK_SIZE+0xff7fff>
    80000490:	00174583          	lbu	a1,1(a4)
    80000494:	00274603          	lbu	a2,2(a4)
    80000498:	00074783          	lbu	a5,0(a4)
    8000049c:	00374683          	lbu	a3,3(a4)
    800004a0:	0085959b          	slliw	a1,a1,0x8
    800004a4:	00b7e7b3          	or	a5,a5,a1
    800004a8:	0106161b          	slliw	a2,a2,0x10
    800004ac:	00c7e7b3          	or	a5,a5,a2
    800004b0:	0186969b          	slliw	a3,a3,0x18
    800004b4:	0117f7b3          	and	a5,a5,a7
    800004b8:	00d7e7b3          	or	a5,a5,a3
    800004bc:	00f82023          	sw	a5,0(a6)
    800004c0:	00470713          	addi	a4,a4,4
    800004c4:	00480813          	addi	a6,a6,4
    800004c8:	fce314e3          	bne	t1,a4,80000490 <_Z10mixColumnsPA4_c+0x3c>
    800004cc:	01010593          	addi	a1,sp,16
    800004d0:	02010f13          	addi	t5,sp,32
    800004d4:	00410e93          	addi	t4,sp,4
    800004d8:	0005ce03          	lbu	t3,0(a1)
    800004dc:	0015c303          	lbu	t1,1(a1)
    800004e0:	0025c883          	lbu	a7,2(a1)
    800004e4:	0035c803          	lbu	a6,3(a1)
    800004e8:	00050613          	mv	a2,a0
    800004ec:	00010693          	mv	a3,sp
    800004f0:	0006cf83          	lbu	t6,0(a3)
    800004f4:	000e0713          	mv	a4,t3
    800004f8:	00800293          	li	t0,8
    800004fc:	00000413          	li	s0,0
    80000500:	00177793          	andi	a5,a4,1
    80000504:	018f939b          	slliw	t2,t6,0x18
    80000508:	40f007bb          	negw	a5,a5
    8000050c:	00fff7b3          	and	a5,t6,a5
    80000510:	001f949b          	slliw	s1,t6,0x1
    80000514:	4183d39b          	sraiw	t2,t2,0x18
    80000518:	0017571b          	srliw	a4,a4,0x1
    8000051c:	fff2829b          	addiw	t0,t0,-1 # 3f7fffff <STACK_SIZE+0x3f7f7fff>
    80000520:	0fe4ff93          	andi	t6,s1,254
    80000524:	00f44433          	xor	s0,s0,a5
    80000528:	0003d463          	bgez	t2,80000530 <_Z10mixColumnsPA4_c+0xdc>
    8000052c:	01bfcf93          	xori	t6,t6,27
    80000530:	0ff77713          	zext.b	a4,a4
    80000534:	fc0296e3          	bnez	t0,80000500 <_Z10mixColumnsPA4_c+0xac>
    80000538:	0046cf83          	lbu	t6,4(a3)
    8000053c:	00030713          	mv	a4,t1
    80000540:	00800393          	li	t2,8
    80000544:	00177793          	andi	a5,a4,1
    80000548:	018f949b          	slliw	s1,t6,0x18
    8000054c:	40f007bb          	negw	a5,a5
    80000550:	00fff7b3          	and	a5,t6,a5
    80000554:	001f991b          	slliw	s2,t6,0x1
    80000558:	4184d49b          	sraiw	s1,s1,0x18
    8000055c:	0017571b          	srliw	a4,a4,0x1
    80000560:	fff3839b          	addiw	t2,t2,-1
    80000564:	0fe97f93          	andi	t6,s2,254
    80000568:	00f2c2b3          	xor	t0,t0,a5
    8000056c:	0004d463          	bgez	s1,80000574 <_Z10mixColumnsPA4_c+0x120>
    80000570:	01bfcf93          	xori	t6,t6,27
    80000574:	0ff77713          	zext.b	a4,a4
    80000578:	fc0396e3          	bnez	t2,80000544 <_Z10mixColumnsPA4_c+0xf0>
    8000057c:	0086cf83          	lbu	t6,8(a3)
    80000580:	0082c2b3          	xor	t0,t0,s0
    80000584:	00088713          	mv	a4,a7
    80000588:	00800393          	li	t2,8
    8000058c:	00000413          	li	s0,0
    80000590:	00177793          	andi	a5,a4,1
    80000594:	018f949b          	slliw	s1,t6,0x18
    80000598:	40f007bb          	negw	a5,a5
    8000059c:	00fff7b3          	and	a5,t6,a5
    800005a0:	001f991b          	slliw	s2,t6,0x1
    800005a4:	4184d49b          	sraiw	s1,s1,0x18
    800005a8:	0017571b          	srliw	a4,a4,0x1
    800005ac:	fff3839b          	addiw	t2,t2,-1
    800005b0:	0fe97f93          	andi	t6,s2,254
    800005b4:	00f44433          	xor	s0,s0,a5
    800005b8:	0004d463          	bgez	s1,800005c0 <_Z10mixColumnsPA4_c+0x16c>
    800005bc:	01bfcf93          	xori	t6,t6,27
    800005c0:	0ff77713          	zext.b	a4,a4
    800005c4:	fc0396e3          	bnez	t2,80000590 <_Z10mixColumnsPA4_c+0x13c>
    800005c8:	00c6cf83          	lbu	t6,12(a3)
    800005cc:	0082c2b3          	xor	t0,t0,s0
    800005d0:	0ff2f293          	zext.b	t0,t0
    800005d4:	00080713          	mv	a4,a6
    800005d8:	00800393          	li	t2,8
    800005dc:	00000413          	li	s0,0
    800005e0:	00177793          	andi	a5,a4,1
    800005e4:	018f949b          	slliw	s1,t6,0x18
    800005e8:	40f007bb          	negw	a5,a5
    800005ec:	00fff7b3          	and	a5,t6,a5
    800005f0:	001f991b          	slliw	s2,t6,0x1
    800005f4:	4184d49b          	sraiw	s1,s1,0x18
    800005f8:	0017571b          	srliw	a4,a4,0x1
    800005fc:	fff3839b          	addiw	t2,t2,-1
    80000600:	0fe97f93          	andi	t6,s2,254
    80000604:	00f44433          	xor	s0,s0,a5
    80000608:	0004d463          	bgez	s1,80000610 <_Z10mixColumnsPA4_c+0x1bc>
    8000060c:	01bfcf93          	xori	t6,t6,27
    80000610:	0ff77713          	zext.b	a4,a4
    80000614:	fc0396e3          	bnez	t2,800005e0 <_Z10mixColumnsPA4_c+0x18c>
    80000618:	0082c7b3          	xor	a5,t0,s0
    8000061c:	00f60023          	sb	a5,0(a2)
    80000620:	00168693          	addi	a3,a3,1
    80000624:	00160613          	addi	a2,a2,1
    80000628:	ecde94e3          	bne	t4,a3,800004f0 <_Z10mixColumnsPA4_c+0x9c>
    8000062c:	00458593          	addi	a1,a1,4
    80000630:	00450513          	addi	a0,a0,4
    80000634:	ebe592e3          	bne	a1,t5,800004d8 <_Z10mixColumnsPA4_c+0x84>
    80000638:	03813403          	ld	s0,56(sp)
    8000063c:	03013483          	ld	s1,48(sp)
    80000640:	02813903          	ld	s2,40(sp)
    80000644:	00000513          	li	a0,0
    80000648:	04010113          	addi	sp,sp,64
    8000064c:	00008067          	ret

0000000080000650 <_Z13invMixColumnsPA4_c>:
    80000650:	fc010113          	addi	sp,sp,-64
    80000654:	00001797          	auipc	a5,0x1
    80000658:	e1c7b783          	ld	a5,-484(a5) # 80001470 <_ZZL20runCorrectnessChecksvE10expectedCt+0x20>
    8000065c:	00f13823          	sd	a5,16(sp)
    80000660:	010008b7          	lui	a7,0x1000
    80000664:	00001797          	auipc	a5,0x1
    80000668:	e147b783          	ld	a5,-492(a5) # 80001478 <_ZZL20runCorrectnessChecksvE10expectedCt+0x28>
    8000066c:	02813c23          	sd	s0,56(sp)
    80000670:	02913823          	sd	s1,48(sp)
    80000674:	03213423          	sd	s2,40(sp)
    80000678:	00f13c23          	sd	a5,24(sp)
    8000067c:	01050313          	addi	t1,a0,16
    80000680:	00010813          	mv	a6,sp
    80000684:	00050713          	mv	a4,a0
    80000688:	fff88893          	addi	a7,a7,-1 # ffffff <STACK_SIZE+0xff7fff>
    8000068c:	00174583          	lbu	a1,1(a4)
    80000690:	00274603          	lbu	a2,2(a4)
    80000694:	00074783          	lbu	a5,0(a4)
    80000698:	00374683          	lbu	a3,3(a4)
    8000069c:	0085959b          	slliw	a1,a1,0x8
    800006a0:	00b7e7b3          	or	a5,a5,a1
    800006a4:	0106161b          	slliw	a2,a2,0x10
    800006a8:	00c7e7b3          	or	a5,a5,a2
    800006ac:	0186969b          	slliw	a3,a3,0x18
    800006b0:	0117f7b3          	and	a5,a5,a7
    800006b4:	00d7e7b3          	or	a5,a5,a3
    800006b8:	00f82023          	sw	a5,0(a6)
    800006bc:	00470713          	addi	a4,a4,4
    800006c0:	00480813          	addi	a6,a6,4
    800006c4:	fce314e3          	bne	t1,a4,8000068c <_Z13invMixColumnsPA4_c+0x3c>
    800006c8:	01010593          	addi	a1,sp,16
    800006cc:	02010f13          	addi	t5,sp,32
    800006d0:	00410e93          	addi	t4,sp,4
    800006d4:	0005ce03          	lbu	t3,0(a1)
    800006d8:	0015c303          	lbu	t1,1(a1)
    800006dc:	0025c883          	lbu	a7,2(a1)
    800006e0:	0035c803          	lbu	a6,3(a1)
    800006e4:	00050613          	mv	a2,a0
    800006e8:	00010693          	mv	a3,sp
    800006ec:	0006cf83          	lbu	t6,0(a3)
    800006f0:	000e0713          	mv	a4,t3
    800006f4:	00800293          	li	t0,8
    800006f8:	00000413          	li	s0,0
    800006fc:	00177793          	andi	a5,a4,1
    80000700:	018f939b          	slliw	t2,t6,0x18
    80000704:	40f007bb          	negw	a5,a5
    80000708:	00fff7b3          	and	a5,t6,a5
    8000070c:	001f949b          	slliw	s1,t6,0x1
    80000710:	4183d39b          	sraiw	t2,t2,0x18
    80000714:	0017571b          	srliw	a4,a4,0x1
    80000718:	fff2829b          	addiw	t0,t0,-1
    8000071c:	0fe4ff93          	andi	t6,s1,254
    80000720:	00f44433          	xor	s0,s0,a5
    80000724:	0003d463          	bgez	t2,8000072c <_Z13invMixColumnsPA4_c+0xdc>
    80000728:	01bfcf93          	xori	t6,t6,27
    8000072c:	0ff77713          	zext.b	a4,a4
    80000730:	fc0296e3          	bnez	t0,800006fc <_Z13invMixColumnsPA4_c+0xac>
    80000734:	0046cf83          	lbu	t6,4(a3)
    80000738:	00030713          	mv	a4,t1
    8000073c:	00800393          	li	t2,8
    80000740:	00177793          	andi	a5,a4,1
    80000744:	018f949b          	slliw	s1,t6,0x18
    80000748:	40f007bb          	negw	a5,a5
    8000074c:	00fff7b3          	and	a5,t6,a5
    80000750:	001f991b          	slliw	s2,t6,0x1
    80000754:	4184d49b          	sraiw	s1,s1,0x18
    80000758:	0017571b          	srliw	a4,a4,0x1
    8000075c:	fff3839b          	addiw	t2,t2,-1
    80000760:	0fe97f93          	andi	t6,s2,254
    80000764:	00f2c2b3          	xor	t0,t0,a5
    80000768:	0004d463          	bgez	s1,80000770 <_Z13invMixColumnsPA4_c+0x120>
    8000076c:	01bfcf93          	xori	t6,t6,27
    80000770:	0ff77713          	zext.b	a4,a4
    80000774:	fc0396e3          	bnez	t2,80000740 <_Z13invMixColumnsPA4_c+0xf0>
    80000778:	0086cf83          	lbu	t6,8(a3)
    8000077c:	0082c2b3          	xor	t0,t0,s0
    80000780:	00088713          	mv	a4,a7
    80000784:	00800393          	li	t2,8
    80000788:	00000413          	li	s0,0
    8000078c:	00177793          	andi	a5,a4,1
    80000790:	018f949b          	slliw	s1,t6,0x18
    80000794:	40f007bb          	negw	a5,a5
    80000798:	00fff7b3          	and	a5,t6,a5
    8000079c:	001f991b          	slliw	s2,t6,0x1
    800007a0:	4184d49b          	sraiw	s1,s1,0x18
    800007a4:	0017571b          	srliw	a4,a4,0x1
    800007a8:	fff3839b          	addiw	t2,t2,-1
    800007ac:	0fe97f93          	andi	t6,s2,254
    800007b0:	00f44433          	xor	s0,s0,a5
    800007b4:	0004d463          	bgez	s1,800007bc <_Z13invMixColumnsPA4_c+0x16c>
    800007b8:	01bfcf93          	xori	t6,t6,27
    800007bc:	0ff77713          	zext.b	a4,a4
    800007c0:	fc0396e3          	bnez	t2,8000078c <_Z13invMixColumnsPA4_c+0x13c>
    800007c4:	00c6cf83          	lbu	t6,12(a3)
    800007c8:	0082c2b3          	xor	t0,t0,s0
    800007cc:	0ff2f293          	zext.b	t0,t0
    800007d0:	00080713          	mv	a4,a6
    800007d4:	00800393          	li	t2,8
    800007d8:	00000413          	li	s0,0
    800007dc:	00177793          	andi	a5,a4,1
    800007e0:	018f949b          	slliw	s1,t6,0x18
    800007e4:	40f007bb          	negw	a5,a5
    800007e8:	00fff7b3          	and	a5,t6,a5
    800007ec:	001f991b          	slliw	s2,t6,0x1
    800007f0:	4184d49b          	sraiw	s1,s1,0x18
    800007f4:	0017571b          	srliw	a4,a4,0x1
    800007f8:	fff3839b          	addiw	t2,t2,-1
    800007fc:	0fe97f93          	andi	t6,s2,254
    80000800:	00f44433          	xor	s0,s0,a5
    80000804:	0004d463          	bgez	s1,8000080c <_Z13invMixColumnsPA4_c+0x1bc>
    80000808:	01bfcf93          	xori	t6,t6,27
    8000080c:	0ff77713          	zext.b	a4,a4
    80000810:	fc0396e3          	bnez	t2,800007dc <_Z13invMixColumnsPA4_c+0x18c>
    80000814:	0082c7b3          	xor	a5,t0,s0
    80000818:	00f60023          	sb	a5,0(a2)
    8000081c:	00168693          	addi	a3,a3,1
    80000820:	00160613          	addi	a2,a2,1
    80000824:	ecde94e3          	bne	t4,a3,800006ec <_Z13invMixColumnsPA4_c+0x9c>
    80000828:	00458593          	addi	a1,a1,4
    8000082c:	00450513          	addi	a0,a0,4
    80000830:	ebe592e3          	bne	a1,t5,800006d4 <_Z13invMixColumnsPA4_c+0x84>
    80000834:	03813403          	ld	s0,56(sp)
    80000838:	03013483          	ld	s1,48(sp)
    8000083c:	02813903          	ld	s2,40(sp)
    80000840:	00000513          	li	a0,0
    80000844:	04010113          	addi	sp,sp,64
    80000848:	00008067          	ret

000000008000084c <_Z10aesEncryptPKcjS0_Pcj>:
    8000084c:	e2010113          	addi	sp,sp,-480
    80000850:	1c113c23          	sd	ra,472(sp)
    80000854:	00013423          	sd	zero,8(sp)
    80000858:	00013823          	sd	zero,16(sp)
    8000085c:	00013c23          	sd	zero,24(sp)
    80000860:	02013023          	sd	zero,32(sp)
    80000864:	1e050e63          	beqz	a0,80000a60 <_Z10aesEncryptPKcjS0_Pcj+0x214>
    80000868:	1c813823          	sd	s0,464(sp)
    8000086c:	00060413          	mv	s0,a2
    80000870:	20060e63          	beqz	a2,80000a8c <_Z10aesEncryptPKcjS0_Pcj+0x240>
    80000874:	1b413823          	sd	s4,432(sp)
    80000878:	00068a13          	mv	s4,a3
    8000087c:	20068063          	beqz	a3,80000a7c <_Z10aesEncryptPKcjS0_Pcj+0x230>
    80000880:	1c913423          	sd	s1,456(sp)
    80000884:	00070493          	mv	s1,a4
    80000888:	01000713          	li	a4,16
    8000088c:	1cb76e63          	bltu	a4,a1,80000a68 <_Z10aesEncryptPKcjS0_Pcj+0x21c>
    80000890:	00f4f713          	andi	a4,s1,15
    80000894:	1c071a63          	bnez	a4,80000a68 <_Z10aesEncryptPKcjS0_Pcj+0x21c>
    80000898:	1c058063          	beqz	a1,80000a58 <_Z10aesEncryptPKcjS0_Pcj+0x20c>
    8000089c:	02059693          	slli	a3,a1,0x20
    800008a0:	00050793          	mv	a5,a0
    800008a4:	0206d693          	srli	a3,a3,0x20
    800008a8:	00810513          	addi	a0,sp,8
    800008ac:	00078713          	mv	a4,a5
    800008b0:	00d506b3          	add	a3,a0,a3
    800008b4:	00050793          	mv	a5,a0
    800008b8:	00074603          	lbu	a2,0(a4)
    800008bc:	00178793          	addi	a5,a5,1
    800008c0:	00170713          	addi	a4,a4,1
    800008c4:	fec78fa3          	sb	a2,-1(a5)
    800008c8:	fed798e3          	bne	a5,a3,800008b8 <_Z10aesEncryptPKcjS0_Pcj+0x6c>
    800008cc:	02810613          	addi	a2,sp,40
    800008d0:	01000593          	li	a1,16
    800008d4:	84dff0ef          	jal	80000120 <_Z12keyExpansionPKcjP6AesKey>
    800008d8:	16048263          	beqz	s1,80000a3c <_Z10aesEncryptPKcjS0_Pcj+0x1f0>
    800008dc:	fff4879b          	addiw	a5,s1,-1
    800008e0:	0047d79b          	srliw	a5,a5,0x4
    800008e4:	00479793          	slli	a5,a5,0x4
    800008e8:	01478793          	addi	a5,a5,20
    800008ec:	1d213023          	sd	s2,448(sp)
    800008f0:	1b513423          	sd	s5,424(sp)
    800008f4:	1b613023          	sd	s6,416(sp)
    800008f8:	004a0a93          	addi	s5,s4,4
    800008fc:	00440693          	addi	a3,s0,4
    80000900:	1b313c23          	sd	s3,440(sp)
    80000904:	19713c23          	sd	s7,408(sp)
    80000908:	19813823          	sd	s8,400(sp)
    8000090c:	00fa0a33          	add	s4,s4,a5
    80000910:	00001417          	auipc	s0,0x1
    80000914:	b7040413          	addi	s0,s0,-1168 # 80001480 <S>
    80000918:	0b810913          	addi	s2,sp,184
    8000091c:	02c10b13          	addi	s6,sp,44
    80000920:	01810493          	addi	s1,sp,24
    80000924:	00048593          	mv	a1,s1
    80000928:	01068993          	addi	s3,a3,16
    8000092c:	ffc68793          	addi	a5,a3,-4
    80000930:	00058713          	mv	a4,a1
    80000934:	0007c603          	lbu	a2,0(a5)
    80000938:	00178793          	addi	a5,a5,1
    8000093c:	00470713          	addi	a4,a4,4
    80000940:	fec70e23          	sb	a2,-4(a4)
    80000944:	fed798e3          	bne	a5,a3,80000934 <_Z10aesEncryptPKcjS0_Pcj+0xe8>
    80000948:	00478693          	addi	a3,a5,4
    8000094c:	00158593          	addi	a1,a1,1
    80000950:	fd369ee3          	bne	a3,s3,8000092c <_Z10aesEncryptPKcjS0_Pcj+0xe0>
    80000954:	02810593          	addi	a1,sp,40
    80000958:	01810513          	addi	a0,sp,24
    8000095c:	919ff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    80000960:	02810b93          	addi	s7,sp,40
    80000964:	01c10c13          	addi	s8,sp,28
    80000968:	010b8b93          	addi	s7,s7,16
    8000096c:	000c0693          	mv	a3,s8
    80000970:	ffc68793          	addi	a5,a3,-4
    80000974:	0007c703          	lbu	a4,0(a5)
    80000978:	00178793          	addi	a5,a5,1
    8000097c:	00e40733          	add	a4,s0,a4
    80000980:	00074703          	lbu	a4,0(a4)
    80000984:	fee78fa3          	sb	a4,-1(a5)
    80000988:	fed796e3          	bne	a5,a3,80000974 <_Z10aesEncryptPKcjS0_Pcj+0x128>
    8000098c:	00478693          	addi	a3,a5,4
    80000990:	ff6690e3          	bne	a3,s6,80000970 <_Z10aesEncryptPKcjS0_Pcj+0x124>
    80000994:	01810513          	addi	a0,sp,24
    80000998:	9a1ff0ef          	jal	80000338 <_Z9shiftRowsPA4_c>
    8000099c:	01810513          	addi	a0,sp,24
    800009a0:	ab5ff0ef          	jal	80000454 <_Z10mixColumnsPA4_c>
    800009a4:	000b8593          	mv	a1,s7
    800009a8:	01810513          	addi	a0,sp,24
    800009ac:	8c9ff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    800009b0:	fb2b9ae3          	bne	s7,s2,80000964 <_Z10aesEncryptPKcjS0_Pcj+0x118>
    800009b4:	ffcc0793          	addi	a5,s8,-4
    800009b8:	0007c703          	lbu	a4,0(a5)
    800009bc:	00178793          	addi	a5,a5,1
    800009c0:	00e40733          	add	a4,s0,a4
    800009c4:	00074703          	lbu	a4,0(a4)
    800009c8:	fee78fa3          	sb	a4,-1(a5)
    800009cc:	ff8796e3          	bne	a5,s8,800009b8 <_Z10aesEncryptPKcjS0_Pcj+0x16c>
    800009d0:	00478c13          	addi	s8,a5,4
    800009d4:	ff6c10e3          	bne	s8,s6,800009b4 <_Z10aesEncryptPKcjS0_Pcj+0x168>
    800009d8:	01810513          	addi	a0,sp,24
    800009dc:	95dff0ef          	jal	80000338 <_Z9shiftRowsPA4_c>
    800009e0:	0c810593          	addi	a1,sp,200
    800009e4:	01810513          	addi	a0,sp,24
    800009e8:	88dff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    800009ec:	010a8613          	addi	a2,s5,16
    800009f0:	ffca8793          	addi	a5,s5,-4
    800009f4:	00048713          	mv	a4,s1
    800009f8:	00074683          	lbu	a3,0(a4)
    800009fc:	00178793          	addi	a5,a5,1
    80000a00:	00470713          	addi	a4,a4,4
    80000a04:	fed78fa3          	sb	a3,-1(a5)
    80000a08:	ff5798e3          	bne	a5,s5,800009f8 <_Z10aesEncryptPKcjS0_Pcj+0x1ac>
    80000a0c:	00478a93          	addi	s5,a5,4
    80000a10:	00148493          	addi	s1,s1,1
    80000a14:	fcca9ee3          	bne	s5,a2,800009f0 <_Z10aesEncryptPKcjS0_Pcj+0x1a4>
    80000a18:	015a0663          	beq	s4,s5,80000a24 <_Z10aesEncryptPKcjS0_Pcj+0x1d8>
    80000a1c:	00098693          	mv	a3,s3
    80000a20:	f01ff06f          	j	80000920 <_Z10aesEncryptPKcjS0_Pcj+0xd4>
    80000a24:	1c013903          	ld	s2,448(sp)
    80000a28:	1b813983          	ld	s3,440(sp)
    80000a2c:	1a813a83          	ld	s5,424(sp)
    80000a30:	1a013b03          	ld	s6,416(sp)
    80000a34:	19813b83          	ld	s7,408(sp)
    80000a38:	19013c03          	ld	s8,400(sp)
    80000a3c:	1d013403          	ld	s0,464(sp)
    80000a40:	1c813483          	ld	s1,456(sp)
    80000a44:	1b013a03          	ld	s4,432(sp)
    80000a48:	00000513          	li	a0,0
    80000a4c:	1d813083          	ld	ra,472(sp)
    80000a50:	1e010113          	addi	sp,sp,480
    80000a54:	00008067          	ret
    80000a58:	00810513          	addi	a0,sp,8
    80000a5c:	e71ff06f          	j	800008cc <_Z10aesEncryptPKcjS0_Pcj+0x80>
    80000a60:	fff00513          	li	a0,-1
    80000a64:	fe9ff06f          	j	80000a4c <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000a68:	1d013403          	ld	s0,464(sp)
    80000a6c:	1c813483          	ld	s1,456(sp)
    80000a70:	1b013a03          	ld	s4,432(sp)
    80000a74:	fff00513          	li	a0,-1
    80000a78:	fd5ff06f          	j	80000a4c <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000a7c:	1d013403          	ld	s0,464(sp)
    80000a80:	1b013a03          	ld	s4,432(sp)
    80000a84:	fff00513          	li	a0,-1
    80000a88:	fc5ff06f          	j	80000a4c <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000a8c:	1d013403          	ld	s0,464(sp)
    80000a90:	fff00513          	li	a0,-1
    80000a94:	fb9ff06f          	j	80000a4c <_Z10aesEncryptPKcjS0_Pcj+0x200>

0000000080000a98 <_Z10aesDecryptPKcjS0_Pcj>:
    80000a98:	e2010113          	addi	sp,sp,-480
    80000a9c:	1c113c23          	sd	ra,472(sp)
    80000aa0:	00013423          	sd	zero,8(sp)
    80000aa4:	00013823          	sd	zero,16(sp)
    80000aa8:	00013c23          	sd	zero,24(sp)
    80000aac:	02013023          	sd	zero,32(sp)
    80000ab0:	1e050e63          	beqz	a0,80000cac <_Z10aesDecryptPKcjS0_Pcj+0x214>
    80000ab4:	1c813823          	sd	s0,464(sp)
    80000ab8:	00060413          	mv	s0,a2
    80000abc:	20060e63          	beqz	a2,80000cd8 <_Z10aesDecryptPKcjS0_Pcj+0x240>
    80000ac0:	1b413823          	sd	s4,432(sp)
    80000ac4:	00068a13          	mv	s4,a3
    80000ac8:	20068063          	beqz	a3,80000cc8 <_Z10aesDecryptPKcjS0_Pcj+0x230>
    80000acc:	1c913423          	sd	s1,456(sp)
    80000ad0:	00070493          	mv	s1,a4
    80000ad4:	01000713          	li	a4,16
    80000ad8:	1cb76e63          	bltu	a4,a1,80000cb4 <_Z10aesDecryptPKcjS0_Pcj+0x21c>
    80000adc:	00f4f713          	andi	a4,s1,15
    80000ae0:	1c071a63          	bnez	a4,80000cb4 <_Z10aesDecryptPKcjS0_Pcj+0x21c>
    80000ae4:	1c058063          	beqz	a1,80000ca4 <_Z10aesDecryptPKcjS0_Pcj+0x20c>
    80000ae8:	02059693          	slli	a3,a1,0x20
    80000aec:	00050793          	mv	a5,a0
    80000af0:	0206d693          	srli	a3,a3,0x20
    80000af4:	00810513          	addi	a0,sp,8
    80000af8:	00078713          	mv	a4,a5
    80000afc:	00d506b3          	add	a3,a0,a3
    80000b00:	00050793          	mv	a5,a0
    80000b04:	00074603          	lbu	a2,0(a4)
    80000b08:	00178793          	addi	a5,a5,1
    80000b0c:	00170713          	addi	a4,a4,1
    80000b10:	fec78fa3          	sb	a2,-1(a5)
    80000b14:	fed798e3          	bne	a5,a3,80000b04 <_Z10aesDecryptPKcjS0_Pcj+0x6c>
    80000b18:	02810613          	addi	a2,sp,40
    80000b1c:	01000593          	li	a1,16
    80000b20:	e00ff0ef          	jal	80000120 <_Z12keyExpansionPKcjP6AesKey>
    80000b24:	16048263          	beqz	s1,80000c88 <_Z10aesDecryptPKcjS0_Pcj+0x1f0>
    80000b28:	fff4879b          	addiw	a5,s1,-1
    80000b2c:	0047d79b          	srliw	a5,a5,0x4
    80000b30:	00479793          	slli	a5,a5,0x4
    80000b34:	01478793          	addi	a5,a5,20
    80000b38:	1d213023          	sd	s2,448(sp)
    80000b3c:	1b513423          	sd	s5,424(sp)
    80000b40:	1b613023          	sd	s6,416(sp)
    80000b44:	004a0a93          	addi	s5,s4,4
    80000b48:	00440693          	addi	a3,s0,4
    80000b4c:	1b313c23          	sd	s3,440(sp)
    80000b50:	19713c23          	sd	s7,408(sp)
    80000b54:	19813823          	sd	s8,400(sp)
    80000b58:	00fa0a33          	add	s4,s4,a5
    80000b5c:	00001417          	auipc	s0,0x1
    80000b60:	92440413          	addi	s0,s0,-1756 # 80001480 <S>
    80000b64:	16810913          	addi	s2,sp,360
    80000b68:	02c10b13          	addi	s6,sp,44
    80000b6c:	01810493          	addi	s1,sp,24
    80000b70:	00048593          	mv	a1,s1
    80000b74:	01068993          	addi	s3,a3,16
    80000b78:	ffc68793          	addi	a5,a3,-4
    80000b7c:	00058713          	mv	a4,a1
    80000b80:	0007c603          	lbu	a2,0(a5)
    80000b84:	00178793          	addi	a5,a5,1
    80000b88:	00470713          	addi	a4,a4,4
    80000b8c:	fec70e23          	sb	a2,-4(a4)
    80000b90:	fed798e3          	bne	a5,a3,80000b80 <_Z10aesDecryptPKcjS0_Pcj+0xe8>
    80000b94:	00478693          	addi	a3,a5,4
    80000b98:	00158593          	addi	a1,a1,1
    80000b9c:	fd369ee3          	bne	a3,s3,80000b78 <_Z10aesDecryptPKcjS0_Pcj+0xe0>
    80000ba0:	0d810593          	addi	a1,sp,216
    80000ba4:	01810513          	addi	a0,sp,24
    80000ba8:	eccff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    80000bac:	0d810b93          	addi	s7,sp,216
    80000bb0:	01810513          	addi	a0,sp,24
    80000bb4:	ff0ff0ef          	jal	800003a4 <_Z12invShiftRowsPA4_c>
    80000bb8:	01c10c13          	addi	s8,sp,28
    80000bbc:	010b8b93          	addi	s7,s7,16
    80000bc0:	000c0693          	mv	a3,s8
    80000bc4:	ffc68793          	addi	a5,a3,-4
    80000bc8:	0007c703          	lbu	a4,0(a5)
    80000bcc:	00178793          	addi	a5,a5,1
    80000bd0:	00e40733          	add	a4,s0,a4
    80000bd4:	10074703          	lbu	a4,256(a4)
    80000bd8:	fee78fa3          	sb	a4,-1(a5)
    80000bdc:	fed796e3          	bne	a5,a3,80000bc8 <_Z10aesDecryptPKcjS0_Pcj+0x130>
    80000be0:	00478693          	addi	a3,a5,4
    80000be4:	ff6690e3          	bne	a3,s6,80000bc4 <_Z10aesDecryptPKcjS0_Pcj+0x12c>
    80000be8:	000b8593          	mv	a1,s7
    80000bec:	01810513          	addi	a0,sp,24
    80000bf0:	e84ff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    80000bf4:	01810513          	addi	a0,sp,24
    80000bf8:	a59ff0ef          	jal	80000650 <_Z13invMixColumnsPA4_c>
    80000bfc:	fb2b9ae3          	bne	s7,s2,80000bb0 <_Z10aesDecryptPKcjS0_Pcj+0x118>
    80000c00:	ffcc0793          	addi	a5,s8,-4
    80000c04:	0007c703          	lbu	a4,0(a5)
    80000c08:	00178793          	addi	a5,a5,1
    80000c0c:	00e40733          	add	a4,s0,a4
    80000c10:	10074703          	lbu	a4,256(a4)
    80000c14:	fee78fa3          	sb	a4,-1(a5)
    80000c18:	ff8796e3          	bne	a5,s8,80000c04 <_Z10aesDecryptPKcjS0_Pcj+0x16c>
    80000c1c:	00478c13          	addi	s8,a5,4
    80000c20:	ff6c10e3          	bne	s8,s6,80000c00 <_Z10aesDecryptPKcjS0_Pcj+0x168>
    80000c24:	01810513          	addi	a0,sp,24
    80000c28:	f7cff0ef          	jal	800003a4 <_Z12invShiftRowsPA4_c>
    80000c2c:	17810593          	addi	a1,sp,376
    80000c30:	01810513          	addi	a0,sp,24
    80000c34:	e40ff0ef          	jal	80000274 <_Z11addRoundKeyPA4_cPKj>
    80000c38:	010a8613          	addi	a2,s5,16
    80000c3c:	ffca8793          	addi	a5,s5,-4
    80000c40:	00048713          	mv	a4,s1
    80000c44:	00074683          	lbu	a3,0(a4)
    80000c48:	00178793          	addi	a5,a5,1
    80000c4c:	00470713          	addi	a4,a4,4
    80000c50:	fed78fa3          	sb	a3,-1(a5)
    80000c54:	ff5798e3          	bne	a5,s5,80000c44 <_Z10aesDecryptPKcjS0_Pcj+0x1ac>
    80000c58:	00478a93          	addi	s5,a5,4
    80000c5c:	00148493          	addi	s1,s1,1
    80000c60:	fcca9ee3          	bne	s5,a2,80000c3c <_Z10aesDecryptPKcjS0_Pcj+0x1a4>
    80000c64:	015a0663          	beq	s4,s5,80000c70 <_Z10aesDecryptPKcjS0_Pcj+0x1d8>
    80000c68:	00098693          	mv	a3,s3
    80000c6c:	f01ff06f          	j	80000b6c <_Z10aesDecryptPKcjS0_Pcj+0xd4>
    80000c70:	1c013903          	ld	s2,448(sp)
    80000c74:	1b813983          	ld	s3,440(sp)
    80000c78:	1a813a83          	ld	s5,424(sp)
    80000c7c:	1a013b03          	ld	s6,416(sp)
    80000c80:	19813b83          	ld	s7,408(sp)
    80000c84:	19013c03          	ld	s8,400(sp)
    80000c88:	1d013403          	ld	s0,464(sp)
    80000c8c:	1c813483          	ld	s1,456(sp)
    80000c90:	1b013a03          	ld	s4,432(sp)
    80000c94:	00000513          	li	a0,0
    80000c98:	1d813083          	ld	ra,472(sp)
    80000c9c:	1e010113          	addi	sp,sp,480
    80000ca0:	00008067          	ret
    80000ca4:	00810513          	addi	a0,sp,8
    80000ca8:	e71ff06f          	j	80000b18 <_Z10aesDecryptPKcjS0_Pcj+0x80>
    80000cac:	fff00513          	li	a0,-1
    80000cb0:	fe9ff06f          	j	80000c98 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000cb4:	1d013403          	ld	s0,464(sp)
    80000cb8:	1c813483          	ld	s1,456(sp)
    80000cbc:	1b013a03          	ld	s4,432(sp)
    80000cc0:	fff00513          	li	a0,-1
    80000cc4:	fd5ff06f          	j	80000c98 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000cc8:	1d013403          	ld	s0,464(sp)
    80000ccc:	1b013a03          	ld	s4,432(sp)
    80000cd0:	fff00513          	li	a0,-1
    80000cd4:	fc5ff06f          	j	80000c98 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000cd8:	1d013403          	ld	s0,464(sp)
    80000cdc:	fff00513          	li	a0,-1
    80000ce0:	fb9ff06f          	j	80000c98 <_Z10aesDecryptPKcjS0_Pcj+0x200>

0000000080000ce4 <_Z13heavy_rng_modji>:
    80000ce4:	a5a5a6b7          	lui	a3,0xa5a5a
    80000ce8:	5a568693          	addi	a3,a3,1445 # ffffffffa5a5a5a5 <_stack_top+0xffffffff25a50f25>
    80000cec:	00d547b3          	xor	a5,a0,a3
    80000cf0:	00156713          	ori	a4,a0,1
    80000cf4:	0cb05263          	blez	a1,80000db8 <_Z13heavy_rng_modji+0xd4>
    80000cf8:	00196eb7          	lui	t4,0x196
    80000cfc:	3c6efe37          	lui	t3,0x3c6ef
    80000d00:	015a5337          	lui	t1,0x15a5
    80000d04:	41c658b7          	lui	a7,0x41c65
    80000d08:	00003837          	lui	a6,0x3
    80000d0c:	00000613          	li	a2,0
    80000d10:	60de8e9b          	addiw	t4,t4,1549 # 19660d <STACK_SIZE+0x18e60d>
    80000d14:	35fe0e1b          	addiw	t3,t3,863 # 3c6ef35f <STACK_SIZE+0x3c6e735f>
    80000d18:	e353031b          	addiw	t1,t1,-459 # 15a4e35 <STACK_SIZE+0x159ce35>
    80000d1c:	e6d8889b          	addiw	a7,a7,-403 # 41c64e6d <STACK_SIZE+0x41c5ce6d>
    80000d20:	0398081b          	addiw	a6,a6,57 # 3039 <STACK_SIZE-0x4fc7>
    80000d24:	03d506bb          	mulw	a3,a0,t4
    80000d28:	00176f13          	ori	t5,a4,1
    80000d2c:	0017e513          	ori	a0,a5,1
    80000d30:	0016061b          	addiw	a2,a2,1
    80000d34:	01c686bb          	addw	a3,a3,t3
    80000d38:	03e6d6bb          	divuw	a3,a3,t5
    80000d3c:	02a6f6bb          	remuw	a3,a3,a0
    80000d40:	026787bb          	mulw	a5,a5,t1
    80000d44:	0016e513          	ori	a0,a3,1
    80000d48:	0017879b          	addiw	a5,a5,1
    80000d4c:	02a7d7bb          	divuw	a5,a5,a0
    80000d50:	03e7f7bb          	remuw	a5,a5,t5
    80000d54:	0317073b          	mulw	a4,a4,a7
    80000d58:	0017ef93          	ori	t6,a5,1
    80000d5c:	00f6c6b3          	xor	a3,a3,a5
    80000d60:	0036df1b          	srliw	t5,a3,0x3
    80000d64:	0107073b          	addw	a4,a4,a6
    80000d68:	03f7573b          	divuw	a4,a4,t6
    80000d6c:	02a7773b          	remuw	a4,a4,a0
    80000d70:	00e787bb          	addw	a5,a5,a4
    80000d74:	0017e513          	ori	a0,a5,1
    80000d78:	02a686bb          	mulw	a3,a3,a0
    80000d7c:	00ef4f33          	xor	t5,t5,a4
    80000d80:	000f0f1b          	sext.w	t5,t5
    80000d84:	001f6713          	ori	a4,t5,1
    80000d88:	02e6f6bb          	remuw	a3,a3,a4
    80000d8c:	02e7d7bb          	divuw	a5,a5,a4
    80000d90:	0016e713          	ori	a4,a3,1
    80000d94:	0006851b          	sext.w	a0,a3
    80000d98:	02e7ffbb          	remuw	t6,a5,a4
    80000d9c:	03e7073b          	mulw	a4,a4,t5
    80000da0:	001fef13          	ori	t5,t6,1
    80000da4:	000f879b          	sext.w	a5,t6
    80000da8:	03e7773b          	remuw	a4,a4,t5
    80000dac:	f6c59ce3          	bne	a1,a2,80000d24 <_Z13heavy_rng_modji+0x40>
    80000db0:	01f6c6b3          	xor	a3,a3,t6
    80000db4:	0006869b          	sext.w	a3,a3
    80000db8:	00d74533          	xor	a0,a4,a3
    80000dbc:	00008067          	ret

0000000080000dc0 <main>:
    80000dc0:	f2010113          	addi	sp,sp,-224
    80000dc4:	1357a7b7          	lui	a5,0x1357a
    80000dc8:	001965b7          	lui	a1,0x196
    80000dcc:	3c6ef637          	lui	a2,0x3c6ef
    80000dd0:	0c113c23          	sd	ra,216(sp)
    80000dd4:	0c813823          	sd	s0,208(sp)
    80000dd8:	0d213023          	sd	s2,192(sp)
    80000ddc:	03010713          	addi	a4,sp,48
    80000de0:	0b010513          	addi	a0,sp,176
    80000de4:	bdf78793          	addi	a5,a5,-1057 # 13579bdf <STACK_SIZE+0x13571bdf>
    80000de8:	60d5859b          	addiw	a1,a1,1549 # 19660d <STACK_SIZE+0x18e60d>
    80000dec:	35f6061b          	addiw	a2,a2,863 # 3c6ef35f <STACK_SIZE+0x3c6e735f>
    80000df0:	02b787bb          	mulw	a5,a5,a1
    80000df4:	00170713          	addi	a4,a4,1
    80000df8:	00c787bb          	addw	a5,a5,a2
    80000dfc:	0187d69b          	srliw	a3,a5,0x18
    80000e00:	fed70fa3          	sb	a3,-1(a4)
    80000e04:	fee516e3          	bne	a0,a4,80000df0 <main+0x30>
    80000e08:	406006b7          	lui	a3,0x40600
    80000e0c:	04100713          	li	a4,65
    80000e10:	00000797          	auipc	a5,0x0
    80000e14:	3b078793          	addi	a5,a5,944 # 800011c0 <main+0x400>
    80000e18:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000e1c:	00178793          	addi	a5,a5,1
    80000e20:	00e68023          	sb	a4,0(a3)
    80000e24:	0007c703          	lbu	a4,0(a5)
    80000e28:	fe071ae3          	bnez	a4,80000e1c <main+0x5c>
    80000e2c:	406006b7          	lui	a3,0x40600
    80000e30:	00013423          	sd	zero,8(sp)
    80000e34:	00013823          	sd	zero,16(sp)
    80000e38:	00013c23          	sd	zero,24(sp)
    80000e3c:	02013023          	sd	zero,32(sp)
    80000e40:	05200713          	li	a4,82
    80000e44:	00000797          	auipc	a5,0x0
    80000e48:	3a478793          	addi	a5,a5,932 # 800011e8 <main+0x428>
    80000e4c:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000e50:	00178793          	addi	a5,a5,1
    80000e54:	00e68023          	sb	a4,0(a3)
    80000e58:	0007c703          	lbu	a4,0(a5)
    80000e5c:	fe071ae3          	bnez	a4,80000e50 <main+0x90>
    80000e60:	406006b7          	lui	a3,0x40600
    80000e64:	05b00713          	li	a4,91
    80000e68:	00000797          	auipc	a5,0x0
    80000e6c:	3a878793          	addi	a5,a5,936 # 80001210 <main+0x450>
    80000e70:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000e74:	00178793          	addi	a5,a5,1
    80000e78:	00e68023          	sb	a4,0(a3)
    80000e7c:	0007c703          	lbu	a4,0(a5)
    80000e80:	fe071ae3          	bnez	a4,80000e74 <main+0xb4>
    80000e84:	01000713          	li	a4,16
    80000e88:	00810693          	addi	a3,sp,8
    80000e8c:	00000617          	auipc	a2,0x0
    80000e90:	5a460613          	addi	a2,a2,1444 # 80001430 <_ZZL20runCorrectnessChecksvE2pt>
    80000e94:	01000593          	li	a1,16
    80000e98:	00000517          	auipc	a0,0x0
    80000e9c:	5a850513          	addi	a0,a0,1448 # 80001440 <_ZZL20runCorrectnessChecksvE3key>
    80000ea0:	9adff0ef          	jal	8000084c <_Z10aesEncryptPKcjS0_Pcj>
    80000ea4:	2e051a63          	bnez	a0,80001198 <main+0x3d8>
    80000ea8:	00810793          	addi	a5,sp,8
    80000eac:	00000717          	auipc	a4,0x0
    80000eb0:	5a470713          	addi	a4,a4,1444 # 80001450 <_ZZL20runCorrectnessChecksvE10expectedCt>
    80000eb4:	01810913          	addi	s2,sp,24
    80000eb8:	0080006f          	j	80000ec0 <main+0x100>
    80000ebc:	02f90e63          	beq	s2,a5,80000ef8 <main+0x138>
    80000ec0:	0007c603          	lbu	a2,0(a5)
    80000ec4:	00074683          	lbu	a3,0(a4)
    80000ec8:	00178793          	addi	a5,a5,1
    80000ecc:	00170713          	addi	a4,a4,1
    80000ed0:	fed606e3          	beq	a2,a3,80000ebc <main+0xfc>
    80000ed4:	00000797          	auipc	a5,0x0
    80000ed8:	38c78793          	addi	a5,a5,908 # 80001260 <main+0x4a0>
    80000edc:	0007c683          	lbu	a3,0(a5)
    80000ee0:	40600737          	lui	a4,0x40600
    80000ee4:	00470713          	addi	a4,a4,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000ee8:	28068263          	beqz	a3,8000116c <main+0x3ac>
    80000eec:	00178793          	addi	a5,a5,1
    80000ef0:	00d70023          	sb	a3,0(a4)
    80000ef4:	fe9ff06f          	j	80000edc <main+0x11c>
    80000ef8:	406006b7          	lui	a3,0x40600
    80000efc:	0c913423          	sd	s1,200(sp)
    80000f00:	05b00713          	li	a4,91
    80000f04:	00000797          	auipc	a5,0x0
    80000f08:	38478793          	addi	a5,a5,900 # 80001288 <main+0x4c8>
    80000f0c:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000f10:	00178793          	addi	a5,a5,1
    80000f14:	00e68023          	sb	a4,0(a3)
    80000f18:	0007c703          	lbu	a4,0(a5)
    80000f1c:	fe071ae3          	bnez	a4,80000f10 <main+0x150>
    80000f20:	406006b7          	lui	a3,0x40600
    80000f24:	05b00713          	li	a4,91
    80000f28:	00000797          	auipc	a5,0x0
    80000f2c:	39078793          	addi	a5,a5,912 # 800012b8 <main+0x4f8>
    80000f30:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000f34:	00178793          	addi	a5,a5,1
    80000f38:	00e68023          	sb	a4,0(a3)
    80000f3c:	0007c703          	lbu	a4,0(a5)
    80000f40:	fe071ae3          	bnez	a4,80000f34 <main+0x174>
    80000f44:	01000713          	li	a4,16
    80000f48:	00090693          	mv	a3,s2
    80000f4c:	00810613          	addi	a2,sp,8
    80000f50:	01000593          	li	a1,16
    80000f54:	00000517          	auipc	a0,0x0
    80000f58:	4ec50513          	addi	a0,a0,1260 # 80001440 <_ZZL20runCorrectnessChecksvE3key>
    80000f5c:	b3dff0ef          	jal	80000a98 <_Z10aesDecryptPKcjS0_Pcj>
    80000f60:	00050493          	mv	s1,a0
    80000f64:	1e051063          	bnez	a0,80001144 <main+0x384>
    80000f68:	00090793          	mv	a5,s2
    80000f6c:	00000717          	auipc	a4,0x0
    80000f70:	4c470713          	addi	a4,a4,1220 # 80001430 <_ZZL20runCorrectnessChecksvE2pt>
    80000f74:	02810593          	addi	a1,sp,40
    80000f78:	0080006f          	j	80000f80 <main+0x1c0>
    80000f7c:	02f58e63          	beq	a1,a5,80000fb8 <main+0x1f8>
    80000f80:	0007c603          	lbu	a2,0(a5)
    80000f84:	00074683          	lbu	a3,0(a4)
    80000f88:	00178793          	addi	a5,a5,1
    80000f8c:	00170713          	addi	a4,a4,1
    80000f90:	fed606e3          	beq	a2,a3,80000f7c <main+0x1bc>
    80000f94:	00000797          	auipc	a5,0x0
    80000f98:	37478793          	addi	a5,a5,884 # 80001308 <main+0x548>
    80000f9c:	0007c683          	lbu	a3,0(a5)
    80000fa0:	40600737          	lui	a4,0x40600
    80000fa4:	00470713          	addi	a4,a4,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000fa8:	1c068063          	beqz	a3,80001168 <main+0x3a8>
    80000fac:	00178793          	addi	a5,a5,1
    80000fb0:	00d70023          	sb	a3,0(a4)
    80000fb4:	fe9ff06f          	j	80000f9c <main+0x1dc>
    80000fb8:	406006b7          	lui	a3,0x40600
    80000fbc:	0b313c23          	sd	s3,184(sp)
    80000fc0:	0b413823          	sd	s4,176(sp)
    80000fc4:	05b00713          	li	a4,91
    80000fc8:	00000797          	auipc	a5,0x0
    80000fcc:	36878793          	addi	a5,a5,872 # 80001330 <main+0x570>
    80000fd0:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000fd4:	00178793          	addi	a5,a5,1
    80000fd8:	00e68023          	sb	a4,0(a3)
    80000fdc:	0007c703          	lbu	a4,0(a5)
    80000fe0:	fe071ae3          	bnez	a4,80000fd4 <main+0x214>
    80000fe4:	406006b7          	lui	a3,0x40600
    80000fe8:	05b00713          	li	a4,91
    80000fec:	00000797          	auipc	a5,0x0
    80000ff0:	37478793          	addi	a5,a5,884 # 80001360 <main+0x5a0>
    80000ff4:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80000ff8:	00178793          	addi	a5,a5,1
    80000ffc:	00e68023          	sb	a4,0(a3)
    80001000:	0007c703          	lbu	a4,0(a5)
    80001004:	fe071ae3          	bnez	a4,80000ff8 <main+0x238>
    80001008:	200039b7          	lui	s3,0x20003
    8000100c:	0009ba03          	ld	s4,0(s3) # 20003000 <STACK_SIZE+0x1fffb000>
    80001010:	0009b503          	ld	a0,0(s3)
    80001014:	3e800593          	li	a1,1000
    80001018:	0005051b          	sext.w	a0,a0
    8000101c:	cc9ff0ef          	jal	80000ce4 <_Z13heavy_rng_modji>
    80001020:	0009b983          	ld	s3,0(s3)
    80001024:	406006b7          	lui	a3,0x40600
    80001028:	0005041b          	sext.w	s0,a0
    8000102c:	05b00713          	li	a4,91
    80001030:	00000797          	auipc	a5,0x0
    80001034:	38878793          	addi	a5,a5,904 # 800013b8 <main+0x5f8>
    80001038:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    8000103c:	00178793          	addi	a5,a5,1
    80001040:	00e68023          	sb	a4,0(a3)
    80001044:	0007c703          	lbu	a4,0(a5)
    80001048:	fe071ae3          	bnez	a4,8000103c <main+0x27c>
    8000104c:	00045863          	bgez	s0,8000105c <main+0x29c>
    80001050:	02d00793          	li	a5,45
    80001054:	00f68023          	sb	a5,0(a3)
    80001058:	4080043b          	negw	s0,s0
    8000105c:	00090613          	mv	a2,s2
    80001060:	00a00693          	li	a3,10
    80001064:	02d4673b          	remw	a4,s0,a3
    80001068:	00160613          	addi	a2,a2,1
    8000106c:	00048793          	mv	a5,s1
    80001070:	0014849b          	addiw	s1,s1,1
    80001074:	02d4443b          	divw	s0,s0,a3
    80001078:	0307071b          	addiw	a4,a4,48
    8000107c:	fee60fa3          	sb	a4,-1(a2)
    80001080:	fe0412e3          	bnez	s0,80001064 <main+0x2a4>
    80001084:	406006b7          	lui	a3,0x40600
    80001088:	00f907b3          	add	a5,s2,a5
    8000108c:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001090:	fff90913          	addi	s2,s2,-1
    80001094:	0007c703          	lbu	a4,0(a5)
    80001098:	fff78793          	addi	a5,a5,-1
    8000109c:	00e68023          	sb	a4,0(a3)
    800010a0:	fef91ae3          	bne	s2,a5,80001094 <main+0x2d4>
    800010a4:	40600937          	lui	s2,0x40600
    800010a8:	02c00713          	li	a4,44
    800010ac:	00000797          	auipc	a5,0x0
    800010b0:	32c78793          	addi	a5,a5,812 # 800013d8 <main+0x618>
    800010b4:	00490913          	addi	s2,s2,4 # 40600004 <STACK_SIZE+0x405f8004>
    800010b8:	00178793          	addi	a5,a5,1
    800010bc:	00e90023          	sb	a4,0(s2)
    800010c0:	0007c703          	lbu	a4,0(a5)
    800010c4:	fe071ae3          	bnez	a4,800010b8 <main+0x2f8>
    800010c8:	414989b3          	sub	s3,s3,s4
    800010cc:	00098513          	mv	a0,s3
    800010d0:	f7dfe0ef          	jal	8000004c <_Z5put_iIyEvT_>
    800010d4:	00a00793          	li	a5,10
    800010d8:	406004b7          	lui	s1,0x40600
    800010dc:	00f90023          	sb	a5,0(s2)
    800010e0:	05b00713          	li	a4,91
    800010e4:	00000797          	auipc	a5,0x0
    800010e8:	30478793          	addi	a5,a5,772 # 800013e8 <main+0x628>
    800010ec:	00448493          	addi	s1,s1,4 # 40600004 <STACK_SIZE+0x405f8004>
    800010f0:	00178793          	addi	a5,a5,1
    800010f4:	00e48023          	sb	a4,0(s1)
    800010f8:	0007c703          	lbu	a4,0(a5)
    800010fc:	fe071ae3          	bnez	a4,800010f0 <main+0x330>
    80001100:	3e800793          	li	a5,1000
    80001104:	02f9d9b3          	divu	s3,s3,a5
    80001108:	000f4537          	lui	a0,0xf4
    8000110c:	24050513          	addi	a0,a0,576 # f4240 <STACK_SIZE+0xec240>
    80001110:	03355533          	divu	a0,a0,s3
    80001114:	f39fe0ef          	jal	8000004c <_Z5put_iIyEvT_>
    80001118:	00a00793          	li	a5,10
    8000111c:	00f48023          	sb	a5,0(s1)
    80001120:	0c813483          	ld	s1,200(sp)
    80001124:	0b813983          	ld	s3,184(sp)
    80001128:	0b013a03          	ld	s4,176(sp)
    8000112c:	0d813083          	ld	ra,216(sp)
    80001130:	00040513          	mv	a0,s0
    80001134:	0d013403          	ld	s0,208(sp)
    80001138:	0c013903          	ld	s2,192(sp)
    8000113c:	0e010113          	addi	sp,sp,224
    80001140:	00008067          	ret
    80001144:	406006b7          	lui	a3,0x40600
    80001148:	00000797          	auipc	a5,0x0
    8000114c:	19878793          	addi	a5,a5,408 # 800012e0 <main+0x520>
    80001150:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001154:	0080006f          	j	8000115c <main+0x39c>
    80001158:	00e68023          	sb	a4,0(a3)
    8000115c:	0007c703          	lbu	a4,0(a5)
    80001160:	00178793          	addi	a5,a5,1
    80001164:	fe071ae3          	bnez	a4,80001158 <main+0x398>
    80001168:	0c813483          	ld	s1,200(sp)
    8000116c:	406006b7          	lui	a3,0x40600
    80001170:	00000797          	auipc	a5,0x0
    80001174:	21878793          	addi	a5,a5,536 # 80001388 <main+0x5c8>
    80001178:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    8000117c:	0080006f          	j	80001184 <main+0x3c4>
    80001180:	00e68023          	sb	a4,0(a3)
    80001184:	0007c703          	lbu	a4,0(a5)
    80001188:	00178793          	addi	a5,a5,1
    8000118c:	fe071ae3          	bnez	a4,80001180 <main+0x3c0>
    80001190:	fff00413          	li	s0,-1
    80001194:	f99ff06f          	j	8000112c <main+0x36c>
    80001198:	406006b7          	lui	a3,0x40600
    8000119c:	00000797          	auipc	a5,0x0
    800011a0:	09c78793          	addi	a5,a5,156 # 80001238 <main+0x478>
    800011a4:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    800011a8:	0080006f          	j	800011b0 <main+0x3f0>
    800011ac:	00e68023          	sb	a4,0(a3)
    800011b0:	0007c703          	lbu	a4,0(a5)
    800011b4:	00178793          	addi	a5,a5,1
    800011b8:	fe071ae3          	bnez	a4,800011ac <main+0x3ec>
    800011bc:	fb1ff06f          	j	8000116c <main+0x3ac>
