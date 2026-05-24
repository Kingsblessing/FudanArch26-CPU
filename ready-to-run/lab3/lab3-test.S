
lab3-test.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_start>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	a0010113          	addi	sp,sp,-1536 # 80009a00 <_stack_top>
    80000008:	00002297          	auipc	t0,0x2
    8000000c:	9f828293          	addi	t0,t0,-1544 # 80001a00 <__bss_end>
    80000010:	00002317          	auipc	t1,0x2
    80000014:	9f030313          	addi	t1,t1,-1552 # 80001a00 <__bss_end>
    80000018:	00628863          	beq	t0,t1,80000028 <_start+0x28>
    8000001c:	0002b023          	sd	zero,0(t0)
    80000020:	00828293          	addi	t0,t0,8
    80000024:	fe62ece3          	bltu	t0,t1,8000001c <_start+0x1c>
    80000028:	795000ef          	jal	80000fbc <main>
    8000002c:	00000513          	li	a0,0
    80000030:	0005006b          	.insn	4, 0x0005006b
    80000034:	3f8002b7          	lui	t0,0x3f800
    80000038:	f00280d3          	.insn	4, 0xf00280d3
    8000003c:	40400337          	lui	t1,0x40400
    80000040:	f0030153          	.insn	4, 0xf0030153
    80000044:	1820f053          	.insn	4, 0x1820f053
    80000048:	fedff06f          	j	80000034 <_start+0x34>

000000008000004c <_Z5put_iIyEvT_>:
    8000004c:	fa010113          	addi	sp,sp,-96
    80000050:	04813823          	sd	s0,80(sp)
    80000054:	05213023          	sd	s2,64(sp)
    80000058:	03313c23          	sd	s3,56(sp)
    8000005c:	03513423          	sd	s5,40(sp)
    80000060:	04113c23          	sd	ra,88(sp)
    80000064:	04913423          	sd	s1,72(sp)
    80000068:	03413823          	sd	s4,48(sp)
    8000006c:	00050413          	mv	s0,a0
    80000070:	00810993          	addi	s3,sp,8
    80000074:	00000913          	li	s2,0
    80000078:	00900a93          	li	s5,9
    8000007c:	00a00593          	li	a1,10
    80000080:	00040513          	mv	a0,s0
    80000084:	440010ef          	jal	800014c4 <__umoddi3>
    80000088:	0305079b          	addiw	a5,a0,48
    8000008c:	00f98023          	sb	a5,0(s3)
    80000090:	00040513          	mv	a0,s0
    80000094:	00a00593          	li	a1,10
    80000098:	00040a13          	mv	s4,s0
    8000009c:	3e0010ef          	jal	8000147c <__hidden___udivdi3>
    800000a0:	00090493          	mv	s1,s2
    800000a4:	00050413          	mv	s0,a0
    800000a8:	0019091b          	addiw	s2,s2,1
    800000ac:	00198993          	addi	s3,s3,1
    800000b0:	fd4ae6e3          	bltu	s5,s4,8000007c <_Z5put_iIyEvT_+0x30>
    800000b4:	40600637          	lui	a2,0x40600
    800000b8:	00810793          	addi	a5,sp,8
    800000bc:	009787b3          	add	a5,a5,s1
    800000c0:	00710693          	addi	a3,sp,7
    800000c4:	00460613          	addi	a2,a2,4 # 40600004 <STACK_SIZE+0x405f8004>
    800000c8:	0007c703          	lbu	a4,0(a5)
    800000cc:	fff78793          	addi	a5,a5,-1
    800000d0:	00e60023          	sb	a4,0(a2)
    800000d4:	fed79ae3          	bne	a5,a3,800000c8 <_Z5put_iIyEvT_+0x7c>
    800000d8:	05813083          	ld	ra,88(sp)
    800000dc:	05013403          	ld	s0,80(sp)
    800000e0:	04813483          	ld	s1,72(sp)
    800000e4:	04013903          	ld	s2,64(sp)
    800000e8:	03813983          	ld	s3,56(sp)
    800000ec:	03013a03          	ld	s4,48(sp)
    800000f0:	02813a83          	ld	s5,40(sp)
    800000f4:	06010113          	addi	sp,sp,96
    800000f8:	00008067          	ret

00000000800000fc <_Z14loadStateArrayPA4_cPKc>:
    800000fc:	00458593          	addi	a1,a1,4
    80000100:	00450613          	addi	a2,a0,4
    80000104:	ffc58793          	addi	a5,a1,-4
    80000108:	00050713          	mv	a4,a0
    8000010c:	0007c683          	lbu	a3,0(a5)
    80000110:	00178793          	addi	a5,a5,1
    80000114:	00470713          	addi	a4,a4,4
    80000118:	fed70e23          	sb	a3,-4(a4)
    8000011c:	feb798e3          	bne	a5,a1,8000010c <_Z14loadStateArrayPA4_cPKc+0x10>
    80000120:	00150513          	addi	a0,a0,1
    80000124:	00478593          	addi	a1,a5,4
    80000128:	fcc51ee3          	bne	a0,a2,80000104 <_Z14loadStateArrayPA4_cPKc+0x8>
    8000012c:	00000513          	li	a0,0
    80000130:	00008067          	ret

0000000080000134 <_Z15storeStateArrayPA4_cPc>:
    80000134:	00458593          	addi	a1,a1,4
    80000138:	00450613          	addi	a2,a0,4
    8000013c:	ffc58793          	addi	a5,a1,-4
    80000140:	00050713          	mv	a4,a0
    80000144:	00074683          	lbu	a3,0(a4)
    80000148:	00178793          	addi	a5,a5,1
    8000014c:	00470713          	addi	a4,a4,4
    80000150:	fed78fa3          	sb	a3,-1(a5)
    80000154:	feb798e3          	bne	a5,a1,80000144 <_Z15storeStateArrayPA4_cPc+0x10>
    80000158:	00150513          	addi	a0,a0,1
    8000015c:	00478593          	addi	a1,a5,4
    80000160:	fcc51ee3          	bne	a0,a2,8000013c <_Z15storeStateArrayPA4_cPc+0x8>
    80000164:	00000513          	li	a0,0
    80000168:	00008067          	ret

000000008000016c <_Z12keyExpansionPKcjP6AesKey>:
    8000016c:	14050663          	beqz	a0,800002b8 <_Z12keyExpansionPKcjP6AesKey+0x14c>
    80000170:	14060463          	beqz	a2,800002b8 <_Z12keyExpansionPKcjP6AesKey+0x14c>
    80000174:	01000793          	li	a5,16
    80000178:	14f59063          	bne	a1,a5,800002b8 <_Z12keyExpansionPKcjP6AesKey+0x14c>
    8000017c:	01050893          	addi	a7,a0,16
    80000180:	00060593          	mv	a1,a2
    80000184:	00054783          	lbu	a5,0(a0)
    80000188:	00154683          	lbu	a3,1(a0)
    8000018c:	00354803          	lbu	a6,3(a0)
    80000190:	00254703          	lbu	a4,2(a0)
    80000194:	0187979b          	slliw	a5,a5,0x18
    80000198:	0106969b          	slliw	a3,a3,0x10
    8000019c:	00d7e7b3          	or	a5,a5,a3
    800001a0:	0107e7b3          	or	a5,a5,a6
    800001a4:	0087171b          	slliw	a4,a4,0x8
    800001a8:	00e7e7b3          	or	a5,a5,a4
    800001ac:	00f5a023          	sw	a5,0(a1)
    800001b0:	00450513          	addi	a0,a0,4
    800001b4:	00458593          	addi	a1,a1,4
    800001b8:	fca896e3          	bne	a7,a0,80000184 <_Z12keyExpansionPKcjP6AesKey+0x18>
    800001bc:	00862583          	lw	a1,8(a2)
    800001c0:	00462e83          	lw	t4,4(a2)
    800001c4:	00c62703          	lw	a4,12(a2)
    800001c8:	00062e03          	lw	t3,0(a2)
    800001cc:	01060693          	addi	a3,a2,16
    800001d0:	00001317          	auipc	t1,0x1
    800001d4:	5b830313          	addi	t1,t1,1464 # 80001788 <_ZL4rcon>
    800001d8:	00001f97          	auipc	t6,0x1
    800001dc:	5d8f8f93          	addi	t6,t6,1496 # 800017b0 <_ZZL20runCorrectnessChecksvE2pt>
    800001e0:	00001897          	auipc	a7,0x1
    800001e4:	62088893          	addi	a7,a7,1568 # 80001800 <S>
    800001e8:	0ff77793          	zext.b	a5,a4
    800001ec:	0107581b          	srliw	a6,a4,0x10
    800001f0:	01875f1b          	srliw	t5,a4,0x18
    800001f4:	0087551b          	srliw	a0,a4,0x8
    800001f8:	00f887b3          	add	a5,a7,a5
    800001fc:	0ff87813          	zext.b	a6,a6
    80000200:	0007c783          	lbu	a5,0(a5)
    80000204:	01e88f33          	add	t5,a7,t5
    80000208:	01088833          	add	a6,a7,a6
    8000020c:	0ff57513          	zext.b	a0,a0
    80000210:	000f4283          	lbu	t0,0(t5)
    80000214:	00084803          	lbu	a6,0(a6)
    80000218:	00a88533          	add	a0,a7,a0
    8000021c:	00054503          	lbu	a0,0(a0)
    80000220:	0087979b          	slliw	a5,a5,0x8
    80000224:	00032f03          	lw	t5,0(t1)
    80000228:	0057c7b3          	xor	a5,a5,t0
    8000022c:	0188181b          	slliw	a6,a6,0x18
    80000230:	0107c7b3          	xor	a5,a5,a6
    80000234:	0105151b          	slliw	a0,a0,0x10
    80000238:	00a7c7b3          	xor	a5,a5,a0
    8000023c:	01e7c7b3          	xor	a5,a5,t5
    80000240:	01c7c7b3          	xor	a5,a5,t3
    80000244:	00078e1b          	sext.w	t3,a5
    80000248:	01de4eb3          	xor	t4,t3,t4
    8000024c:	00bec5b3          	xor	a1,t4,a1
    80000250:	0005859b          	sext.w	a1,a1
    80000254:	00b74733          	xor	a4,a4,a1
    80000258:	01c6a023          	sw	t3,0(a3)
    8000025c:	01d6a223          	sw	t4,4(a3)
    80000260:	00b6a423          	sw	a1,8(a3)
    80000264:	00e6a623          	sw	a4,12(a3)
    80000268:	00430313          	addi	t1,t1,4
    8000026c:	01068693          	addi	a3,a3,16
    80000270:	f66f9ce3          	bne	t6,t1,800001e8 <_Z12keyExpansionPKcjP6AesKey+0x7c>
    80000274:	00161893          	slli	a7,a2,0x1
    80000278:	0a060713          	addi	a4,a2,160
    8000027c:	15088893          	addi	a7,a7,336
    80000280:	ff060613          	addi	a2,a2,-16
    80000284:	01000813          	li	a6,16
    80000288:	40e88533          	sub	a0,a7,a4
    8000028c:	00000793          	li	a5,0
    80000290:	00f706b3          	add	a3,a4,a5
    80000294:	0006a583          	lw	a1,0(a3)
    80000298:	00f506b3          	add	a3,a0,a5
    8000029c:	00478793          	addi	a5,a5,4
    800002a0:	00b6a023          	sw	a1,0(a3)
    800002a4:	ff0796e3          	bne	a5,a6,80000290 <_Z12keyExpansionPKcjP6AesKey+0x124>
    800002a8:	ff070713          	addi	a4,a4,-16
    800002ac:	fcc71ee3          	bne	a4,a2,80000288 <_Z12keyExpansionPKcjP6AesKey+0x11c>
    800002b0:	00000513          	li	a0,0
    800002b4:	00008067          	ret
    800002b8:	fff00513          	li	a0,-1
    800002bc:	00008067          	ret

00000000800002c0 <_Z11addRoundKeyPA4_cPKj>:
    800002c0:	01800313          	li	t1,24
    800002c4:	01058893          	addi	a7,a1,16
    800002c8:	ff800e13          	li	t3,-8
    800002cc:	0003081b          	sext.w	a6,t1
    800002d0:	00058713          	mv	a4,a1
    800002d4:	00050793          	mv	a5,a0
    800002d8:	00072603          	lw	a2,0(a4)
    800002dc:	0007c683          	lbu	a3,0(a5)
    800002e0:	00470713          	addi	a4,a4,4
    800002e4:	0106563b          	srlw	a2,a2,a6
    800002e8:	00c6c6b3          	xor	a3,a3,a2
    800002ec:	00d78023          	sb	a3,0(a5)
    800002f0:	00178793          	addi	a5,a5,1
    800002f4:	fee892e3          	bne	a7,a4,800002d8 <_Z11addRoundKeyPA4_cPKj+0x18>
    800002f8:	ff83031b          	addiw	t1,t1,-8
    800002fc:	00450513          	addi	a0,a0,4
    80000300:	fdc316e3          	bne	t1,t3,800002cc <_Z11addRoundKeyPA4_cPKj+0xc>
    80000304:	00000513          	li	a0,0
    80000308:	00008067          	ret

000000008000030c <_Z8subBytesPA4_c>:
    8000030c:	00450693          	addi	a3,a0,4
    80000310:	01450593          	addi	a1,a0,20
    80000314:	00001617          	auipc	a2,0x1
    80000318:	4ec60613          	addi	a2,a2,1260 # 80001800 <S>
    8000031c:	ffc68793          	addi	a5,a3,-4
    80000320:	0007c703          	lbu	a4,0(a5)
    80000324:	00178793          	addi	a5,a5,1
    80000328:	00e60733          	add	a4,a2,a4
    8000032c:	00074703          	lbu	a4,0(a4)
    80000330:	fee78fa3          	sb	a4,-1(a5)
    80000334:	fed796e3          	bne	a5,a3,80000320 <_Z8subBytesPA4_c+0x14>
    80000338:	00478693          	addi	a3,a5,4
    8000033c:	feb690e3          	bne	a3,a1,8000031c <_Z8subBytesPA4_c+0x10>
    80000340:	00000513          	li	a0,0
    80000344:	00008067          	ret

0000000080000348 <_Z11invSubBytesPA4_c>:
    80000348:	00450693          	addi	a3,a0,4
    8000034c:	01450593          	addi	a1,a0,20
    80000350:	00001617          	auipc	a2,0x1
    80000354:	4b060613          	addi	a2,a2,1200 # 80001800 <S>
    80000358:	ffc68793          	addi	a5,a3,-4
    8000035c:	0007c703          	lbu	a4,0(a5)
    80000360:	00178793          	addi	a5,a5,1
    80000364:	00e60733          	add	a4,a2,a4
    80000368:	10074703          	lbu	a4,256(a4)
    8000036c:	fee78fa3          	sb	a4,-1(a5)
    80000370:	fed796e3          	bne	a5,a3,8000035c <_Z11invSubBytesPA4_c+0x14>
    80000374:	00478693          	addi	a3,a5,4
    80000378:	feb690e3          	bne	a3,a1,80000358 <_Z11invSubBytesPA4_c+0x10>
    8000037c:	00000513          	li	a0,0
    80000380:	00008067          	ret

0000000080000384 <_Z9shiftRowsPA4_c>:
    80000384:	02000693          	li	a3,32
    80000388:	00054783          	lbu	a5,0(a0)
    8000038c:	00154603          	lbu	a2,1(a0)
    80000390:	00354583          	lbu	a1,3(a0)
    80000394:	00254703          	lbu	a4,2(a0)
    80000398:	0106161b          	slliw	a2,a2,0x10
    8000039c:	0187979b          	slliw	a5,a5,0x18
    800003a0:	00c7e7b3          	or	a5,a5,a2
    800003a4:	00b7e7b3          	or	a5,a5,a1
    800003a8:	0087171b          	slliw	a4,a4,0x8
    800003ac:	40d0063b          	negw	a2,a3
    800003b0:	00e7e7b3          	or	a5,a5,a4
    800003b4:	00d7d73b          	srlw	a4,a5,a3
    800003b8:	00c797bb          	sllw	a5,a5,a2
    800003bc:	00f767b3          	or	a5,a4,a5
    800003c0:	0187d59b          	srliw	a1,a5,0x18
    800003c4:	0107d61b          	srliw	a2,a5,0x10
    800003c8:	0087d71b          	srliw	a4,a5,0x8
    800003cc:	00b50023          	sb	a1,0(a0)
    800003d0:	00c500a3          	sb	a2,1(a0)
    800003d4:	00e50123          	sb	a4,2(a0)
    800003d8:	00f501a3          	sb	a5,3(a0)
    800003dc:	ff86869b          	addiw	a3,a3,-8
    800003e0:	00450513          	addi	a0,a0,4
    800003e4:	fa0692e3          	bnez	a3,80000388 <_Z9shiftRowsPA4_c+0x4>
    800003e8:	00000513          	li	a0,0
    800003ec:	00008067          	ret

00000000800003f0 <_Z12invShiftRowsPA4_c>:
    800003f0:	02000693          	li	a3,32
    800003f4:	00054783          	lbu	a5,0(a0)
    800003f8:	00154603          	lbu	a2,1(a0)
    800003fc:	00354583          	lbu	a1,3(a0)
    80000400:	00254703          	lbu	a4,2(a0)
    80000404:	0106161b          	slliw	a2,a2,0x10
    80000408:	0187979b          	slliw	a5,a5,0x18
    8000040c:	00c7e7b3          	or	a5,a5,a2
    80000410:	00b7e7b3          	or	a5,a5,a1
    80000414:	0087171b          	slliw	a4,a4,0x8
    80000418:	40d0063b          	negw	a2,a3
    8000041c:	00e7e7b3          	or	a5,a5,a4
    80000420:	00d7973b          	sllw	a4,a5,a3
    80000424:	00c7d7bb          	srlw	a5,a5,a2
    80000428:	00f767b3          	or	a5,a4,a5
    8000042c:	0187d59b          	srliw	a1,a5,0x18
    80000430:	0107d61b          	srliw	a2,a5,0x10
    80000434:	0087d71b          	srliw	a4,a5,0x8
    80000438:	00b50023          	sb	a1,0(a0)
    8000043c:	00c500a3          	sb	a2,1(a0)
    80000440:	00e50123          	sb	a4,2(a0)
    80000444:	00f501a3          	sb	a5,3(a0)
    80000448:	ff86869b          	addiw	a3,a3,-8
    8000044c:	00450513          	addi	a0,a0,4
    80000450:	fa0692e3          	bnez	a3,800003f4 <_Z12invShiftRowsPA4_c+0x4>
    80000454:	00000513          	li	a0,0
    80000458:	00008067          	ret

000000008000045c <_Z4GMulcc>:
    8000045c:	00050713          	mv	a4,a0
    80000460:	00800693          	li	a3,8
    80000464:	00000513          	li	a0,0
    80000468:	00177793          	andi	a5,a4,1
    8000046c:	0185961b          	slliw	a2,a1,0x18
    80000470:	40f007bb          	negw	a5,a5
    80000474:	00f5f7b3          	and	a5,a1,a5
    80000478:	0015981b          	slliw	a6,a1,0x1
    8000047c:	4186561b          	sraiw	a2,a2,0x18
    80000480:	fff6869b          	addiw	a3,a3,-1
    80000484:	0fe87593          	andi	a1,a6,254
    80000488:	00f54533          	xor	a0,a0,a5
    8000048c:	00065463          	bgez	a2,80000494 <_Z4GMulcc+0x38>
    80000490:	01b5c593          	xori	a1,a1,27
    80000494:	00175713          	srli	a4,a4,0x1
    80000498:	fc0698e3          	bnez	a3,80000468 <_Z4GMulcc+0xc>
    8000049c:	00008067          	ret

00000000800004a0 <_Z10mixColumnsPA4_c>:
    800004a0:	fc010113          	addi	sp,sp,-64
    800004a4:	00001797          	auipc	a5,0x1
    800004a8:	33c7b783          	ld	a5,828(a5) # 800017e0 <_ZZL20runCorrectnessChecksvE10expectedCt+0x10>
    800004ac:	00f13823          	sd	a5,16(sp)
    800004b0:	010008b7          	lui	a7,0x1000
    800004b4:	00001797          	auipc	a5,0x1
    800004b8:	3347b783          	ld	a5,820(a5) # 800017e8 <_ZZL20runCorrectnessChecksvE10expectedCt+0x18>
    800004bc:	02813c23          	sd	s0,56(sp)
    800004c0:	02913823          	sd	s1,48(sp)
    800004c4:	03213423          	sd	s2,40(sp)
    800004c8:	00f13c23          	sd	a5,24(sp)
    800004cc:	01050313          	addi	t1,a0,16
    800004d0:	00010813          	mv	a6,sp
    800004d4:	00050713          	mv	a4,a0
    800004d8:	fff88893          	addi	a7,a7,-1 # ffffff <STACK_SIZE+0xff7fff>
    800004dc:	00174583          	lbu	a1,1(a4)
    800004e0:	00274603          	lbu	a2,2(a4)
    800004e4:	00074783          	lbu	a5,0(a4)
    800004e8:	00374683          	lbu	a3,3(a4)
    800004ec:	0085959b          	slliw	a1,a1,0x8
    800004f0:	00b7e7b3          	or	a5,a5,a1
    800004f4:	0106161b          	slliw	a2,a2,0x10
    800004f8:	00c7e7b3          	or	a5,a5,a2
    800004fc:	0186969b          	slliw	a3,a3,0x18
    80000500:	0117f7b3          	and	a5,a5,a7
    80000504:	00d7e7b3          	or	a5,a5,a3
    80000508:	00f82023          	sw	a5,0(a6)
    8000050c:	00470713          	addi	a4,a4,4
    80000510:	00480813          	addi	a6,a6,4
    80000514:	fce314e3          	bne	t1,a4,800004dc <_Z10mixColumnsPA4_c+0x3c>
    80000518:	01010593          	addi	a1,sp,16
    8000051c:	02010f13          	addi	t5,sp,32
    80000520:	00410e93          	addi	t4,sp,4
    80000524:	0005ce03          	lbu	t3,0(a1)
    80000528:	0015c303          	lbu	t1,1(a1)
    8000052c:	0025c883          	lbu	a7,2(a1)
    80000530:	0035c803          	lbu	a6,3(a1)
    80000534:	00050613          	mv	a2,a0
    80000538:	00010693          	mv	a3,sp
    8000053c:	0006cf83          	lbu	t6,0(a3)
    80000540:	000e0713          	mv	a4,t3
    80000544:	00800293          	li	t0,8
    80000548:	00000413          	li	s0,0
    8000054c:	00177793          	andi	a5,a4,1
    80000550:	018f939b          	slliw	t2,t6,0x18
    80000554:	40f007bb          	negw	a5,a5
    80000558:	00fff7b3          	and	a5,t6,a5
    8000055c:	001f949b          	slliw	s1,t6,0x1
    80000560:	4183d39b          	sraiw	t2,t2,0x18
    80000564:	0017571b          	srliw	a4,a4,0x1
    80000568:	fff2829b          	addiw	t0,t0,-1 # 3f7fffff <STACK_SIZE+0x3f7f7fff>
    8000056c:	0fe4ff93          	andi	t6,s1,254
    80000570:	00f44433          	xor	s0,s0,a5
    80000574:	0003d463          	bgez	t2,8000057c <_Z10mixColumnsPA4_c+0xdc>
    80000578:	01bfcf93          	xori	t6,t6,27
    8000057c:	0ff77713          	zext.b	a4,a4
    80000580:	fc0296e3          	bnez	t0,8000054c <_Z10mixColumnsPA4_c+0xac>
    80000584:	0046cf83          	lbu	t6,4(a3)
    80000588:	00030713          	mv	a4,t1
    8000058c:	00800393          	li	t2,8
    80000590:	00177793          	andi	a5,a4,1
    80000594:	018f949b          	slliw	s1,t6,0x18
    80000598:	40f007bb          	negw	a5,a5
    8000059c:	00fff7b3          	and	a5,t6,a5
    800005a0:	001f991b          	slliw	s2,t6,0x1
    800005a4:	4184d49b          	sraiw	s1,s1,0x18
    800005a8:	0017571b          	srliw	a4,a4,0x1
    800005ac:	fff3839b          	addiw	t2,t2,-1
    800005b0:	0fe97f93          	andi	t6,s2,254
    800005b4:	00f2c2b3          	xor	t0,t0,a5
    800005b8:	0004d463          	bgez	s1,800005c0 <_Z10mixColumnsPA4_c+0x120>
    800005bc:	01bfcf93          	xori	t6,t6,27
    800005c0:	0ff77713          	zext.b	a4,a4
    800005c4:	fc0396e3          	bnez	t2,80000590 <_Z10mixColumnsPA4_c+0xf0>
    800005c8:	0086cf83          	lbu	t6,8(a3)
    800005cc:	0082c2b3          	xor	t0,t0,s0
    800005d0:	00088713          	mv	a4,a7
    800005d4:	00800393          	li	t2,8
    800005d8:	00000413          	li	s0,0
    800005dc:	00177793          	andi	a5,a4,1
    800005e0:	018f949b          	slliw	s1,t6,0x18
    800005e4:	40f007bb          	negw	a5,a5
    800005e8:	00fff7b3          	and	a5,t6,a5
    800005ec:	001f991b          	slliw	s2,t6,0x1
    800005f0:	4184d49b          	sraiw	s1,s1,0x18
    800005f4:	0017571b          	srliw	a4,a4,0x1
    800005f8:	fff3839b          	addiw	t2,t2,-1
    800005fc:	0fe97f93          	andi	t6,s2,254
    80000600:	00f44433          	xor	s0,s0,a5
    80000604:	0004d463          	bgez	s1,8000060c <_Z10mixColumnsPA4_c+0x16c>
    80000608:	01bfcf93          	xori	t6,t6,27
    8000060c:	0ff77713          	zext.b	a4,a4
    80000610:	fc0396e3          	bnez	t2,800005dc <_Z10mixColumnsPA4_c+0x13c>
    80000614:	00c6cf83          	lbu	t6,12(a3)
    80000618:	0082c2b3          	xor	t0,t0,s0
    8000061c:	0ff2f293          	zext.b	t0,t0
    80000620:	00080713          	mv	a4,a6
    80000624:	00800393          	li	t2,8
    80000628:	00000413          	li	s0,0
    8000062c:	00177793          	andi	a5,a4,1
    80000630:	018f949b          	slliw	s1,t6,0x18
    80000634:	40f007bb          	negw	a5,a5
    80000638:	00fff7b3          	and	a5,t6,a5
    8000063c:	001f991b          	slliw	s2,t6,0x1
    80000640:	4184d49b          	sraiw	s1,s1,0x18
    80000644:	0017571b          	srliw	a4,a4,0x1
    80000648:	fff3839b          	addiw	t2,t2,-1
    8000064c:	0fe97f93          	andi	t6,s2,254
    80000650:	00f44433          	xor	s0,s0,a5
    80000654:	0004d463          	bgez	s1,8000065c <_Z10mixColumnsPA4_c+0x1bc>
    80000658:	01bfcf93          	xori	t6,t6,27
    8000065c:	0ff77713          	zext.b	a4,a4
    80000660:	fc0396e3          	bnez	t2,8000062c <_Z10mixColumnsPA4_c+0x18c>
    80000664:	0082c7b3          	xor	a5,t0,s0
    80000668:	00f60023          	sb	a5,0(a2)
    8000066c:	00168693          	addi	a3,a3,1
    80000670:	00160613          	addi	a2,a2,1
    80000674:	ecde94e3          	bne	t4,a3,8000053c <_Z10mixColumnsPA4_c+0x9c>
    80000678:	00458593          	addi	a1,a1,4
    8000067c:	00450513          	addi	a0,a0,4
    80000680:	ebe592e3          	bne	a1,t5,80000524 <_Z10mixColumnsPA4_c+0x84>
    80000684:	03813403          	ld	s0,56(sp)
    80000688:	03013483          	ld	s1,48(sp)
    8000068c:	02813903          	ld	s2,40(sp)
    80000690:	00000513          	li	a0,0
    80000694:	04010113          	addi	sp,sp,64
    80000698:	00008067          	ret

000000008000069c <_Z13invMixColumnsPA4_c>:
    8000069c:	fc010113          	addi	sp,sp,-64
    800006a0:	00001797          	auipc	a5,0x1
    800006a4:	1507b783          	ld	a5,336(a5) # 800017f0 <_ZZL20runCorrectnessChecksvE10expectedCt+0x20>
    800006a8:	00f13823          	sd	a5,16(sp)
    800006ac:	010008b7          	lui	a7,0x1000
    800006b0:	00001797          	auipc	a5,0x1
    800006b4:	1487b783          	ld	a5,328(a5) # 800017f8 <_ZZL20runCorrectnessChecksvE10expectedCt+0x28>
    800006b8:	02813c23          	sd	s0,56(sp)
    800006bc:	02913823          	sd	s1,48(sp)
    800006c0:	03213423          	sd	s2,40(sp)
    800006c4:	00f13c23          	sd	a5,24(sp)
    800006c8:	01050313          	addi	t1,a0,16
    800006cc:	00010813          	mv	a6,sp
    800006d0:	00050713          	mv	a4,a0
    800006d4:	fff88893          	addi	a7,a7,-1 # ffffff <STACK_SIZE+0xff7fff>
    800006d8:	00174583          	lbu	a1,1(a4)
    800006dc:	00274603          	lbu	a2,2(a4)
    800006e0:	00074783          	lbu	a5,0(a4)
    800006e4:	00374683          	lbu	a3,3(a4)
    800006e8:	0085959b          	slliw	a1,a1,0x8
    800006ec:	00b7e7b3          	or	a5,a5,a1
    800006f0:	0106161b          	slliw	a2,a2,0x10
    800006f4:	00c7e7b3          	or	a5,a5,a2
    800006f8:	0186969b          	slliw	a3,a3,0x18
    800006fc:	0117f7b3          	and	a5,a5,a7
    80000700:	00d7e7b3          	or	a5,a5,a3
    80000704:	00f82023          	sw	a5,0(a6)
    80000708:	00470713          	addi	a4,a4,4
    8000070c:	00480813          	addi	a6,a6,4
    80000710:	fce314e3          	bne	t1,a4,800006d8 <_Z13invMixColumnsPA4_c+0x3c>
    80000714:	01010593          	addi	a1,sp,16
    80000718:	02010f13          	addi	t5,sp,32
    8000071c:	00410e93          	addi	t4,sp,4
    80000720:	0005ce03          	lbu	t3,0(a1)
    80000724:	0015c303          	lbu	t1,1(a1)
    80000728:	0025c883          	lbu	a7,2(a1)
    8000072c:	0035c803          	lbu	a6,3(a1)
    80000730:	00050613          	mv	a2,a0
    80000734:	00010693          	mv	a3,sp
    80000738:	0006cf83          	lbu	t6,0(a3)
    8000073c:	000e0713          	mv	a4,t3
    80000740:	00800293          	li	t0,8
    80000744:	00000413          	li	s0,0
    80000748:	00177793          	andi	a5,a4,1
    8000074c:	018f939b          	slliw	t2,t6,0x18
    80000750:	40f007bb          	negw	a5,a5
    80000754:	00fff7b3          	and	a5,t6,a5
    80000758:	001f949b          	slliw	s1,t6,0x1
    8000075c:	4183d39b          	sraiw	t2,t2,0x18
    80000760:	0017571b          	srliw	a4,a4,0x1
    80000764:	fff2829b          	addiw	t0,t0,-1
    80000768:	0fe4ff93          	andi	t6,s1,254
    8000076c:	00f44433          	xor	s0,s0,a5
    80000770:	0003d463          	bgez	t2,80000778 <_Z13invMixColumnsPA4_c+0xdc>
    80000774:	01bfcf93          	xori	t6,t6,27
    80000778:	0ff77713          	zext.b	a4,a4
    8000077c:	fc0296e3          	bnez	t0,80000748 <_Z13invMixColumnsPA4_c+0xac>
    80000780:	0046cf83          	lbu	t6,4(a3)
    80000784:	00030713          	mv	a4,t1
    80000788:	00800393          	li	t2,8
    8000078c:	00177793          	andi	a5,a4,1
    80000790:	018f949b          	slliw	s1,t6,0x18
    80000794:	40f007bb          	negw	a5,a5
    80000798:	00fff7b3          	and	a5,t6,a5
    8000079c:	001f991b          	slliw	s2,t6,0x1
    800007a0:	4184d49b          	sraiw	s1,s1,0x18
    800007a4:	0017571b          	srliw	a4,a4,0x1
    800007a8:	fff3839b          	addiw	t2,t2,-1
    800007ac:	0fe97f93          	andi	t6,s2,254
    800007b0:	00f2c2b3          	xor	t0,t0,a5
    800007b4:	0004d463          	bgez	s1,800007bc <_Z13invMixColumnsPA4_c+0x120>
    800007b8:	01bfcf93          	xori	t6,t6,27
    800007bc:	0ff77713          	zext.b	a4,a4
    800007c0:	fc0396e3          	bnez	t2,8000078c <_Z13invMixColumnsPA4_c+0xf0>
    800007c4:	0086cf83          	lbu	t6,8(a3)
    800007c8:	0082c2b3          	xor	t0,t0,s0
    800007cc:	00088713          	mv	a4,a7
    800007d0:	00800393          	li	t2,8
    800007d4:	00000413          	li	s0,0
    800007d8:	00177793          	andi	a5,a4,1
    800007dc:	018f949b          	slliw	s1,t6,0x18
    800007e0:	40f007bb          	negw	a5,a5
    800007e4:	00fff7b3          	and	a5,t6,a5
    800007e8:	001f991b          	slliw	s2,t6,0x1
    800007ec:	4184d49b          	sraiw	s1,s1,0x18
    800007f0:	0017571b          	srliw	a4,a4,0x1
    800007f4:	fff3839b          	addiw	t2,t2,-1
    800007f8:	0fe97f93          	andi	t6,s2,254
    800007fc:	00f44433          	xor	s0,s0,a5
    80000800:	0004d463          	bgez	s1,80000808 <_Z13invMixColumnsPA4_c+0x16c>
    80000804:	01bfcf93          	xori	t6,t6,27
    80000808:	0ff77713          	zext.b	a4,a4
    8000080c:	fc0396e3          	bnez	t2,800007d8 <_Z13invMixColumnsPA4_c+0x13c>
    80000810:	00c6cf83          	lbu	t6,12(a3)
    80000814:	0082c2b3          	xor	t0,t0,s0
    80000818:	0ff2f293          	zext.b	t0,t0
    8000081c:	00080713          	mv	a4,a6
    80000820:	00800393          	li	t2,8
    80000824:	00000413          	li	s0,0
    80000828:	00177793          	andi	a5,a4,1
    8000082c:	018f949b          	slliw	s1,t6,0x18
    80000830:	40f007bb          	negw	a5,a5
    80000834:	00fff7b3          	and	a5,t6,a5
    80000838:	001f991b          	slliw	s2,t6,0x1
    8000083c:	4184d49b          	sraiw	s1,s1,0x18
    80000840:	0017571b          	srliw	a4,a4,0x1
    80000844:	fff3839b          	addiw	t2,t2,-1
    80000848:	0fe97f93          	andi	t6,s2,254
    8000084c:	00f44433          	xor	s0,s0,a5
    80000850:	0004d463          	bgez	s1,80000858 <_Z13invMixColumnsPA4_c+0x1bc>
    80000854:	01bfcf93          	xori	t6,t6,27
    80000858:	0ff77713          	zext.b	a4,a4
    8000085c:	fc0396e3          	bnez	t2,80000828 <_Z13invMixColumnsPA4_c+0x18c>
    80000860:	0082c7b3          	xor	a5,t0,s0
    80000864:	00f60023          	sb	a5,0(a2)
    80000868:	00168693          	addi	a3,a3,1
    8000086c:	00160613          	addi	a2,a2,1
    80000870:	ecde94e3          	bne	t4,a3,80000738 <_Z13invMixColumnsPA4_c+0x9c>
    80000874:	00458593          	addi	a1,a1,4
    80000878:	00450513          	addi	a0,a0,4
    8000087c:	ebe592e3          	bne	a1,t5,80000720 <_Z13invMixColumnsPA4_c+0x84>
    80000880:	03813403          	ld	s0,56(sp)
    80000884:	03013483          	ld	s1,48(sp)
    80000888:	02813903          	ld	s2,40(sp)
    8000088c:	00000513          	li	a0,0
    80000890:	04010113          	addi	sp,sp,64
    80000894:	00008067          	ret

0000000080000898 <_Z10aesEncryptPKcjS0_Pcj>:
    80000898:	e2010113          	addi	sp,sp,-480
    8000089c:	1c113c23          	sd	ra,472(sp)
    800008a0:	00013423          	sd	zero,8(sp)
    800008a4:	00013823          	sd	zero,16(sp)
    800008a8:	00013c23          	sd	zero,24(sp)
    800008ac:	02013023          	sd	zero,32(sp)
    800008b0:	1e050e63          	beqz	a0,80000aac <_Z10aesEncryptPKcjS0_Pcj+0x214>
    800008b4:	1c813823          	sd	s0,464(sp)
    800008b8:	00060413          	mv	s0,a2
    800008bc:	20060e63          	beqz	a2,80000ad8 <_Z10aesEncryptPKcjS0_Pcj+0x240>
    800008c0:	1b413823          	sd	s4,432(sp)
    800008c4:	00068a13          	mv	s4,a3
    800008c8:	20068063          	beqz	a3,80000ac8 <_Z10aesEncryptPKcjS0_Pcj+0x230>
    800008cc:	1c913423          	sd	s1,456(sp)
    800008d0:	00070493          	mv	s1,a4
    800008d4:	01000713          	li	a4,16
    800008d8:	1cb76e63          	bltu	a4,a1,80000ab4 <_Z10aesEncryptPKcjS0_Pcj+0x21c>
    800008dc:	00f4f713          	andi	a4,s1,15
    800008e0:	1c071a63          	bnez	a4,80000ab4 <_Z10aesEncryptPKcjS0_Pcj+0x21c>
    800008e4:	1c058063          	beqz	a1,80000aa4 <_Z10aesEncryptPKcjS0_Pcj+0x20c>
    800008e8:	02059693          	slli	a3,a1,0x20
    800008ec:	00050793          	mv	a5,a0
    800008f0:	0206d693          	srli	a3,a3,0x20
    800008f4:	00810513          	addi	a0,sp,8
    800008f8:	00078713          	mv	a4,a5
    800008fc:	00d506b3          	add	a3,a0,a3
    80000900:	00050793          	mv	a5,a0
    80000904:	00074603          	lbu	a2,0(a4)
    80000908:	00178793          	addi	a5,a5,1
    8000090c:	00170713          	addi	a4,a4,1
    80000910:	fec78fa3          	sb	a2,-1(a5)
    80000914:	fed798e3          	bne	a5,a3,80000904 <_Z10aesEncryptPKcjS0_Pcj+0x6c>
    80000918:	02810613          	addi	a2,sp,40
    8000091c:	01000593          	li	a1,16
    80000920:	84dff0ef          	jal	8000016c <_Z12keyExpansionPKcjP6AesKey>
    80000924:	16048263          	beqz	s1,80000a88 <_Z10aesEncryptPKcjS0_Pcj+0x1f0>
    80000928:	fff4879b          	addiw	a5,s1,-1
    8000092c:	0047d79b          	srliw	a5,a5,0x4
    80000930:	00479793          	slli	a5,a5,0x4
    80000934:	01478793          	addi	a5,a5,20
    80000938:	1d213023          	sd	s2,448(sp)
    8000093c:	1b513423          	sd	s5,424(sp)
    80000940:	1b613023          	sd	s6,416(sp)
    80000944:	004a0a93          	addi	s5,s4,4
    80000948:	00440693          	addi	a3,s0,4
    8000094c:	1b313c23          	sd	s3,440(sp)
    80000950:	19713c23          	sd	s7,408(sp)
    80000954:	19813823          	sd	s8,400(sp)
    80000958:	00fa0a33          	add	s4,s4,a5
    8000095c:	00001417          	auipc	s0,0x1
    80000960:	ea440413          	addi	s0,s0,-348 # 80001800 <S>
    80000964:	0b810913          	addi	s2,sp,184
    80000968:	02c10b13          	addi	s6,sp,44
    8000096c:	01810493          	addi	s1,sp,24
    80000970:	00048593          	mv	a1,s1
    80000974:	01068993          	addi	s3,a3,16
    80000978:	ffc68793          	addi	a5,a3,-4
    8000097c:	00058713          	mv	a4,a1
    80000980:	0007c603          	lbu	a2,0(a5)
    80000984:	00178793          	addi	a5,a5,1
    80000988:	00470713          	addi	a4,a4,4
    8000098c:	fec70e23          	sb	a2,-4(a4)
    80000990:	fed798e3          	bne	a5,a3,80000980 <_Z10aesEncryptPKcjS0_Pcj+0xe8>
    80000994:	00478693          	addi	a3,a5,4
    80000998:	00158593          	addi	a1,a1,1
    8000099c:	fd369ee3          	bne	a3,s3,80000978 <_Z10aesEncryptPKcjS0_Pcj+0xe0>
    800009a0:	02810593          	addi	a1,sp,40
    800009a4:	01810513          	addi	a0,sp,24
    800009a8:	919ff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    800009ac:	02810b93          	addi	s7,sp,40
    800009b0:	01c10c13          	addi	s8,sp,28
    800009b4:	010b8b93          	addi	s7,s7,16
    800009b8:	000c0693          	mv	a3,s8
    800009bc:	ffc68793          	addi	a5,a3,-4
    800009c0:	0007c703          	lbu	a4,0(a5)
    800009c4:	00178793          	addi	a5,a5,1
    800009c8:	00e40733          	add	a4,s0,a4
    800009cc:	00074703          	lbu	a4,0(a4)
    800009d0:	fee78fa3          	sb	a4,-1(a5)
    800009d4:	fed796e3          	bne	a5,a3,800009c0 <_Z10aesEncryptPKcjS0_Pcj+0x128>
    800009d8:	00478693          	addi	a3,a5,4
    800009dc:	ff6690e3          	bne	a3,s6,800009bc <_Z10aesEncryptPKcjS0_Pcj+0x124>
    800009e0:	01810513          	addi	a0,sp,24
    800009e4:	9a1ff0ef          	jal	80000384 <_Z9shiftRowsPA4_c>
    800009e8:	01810513          	addi	a0,sp,24
    800009ec:	ab5ff0ef          	jal	800004a0 <_Z10mixColumnsPA4_c>
    800009f0:	000b8593          	mv	a1,s7
    800009f4:	01810513          	addi	a0,sp,24
    800009f8:	8c9ff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    800009fc:	fb2b9ae3          	bne	s7,s2,800009b0 <_Z10aesEncryptPKcjS0_Pcj+0x118>
    80000a00:	ffcc0793          	addi	a5,s8,-4
    80000a04:	0007c703          	lbu	a4,0(a5)
    80000a08:	00178793          	addi	a5,a5,1
    80000a0c:	00e40733          	add	a4,s0,a4
    80000a10:	00074703          	lbu	a4,0(a4)
    80000a14:	fee78fa3          	sb	a4,-1(a5)
    80000a18:	ff8796e3          	bne	a5,s8,80000a04 <_Z10aesEncryptPKcjS0_Pcj+0x16c>
    80000a1c:	00478c13          	addi	s8,a5,4
    80000a20:	ff6c10e3          	bne	s8,s6,80000a00 <_Z10aesEncryptPKcjS0_Pcj+0x168>
    80000a24:	01810513          	addi	a0,sp,24
    80000a28:	95dff0ef          	jal	80000384 <_Z9shiftRowsPA4_c>
    80000a2c:	0c810593          	addi	a1,sp,200
    80000a30:	01810513          	addi	a0,sp,24
    80000a34:	88dff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    80000a38:	010a8613          	addi	a2,s5,16
    80000a3c:	ffca8793          	addi	a5,s5,-4
    80000a40:	00048713          	mv	a4,s1
    80000a44:	00074683          	lbu	a3,0(a4)
    80000a48:	00178793          	addi	a5,a5,1
    80000a4c:	00470713          	addi	a4,a4,4
    80000a50:	fed78fa3          	sb	a3,-1(a5)
    80000a54:	ff5798e3          	bne	a5,s5,80000a44 <_Z10aesEncryptPKcjS0_Pcj+0x1ac>
    80000a58:	00478a93          	addi	s5,a5,4
    80000a5c:	00148493          	addi	s1,s1,1
    80000a60:	fcca9ee3          	bne	s5,a2,80000a3c <_Z10aesEncryptPKcjS0_Pcj+0x1a4>
    80000a64:	015a0663          	beq	s4,s5,80000a70 <_Z10aesEncryptPKcjS0_Pcj+0x1d8>
    80000a68:	00098693          	mv	a3,s3
    80000a6c:	f01ff06f          	j	8000096c <_Z10aesEncryptPKcjS0_Pcj+0xd4>
    80000a70:	1c013903          	ld	s2,448(sp)
    80000a74:	1b813983          	ld	s3,440(sp)
    80000a78:	1a813a83          	ld	s5,424(sp)
    80000a7c:	1a013b03          	ld	s6,416(sp)
    80000a80:	19813b83          	ld	s7,408(sp)
    80000a84:	19013c03          	ld	s8,400(sp)
    80000a88:	1d013403          	ld	s0,464(sp)
    80000a8c:	1c813483          	ld	s1,456(sp)
    80000a90:	1b013a03          	ld	s4,432(sp)
    80000a94:	00000513          	li	a0,0
    80000a98:	1d813083          	ld	ra,472(sp)
    80000a9c:	1e010113          	addi	sp,sp,480
    80000aa0:	00008067          	ret
    80000aa4:	00810513          	addi	a0,sp,8
    80000aa8:	e71ff06f          	j	80000918 <_Z10aesEncryptPKcjS0_Pcj+0x80>
    80000aac:	fff00513          	li	a0,-1
    80000ab0:	fe9ff06f          	j	80000a98 <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000ab4:	1d013403          	ld	s0,464(sp)
    80000ab8:	1c813483          	ld	s1,456(sp)
    80000abc:	1b013a03          	ld	s4,432(sp)
    80000ac0:	fff00513          	li	a0,-1
    80000ac4:	fd5ff06f          	j	80000a98 <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000ac8:	1d013403          	ld	s0,464(sp)
    80000acc:	1b013a03          	ld	s4,432(sp)
    80000ad0:	fff00513          	li	a0,-1
    80000ad4:	fc5ff06f          	j	80000a98 <_Z10aesEncryptPKcjS0_Pcj+0x200>
    80000ad8:	1d013403          	ld	s0,464(sp)
    80000adc:	fff00513          	li	a0,-1
    80000ae0:	fb9ff06f          	j	80000a98 <_Z10aesEncryptPKcjS0_Pcj+0x200>

0000000080000ae4 <_Z10aesDecryptPKcjS0_Pcj>:
    80000ae4:	e2010113          	addi	sp,sp,-480
    80000ae8:	1c113c23          	sd	ra,472(sp)
    80000aec:	00013423          	sd	zero,8(sp)
    80000af0:	00013823          	sd	zero,16(sp)
    80000af4:	00013c23          	sd	zero,24(sp)
    80000af8:	02013023          	sd	zero,32(sp)
    80000afc:	1e050e63          	beqz	a0,80000cf8 <_Z10aesDecryptPKcjS0_Pcj+0x214>
    80000b00:	1c813823          	sd	s0,464(sp)
    80000b04:	00060413          	mv	s0,a2
    80000b08:	20060e63          	beqz	a2,80000d24 <_Z10aesDecryptPKcjS0_Pcj+0x240>
    80000b0c:	1b413823          	sd	s4,432(sp)
    80000b10:	00068a13          	mv	s4,a3
    80000b14:	20068063          	beqz	a3,80000d14 <_Z10aesDecryptPKcjS0_Pcj+0x230>
    80000b18:	1c913423          	sd	s1,456(sp)
    80000b1c:	00070493          	mv	s1,a4
    80000b20:	01000713          	li	a4,16
    80000b24:	1cb76e63          	bltu	a4,a1,80000d00 <_Z10aesDecryptPKcjS0_Pcj+0x21c>
    80000b28:	00f4f713          	andi	a4,s1,15
    80000b2c:	1c071a63          	bnez	a4,80000d00 <_Z10aesDecryptPKcjS0_Pcj+0x21c>
    80000b30:	1c058063          	beqz	a1,80000cf0 <_Z10aesDecryptPKcjS0_Pcj+0x20c>
    80000b34:	02059693          	slli	a3,a1,0x20
    80000b38:	00050793          	mv	a5,a0
    80000b3c:	0206d693          	srli	a3,a3,0x20
    80000b40:	00810513          	addi	a0,sp,8
    80000b44:	00078713          	mv	a4,a5
    80000b48:	00d506b3          	add	a3,a0,a3
    80000b4c:	00050793          	mv	a5,a0
    80000b50:	00074603          	lbu	a2,0(a4)
    80000b54:	00178793          	addi	a5,a5,1
    80000b58:	00170713          	addi	a4,a4,1
    80000b5c:	fec78fa3          	sb	a2,-1(a5)
    80000b60:	fed798e3          	bne	a5,a3,80000b50 <_Z10aesDecryptPKcjS0_Pcj+0x6c>
    80000b64:	02810613          	addi	a2,sp,40
    80000b68:	01000593          	li	a1,16
    80000b6c:	e00ff0ef          	jal	8000016c <_Z12keyExpansionPKcjP6AesKey>
    80000b70:	16048263          	beqz	s1,80000cd4 <_Z10aesDecryptPKcjS0_Pcj+0x1f0>
    80000b74:	fff4879b          	addiw	a5,s1,-1
    80000b78:	0047d79b          	srliw	a5,a5,0x4
    80000b7c:	00479793          	slli	a5,a5,0x4
    80000b80:	01478793          	addi	a5,a5,20
    80000b84:	1d213023          	sd	s2,448(sp)
    80000b88:	1b513423          	sd	s5,424(sp)
    80000b8c:	1b613023          	sd	s6,416(sp)
    80000b90:	004a0a93          	addi	s5,s4,4
    80000b94:	00440693          	addi	a3,s0,4
    80000b98:	1b313c23          	sd	s3,440(sp)
    80000b9c:	19713c23          	sd	s7,408(sp)
    80000ba0:	19813823          	sd	s8,400(sp)
    80000ba4:	00fa0a33          	add	s4,s4,a5
    80000ba8:	00001417          	auipc	s0,0x1
    80000bac:	c5840413          	addi	s0,s0,-936 # 80001800 <S>
    80000bb0:	16810913          	addi	s2,sp,360
    80000bb4:	02c10b13          	addi	s6,sp,44
    80000bb8:	01810493          	addi	s1,sp,24
    80000bbc:	00048593          	mv	a1,s1
    80000bc0:	01068993          	addi	s3,a3,16
    80000bc4:	ffc68793          	addi	a5,a3,-4
    80000bc8:	00058713          	mv	a4,a1
    80000bcc:	0007c603          	lbu	a2,0(a5)
    80000bd0:	00178793          	addi	a5,a5,1
    80000bd4:	00470713          	addi	a4,a4,4
    80000bd8:	fec70e23          	sb	a2,-4(a4)
    80000bdc:	fed798e3          	bne	a5,a3,80000bcc <_Z10aesDecryptPKcjS0_Pcj+0xe8>
    80000be0:	00478693          	addi	a3,a5,4
    80000be4:	00158593          	addi	a1,a1,1
    80000be8:	fd369ee3          	bne	a3,s3,80000bc4 <_Z10aesDecryptPKcjS0_Pcj+0xe0>
    80000bec:	0d810593          	addi	a1,sp,216
    80000bf0:	01810513          	addi	a0,sp,24
    80000bf4:	eccff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    80000bf8:	0d810b93          	addi	s7,sp,216
    80000bfc:	01810513          	addi	a0,sp,24
    80000c00:	ff0ff0ef          	jal	800003f0 <_Z12invShiftRowsPA4_c>
    80000c04:	01c10c13          	addi	s8,sp,28
    80000c08:	010b8b93          	addi	s7,s7,16
    80000c0c:	000c0693          	mv	a3,s8
    80000c10:	ffc68793          	addi	a5,a3,-4
    80000c14:	0007c703          	lbu	a4,0(a5)
    80000c18:	00178793          	addi	a5,a5,1
    80000c1c:	00e40733          	add	a4,s0,a4
    80000c20:	10074703          	lbu	a4,256(a4)
    80000c24:	fee78fa3          	sb	a4,-1(a5)
    80000c28:	fed796e3          	bne	a5,a3,80000c14 <_Z10aesDecryptPKcjS0_Pcj+0x130>
    80000c2c:	00478693          	addi	a3,a5,4
    80000c30:	ff6690e3          	bne	a3,s6,80000c10 <_Z10aesDecryptPKcjS0_Pcj+0x12c>
    80000c34:	000b8593          	mv	a1,s7
    80000c38:	01810513          	addi	a0,sp,24
    80000c3c:	e84ff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    80000c40:	01810513          	addi	a0,sp,24
    80000c44:	a59ff0ef          	jal	8000069c <_Z13invMixColumnsPA4_c>
    80000c48:	fb2b9ae3          	bne	s7,s2,80000bfc <_Z10aesDecryptPKcjS0_Pcj+0x118>
    80000c4c:	ffcc0793          	addi	a5,s8,-4
    80000c50:	0007c703          	lbu	a4,0(a5)
    80000c54:	00178793          	addi	a5,a5,1
    80000c58:	00e40733          	add	a4,s0,a4
    80000c5c:	10074703          	lbu	a4,256(a4)
    80000c60:	fee78fa3          	sb	a4,-1(a5)
    80000c64:	ff8796e3          	bne	a5,s8,80000c50 <_Z10aesDecryptPKcjS0_Pcj+0x16c>
    80000c68:	00478c13          	addi	s8,a5,4
    80000c6c:	ff6c10e3          	bne	s8,s6,80000c4c <_Z10aesDecryptPKcjS0_Pcj+0x168>
    80000c70:	01810513          	addi	a0,sp,24
    80000c74:	f7cff0ef          	jal	800003f0 <_Z12invShiftRowsPA4_c>
    80000c78:	17810593          	addi	a1,sp,376
    80000c7c:	01810513          	addi	a0,sp,24
    80000c80:	e40ff0ef          	jal	800002c0 <_Z11addRoundKeyPA4_cPKj>
    80000c84:	010a8613          	addi	a2,s5,16
    80000c88:	ffca8793          	addi	a5,s5,-4
    80000c8c:	00048713          	mv	a4,s1
    80000c90:	00074683          	lbu	a3,0(a4)
    80000c94:	00178793          	addi	a5,a5,1
    80000c98:	00470713          	addi	a4,a4,4
    80000c9c:	fed78fa3          	sb	a3,-1(a5)
    80000ca0:	ff5798e3          	bne	a5,s5,80000c90 <_Z10aesDecryptPKcjS0_Pcj+0x1ac>
    80000ca4:	00478a93          	addi	s5,a5,4
    80000ca8:	00148493          	addi	s1,s1,1
    80000cac:	fcca9ee3          	bne	s5,a2,80000c88 <_Z10aesDecryptPKcjS0_Pcj+0x1a4>
    80000cb0:	015a0663          	beq	s4,s5,80000cbc <_Z10aesDecryptPKcjS0_Pcj+0x1d8>
    80000cb4:	00098693          	mv	a3,s3
    80000cb8:	f01ff06f          	j	80000bb8 <_Z10aesDecryptPKcjS0_Pcj+0xd4>
    80000cbc:	1c013903          	ld	s2,448(sp)
    80000cc0:	1b813983          	ld	s3,440(sp)
    80000cc4:	1a813a83          	ld	s5,424(sp)
    80000cc8:	1a013b03          	ld	s6,416(sp)
    80000ccc:	19813b83          	ld	s7,408(sp)
    80000cd0:	19013c03          	ld	s8,400(sp)
    80000cd4:	1d013403          	ld	s0,464(sp)
    80000cd8:	1c813483          	ld	s1,456(sp)
    80000cdc:	1b013a03          	ld	s4,432(sp)
    80000ce0:	00000513          	li	a0,0
    80000ce4:	1d813083          	ld	ra,472(sp)
    80000ce8:	1e010113          	addi	sp,sp,480
    80000cec:	00008067          	ret
    80000cf0:	00810513          	addi	a0,sp,8
    80000cf4:	e71ff06f          	j	80000b64 <_Z10aesDecryptPKcjS0_Pcj+0x80>
    80000cf8:	fff00513          	li	a0,-1
    80000cfc:	fe9ff06f          	j	80000ce4 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000d00:	1d013403          	ld	s0,464(sp)
    80000d04:	1c813483          	ld	s1,456(sp)
    80000d08:	1b013a03          	ld	s4,432(sp)
    80000d0c:	fff00513          	li	a0,-1
    80000d10:	fd5ff06f          	j	80000ce4 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000d14:	1d013403          	ld	s0,464(sp)
    80000d18:	1b013a03          	ld	s4,432(sp)
    80000d1c:	fff00513          	li	a0,-1
    80000d20:	fc5ff06f          	j	80000ce4 <_Z10aesDecryptPKcjS0_Pcj+0x200>
    80000d24:	1d013403          	ld	s0,464(sp)
    80000d28:	fff00513          	li	a0,-1
    80000d2c:	fb9ff06f          	j	80000ce4 <_Z10aesDecryptPKcjS0_Pcj+0x200>

0000000080000d30 <_Z13heavy_rng_modji>:
    80000d30:	fb010113          	addi	sp,sp,-80
    80000d34:	a5a5a7b7          	lui	a5,0xa5a5a
    80000d38:	01513c23          	sd	s5,24(sp)
    80000d3c:	01613823          	sd	s6,16(sp)
    80000d40:	5a578793          	addi	a5,a5,1445 # ffffffffa5a5a5a5 <_stack_top+0xffffffff25a50ba5>
    80000d44:	04113423          	sd	ra,72(sp)
    80000d48:	00f54b33          	xor	s6,a0,a5
    80000d4c:	00156a93          	ori	s5,a0,1
    80000d50:	24b05863          	blez	a1,80000fa0 <_Z13heavy_rng_modji+0x270>
    80000d54:	02913c23          	sd	s1,56(sp)
    80000d58:	03213823          	sd	s2,48(sp)
    80000d5c:	000034b7          	lui	s1,0x3
    80000d60:	3c6ef937          	lui	s2,0x3c6ef
    80000d64:	04813023          	sd	s0,64(sp)
    80000d68:	03313423          	sd	s3,40(sp)
    80000d6c:	03413023          	sd	s4,32(sp)
    80000d70:	01713423          	sd	s7,8(sp)
    80000d74:	01813023          	sd	s8,0(sp)
    80000d78:	00050b93          	mv	s7,a0
    80000d7c:	00058413          	mv	s0,a1
    80000d80:	00000993          	li	s3,0
    80000d84:	001b6a13          	ori	s4,s6,1
    80000d88:	35f9091b          	addiw	s2,s2,863 # 3c6ef35f <STACK_SIZE+0x3c6e735f>
    80000d8c:	0394849b          	addiw	s1,s1,57 # 3039 <STACK_SIZE-0x4fc7>
    80000d90:	002b971b          	slliw	a4,s7,0x2
    80000d94:	0177073b          	addw	a4,a4,s7
    80000d98:	0067179b          	slliw	a5,a4,0x6
    80000d9c:	40e787bb          	subw	a5,a5,a4
    80000da0:	0027979b          	slliw	a5,a5,0x2
    80000da4:	017787bb          	addw	a5,a5,s7
    80000da8:	0057971b          	slliw	a4,a5,0x5
    80000dac:	00e787bb          	addw	a5,a5,a4
    80000db0:	0037979b          	slliw	a5,a5,0x3
    80000db4:	017787bb          	addw	a5,a5,s7
    80000db8:	0027971b          	slliw	a4,a5,0x2
    80000dbc:	00e787bb          	addw	a5,a5,a4
    80000dc0:	001aec13          	ori	s8,s5,1
    80000dc4:	0127853b          	addw	a0,a5,s2
    80000dc8:	020c1c13          	slli	s8,s8,0x20
    80000dcc:	020c5c13          	srli	s8,s8,0x20
    80000dd0:	02051513          	slli	a0,a0,0x20
    80000dd4:	000c0593          	mv	a1,s8
    80000dd8:	02055513          	srli	a0,a0,0x20
    80000ddc:	6a0000ef          	jal	8000147c <__hidden___udivdi3>
    80000de0:	020a1593          	slli	a1,s4,0x20
    80000de4:	02051513          	slli	a0,a0,0x20
    80000de8:	0205d593          	srli	a1,a1,0x20
    80000dec:	02055513          	srli	a0,a0,0x20
    80000df0:	6d4000ef          	jal	800014c4 <__umoddi3>
    80000df4:	002b171b          	slliw	a4,s6,0x2
    80000df8:	0167073b          	addw	a4,a4,s6
    80000dfc:	0037171b          	slliw	a4,a4,0x3
    80000e00:	0167073b          	addw	a4,a4,s6
    80000e04:	0047171b          	slliw	a4,a4,0x4
    80000e08:	0167073b          	addw	a4,a4,s6
    80000e0c:	0077179b          	slliw	a5,a4,0x7
    80000e10:	40e787bb          	subw	a5,a5,a4
    80000e14:	0027979b          	slliw	a5,a5,0x2
    80000e18:	016787bb          	addw	a5,a5,s6
    80000e1c:	0047971b          	slliw	a4,a5,0x4
    80000e20:	00e787bb          	addw	a5,a5,a4
    80000e24:	00050a1b          	sext.w	s4,a0
    80000e28:	0027979b          	slliw	a5,a5,0x2
    80000e2c:	0167853b          	addw	a0,a5,s6
    80000e30:	001a6b93          	ori	s7,s4,1
    80000e34:	0015051b          	addiw	a0,a0,1
    80000e38:	020b9b93          	slli	s7,s7,0x20
    80000e3c:	020bdb93          	srli	s7,s7,0x20
    80000e40:	02051513          	slli	a0,a0,0x20
    80000e44:	000b8593          	mv	a1,s7
    80000e48:	02055513          	srli	a0,a0,0x20
    80000e4c:	630000ef          	jal	8000147c <__hidden___udivdi3>
    80000e50:	02051513          	slli	a0,a0,0x20
    80000e54:	000c0593          	mv	a1,s8
    80000e58:	02055513          	srli	a0,a0,0x20
    80000e5c:	668000ef          	jal	800014c4 <__umoddi3>
    80000e60:	008a979b          	slliw	a5,s5,0x8
    80000e64:	415787bb          	subw	a5,a5,s5
    80000e68:	0037979b          	slliw	a5,a5,0x3
    80000e6c:	015787bb          	addw	a5,a5,s5
    80000e70:	0077979b          	slliw	a5,a5,0x7
    80000e74:	015787bb          	addw	a5,a5,s5
    80000e78:	0037979b          	slliw	a5,a5,0x3
    80000e7c:	415787bb          	subw	a5,a5,s5
    80000e80:	0057971b          	slliw	a4,a5,0x5
    80000e84:	00e787bb          	addw	a5,a5,a4
    80000e88:	0027979b          	slliw	a5,a5,0x2
    80000e8c:	415787bb          	subw	a5,a5,s5
    80000e90:	0027979b          	slliw	a5,a5,0x2
    80000e94:	00050b1b          	sext.w	s6,a0
    80000e98:	0157853b          	addw	a0,a5,s5
    80000e9c:	001b6593          	ori	a1,s6,1
    80000ea0:	0095053b          	addw	a0,a0,s1
    80000ea4:	02059593          	slli	a1,a1,0x20
    80000ea8:	02051513          	slli	a0,a0,0x20
    80000eac:	0205d593          	srli	a1,a1,0x20
    80000eb0:	02055513          	srli	a0,a0,0x20
    80000eb4:	5c8000ef          	jal	8000147c <__hidden___udivdi3>
    80000eb8:	02051513          	slli	a0,a0,0x20
    80000ebc:	000b8593          	mv	a1,s7
    80000ec0:	02055513          	srli	a0,a0,0x20
    80000ec4:	600000ef          	jal	800014c4 <__umoddi3>
    80000ec8:	016a45b3          	xor	a1,s4,s6
    80000ecc:	0035d79b          	srliw	a5,a1,0x3
    80000ed0:	00f54a33          	xor	s4,a0,a5
    80000ed4:	01650b3b          	addw	s6,a0,s6
    80000ed8:	000a0a1b          	sext.w	s4,s4
    80000edc:	001b6513          	ori	a0,s6,1
    80000ee0:	001a6a93          	ori	s5,s4,1
    80000ee4:	52c000ef          	jal	80001410 <__muldi3>
    80000ee8:	020a9a93          	slli	s5,s5,0x20
    80000eec:	020ada93          	srli	s5,s5,0x20
    80000ef0:	02051513          	slli	a0,a0,0x20
    80000ef4:	000a8593          	mv	a1,s5
    80000ef8:	02055513          	srli	a0,a0,0x20
    80000efc:	5c8000ef          	jal	800014c4 <__umoddi3>
    80000f00:	00050b93          	mv	s7,a0
    80000f04:	020b1513          	slli	a0,s6,0x20
    80000f08:	000a8593          	mv	a1,s5
    80000f0c:	02055513          	srli	a0,a0,0x20
    80000f10:	000b8b9b          	sext.w	s7,s7
    80000f14:	568000ef          	jal	8000147c <__hidden___udivdi3>
    80000f18:	001bea93          	ori	s5,s7,1
    80000f1c:	020a9593          	slli	a1,s5,0x20
    80000f20:	02051513          	slli	a0,a0,0x20
    80000f24:	0205d593          	srli	a1,a1,0x20
    80000f28:	02055513          	srli	a0,a0,0x20
    80000f2c:	598000ef          	jal	800014c4 <__umoddi3>
    80000f30:	00050b13          	mv	s6,a0
    80000f34:	000a0593          	mv	a1,s4
    80000f38:	000a8513          	mv	a0,s5
    80000f3c:	000b0b1b          	sext.w	s6,s6
    80000f40:	4d0000ef          	jal	80001410 <__muldi3>
    80000f44:	001b6a13          	ori	s4,s6,1
    80000f48:	020a1593          	slli	a1,s4,0x20
    80000f4c:	02051513          	slli	a0,a0,0x20
    80000f50:	0205d593          	srli	a1,a1,0x20
    80000f54:	02055513          	srli	a0,a0,0x20
    80000f58:	56c000ef          	jal	800014c4 <__umoddi3>
    80000f5c:	0019899b          	addiw	s3,s3,1
    80000f60:	00050a9b          	sext.w	s5,a0
    80000f64:	e33416e3          	bne	s0,s3,80000d90 <_Z13heavy_rng_modji+0x60>
    80000f68:	04013403          	ld	s0,64(sp)
    80000f6c:	04813083          	ld	ra,72(sp)
    80000f70:	016bc533          	xor	a0,s7,s6
    80000f74:	03813483          	ld	s1,56(sp)
    80000f78:	03013903          	ld	s2,48(sp)
    80000f7c:	02813983          	ld	s3,40(sp)
    80000f80:	02013a03          	ld	s4,32(sp)
    80000f84:	00813b83          	ld	s7,8(sp)
    80000f88:	00013c03          	ld	s8,0(sp)
    80000f8c:	01013b03          	ld	s6,16(sp)
    80000f90:	00aac533          	xor	a0,s5,a0
    80000f94:	01813a83          	ld	s5,24(sp)
    80000f98:	05010113          	addi	sp,sp,80
    80000f9c:	00008067          	ret
    80000fa0:	04813083          	ld	ra,72(sp)
    80000fa4:	00078513          	mv	a0,a5
    80000fa8:	01013b03          	ld	s6,16(sp)
    80000fac:	00aac533          	xor	a0,s5,a0
    80000fb0:	01813a83          	ld	s5,24(sp)
    80000fb4:	05010113          	addi	sp,sp,80
    80000fb8:	00008067          	ret

0000000080000fbc <main>:
    80000fbc:	f1010113          	addi	sp,sp,-240
    80000fc0:	1357a737          	lui	a4,0x1357a
    80000fc4:	3c6ef5b7          	lui	a1,0x3c6ef
    80000fc8:	0e113423          	sd	ra,232(sp)
    80000fcc:	0e813023          	sd	s0,224(sp)
    80000fd0:	0d413023          	sd	s4,192(sp)
    80000fd4:	03010613          	addi	a2,sp,48
    80000fd8:	0b010513          	addi	a0,sp,176
    80000fdc:	bdf70713          	addi	a4,a4,-1057 # 13579bdf <STACK_SIZE+0x13571bdf>
    80000fe0:	35f5859b          	addiw	a1,a1,863 # 3c6ef35f <STACK_SIZE+0x3c6e735f>
    80000fe4:	0027169b          	slliw	a3,a4,0x2
    80000fe8:	00e686bb          	addw	a3,a3,a4
    80000fec:	0066979b          	slliw	a5,a3,0x6
    80000ff0:	40d787bb          	subw	a5,a5,a3
    80000ff4:	0027979b          	slliw	a5,a5,0x2
    80000ff8:	00e787bb          	addw	a5,a5,a4
    80000ffc:	0057969b          	slliw	a3,a5,0x5
    80001000:	00d787bb          	addw	a5,a5,a3
    80001004:	0037979b          	slliw	a5,a5,0x3
    80001008:	00e787bb          	addw	a5,a5,a4
    8000100c:	0027971b          	slliw	a4,a5,0x2
    80001010:	00e787bb          	addw	a5,a5,a4
    80001014:	00b787bb          	addw	a5,a5,a1
    80001018:	0187d71b          	srliw	a4,a5,0x18
    8000101c:	00e60023          	sb	a4,0(a2)
    80001020:	00160613          	addi	a2,a2,1
    80001024:	0007871b          	sext.w	a4,a5
    80001028:	fac51ee3          	bne	a0,a2,80000fe4 <main+0x28>
    8000102c:	406006b7          	lui	a3,0x40600
    80001030:	04100713          	li	a4,65
    80001034:	00000797          	auipc	a5,0x0
    80001038:	50c78793          	addi	a5,a5,1292 # 80001540 <__moddi3+0x48>
    8000103c:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001040:	00178793          	addi	a5,a5,1
    80001044:	00e68023          	sb	a4,0(a3)
    80001048:	0007c703          	lbu	a4,0(a5)
    8000104c:	fe071ae3          	bnez	a4,80001040 <main+0x84>
    80001050:	406006b7          	lui	a3,0x40600
    80001054:	00013423          	sd	zero,8(sp)
    80001058:	00013823          	sd	zero,16(sp)
    8000105c:	00013c23          	sd	zero,24(sp)
    80001060:	02013023          	sd	zero,32(sp)
    80001064:	05200713          	li	a4,82
    80001068:	00000797          	auipc	a5,0x0
    8000106c:	50078793          	addi	a5,a5,1280 # 80001568 <__moddi3+0x70>
    80001070:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001074:	00178793          	addi	a5,a5,1
    80001078:	00e68023          	sb	a4,0(a3)
    8000107c:	0007c703          	lbu	a4,0(a5)
    80001080:	fe071ae3          	bnez	a4,80001074 <main+0xb8>
    80001084:	406006b7          	lui	a3,0x40600
    80001088:	05b00713          	li	a4,91
    8000108c:	00000797          	auipc	a5,0x0
    80001090:	50478793          	addi	a5,a5,1284 # 80001590 <__moddi3+0x98>
    80001094:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001098:	00178793          	addi	a5,a5,1
    8000109c:	00e68023          	sb	a4,0(a3)
    800010a0:	0007c703          	lbu	a4,0(a5)
    800010a4:	fe071ae3          	bnez	a4,80001098 <main+0xdc>
    800010a8:	01000713          	li	a4,16
    800010ac:	00810693          	addi	a3,sp,8
    800010b0:	00000617          	auipc	a2,0x0
    800010b4:	70060613          	addi	a2,a2,1792 # 800017b0 <_ZZL20runCorrectnessChecksvE2pt>
    800010b8:	01000593          	li	a1,16
    800010bc:	00000517          	auipc	a0,0x0
    800010c0:	70450513          	addi	a0,a0,1796 # 800017c0 <_ZZL20runCorrectnessChecksvE3key>
    800010c4:	fd4ff0ef          	jal	80000898 <_Z10aesEncryptPKcjS0_Pcj>
    800010c8:	32051063          	bnez	a0,800013e8 <main+0x42c>
    800010cc:	00810793          	addi	a5,sp,8
    800010d0:	00000717          	auipc	a4,0x0
    800010d4:	70070713          	addi	a4,a4,1792 # 800017d0 <_ZZL20runCorrectnessChecksvE10expectedCt>
    800010d8:	01810a13          	addi	s4,sp,24
    800010dc:	0080006f          	j	800010e4 <main+0x128>
    800010e0:	02fa0e63          	beq	s4,a5,8000111c <main+0x160>
    800010e4:	0007c603          	lbu	a2,0(a5)
    800010e8:	00074683          	lbu	a3,0(a4)
    800010ec:	00178793          	addi	a5,a5,1
    800010f0:	00170713          	addi	a4,a4,1
    800010f4:	fed606e3          	beq	a2,a3,800010e0 <main+0x124>
    800010f8:	00000797          	auipc	a5,0x0
    800010fc:	4e878793          	addi	a5,a5,1256 # 800015e0 <__moddi3+0xe8>
    80001100:	0007c683          	lbu	a3,0(a5)
    80001104:	40600737          	lui	a4,0x40600
    80001108:	00470713          	addi	a4,a4,4 # 40600004 <STACK_SIZE+0x405f8004>
    8000110c:	2a068863          	beqz	a3,800013bc <main+0x400>
    80001110:	00178793          	addi	a5,a5,1
    80001114:	00d70023          	sb	a3,0(a4)
    80001118:	fe9ff06f          	j	80001100 <main+0x144>
    8000111c:	406006b7          	lui	a3,0x40600
    80001120:	0d213823          	sd	s2,208(sp)
    80001124:	05b00713          	li	a4,91
    80001128:	00000797          	auipc	a5,0x0
    8000112c:	4e078793          	addi	a5,a5,1248 # 80001608 <__moddi3+0x110>
    80001130:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001134:	00178793          	addi	a5,a5,1
    80001138:	00e68023          	sb	a4,0(a3)
    8000113c:	0007c703          	lbu	a4,0(a5)
    80001140:	fe071ae3          	bnez	a4,80001134 <main+0x178>
    80001144:	406006b7          	lui	a3,0x40600
    80001148:	05b00713          	li	a4,91
    8000114c:	00000797          	auipc	a5,0x0
    80001150:	4ec78793          	addi	a5,a5,1260 # 80001638 <__moddi3+0x140>
    80001154:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001158:	00178793          	addi	a5,a5,1
    8000115c:	00e68023          	sb	a4,0(a3)
    80001160:	0007c703          	lbu	a4,0(a5)
    80001164:	fe071ae3          	bnez	a4,80001158 <main+0x19c>
    80001168:	01000713          	li	a4,16
    8000116c:	000a0693          	mv	a3,s4
    80001170:	00810613          	addi	a2,sp,8
    80001174:	01000593          	li	a1,16
    80001178:	00000517          	auipc	a0,0x0
    8000117c:	64850513          	addi	a0,a0,1608 # 800017c0 <_ZZL20runCorrectnessChecksvE3key>
    80001180:	965ff0ef          	jal	80000ae4 <_Z10aesDecryptPKcjS0_Pcj>
    80001184:	00050913          	mv	s2,a0
    80001188:	20051663          	bnez	a0,80001394 <main+0x3d8>
    8000118c:	000a0793          	mv	a5,s4
    80001190:	00000717          	auipc	a4,0x0
    80001194:	62070713          	addi	a4,a4,1568 # 800017b0 <_ZZL20runCorrectnessChecksvE2pt>
    80001198:	02810593          	addi	a1,sp,40
    8000119c:	0080006f          	j	800011a4 <main+0x1e8>
    800011a0:	02f58e63          	beq	a1,a5,800011dc <main+0x220>
    800011a4:	0007c603          	lbu	a2,0(a5)
    800011a8:	00074683          	lbu	a3,0(a4)
    800011ac:	00178793          	addi	a5,a5,1
    800011b0:	00170713          	addi	a4,a4,1
    800011b4:	fed606e3          	beq	a2,a3,800011a0 <main+0x1e4>
    800011b8:	00000797          	auipc	a5,0x0
    800011bc:	4d078793          	addi	a5,a5,1232 # 80001688 <__moddi3+0x190>
    800011c0:	0007c683          	lbu	a3,0(a5)
    800011c4:	40600737          	lui	a4,0x40600
    800011c8:	00470713          	addi	a4,a4,4 # 40600004 <STACK_SIZE+0x405f8004>
    800011cc:	1e068663          	beqz	a3,800013b8 <main+0x3fc>
    800011d0:	00178793          	addi	a5,a5,1
    800011d4:	00d70023          	sb	a3,0(a4)
    800011d8:	fe9ff06f          	j	800011c0 <main+0x204>
    800011dc:	406006b7          	lui	a3,0x40600
    800011e0:	0c913c23          	sd	s1,216(sp)
    800011e4:	0d313423          	sd	s3,200(sp)
    800011e8:	0b513c23          	sd	s5,184(sp)
    800011ec:	0b613823          	sd	s6,176(sp)
    800011f0:	05b00713          	li	a4,91
    800011f4:	00000797          	auipc	a5,0x0
    800011f8:	4bc78793          	addi	a5,a5,1212 # 800016b0 <__moddi3+0x1b8>
    800011fc:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001200:	00178793          	addi	a5,a5,1
    80001204:	00e68023          	sb	a4,0(a3)
    80001208:	0007c703          	lbu	a4,0(a5)
    8000120c:	fe071ae3          	bnez	a4,80001200 <main+0x244>
    80001210:	406006b7          	lui	a3,0x40600
    80001214:	05b00713          	li	a4,91
    80001218:	00000797          	auipc	a5,0x0
    8000121c:	4c878793          	addi	a5,a5,1224 # 800016e0 <__moddi3+0x1e8>
    80001220:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001224:	00178793          	addi	a5,a5,1
    80001228:	00e68023          	sb	a4,0(a3)
    8000122c:	0007c703          	lbu	a4,0(a5)
    80001230:	fe071ae3          	bnez	a4,80001224 <main+0x268>
    80001234:	200034b7          	lui	s1,0x20003
    80001238:	0004bb03          	ld	s6,0(s1) # 20003000 <STACK_SIZE+0x1fffb000>
    8000123c:	0004b503          	ld	a0,0(s1)
    80001240:	3e800593          	li	a1,1000
    80001244:	0005051b          	sext.w	a0,a0
    80001248:	ae9ff0ef          	jal	80000d30 <_Z13heavy_rng_modji>
    8000124c:	0004ba83          	ld	s5,0(s1)
    80001250:	406006b7          	lui	a3,0x40600
    80001254:	0005041b          	sext.w	s0,a0
    80001258:	05b00713          	li	a4,91
    8000125c:	00000797          	auipc	a5,0x0
    80001260:	4dc78793          	addi	a5,a5,1244 # 80001738 <__moddi3+0x240>
    80001264:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001268:	00178793          	addi	a5,a5,1
    8000126c:	00e68023          	sb	a4,0(a3)
    80001270:	0007c703          	lbu	a4,0(a5)
    80001274:	fe071ae3          	bnez	a4,80001268 <main+0x2ac>
    80001278:	10044663          	bltz	s0,80001384 <main+0x3c8>
    8000127c:	000a0993          	mv	s3,s4
    80001280:	00a00593          	li	a1,10
    80001284:	00040513          	mv	a0,s0
    80001288:	270000ef          	jal	800014f8 <__moddi3>
    8000128c:	0305079b          	addiw	a5,a0,48
    80001290:	00f98023          	sb	a5,0(s3)
    80001294:	00040513          	mv	a0,s0
    80001298:	00a00593          	li	a1,10
    8000129c:	1d8000ef          	jal	80001474 <__divdi3>
    800012a0:	0005041b          	sext.w	s0,a0
    800012a4:	00090493          	mv	s1,s2
    800012a8:	00198993          	addi	s3,s3,1
    800012ac:	0019091b          	addiw	s2,s2,1
    800012b0:	fc0418e3          	bnez	s0,80001280 <main+0x2c4>
    800012b4:	406006b7          	lui	a3,0x40600
    800012b8:	009a07b3          	add	a5,s4,s1
    800012bc:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    800012c0:	fffa0a13          	addi	s4,s4,-1
    800012c4:	0007c703          	lbu	a4,0(a5)
    800012c8:	fff78793          	addi	a5,a5,-1
    800012cc:	00e68023          	sb	a4,0(a3)
    800012d0:	ff479ae3          	bne	a5,s4,800012c4 <main+0x308>
    800012d4:	40600937          	lui	s2,0x40600
    800012d8:	02c00713          	li	a4,44
    800012dc:	00000797          	auipc	a5,0x0
    800012e0:	47c78793          	addi	a5,a5,1148 # 80001758 <__moddi3+0x260>
    800012e4:	00490913          	addi	s2,s2,4 # 40600004 <STACK_SIZE+0x405f8004>
    800012e8:	00178793          	addi	a5,a5,1
    800012ec:	00e90023          	sb	a4,0(s2)
    800012f0:	0007c703          	lbu	a4,0(a5)
    800012f4:	fe071ae3          	bnez	a4,800012e8 <main+0x32c>
    800012f8:	416a8ab3          	sub	s5,s5,s6
    800012fc:	000a8513          	mv	a0,s5
    80001300:	d4dfe0ef          	jal	8000004c <_Z5put_iIyEvT_>
    80001304:	00a00793          	li	a5,10
    80001308:	406004b7          	lui	s1,0x40600
    8000130c:	00f90023          	sb	a5,0(s2)
    80001310:	05b00713          	li	a4,91
    80001314:	00000797          	auipc	a5,0x0
    80001318:	45478793          	addi	a5,a5,1108 # 80001768 <__moddi3+0x270>
    8000131c:	00448493          	addi	s1,s1,4 # 40600004 <STACK_SIZE+0x405f8004>
    80001320:	00178793          	addi	a5,a5,1
    80001324:	00e48023          	sb	a4,0(s1)
    80001328:	0007c703          	lbu	a4,0(a5)
    8000132c:	fe071ae3          	bnez	a4,80001320 <main+0x364>
    80001330:	3e800593          	li	a1,1000
    80001334:	000a8513          	mv	a0,s5
    80001338:	144000ef          	jal	8000147c <__hidden___udivdi3>
    8000133c:	00050593          	mv	a1,a0
    80001340:	000f4537          	lui	a0,0xf4
    80001344:	24050513          	addi	a0,a0,576 # f4240 <STACK_SIZE+0xec240>
    80001348:	134000ef          	jal	8000147c <__hidden___udivdi3>
    8000134c:	d01fe0ef          	jal	8000004c <_Z5put_iIyEvT_>
    80001350:	00a00793          	li	a5,10
    80001354:	00f48023          	sb	a5,0(s1)
    80001358:	0d813483          	ld	s1,216(sp)
    8000135c:	0d013903          	ld	s2,208(sp)
    80001360:	0c813983          	ld	s3,200(sp)
    80001364:	0b813a83          	ld	s5,184(sp)
    80001368:	0b013b03          	ld	s6,176(sp)
    8000136c:	0e813083          	ld	ra,232(sp)
    80001370:	00040513          	mv	a0,s0
    80001374:	0e013403          	ld	s0,224(sp)
    80001378:	0c013a03          	ld	s4,192(sp)
    8000137c:	0f010113          	addi	sp,sp,240
    80001380:	00008067          	ret
    80001384:	02d00793          	li	a5,45
    80001388:	00f68023          	sb	a5,0(a3)
    8000138c:	4080043b          	negw	s0,s0
    80001390:	eedff06f          	j	8000127c <main+0x2c0>
    80001394:	406006b7          	lui	a3,0x40600
    80001398:	00000797          	auipc	a5,0x0
    8000139c:	2c878793          	addi	a5,a5,712 # 80001660 <__moddi3+0x168>
    800013a0:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    800013a4:	0080006f          	j	800013ac <main+0x3f0>
    800013a8:	00e68023          	sb	a4,0(a3)
    800013ac:	0007c703          	lbu	a4,0(a5)
    800013b0:	00178793          	addi	a5,a5,1
    800013b4:	fe071ae3          	bnez	a4,800013a8 <main+0x3ec>
    800013b8:	0d013903          	ld	s2,208(sp)
    800013bc:	406006b7          	lui	a3,0x40600
    800013c0:	00000797          	auipc	a5,0x0
    800013c4:	34878793          	addi	a5,a5,840 # 80001708 <__moddi3+0x210>
    800013c8:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    800013cc:	0080006f          	j	800013d4 <main+0x418>
    800013d0:	00e68023          	sb	a4,0(a3)
    800013d4:	0007c703          	lbu	a4,0(a5)
    800013d8:	00178793          	addi	a5,a5,1
    800013dc:	fe071ae3          	bnez	a4,800013d0 <main+0x414>
    800013e0:	fff00413          	li	s0,-1
    800013e4:	f89ff06f          	j	8000136c <main+0x3b0>
    800013e8:	406006b7          	lui	a3,0x40600
    800013ec:	00000797          	auipc	a5,0x0
    800013f0:	1cc78793          	addi	a5,a5,460 # 800015b8 <__moddi3+0xc0>
    800013f4:	00468693          	addi	a3,a3,4 # 40600004 <STACK_SIZE+0x405f8004>
    800013f8:	0080006f          	j	80001400 <main+0x444>
    800013fc:	00e68023          	sb	a4,0(a3)
    80001400:	0007c703          	lbu	a4,0(a5)
    80001404:	00178793          	addi	a5,a5,1
    80001408:	fe071ae3          	bnez	a4,800013fc <main+0x440>
    8000140c:	fb1ff06f          	j	800013bc <main+0x400>

0000000080001410 <__muldi3>:
    80001410:	00050613          	mv	a2,a0
    80001414:	00000513          	li	a0,0
    80001418:	0015f693          	andi	a3,a1,1
    8000141c:	00068463          	beqz	a3,80001424 <__muldi3+0x14>
    80001420:	00c50533          	add	a0,a0,a2
    80001424:	0015d593          	srli	a1,a1,0x1
    80001428:	00161613          	slli	a2,a2,0x1
    8000142c:	fe0596e3          	bnez	a1,80001418 <__muldi3+0x8>
    80001430:	00008067          	ret

0000000080001434 <__udivsi3>:
    80001434:	02051513          	slli	a0,a0,0x20
    80001438:	02059593          	slli	a1,a1,0x20
    8000143c:	00008293          	mv	t0,ra
    80001440:	03c000ef          	jal	8000147c <__hidden___udivdi3>
    80001444:	0005051b          	sext.w	a0,a0
    80001448:	00028067          	jr	t0

000000008000144c <__umodsi3>:
    8000144c:	02051513          	slli	a0,a0,0x20
    80001450:	02059593          	slli	a1,a1,0x20
    80001454:	02055513          	srli	a0,a0,0x20
    80001458:	0205d593          	srli	a1,a1,0x20
    8000145c:	00008293          	mv	t0,ra
    80001460:	01c000ef          	jal	8000147c <__hidden___udivdi3>
    80001464:	0005851b          	sext.w	a0,a1
    80001468:	00028067          	jr	t0

000000008000146c <__divsi3>:
    8000146c:	fff00293          	li	t0,-1
    80001470:	0a558c63          	beq	a1,t0,80001528 <__moddi3+0x30>

0000000080001474 <__divdi3>:
    80001474:	06054063          	bltz	a0,800014d4 <__umoddi3+0x10>
    80001478:	0605c663          	bltz	a1,800014e4 <__umoddi3+0x20>

000000008000147c <__hidden___udivdi3>:
    8000147c:	00058613          	mv	a2,a1
    80001480:	00050593          	mv	a1,a0
    80001484:	fff00513          	li	a0,-1
    80001488:	02060c63          	beqz	a2,800014c0 <__hidden___udivdi3+0x44>
    8000148c:	00100693          	li	a3,1
    80001490:	00b67a63          	bgeu	a2,a1,800014a4 <__hidden___udivdi3+0x28>
    80001494:	00c05863          	blez	a2,800014a4 <__hidden___udivdi3+0x28>
    80001498:	00161613          	slli	a2,a2,0x1
    8000149c:	00169693          	slli	a3,a3,0x1
    800014a0:	feb66ae3          	bltu	a2,a1,80001494 <__hidden___udivdi3+0x18>
    800014a4:	00000513          	li	a0,0
    800014a8:	00c5e663          	bltu	a1,a2,800014b4 <__hidden___udivdi3+0x38>
    800014ac:	40c585b3          	sub	a1,a1,a2
    800014b0:	00d56533          	or	a0,a0,a3
    800014b4:	0016d693          	srli	a3,a3,0x1
    800014b8:	00165613          	srli	a2,a2,0x1
    800014bc:	fe0696e3          	bnez	a3,800014a8 <__hidden___udivdi3+0x2c>
    800014c0:	00008067          	ret

00000000800014c4 <__umoddi3>:
    800014c4:	00008293          	mv	t0,ra
    800014c8:	fb5ff0ef          	jal	8000147c <__hidden___udivdi3>
    800014cc:	00058513          	mv	a0,a1
    800014d0:	00028067          	jr	t0
    800014d4:	40a00533          	neg	a0,a0
    800014d8:	00b04863          	bgtz	a1,800014e8 <__umoddi3+0x24>
    800014dc:	40b005b3          	neg	a1,a1
    800014e0:	f9dff06f          	j	8000147c <__hidden___udivdi3>
    800014e4:	40b005b3          	neg	a1,a1
    800014e8:	00008293          	mv	t0,ra
    800014ec:	f91ff0ef          	jal	8000147c <__hidden___udivdi3>
    800014f0:	40a00533          	neg	a0,a0
    800014f4:	00028067          	jr	t0

00000000800014f8 <__moddi3>:
    800014f8:	00008293          	mv	t0,ra
    800014fc:	0005ca63          	bltz	a1,80001510 <__moddi3+0x18>
    80001500:	00054c63          	bltz	a0,80001518 <__moddi3+0x20>
    80001504:	f79ff0ef          	jal	8000147c <__hidden___udivdi3>
    80001508:	00058513          	mv	a0,a1
    8000150c:	00028067          	jr	t0
    80001510:	40b005b3          	neg	a1,a1
    80001514:	fe0558e3          	bgez	a0,80001504 <__moddi3+0xc>
    80001518:	40a00533          	neg	a0,a0
    8000151c:	f61ff0ef          	jal	8000147c <__hidden___udivdi3>
    80001520:	40b00533          	neg	a0,a1
    80001524:	00028067          	jr	t0
    80001528:	01f29293          	slli	t0,t0,0x1f
    8000152c:	f45514e3          	bne	a0,t0,80001474 <__divdi3>
    80001530:	00008067          	ret
