
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	addi	sp,sp,-1776 # 80007910 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbbf>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e0078793          	addi	a5,a5,-512 # 80000e84 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	711d                	addi	sp,sp,-96
    800000d6:	ec86                	sd	ra,88(sp)
    800000d8:	e8a2                	sd	s0,80(sp)
    800000da:	e0ca                	sd	s2,64(sp)
    800000dc:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    800000de:	04c05863          	blez	a2,8000012e <consolewrite+0x5a>
    800000e2:	e4a6                	sd	s1,72(sp)
    800000e4:	fc4e                	sd	s3,56(sp)
    800000e6:	f852                	sd	s4,48(sp)
    800000e8:	f456                	sd	s5,40(sp)
    800000ea:	f05a                	sd	s6,32(sp)
    800000ec:	ec5e                	sd	s7,24(sp)
    800000ee:	8a2a                	mv	s4,a0
    800000f0:	84ae                	mv	s1,a1
    800000f2:	89b2                	mv	s3,a2
    800000f4:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000f6:	faf40b93          	addi	s7,s0,-81
    800000fa:	4b05                	li	s6,1
    800000fc:	5afd                	li	s5,-1
    800000fe:	86da                	mv	a3,s6
    80000100:	8626                	mv	a2,s1
    80000102:	85d2                	mv	a1,s4
    80000104:	855e                	mv	a0,s7
    80000106:	144020ef          	jal	8000224a <either_copyin>
    8000010a:	03550463          	beq	a0,s5,80000132 <consolewrite+0x5e>
      break;
    uartputc(c);
    8000010e:	faf44503          	lbu	a0,-81(s0)
    80000112:	02d000ef          	jal	8000093e <uartputc>
  for(i = 0; i < n; i++){
    80000116:	2905                	addiw	s2,s2,1
    80000118:	0485                	addi	s1,s1,1
    8000011a:	ff2992e3          	bne	s3,s2,800000fe <consolewrite+0x2a>
    8000011e:	894e                	mv	s2,s3
    80000120:	64a6                	ld	s1,72(sp)
    80000122:	79e2                	ld	s3,56(sp)
    80000124:	7a42                	ld	s4,48(sp)
    80000126:	7aa2                	ld	s5,40(sp)
    80000128:	7b02                	ld	s6,32(sp)
    8000012a:	6be2                	ld	s7,24(sp)
    8000012c:	a809                	j	8000013e <consolewrite+0x6a>
    8000012e:	4901                	li	s2,0
    80000130:	a039                	j	8000013e <consolewrite+0x6a>
    80000132:	64a6                	ld	s1,72(sp)
    80000134:	79e2                	ld	s3,56(sp)
    80000136:	7a42                	ld	s4,48(sp)
    80000138:	7aa2                	ld	s5,40(sp)
    8000013a:	7b02                	ld	s6,32(sp)
    8000013c:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60e6                	ld	ra,88(sp)
    80000142:	6446                	ld	s0,80(sp)
    80000144:	6906                	ld	s2,64(sp)
    80000146:	6125                	addi	sp,sp,96
    80000148:	8082                	ret

000000008000014a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014a:	711d                	addi	sp,sp,-96
    8000014c:	ec86                	sd	ra,88(sp)
    8000014e:	e8a2                	sd	s0,80(sp)
    80000150:	e4a6                	sd	s1,72(sp)
    80000152:	e0ca                	sd	s2,64(sp)
    80000154:	fc4e                	sd	s3,56(sp)
    80000156:	f852                	sd	s4,48(sp)
    80000158:	f456                	sd	s5,40(sp)
    8000015a:	f05a                	sd	s6,32(sp)
    8000015c:	1080                	addi	s0,sp,96
    8000015e:	8aaa                	mv	s5,a0
    80000160:	8a2e                	mv	s4,a1
    80000162:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000164:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000166:	0000f517          	auipc	a0,0xf
    8000016a:	7aa50513          	addi	a0,a0,1962 # 8000f910 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	0000f497          	auipc	s1,0xf
    80000176:	79e48493          	addi	s1,s1,1950 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00010917          	auipc	s2,0x10
    8000017e:	82e90913          	addi	s2,s2,-2002 # 8000f9a8 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	74d010ef          	jal	800020e2 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	50b010ef          	jal	80001eaa <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	0000f717          	auipc	a4,0xf
    800001b6:	75e70713          	addi	a4,a4,1886 # 8000f910 <cons>
    800001ba:	0017869b          	addiw	a3,a5,1
    800001be:	08d72c23          	sw	a3,152(a4)
    800001c2:	07f7f693          	andi	a3,a5,127
    800001c6:	9736                	add	a4,a4,a3
    800001c8:	01874703          	lbu	a4,24(a4)
    800001cc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001d0:	4691                	li	a3,4
    800001d2:	04db8663          	beq	s7,a3,8000021e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001d6:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001da:	4685                	li	a3,1
    800001dc:	faf40613          	addi	a2,s0,-81
    800001e0:	85d2                	mv	a1,s4
    800001e2:	8556                	mv	a0,s5
    800001e4:	01c020ef          	jal	80002200 <either_copyout>
    800001e8:	57fd                	li	a5,-1
    800001ea:	04f50663          	beq	a0,a5,80000236 <consoleread+0xec>
      break;

    dst++;
    800001ee:	0a05                	addi	s4,s4,1
    --n;
    800001f0:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001f2:	47a9                	li	a5,10
    800001f4:	04fb8b63          	beq	s7,a5,8000024a <consoleread+0x100>
    800001f8:	6be2                	ld	s7,24(sp)
    800001fa:	b761                	j	80000182 <consoleread+0x38>
        release(&cons.lock);
    800001fc:	0000f517          	auipc	a0,0xf
    80000200:	71450513          	addi	a0,a0,1812 # 8000f910 <cons>
    80000204:	28f000ef          	jal	80000c92 <release>
        return -1;
    80000208:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000020a:	60e6                	ld	ra,88(sp)
    8000020c:	6446                	ld	s0,80(sp)
    8000020e:	64a6                	ld	s1,72(sp)
    80000210:	6906                	ld	s2,64(sp)
    80000212:	79e2                	ld	s3,56(sp)
    80000214:	7a42                	ld	s4,48(sp)
    80000216:	7aa2                	ld	s5,40(sp)
    80000218:	7b02                	ld	s6,32(sp)
    8000021a:	6125                	addi	sp,sp,96
    8000021c:	8082                	ret
      if(n < target){
    8000021e:	0169fa63          	bgeu	s3,s6,80000232 <consoleread+0xe8>
        cons.r--;
    80000222:	0000f717          	auipc	a4,0xf
    80000226:	78f72323          	sw	a5,1926(a4) # 8000f9a8 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	0000f517          	auipc	a0,0xf
    8000023c:	6d850513          	addi	a0,a0,1752 # 8000f910 <cons>
    80000240:	253000ef          	jal	80000c92 <release>
  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	b7c9                	j	8000020a <consoleread+0xc0>
    8000024a:	6be2                	ld	s7,24(sp)
    8000024c:	b7f5                	j	80000238 <consoleread+0xee>

000000008000024e <consputc>:
{
    8000024e:	1141                	addi	sp,sp,-16
    80000250:	e406                	sd	ra,8(sp)
    80000252:	e022                	sd	s0,0(sp)
    80000254:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000256:	10000793          	li	a5,256
    8000025a:	00f50863          	beq	a0,a5,8000026a <consputc+0x1c>
    uartputc_sync(c);
    8000025e:	5fe000ef          	jal	8000085c <uartputc_sync>
}
    80000262:	60a2                	ld	ra,8(sp)
    80000264:	6402                	ld	s0,0(sp)
    80000266:	0141                	addi	sp,sp,16
    80000268:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000026a:	4521                	li	a0,8
    8000026c:	5f0000ef          	jal	8000085c <uartputc_sync>
    80000270:	02000513          	li	a0,32
    80000274:	5e8000ef          	jal	8000085c <uartputc_sync>
    80000278:	4521                	li	a0,8
    8000027a:	5e2000ef          	jal	8000085c <uartputc_sync>
    8000027e:	b7d5                	j	80000262 <consputc+0x14>

0000000080000280 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000280:	7179                	addi	sp,sp,-48
    80000282:	f406                	sd	ra,40(sp)
    80000284:	f022                	sd	s0,32(sp)
    80000286:	ec26                	sd	s1,24(sp)
    80000288:	1800                	addi	s0,sp,48
    8000028a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000028c:	0000f517          	auipc	a0,0xf
    80000290:	68450513          	addi	a0,a0,1668 # 8000f910 <cons>
    80000294:	16b000ef          	jal	80000bfe <acquire>

  switch(c){
    80000298:	47d5                	li	a5,21
    8000029a:	08f48e63          	beq	s1,a5,80000336 <consoleintr+0xb6>
    8000029e:	0297c563          	blt	a5,s1,800002c8 <consoleintr+0x48>
    800002a2:	47a1                	li	a5,8
    800002a4:	0ef48863          	beq	s1,a5,80000394 <consoleintr+0x114>
    800002a8:	47c1                	li	a5,16
    800002aa:	10f49963          	bne	s1,a5,800003bc <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002ae:	7e7010ef          	jal	80002294 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	0000f517          	auipc	a0,0xf
    800002b6:	65e50513          	addi	a0,a0,1630 # 8000f910 <cons>
    800002ba:	1d9000ef          	jal	80000c92 <release>
}
    800002be:	70a2                	ld	ra,40(sp)
    800002c0:	7402                	ld	s0,32(sp)
    800002c2:	64e2                	ld	s1,24(sp)
    800002c4:	6145                	addi	sp,sp,48
    800002c6:	8082                	ret
  switch(c){
    800002c8:	07f00793          	li	a5,127
    800002cc:	0cf48463          	beq	s1,a5,80000394 <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002d0:	0000f717          	auipc	a4,0xf
    800002d4:	64070713          	addi	a4,a4,1600 # 8000f910 <cons>
    800002d8:	0a072783          	lw	a5,160(a4)
    800002dc:	09872703          	lw	a4,152(a4)
    800002e0:	9f99                	subw	a5,a5,a4
    800002e2:	07f00713          	li	a4,127
    800002e6:	fcf766e3          	bltu	a4,a5,800002b2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002ea:	47b5                	li	a5,13
    800002ec:	0cf48b63          	beq	s1,a5,800003c2 <consoleintr+0x142>
      consputc(c);
    800002f0:	8526                	mv	a0,s1
    800002f2:	f5dff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f6:	0000f797          	auipc	a5,0xf
    800002fa:	61a78793          	addi	a5,a5,1562 # 8000f910 <cons>
    800002fe:	0a07a683          	lw	a3,160(a5)
    80000302:	0016871b          	addiw	a4,a3,1
    80000306:	863a                	mv	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0cf48963          	beq	s1,a5,800003ea <consoleintr+0x16a>
    8000031c:	4791                	li	a5,4
    8000031e:	0cf48663          	beq	s1,a5,800003ea <consoleintr+0x16a>
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	6867a783          	lw	a5,1670(a5) # 8000f9a8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	0000f717          	auipc	a4,0xf
    8000033e:	5d670713          	addi	a4,a4,1494 # 8000f910 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	0000f497          	auipc	s1,0xf
    8000034e:	5c648493          	addi	s1,s1,1478 # 8000f910 <cons>
    while(cons.e != cons.w &&
    80000352:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000354:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000358:	02f70863          	beq	a4,a5,80000388 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000035c:	37fd                	addiw	a5,a5,-1
    8000035e:	07f7f713          	andi	a4,a5,127
    80000362:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000364:	01874703          	lbu	a4,24(a4)
    80000368:	03270363          	beq	a4,s2,8000038e <consoleintr+0x10e>
      cons.e--;
    8000036c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000370:	854e                	mv	a0,s3
    80000372:	eddff0ef          	jal	8000024e <consputc>
    while(cons.e != cons.w &&
    80000376:	0a04a783          	lw	a5,160(s1)
    8000037a:	09c4a703          	lw	a4,156(s1)
    8000037e:	fcf71fe3          	bne	a4,a5,8000035c <consoleintr+0xdc>
    80000382:	6942                	ld	s2,16(sp)
    80000384:	69a2                	ld	s3,8(sp)
    80000386:	b735                	j	800002b2 <consoleintr+0x32>
    80000388:	6942                	ld	s2,16(sp)
    8000038a:	69a2                	ld	s3,8(sp)
    8000038c:	b71d                	j	800002b2 <consoleintr+0x32>
    8000038e:	6942                	ld	s2,16(sp)
    80000390:	69a2                	ld	s3,8(sp)
    80000392:	b705                	j	800002b2 <consoleintr+0x32>
    if(cons.e != cons.w){
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	57c70713          	addi	a4,a4,1404 # 8000f910 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	0000f717          	auipc	a4,0xf
    800003ae:	60f72323          	sw	a5,1542(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    800003b2:	10000513          	li	a0,256
    800003b6:	e99ff0ef          	jal	8000024e <consputc>
    800003ba:	bde5                	j	800002b2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003bc:	ee048be3          	beqz	s1,800002b2 <consoleintr+0x32>
    800003c0:	bf01                	j	800002d0 <consoleintr+0x50>
      consputc(c);
    800003c2:	4529                	li	a0,10
    800003c4:	e8bff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003c8:	0000f797          	auipc	a5,0xf
    800003cc:	54878793          	addi	a5,a5,1352 # 8000f910 <cons>
    800003d0:	0a07a703          	lw	a4,160(a5)
    800003d4:	0017069b          	addiw	a3,a4,1
    800003d8:	8636                	mv	a2,a3
    800003da:	0ad7a023          	sw	a3,160(a5)
    800003de:	07f77713          	andi	a4,a4,127
    800003e2:	97ba                	add	a5,a5,a4
    800003e4:	4729                	li	a4,10
    800003e6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	5cc7a123          	sw	a2,1474(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	0000f517          	auipc	a0,0xf
    800003f6:	5b650513          	addi	a0,a0,1462 # 8000f9a8 <cons+0x98>
    800003fa:	2fd010ef          	jal	80001ef6 <wakeup>
    800003fe:	bd55                	j	800002b2 <consoleintr+0x32>

0000000080000400 <consoleinit>:

void
consoleinit(void)
{
    80000400:	1141                	addi	sp,sp,-16
    80000402:	e406                	sd	ra,8(sp)
    80000404:	e022                	sd	s0,0(sp)
    80000406:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000408:	00007597          	auipc	a1,0x7
    8000040c:	bf858593          	addi	a1,a1,-1032 # 80007000 <etext>
    80000410:	0000f517          	auipc	a0,0xf
    80000414:	50050513          	addi	a0,a0,1280 # 8000f910 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	0001f797          	auipc	a5,0x1f
    80000424:	68878793          	addi	a5,a5,1672 # 8001faa8 <devsw>
    80000428:	00000717          	auipc	a4,0x0
    8000042c:	d2270713          	addi	a4,a4,-734 # 8000014a <consoleread>
    80000430:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000432:	00000717          	auipc	a4,0x0
    80000436:	ca270713          	addi	a4,a4,-862 # 800000d4 <consolewrite>
    8000043a:	ef98                	sd	a4,24(a5)
}
    8000043c:	60a2                	ld	ra,8(sp)
    8000043e:	6402                	ld	s0,0(sp)
    80000440:	0141                	addi	sp,sp,16
    80000442:	8082                	ret

0000000080000444 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000444:	7179                	addi	sp,sp,-48
    80000446:	f406                	sd	ra,40(sp)
    80000448:	f022                	sd	s0,32(sp)
    8000044a:	ec26                	sd	s1,24(sp)
    8000044c:	e84a                	sd	s2,16(sp)
    8000044e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000450:	c219                	beqz	a2,80000456 <printint+0x12>
    80000452:	06054a63          	bltz	a0,800004c6 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000456:	4e01                	li	t3,0

  i = 0;
    80000458:	fd040313          	addi	t1,s0,-48
    x = xx;
    8000045c:	869a                	mv	a3,t1
  i = 0;
    8000045e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000460:	00007817          	auipc	a6,0x7
    80000464:	31080813          	addi	a6,a6,784 # 80007770 <digits>
    80000468:	88be                	mv	a7,a5
    8000046a:	0017861b          	addiw	a2,a5,1
    8000046e:	87b2                	mv	a5,a2
    80000470:	02b57733          	remu	a4,a0,a1
    80000474:	9742                	add	a4,a4,a6
    80000476:	00074703          	lbu	a4,0(a4)
    8000047a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000047e:	872a                	mv	a4,a0
    80000480:	02b55533          	divu	a0,a0,a1
    80000484:	0685                	addi	a3,a3,1
    80000486:	feb771e3          	bgeu	a4,a1,80000468 <printint+0x24>

  if(sign)
    8000048a:	000e0c63          	beqz	t3,800004a2 <printint+0x5e>
    buf[i++] = '-';
    8000048e:	fe060793          	addi	a5,a2,-32
    80000492:	00878633          	add	a2,a5,s0
    80000496:	02d00793          	li	a5,45
    8000049a:	fef60823          	sb	a5,-16(a2)
    8000049e:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004a2:	fff7891b          	addiw	s2,a5,-1
    800004a6:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004aa:	fff4c503          	lbu	a0,-1(s1)
    800004ae:	da1ff0ef          	jal	8000024e <consputc>
  while(--i >= 0)
    800004b2:	397d                	addiw	s2,s2,-1
    800004b4:	14fd                	addi	s1,s1,-1
    800004b6:	fe095ae3          	bgez	s2,800004aa <printint+0x66>
}
    800004ba:	70a2                	ld	ra,40(sp)
    800004bc:	7402                	ld	s0,32(sp)
    800004be:	64e2                	ld	s1,24(sp)
    800004c0:	6942                	ld	s2,16(sp)
    800004c2:	6145                	addi	sp,sp,48
    800004c4:	8082                	ret
    x = -xx;
    800004c6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004ca:	4e05                	li	t3,1
    x = -xx;
    800004cc:	b771                	j	80000458 <printint+0x14>

00000000800004ce <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004ce:	7155                	addi	sp,sp,-208
    800004d0:	e506                	sd	ra,136(sp)
    800004d2:	e122                	sd	s0,128(sp)
    800004d4:	f0d2                	sd	s4,96(sp)
    800004d6:	0900                	addi	s0,sp,144
    800004d8:	8a2a                	mv	s4,a0
    800004da:	e40c                	sd	a1,8(s0)
    800004dc:	e810                	sd	a2,16(s0)
    800004de:	ec14                	sd	a3,24(s0)
    800004e0:	f018                	sd	a4,32(s0)
    800004e2:	f41c                	sd	a5,40(s0)
    800004e4:	03043823          	sd	a6,48(s0)
    800004e8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004ec:	0000f797          	auipc	a5,0xf
    800004f0:	4e47a783          	lw	a5,1252(a5) # 8000f9d0 <pr+0x18>
    800004f4:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004f8:	e3a1                	bnez	a5,80000538 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fa:	00840793          	addi	a5,s0,8
    800004fe:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000502:	00054503          	lbu	a0,0(a0)
    80000506:	26050663          	beqz	a0,80000772 <printf+0x2a4>
    8000050a:	fca6                	sd	s1,120(sp)
    8000050c:	f8ca                	sd	s2,112(sp)
    8000050e:	f4ce                	sd	s3,104(sp)
    80000510:	ecd6                	sd	s5,88(sp)
    80000512:	e8da                	sd	s6,80(sp)
    80000514:	e0e2                	sd	s8,64(sp)
    80000516:	fc66                	sd	s9,56(sp)
    80000518:	f86a                	sd	s10,48(sp)
    8000051a:	f46e                	sd	s11,40(sp)
    8000051c:	4981                	li	s3,0
    if(cx != '%'){
    8000051e:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000522:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000526:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000052a:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000052e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000532:	07000d93          	li	s11,112
    80000536:	a80d                	j	80000568 <printf+0x9a>
    acquire(&pr.lock);
    80000538:	0000f517          	auipc	a0,0xf
    8000053c:	48050513          	addi	a0,a0,1152 # 8000f9b8 <pr>
    80000540:	6be000ef          	jal	80000bfe <acquire>
  va_start(ap, fmt);
    80000544:	00840793          	addi	a5,s0,8
    80000548:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054c:	000a4503          	lbu	a0,0(s4)
    80000550:	fd4d                	bnez	a0,8000050a <printf+0x3c>
    80000552:	ac3d                	j	80000790 <printf+0x2c2>
      consputc(cx);
    80000554:	cfbff0ef          	jal	8000024e <consputc>
      continue;
    80000558:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055a:	2485                	addiw	s1,s1,1
    8000055c:	89a6                	mv	s3,s1
    8000055e:	94d2                	add	s1,s1,s4
    80000560:	0004c503          	lbu	a0,0(s1)
    80000564:	1e050b63          	beqz	a0,8000075a <printf+0x28c>
    if(cx != '%'){
    80000568:	ff5516e3          	bne	a0,s5,80000554 <printf+0x86>
    i++;
    8000056c:	0019879b          	addiw	a5,s3,1
    80000570:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    80000572:	00fa0733          	add	a4,s4,a5
    80000576:	00074903          	lbu	s2,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000057a:	1e090063          	beqz	s2,8000075a <printf+0x28c>
    8000057e:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    80000582:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    80000584:	c701                	beqz	a4,8000058c <printf+0xbe>
    80000586:	97d2                	add	a5,a5,s4
    80000588:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    8000058c:	03690763          	beq	s2,s6,800005ba <printf+0xec>
    } else if(c0 == 'l' && c1 == 'd'){
    80000590:	05890163          	beq	s2,s8,800005d2 <printf+0x104>
    } else if(c0 == 'u'){
    80000594:	0d990b63          	beq	s2,s9,8000066a <printf+0x19c>
    } else if(c0 == 'x'){
    80000598:	13a90163          	beq	s2,s10,800006ba <printf+0x1ec>
    } else if(c0 == 'p'){
    8000059c:	13b90b63          	beq	s2,s11,800006d2 <printf+0x204>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005a0:	07300793          	li	a5,115
    800005a4:	16f90a63          	beq	s2,a5,80000718 <printf+0x24a>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a8:	1b590463          	beq	s2,s5,80000750 <printf+0x282>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005ac:	8556                	mv	a0,s5
    800005ae:	ca1ff0ef          	jal	8000024e <consputc>
      consputc(c0);
    800005b2:	854a                	mv	a0,s2
    800005b4:	c9bff0ef          	jal	8000024e <consputc>
    800005b8:	b74d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4605                	li	a2,1
    800005c8:	45a9                	li	a1,10
    800005ca:	4388                	lw	a0,0(a5)
    800005cc:	e79ff0ef          	jal	80000444 <printint>
    800005d0:	b769                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005d2:	03670663          	beq	a4,s6,800005fe <printf+0x130>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005d6:	05870263          	beq	a4,s8,8000061a <printf+0x14c>
    } else if(c0 == 'l' && c1 == 'u'){
    800005da:	0b970463          	beq	a4,s9,80000682 <printf+0x1b4>
    } else if(c0 == 'l' && c1 == 'x'){
    800005de:	fda717e3          	bne	a4,s10,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    800005e2:	f8843783          	ld	a5,-120(s0)
    800005e6:	00878713          	addi	a4,a5,8
    800005ea:	f8e43423          	sd	a4,-120(s0)
    800005ee:	4601                	li	a2,0
    800005f0:	45c1                	li	a1,16
    800005f2:	6388                	ld	a0,0(a5)
    800005f4:	e51ff0ef          	jal	80000444 <printint>
      i += 1;
    800005f8:	0029849b          	addiw	s1,s3,2
    800005fc:	bfb9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005fe:	f8843783          	ld	a5,-120(s0)
    80000602:	00878713          	addi	a4,a5,8
    80000606:	f8e43423          	sd	a4,-120(s0)
    8000060a:	4605                	li	a2,1
    8000060c:	45a9                	li	a1,10
    8000060e:	6388                	ld	a0,0(a5)
    80000610:	e35ff0ef          	jal	80000444 <printint>
      i += 1;
    80000614:	0029849b          	addiw	s1,s3,2
    80000618:	b789                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000061a:	06400793          	li	a5,100
    8000061e:	02f68863          	beq	a3,a5,8000064e <printf+0x180>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000622:	07500793          	li	a5,117
    80000626:	06f68c63          	beq	a3,a5,8000069e <printf+0x1d0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000062a:	07800793          	li	a5,120
    8000062e:	f6f69fe3          	bne	a3,a5,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    80000632:	f8843783          	ld	a5,-120(s0)
    80000636:	00878713          	addi	a4,a5,8
    8000063a:	f8e43423          	sd	a4,-120(s0)
    8000063e:	4601                	li	a2,0
    80000640:	45c1                	li	a1,16
    80000642:	6388                	ld	a0,0(a5)
    80000644:	e01ff0ef          	jal	80000444 <printint>
      i += 2;
    80000648:	0039849b          	addiw	s1,s3,3
    8000064c:	b739                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    8000064e:	f8843783          	ld	a5,-120(s0)
    80000652:	00878713          	addi	a4,a5,8
    80000656:	f8e43423          	sd	a4,-120(s0)
    8000065a:	4605                	li	a2,1
    8000065c:	45a9                	li	a1,10
    8000065e:	6388                	ld	a0,0(a5)
    80000660:	de5ff0ef          	jal	80000444 <printint>
      i += 2;
    80000664:	0039849b          	addiw	s1,s3,3
    80000668:	bdcd                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4601                	li	a2,0
    80000678:	45a9                	li	a1,10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	dc9ff0ef          	jal	80000444 <printint>
    80000680:	bde9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4601                	li	a2,0
    80000690:	45a9                	li	a1,10
    80000692:	6388                	ld	a0,0(a5)
    80000694:	db1ff0ef          	jal	80000444 <printint>
      i += 1;
    80000698:	0029849b          	addiw	s1,s3,2
    8000069c:	bd7d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	4601                	li	a2,0
    800006ac:	45a9                	li	a1,10
    800006ae:	6388                	ld	a0,0(a5)
    800006b0:	d95ff0ef          	jal	80000444 <printint>
      i += 2;
    800006b4:	0039849b          	addiw	s1,s3,3
    800006b8:	b54d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	00878713          	addi	a4,a5,8
    800006c2:	f8e43423          	sd	a4,-120(s0)
    800006c6:	4601                	li	a2,0
    800006c8:	45c1                	li	a1,16
    800006ca:	4388                	lw	a0,0(a5)
    800006cc:	d79ff0ef          	jal	80000444 <printint>
    800006d0:	b569                	j	8000055a <printf+0x8c>
    800006d2:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006d4:	f8843783          	ld	a5,-120(s0)
    800006d8:	00878713          	addi	a4,a5,8
    800006dc:	f8e43423          	sd	a4,-120(s0)
    800006e0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e4:	03000513          	li	a0,48
    800006e8:	b67ff0ef          	jal	8000024e <consputc>
  consputc('x');
    800006ec:	07800513          	li	a0,120
    800006f0:	b5fff0ef          	jal	8000024e <consputc>
    800006f4:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f6:	00007b97          	auipc	s7,0x7
    800006fa:	07ab8b93          	addi	s7,s7,122 # 80007770 <digits>
    800006fe:	03c9d793          	srli	a5,s3,0x3c
    80000702:	97de                	add	a5,a5,s7
    80000704:	0007c503          	lbu	a0,0(a5)
    80000708:	b47ff0ef          	jal	8000024e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0992                	slli	s3,s3,0x4
    8000070e:	397d                	addiw	s2,s2,-1
    80000710:	fe0917e3          	bnez	s2,800006fe <printf+0x230>
    80000714:	6ba6                	ld	s7,72(sp)
    80000716:	b591                	j	8000055a <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x274>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e20505e3          	beqz	a0,8000055a <printf+0x8c>
        consputc(*s);
    80000734:	b1bff0ef          	jal	8000024e <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x266>
    80000740:	bd29                	j	8000055a <printf+0x8c>
        s = "(null)";
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8c690913          	addi	s2,s2,-1850 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x266>
      consputc('%');
    80000750:	02500513          	li	a0,37
    80000754:	afbff0ef          	jal	8000024e <consputc>
    80000758:	b509                	j	8000055a <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000075a:	f7843783          	ld	a5,-136(s0)
    8000075e:	e385                	bnez	a5,8000077e <printf+0x2b0>
    80000760:	74e6                	ld	s1,120(sp)
    80000762:	7946                	ld	s2,112(sp)
    80000764:	79a6                	ld	s3,104(sp)
    80000766:	6ae6                	ld	s5,88(sp)
    80000768:	6b46                	ld	s6,80(sp)
    8000076a:	6c06                	ld	s8,64(sp)
    8000076c:	7ce2                	ld	s9,56(sp)
    8000076e:	7d42                	ld	s10,48(sp)
    80000770:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000772:	4501                	li	a0,0
    80000774:	60aa                	ld	ra,136(sp)
    80000776:	640a                	ld	s0,128(sp)
    80000778:	7a06                	ld	s4,96(sp)
    8000077a:	6169                	addi	sp,sp,208
    8000077c:	8082                	ret
    8000077e:	74e6                	ld	s1,120(sp)
    80000780:	7946                	ld	s2,112(sp)
    80000782:	79a6                	ld	s3,104(sp)
    80000784:	6ae6                	ld	s5,88(sp)
    80000786:	6b46                	ld	s6,80(sp)
    80000788:	6c06                	ld	s8,64(sp)
    8000078a:	7ce2                	ld	s9,56(sp)
    8000078c:	7d42                	ld	s10,48(sp)
    8000078e:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000790:	0000f517          	auipc	a0,0xf
    80000794:	22850513          	addi	a0,a0,552 # 8000f9b8 <pr>
    80000798:	4fa000ef          	jal	80000c92 <release>
    8000079c:	bfd9                	j	80000772 <printf+0x2a4>

000000008000079e <panic>:

void
panic(char *s)
{
    8000079e:	1101                	addi	sp,sp,-32
    800007a0:	ec06                	sd	ra,24(sp)
    800007a2:	e822                	sd	s0,16(sp)
    800007a4:	e426                	sd	s1,8(sp)
    800007a6:	1000                	addi	s0,sp,32
    800007a8:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007aa:	0000f797          	auipc	a5,0xf
    800007ae:	2207a323          	sw	zero,550(a5) # 8000f9d0 <pr+0x18>
  printf("panic: ");
    800007b2:	00007517          	auipc	a0,0x7
    800007b6:	86650513          	addi	a0,a0,-1946 # 80007018 <etext+0x18>
    800007ba:	d15ff0ef          	jal	800004ce <printf>
  printf("%s\n", s);
    800007be:	85a6                	mv	a1,s1
    800007c0:	00007517          	auipc	a0,0x7
    800007c4:	86050513          	addi	a0,a0,-1952 # 80007020 <etext+0x20>
    800007c8:	d07ff0ef          	jal	800004ce <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007cc:	4785                	li	a5,1
    800007ce:	00007717          	auipc	a4,0x7
    800007d2:	10f72123          	sw	a5,258(a4) # 800078d0 <panicked>
  for(;;)
    800007d6:	a001                	j	800007d6 <panic+0x38>

00000000800007d8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007d8:	1101                	addi	sp,sp,-32
    800007da:	ec06                	sd	ra,24(sp)
    800007dc:	e822                	sd	s0,16(sp)
    800007de:	e426                	sd	s1,8(sp)
    800007e0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007e2:	0000f497          	auipc	s1,0xf
    800007e6:	1d648493          	addi	s1,s1,470 # 8000f9b8 <pr>
    800007ea:	00007597          	auipc	a1,0x7
    800007ee:	83e58593          	addi	a1,a1,-1986 # 80007028 <etext+0x28>
    800007f2:	8526                	mv	a0,s1
    800007f4:	386000ef          	jal	80000b7a <initlock>
  pr.locking = 1;
    800007f8:	4785                	li	a5,1
    800007fa:	cc9c                	sw	a5,24(s1)
}
    800007fc:	60e2                	ld	ra,24(sp)
    800007fe:	6442                	ld	s0,16(sp)
    80000800:	64a2                	ld	s1,8(sp)
    80000802:	6105                	addi	sp,sp,32
    80000804:	8082                	ret

0000000080000806 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000806:	1141                	addi	sp,sp,-16
    80000808:	e406                	sd	ra,8(sp)
    8000080a:	e022                	sd	s0,0(sp)
    8000080c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000080e:	100007b7          	lui	a5,0x10000
    80000812:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000816:	10000737          	lui	a4,0x10000
    8000081a:	f8000693          	li	a3,-128
    8000081e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000822:	468d                	li	a3,3
    80000824:	10000637          	lui	a2,0x10000
    80000828:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	8732                	mv	a4,a2
    80000836:	461d                	li	a2,7
    80000838:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000840:	00006597          	auipc	a1,0x6
    80000844:	7f058593          	addi	a1,a1,2032 # 80007030 <etext+0x30>
    80000848:	0000f517          	auipc	a0,0xf
    8000084c:	19050513          	addi	a0,a0,400 # 8000f9d8 <uart_tx_lock>
    80000850:	32a000ef          	jal	80000b7a <initlock>
}
    80000854:	60a2                	ld	ra,8(sp)
    80000856:	6402                	ld	s0,0(sp)
    80000858:	0141                	addi	sp,sp,16
    8000085a:	8082                	ret

000000008000085c <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085c:	1101                	addi	sp,sp,-32
    8000085e:	ec06                	sd	ra,24(sp)
    80000860:	e822                	sd	s0,16(sp)
    80000862:	e426                	sd	s1,8(sp)
    80000864:	1000                	addi	s0,sp,32
    80000866:	84aa                	mv	s1,a0
  push_off();
    80000868:	356000ef          	jal	80000bbe <push_off>

  if(panicked){
    8000086c:	00007797          	auipc	a5,0x7
    80000870:	0647a783          	lw	a5,100(a5) # 800078d0 <panicked>
    80000874:	e795                	bnez	a5,800008a0 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000876:	10000737          	lui	a4,0x10000
    8000087a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000087c:	00074783          	lbu	a5,0(a4)
    80000880:	0207f793          	andi	a5,a5,32
    80000884:	dfe5                	beqz	a5,8000087c <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000886:	0ff4f513          	zext.b	a0,s1
    8000088a:	100007b7          	lui	a5,0x10000
    8000088e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000892:	3b0000ef          	jal	80000c42 <pop_off>
}
    80000896:	60e2                	ld	ra,24(sp)
    80000898:	6442                	ld	s0,16(sp)
    8000089a:	64a2                	ld	s1,8(sp)
    8000089c:	6105                	addi	sp,sp,32
    8000089e:	8082                	ret
    for(;;)
    800008a0:	a001                	j	800008a0 <uartputc_sync+0x44>

00000000800008a2 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a2:	00007797          	auipc	a5,0x7
    800008a6:	0367b783          	ld	a5,54(a5) # 800078d8 <uart_tx_r>
    800008aa:	00007717          	auipc	a4,0x7
    800008ae:	03673703          	ld	a4,54(a4) # 800078e0 <uart_tx_w>
    800008b2:	08f70163          	beq	a4,a5,80000934 <uartstart+0x92>
{
    800008b6:	7139                	addi	sp,sp,-64
    800008b8:	fc06                	sd	ra,56(sp)
    800008ba:	f822                	sd	s0,48(sp)
    800008bc:	f426                	sd	s1,40(sp)
    800008be:	f04a                	sd	s2,32(sp)
    800008c0:	ec4e                	sd	s3,24(sp)
    800008c2:	e852                	sd	s4,16(sp)
    800008c4:	e456                	sd	s5,8(sp)
    800008c6:	e05a                	sd	s6,0(sp)
    800008c8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ca:	10000937          	lui	s2,0x10000
    800008ce:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d0:	0000fa97          	auipc	s5,0xf
    800008d4:	108a8a93          	addi	s5,s5,264 # 8000f9d8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	00007497          	auipc	s1,0x7
    800008dc:	00048493          	mv	s1,s1
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	00007997          	auipc	s3,0x7
    800008e8:	ffc98993          	addi	s3,s3,-4 # 800078e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ec:	00094703          	lbu	a4,0(s2)
    800008f0:	02077713          	andi	a4,a4,32
    800008f4:	c715                	beqz	a4,80000920 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f6:	01f7f713          	andi	a4,a5,31
    800008fa:	9756                	add	a4,a4,s5
    800008fc:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80000900:	0785                	addi	a5,a5,1
    80000902:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000904:	8526                	mv	a0,s1
    80000906:	5f0010ef          	jal	80001ef6 <wakeup>
    WriteReg(THR, c);
    8000090a:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000090e:	609c                	ld	a5,0(s1)
    80000910:	0009b703          	ld	a4,0(s3)
    80000914:	fcf71ce3          	bne	a4,a5,800008ec <uartstart+0x4a>
      ReadReg(ISR);
    80000918:	100007b7          	lui	a5,0x10000
    8000091c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80000920:	70e2                	ld	ra,56(sp)
    80000922:	7442                	ld	s0,48(sp)
    80000924:	74a2                	ld	s1,40(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	69e2                	ld	s3,24(sp)
    8000092a:	6a42                	ld	s4,16(sp)
    8000092c:	6aa2                	ld	s5,8(sp)
    8000092e:	6b02                	ld	s6,0(sp)
    80000930:	6121                	addi	sp,sp,64
    80000932:	8082                	ret
      ReadReg(ISR);
    80000934:	100007b7          	lui	a5,0x10000
    80000938:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000093c:	8082                	ret

000000008000093e <uartputc>:
{
    8000093e:	7179                	addi	sp,sp,-48
    80000940:	f406                	sd	ra,40(sp)
    80000942:	f022                	sd	s0,32(sp)
    80000944:	ec26                	sd	s1,24(sp)
    80000946:	e84a                	sd	s2,16(sp)
    80000948:	e44e                	sd	s3,8(sp)
    8000094a:	e052                	sd	s4,0(sp)
    8000094c:	1800                	addi	s0,sp,48
    8000094e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000950:	0000f517          	auipc	a0,0xf
    80000954:	08850513          	addi	a0,a0,136 # 8000f9d8 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	00007797          	auipc	a5,0x7
    80000960:	f747a783          	lw	a5,-140(a5) # 800078d0 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	00007717          	auipc	a4,0x7
    8000096a:	f7a73703          	ld	a4,-134(a4) # 800078e0 <uart_tx_w>
    8000096e:	00007797          	auipc	a5,0x7
    80000972:	f6a7b783          	ld	a5,-150(a5) # 800078d8 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	0000f997          	auipc	s3,0xf
    8000097e:	05e98993          	addi	s3,s3,94 # 8000f9d8 <uart_tx_lock>
    80000982:	00007497          	auipc	s1,0x7
    80000986:	f5648493          	addi	s1,s1,-170 # 800078d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	00007917          	auipc	s2,0x7
    8000098e:	f5690913          	addi	s2,s2,-170 # 800078e0 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	510010ef          	jal	80001eaa <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	0000f497          	auipc	s1,0xf
    800009b0:	02c48493          	addi	s1,s1,44 # 8000f9d8 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	00007797          	auipc	a5,0x7
    800009c4:	f2e7b023          	sd	a4,-224(a5) # 800078e0 <uart_tx_w>
  uartstart();
    800009c8:	edbff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	2c4000ef          	jal	80000c92 <release>
}
    800009d2:	70a2                	ld	ra,40(sp)
    800009d4:	7402                	ld	s0,32(sp)
    800009d6:	64e2                	ld	s1,24(sp)
    800009d8:	6942                	ld	s2,16(sp)
    800009da:	69a2                	ld	s3,8(sp)
    800009dc:	6a02                	ld	s4,0(sp)
    800009de:	6145                	addi	sp,sp,48
    800009e0:	8082                	ret
    for(;;)
    800009e2:	a001                	j	800009e2 <uartputc+0xa4>

00000000800009e4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e4:	1141                	addi	sp,sp,-16
    800009e6:	e406                	sd	ra,8(sp)
    800009e8:	e022                	sd	s0,0(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009f4:	8b85                	andi	a5,a5,1
    800009f6:	cb89                	beqz	a5,80000a08 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009f8:	100007b7          	lui	a5,0x10000
    800009fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a00:	60a2                	ld	ra,8(sp)
    80000a02:	6402                	ld	s0,0(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfdd                	j	80000a00 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a18:	fcdff0ef          	jal	800009e4 <uartgetc>
    if(c == -1)
    80000a1c:	00950563          	beq	a0,s1,80000a26 <uartintr+0x1a>
      break;
    consoleintr(c);
    80000a20:	861ff0ef          	jal	80000280 <consoleintr>
  while(1){
    80000a24:	bfd5                	j	80000a18 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a26:	0000f497          	auipc	s1,0xf
    80000a2a:	fb248493          	addi	s1,s1,-78 # 8000f9d8 <uart_tx_lock>
    80000a2e:	8526                	mv	a0,s1
    80000a30:	1ce000ef          	jal	80000bfe <acquire>
  uartstart();
    80000a34:	e6fff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	258000ef          	jal	80000c92 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret

0000000080000a48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a48:	1101                	addi	sp,sp,-32
    80000a4a:	ec06                	sd	ra,24(sp)
    80000a4c:	e822                	sd	s0,16(sp)
    80000a4e:	e426                	sd	s1,8(sp)
    80000a50:	e04a                	sd	s2,0(sp)
    80000a52:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a54:	03451793          	slli	a5,a0,0x34
    80000a58:	e7a9                	bnez	a5,80000aa2 <kfree+0x5a>
    80000a5a:	84aa                	mv	s1,a0
    80000a5c:	00020797          	auipc	a5,0x20
    80000a60:	1e478793          	addi	a5,a5,484 # 80020c40 <end>
    80000a64:	02f56f63          	bltu	a0,a5,80000aa2 <kfree+0x5a>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	02f57b63          	bgeu	a0,a5,80000aa2 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a70:	6605                	lui	a2,0x1
    80000a72:	4585                	li	a1,1
    80000a74:	25a000ef          	jal	80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a78:	0000f917          	auipc	s2,0xf
    80000a7c:	f9890913          	addi	s2,s2,-104 # 8000fa10 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	17c000ef          	jal	80000bfe <acquire>
  r->next = kmem.freelist;
    80000a86:	01893783          	ld	a5,24(s2)
    80000a8a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a8c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a90:	854a                	mv	a0,s2
    80000a92:	200000ef          	jal	80000c92 <release>
}
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6902                	ld	s2,0(sp)
    80000a9e:	6105                	addi	sp,sp,32
    80000aa0:	8082                	ret
    panic("kfree");
    80000aa2:	00006517          	auipc	a0,0x6
    80000aa6:	59650513          	addi	a0,a0,1430 # 80007038 <etext+0x38>
    80000aaa:	cf5ff0ef          	jal	8000079e <panic>

0000000080000aae <freerange>:
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab8:	6785                	lui	a5,0x1
    80000aba:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000abe:	00e504b3          	add	s1,a0,a4
    80000ac2:	777d                	lui	a4,0xfffff
    80000ac4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac6:	94be                	add	s1,s1,a5
    80000ac8:	0295e263          	bltu	a1,s1,80000aec <freerange+0x3e>
    80000acc:	e84a                	sd	s2,16(sp)
    80000ace:	e44e                	sd	s3,8(sp)
    80000ad0:	e052                	sd	s4,0(sp)
    80000ad2:	892e                	mv	s2,a1
    kfree(p);
    80000ad4:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	89be                	mv	s3,a5
    kfree(p);
    80000ad8:	01448533          	add	a0,s1,s4
    80000adc:	f6dff0ef          	jal	80000a48 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94ce                	add	s1,s1,s3
    80000ae2:	fe997be3          	bgeu	s2,s1,80000ad8 <freerange+0x2a>
    80000ae6:	6942                	ld	s2,16(sp)
    80000ae8:	69a2                	ld	s3,8(sp)
    80000aea:	6a02                	ld	s4,0(sp)
}
    80000aec:	70a2                	ld	ra,40(sp)
    80000aee:	7402                	ld	s0,32(sp)
    80000af0:	64e2                	ld	s1,24(sp)
    80000af2:	6145                	addi	sp,sp,48
    80000af4:	8082                	ret

0000000080000af6 <kinit>:
{
    80000af6:	1141                	addi	sp,sp,-16
    80000af8:	e406                	sd	ra,8(sp)
    80000afa:	e022                	sd	s0,0(sp)
    80000afc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000afe:	00006597          	auipc	a1,0x6
    80000b02:	54258593          	addi	a1,a1,1346 # 80007040 <etext+0x40>
    80000b06:	0000f517          	auipc	a0,0xf
    80000b0a:	f0a50513          	addi	a0,a0,-246 # 8000fa10 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00020517          	auipc	a0,0x20
    80000b1a:	12a50513          	addi	a0,a0,298 # 80020c40 <end>
    80000b1e:	f91ff0ef          	jal	80000aae <freerange>
}
    80000b22:	60a2                	ld	ra,8(sp)
    80000b24:	6402                	ld	s0,0(sp)
    80000b26:	0141                	addi	sp,sp,16
    80000b28:	8082                	ret

0000000080000b2a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b34:	0000f497          	auipc	s1,0xf
    80000b38:	edc48493          	addi	s1,s1,-292 # 8000fa10 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	0000f517          	auipc	a0,0xf
    80000b4c:	ec850513          	addi	a0,a0,-312 # 8000fa10 <kmem>
    80000b50:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b52:	140000ef          	jal	80000c92 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	172000ef          	jal	80000cce <memset>
  return (void*)r;
}
    80000b60:	8526                	mv	a0,s1
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
  release(&kmem.lock);
    80000b6c:	0000f517          	auipc	a0,0xf
    80000b70:	ea450513          	addi	a0,a0,-348 # 8000fa10 <kmem>
    80000b74:	11e000ef          	jal	80000c92 <release>
  if(r)
    80000b78:	b7e5                	j	80000b60 <kalloc+0x36>

0000000080000b7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7a:	1141                	addi	sp,sp,-16
    80000b7c:	e406                	sd	ra,8(sp)
    80000b7e:	e022                	sd	s0,0(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	60a2                	ld	ra,8(sp)
    80000b8e:	6402                	ld	s0,0(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	411c                	lw	a5,0(a0)
    80000b96:	e399                	bnez	a5,80000b9c <holding+0x8>
    80000b98:	4501                	li	a0,0
  return r;
}
    80000b9a:	8082                	ret
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba6:	6904                	ld	s1,16(a0)
    80000ba8:	515000ef          	jal	800018bc <mycpu>
    80000bac:	40a48533          	sub	a0,s1,a0
    80000bb0:	00153513          	seqz	a0,a0
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret

0000000080000bbe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbe:	1101                	addi	sp,sp,-32
    80000bc0:	ec06                	sd	ra,24(sp)
    80000bc2:	e822                	sd	s0,16(sp)
    80000bc4:	e426                	sd	s1,8(sp)
    80000bc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc8:	100024f3          	csrr	s1,sstatus
    80000bcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd6:	4e7000ef          	jal	800018bc <mycpu>
    80000bda:	5d3c                	lw	a5,120(a0)
    80000bdc:	cb99                	beqz	a5,80000bf2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bde:	4df000ef          	jal	800018bc <mycpu>
    80000be2:	5d3c                	lw	a5,120(a0)
    80000be4:	2785                	addiw	a5,a5,1
    80000be6:	dd3c                	sw	a5,120(a0)
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret
    mycpu()->intena = old;
    80000bf2:	4cb000ef          	jal	800018bc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	b7cd                	j	80000bde <push_off+0x20>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	fb5ff0ef          	jal	80000bbe <push_off>
  if(holding(lk))
    80000c0e:	8526                	mv	a0,s1
    80000c10:	f85ff0ef          	jal	80000b94 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c14:	4705                	li	a4,1
  if(holding(lk))
    80000c16:	e105                	bnez	a0,80000c36 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c18:	87ba                	mv	a5,a4
    80000c1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c1e:	2781                	sext.w	a5,a5
    80000c20:	ffe5                	bnez	a5,80000c18 <acquire+0x1a>
  __sync_synchronize();
    80000c22:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c26:	497000ef          	jal	800018bc <mycpu>
    80000c2a:	e888                	sd	a0,16(s1)
}
    80000c2c:	60e2                	ld	ra,24(sp)
    80000c2e:	6442                	ld	s0,16(sp)
    80000c30:	64a2                	ld	s1,8(sp)
    80000c32:	6105                	addi	sp,sp,32
    80000c34:	8082                	ret
    panic("acquire");
    80000c36:	00006517          	auipc	a0,0x6
    80000c3a:	41250513          	addi	a0,a0,1042 # 80007048 <etext+0x48>
    80000c3e:	b61ff0ef          	jal	8000079e <panic>

0000000080000c42 <pop_off>:

void
pop_off(void)
{
    80000c42:	1141                	addi	sp,sp,-16
    80000c44:	e406                	sd	ra,8(sp)
    80000c46:	e022                	sd	s0,0(sp)
    80000c48:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4a:	473000ef          	jal	800018bc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e39d                	bnez	a5,80000c7a <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05763          	blez	a5,80000c86 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c60:	eb89                	bnez	a5,80000c72 <pop_off+0x30>
    80000c62:	5d7c                	lw	a5,124(a0)
    80000c64:	c799                	beqz	a5,80000c72 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c72:	60a2                	ld	ra,8(sp)
    80000c74:	6402                	ld	s0,0(sp)
    80000c76:	0141                	addi	sp,sp,16
    80000c78:	8082                	ret
    panic("pop_off - interruptible");
    80000c7a:	00006517          	auipc	a0,0x6
    80000c7e:	3d650513          	addi	a0,a0,982 # 80007050 <etext+0x50>
    80000c82:	b1dff0ef          	jal	8000079e <panic>
    panic("pop_off");
    80000c86:	00006517          	auipc	a0,0x6
    80000c8a:	3e250513          	addi	a0,a0,994 # 80007068 <etext+0x68>
    80000c8e:	b11ff0ef          	jal	8000079e <panic>

0000000080000c92 <release>:
{
    80000c92:	1101                	addi	sp,sp,-32
    80000c94:	ec06                	sd	ra,24(sp)
    80000c96:	e822                	sd	s0,16(sp)
    80000c98:	e426                	sd	s1,8(sp)
    80000c9a:	1000                	addi	s0,sp,32
    80000c9c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9e:	ef7ff0ef          	jal	80000b94 <holding>
    80000ca2:	c105                	beqz	a0,80000cc2 <release+0x30>
  lk->cpu = 0;
    80000ca4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cac:	0310000f          	fence	rw,w
    80000cb0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cb4:	f8fff0ef          	jal	80000c42 <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00006517          	auipc	a0,0x6
    80000cc6:	3ae50513          	addi	a0,a0,942 # 80007070 <etext+0x70>
    80000cca:	ad5ff0ef          	jal	8000079e <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd6:	ca19                	beqz	a2,80000cec <memset+0x1e>
    80000cd8:	87aa                	mv	a5,a0
    80000cda:	1602                	slli	a2,a2,0x20
    80000cdc:	9201                	srli	a2,a2,0x20
    80000cde:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce6:	0785                	addi	a5,a5,1
    80000ce8:	fee79de3          	bne	a5,a4,80000ce2 <memset+0x14>
  }
  return dst;
}
    80000cec:	60a2                	ld	ra,8(sp)
    80000cee:	6402                	ld	s0,0(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e406                	sd	ra,8(sp)
    80000cf8:	e022                	sd	s0,0(sp)
    80000cfa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfc:	ca0d                	beqz	a2,80000d2e <memcmp+0x3a>
    80000cfe:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d02:	1682                	slli	a3,a3,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	0685                	addi	a3,a3,1
    80000d08:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0a:	00054783          	lbu	a5,0(a0)
    80000d0e:	0005c703          	lbu	a4,0(a1)
    80000d12:	00e79863          	bne	a5,a4,80000d22 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d16:	0505                	addi	a0,a0,1
    80000d18:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1a:	fed518e3          	bne	a0,a3,80000d0a <memcmp+0x16>
  }

  return 0;
    80000d1e:	4501                	li	a0,0
    80000d20:	a019                	j	80000d26 <memcmp+0x32>
      return *s1 - *s2;
    80000d22:	40e7853b          	subw	a0,a5,a4
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	bfdd                	j	80000d26 <memcmp+0x32>

0000000080000d32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e406                	sd	ra,8(sp)
    80000d36:	e022                	sd	s0,0(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d3a:	c205                	beqz	a2,80000d5a <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3c:	02a5e363          	bltu	a1,a0,80000d62 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d40:	1602                	slli	a2,a2,0x20
    80000d42:	9201                	srli	a2,a2,0x20
    80000d44:	00c587b3          	add	a5,a1,a2
{
    80000d48:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d4a:	0585                	addi	a1,a1,1
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde3c1>
    80000d4e:	fff5c683          	lbu	a3,-1(a1)
    80000d52:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d56:	feb79ae3          	bne	a5,a1,80000d4a <memmove+0x18>

  return dst;
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret
  if(s < d && s + n > d){
    80000d62:	02061693          	slli	a3,a2,0x20
    80000d66:	9281                	srli	a3,a3,0x20
    80000d68:	00d58733          	add	a4,a1,a3
    80000d6c:	fce57ae3          	bgeu	a0,a4,80000d40 <memmove+0xe>
    d += n;
    80000d70:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d72:	fff6079b          	addiw	a5,a2,-1
    80000d76:	1782                	slli	a5,a5,0x20
    80000d78:	9381                	srli	a5,a5,0x20
    80000d7a:	fff7c793          	not	a5,a5
    80000d7e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d80:	177d                	addi	a4,a4,-1
    80000d82:	16fd                	addi	a3,a3,-1
    80000d84:	00074603          	lbu	a2,0(a4)
    80000d88:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d8c:	fee79ae3          	bne	a5,a4,80000d80 <memmove+0x4e>
    80000d90:	b7e9                	j	80000d5a <memmove+0x28>

0000000080000d92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e406                	sd	ra,8(sp)
    80000d96:	e022                	sd	s0,0(sp)
    80000d98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9a:	f99ff0ef          	jal	80000d32 <memmove>
}
    80000d9e:	60a2                	ld	ra,8(sp)
    80000da0:	6402                	ld	s0,0(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dae:	ce11                	beqz	a2,80000dca <strncmp+0x24>
    80000db0:	00054783          	lbu	a5,0(a0)
    80000db4:	cf89                	beqz	a5,80000dce <strncmp+0x28>
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	00f71a63          	bne	a4,a5,80000dce <strncmp+0x28>
    n--, p++, q++;
    80000dbe:	367d                	addiw	a2,a2,-1
    80000dc0:	0505                	addi	a0,a0,1
    80000dc2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dc4:	f675                	bnez	a2,80000db0 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	a801                	j	80000dd8 <strncmp+0x32>
    80000dca:	4501                	li	a0,0
    80000dcc:	a031                	j	80000dd8 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dce:	00054503          	lbu	a0,0(a0)
    80000dd2:	0005c783          	lbu	a5,0(a1)
    80000dd6:	9d1d                	subw	a0,a0,a5
}
    80000dd8:	60a2                	ld	ra,8(sp)
    80000dda:	6402                	ld	s0,0(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de8:	87aa                	mv	a5,a0
    80000dea:	86b2                	mv	a3,a2
    80000dec:	367d                	addiw	a2,a2,-1
    80000dee:	02d05563          	blez	a3,80000e18 <strncpy+0x38>
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	fee78fa3          	sb	a4,-1(a5)
    80000dfc:	0585                	addi	a1,a1,1
    80000dfe:	f775                	bnez	a4,80000dea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e00:	873e                	mv	a4,a5
    80000e02:	00c05b63          	blez	a2,80000e18 <strncpy+0x38>
    80000e06:	9fb5                	addw	a5,a5,a3
    80000e08:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e10:	40e786bb          	subw	a3,a5,a4
    80000e14:	fed04be3          	bgtz	a3,80000e0a <strncpy+0x2a>
  return os;
}
    80000e18:	60a2                	ld	ra,8(sp)
    80000e1a:	6402                	ld	s0,0(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret

0000000080000e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e406                	sd	ra,8(sp)
    80000e24:	e022                	sd	s0,0(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e28:	02c05363          	blez	a2,80000e4e <safestrcpy+0x2e>
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	1682                	slli	a3,a3,0x20
    80000e32:	9281                	srli	a3,a3,0x20
    80000e34:	96ae                	add	a3,a3,a1
    80000e36:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e38:	00d58963          	beq	a1,a3,80000e4a <safestrcpy+0x2a>
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    80000e48:	fb65                	bnez	a4,80000e38 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e4a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e406                	sd	ra,8(sp)
    80000e5a:	e022                	sd	s0,0(sp)
    80000e5c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf99                	beqz	a5,80000e80 <strlen+0x2a>
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	87aa                	mv	a5,a0
    80000e68:	86be                	mv	a3,a5
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff7c703          	lbu	a4,-1(a5)
    80000e70:	ff65                	bnez	a4,80000e68 <strlen+0x12>
    80000e72:	40a6853b          	subw	a0,a3,a0
    80000e76:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e80:	4501                	li	a0,0
    80000e82:	bfdd                	j	80000e78 <strlen+0x22>

0000000080000e84 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8c:	21d000ef          	jal	800018a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00007717          	auipc	a4,0x7
    80000e94:	a5870713          	addi	a4,a4,-1448 # 800078e8 <started>
  if(cpuid() == 0){
    80000e98:	c51d                	beqz	a0,80000ec6 <main+0x42>
    while(started == 0)
    80000e9a:	431c                	lw	a5,0(a4)
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dff5                	beqz	a5,80000e9a <main+0x16>
      ;
    __sync_synchronize();
    80000ea0:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ea4:	205000ef          	jal	800018a8 <cpuid>
    80000ea8:	85aa                	mv	a1,a0
    80000eaa:	00006517          	auipc	a0,0x6
    80000eae:	1ee50513          	addi	a0,a0,494 # 80007098 <etext+0x98>
    80000eb2:	e1cff0ef          	jal	800004ce <printf>
    kvminithart();    // turn on paging
    80000eb6:	080000ef          	jal	80000f36 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eba:	50c010ef          	jal	800023c6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	3ca040ef          	jal	80005288 <plicinithart>
  }

  scheduler();        
    80000ec2:	64f000ef          	jal	80001d10 <scheduler>
    consoleinit();
    80000ec6:	d3aff0ef          	jal	80000400 <consoleinit>
    printfinit();
    80000eca:	90fff0ef          	jal	800007d8 <printfinit>
    printf("\n");
    80000ece:	00006517          	auipc	a0,0x6
    80000ed2:	1aa50513          	addi	a0,a0,426 # 80007078 <etext+0x78>
    80000ed6:	df8ff0ef          	jal	800004ce <printf>
    printf("xv6 kernel is booting\n");
    80000eda:	00006517          	auipc	a0,0x6
    80000ede:	1a650513          	addi	a0,a0,422 # 80007080 <etext+0x80>
    80000ee2:	decff0ef          	jal	800004ce <printf>
    printf("\n");
    80000ee6:	00006517          	auipc	a0,0x6
    80000eea:	19250513          	addi	a0,a0,402 # 80007078 <etext+0x78>
    80000eee:	de0ff0ef          	jal	800004ce <printf>
    kinit();         // physical page allocator
    80000ef2:	c05ff0ef          	jal	80000af6 <kinit>
    kvminit();       // create kernel page table
    80000ef6:	2ce000ef          	jal	800011c4 <kvminit>
    kvminithart();   // turn on paging
    80000efa:	03c000ef          	jal	80000f36 <kvminithart>
    procinit();      // process table
    80000efe:	0fb000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000f02:	4a0010ef          	jal	800023a2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	4c0010ef          	jal	800023c6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	364040ef          	jal	8000526e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	37a040ef          	jal	80005288 <plicinithart>
    binit();         // buffer cache
    80000f12:	2e3010ef          	jal	800029f4 <binit>
    iinit();         // inode table
    80000f16:	0ae020ef          	jal	80002fc4 <iinit>
    fileinit();      // file table
    80000f1a:	67d020ef          	jal	80003d96 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	45a040ef          	jal	80005378 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	423000ef          	jal	80001b44 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00007717          	auipc	a4,0x7
    80000f30:	9af72e23          	sw	a5,-1604(a4) # 800078e8 <started>
    80000f34:	b779                	j	80000ec2 <main+0x3e>

0000000080000f36 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e406                	sd	ra,8(sp)
    80000f3a:	e022                	sd	s0,0(sp)
    80000f3c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f3e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f42:	00007797          	auipc	a5,0x7
    80000f46:	9ae7b783          	ld	a5,-1618(a5) # 800078f0 <kernel_pagetable>
    80000f4a:	83b1                	srli	a5,a5,0xc
    80000f4c:	577d                	li	a4,-1
    80000f4e:	177e                	slli	a4,a4,0x3f
    80000f50:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f52:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f56:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f5a:	60a2                	ld	ra,8(sp)
    80000f5c:	6402                	ld	s0,0(sp)
    80000f5e:	0141                	addi	sp,sp,16
    80000f60:	8082                	ret

0000000080000f62 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f62:	7139                	addi	sp,sp,-64
    80000f64:	fc06                	sd	ra,56(sp)
    80000f66:	f822                	sd	s0,48(sp)
    80000f68:	f426                	sd	s1,40(sp)
    80000f6a:	f04a                	sd	s2,32(sp)
    80000f6c:	ec4e                	sd	s3,24(sp)
    80000f6e:	e852                	sd	s4,16(sp)
    80000f70:	e456                	sd	s5,8(sp)
    80000f72:	e05a                	sd	s6,0(sp)
    80000f74:	0080                	addi	s0,sp,64
    80000f76:	84aa                	mv	s1,a0
    80000f78:	89ae                	mv	s3,a1
    80000f7a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f82:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f84:	04b7e263          	bltu	a5,a1,80000fc8 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f88:	0149d933          	srl	s2,s3,s4
    80000f8c:	1ff97913          	andi	s2,s2,511
    80000f90:	090e                	slli	s2,s2,0x3
    80000f92:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f94:	00093483          	ld	s1,0(s2)
    80000f98:	0014f793          	andi	a5,s1,1
    80000f9c:	cf85                	beqz	a5,80000fd4 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9e:	80a9                	srli	s1,s1,0xa
    80000fa0:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fa2:	3a5d                	addiw	s4,s4,-9
    80000fa4:	ff6a12e3          	bne	s4,s6,80000f88 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fa8:	00c9d513          	srli	a0,s3,0xc
    80000fac:	1ff57513          	andi	a0,a0,511
    80000fb0:	050e                	slli	a0,a0,0x3
    80000fb2:	9526                	add	a0,a0,s1
}
    80000fb4:	70e2                	ld	ra,56(sp)
    80000fb6:	7442                	ld	s0,48(sp)
    80000fb8:	74a2                	ld	s1,40(sp)
    80000fba:	7902                	ld	s2,32(sp)
    80000fbc:	69e2                	ld	s3,24(sp)
    80000fbe:	6a42                	ld	s4,16(sp)
    80000fc0:	6aa2                	ld	s5,8(sp)
    80000fc2:	6b02                	ld	s6,0(sp)
    80000fc4:	6121                	addi	sp,sp,64
    80000fc6:	8082                	ret
    panic("walk");
    80000fc8:	00006517          	auipc	a0,0x6
    80000fcc:	0e850513          	addi	a0,a0,232 # 800070b0 <etext+0xb0>
    80000fd0:	fceff0ef          	jal	8000079e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fd4:	020a8263          	beqz	s5,80000ff8 <walk+0x96>
    80000fd8:	b53ff0ef          	jal	80000b2a <kalloc>
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	d979                	beqz	a0,80000fb4 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fe0:	6605                	lui	a2,0x1
    80000fe2:	4581                	li	a1,0
    80000fe4:	cebff0ef          	jal	80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe8:	00c4d793          	srli	a5,s1,0xc
    80000fec:	07aa                	slli	a5,a5,0xa
    80000fee:	0017e793          	ori	a5,a5,1
    80000ff2:	00f93023          	sd	a5,0(s2)
    80000ff6:	b775                	j	80000fa2 <walk+0x40>
        return 0;
    80000ff8:	4501                	li	a0,0
    80000ffa:	bf6d                	j	80000fb4 <walk+0x52>

0000000080000ffc <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	00b7f463          	bgeu	a5,a1,80001008 <walkaddr+0xc>
    return 0;
    80001004:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001006:	8082                	ret
{
    80001008:	1141                	addi	sp,sp,-16
    8000100a:	e406                	sd	ra,8(sp)
    8000100c:	e022                	sd	s0,0(sp)
    8000100e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001010:	4601                	li	a2,0
    80001012:	f51ff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001016:	c105                	beqz	a0,80001036 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001018:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000101a:	0117f693          	andi	a3,a5,17
    8000101e:	4745                	li	a4,17
    return 0;
    80001020:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001022:	00e68663          	beq	a3,a4,8000102e <walkaddr+0x32>
}
    80001026:	60a2                	ld	ra,8(sp)
    80001028:	6402                	ld	s0,0(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret
  pa = PTE2PA(*pte);
    8000102e:	83a9                	srli	a5,a5,0xa
    80001030:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001034:	bfcd                	j	80001026 <walkaddr+0x2a>
    return 0;
    80001036:	4501                	li	a0,0
    80001038:	b7fd                	j	80001026 <walkaddr+0x2a>

000000008000103a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000103a:	715d                	addi	sp,sp,-80
    8000103c:	e486                	sd	ra,72(sp)
    8000103e:	e0a2                	sd	s0,64(sp)
    80001040:	fc26                	sd	s1,56(sp)
    80001042:	f84a                	sd	s2,48(sp)
    80001044:	f44e                	sd	s3,40(sp)
    80001046:	f052                	sd	s4,32(sp)
    80001048:	ec56                	sd	s5,24(sp)
    8000104a:	e85a                	sd	s6,16(sp)
    8000104c:	e45e                	sd	s7,8(sp)
    8000104e:	e062                	sd	s8,0(sp)
    80001050:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001052:	03459793          	slli	a5,a1,0x34
    80001056:	e7b1                	bnez	a5,800010a2 <mappages+0x68>
    80001058:	8aaa                	mv	s5,a0
    8000105a:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000105c:	03461793          	slli	a5,a2,0x34
    80001060:	e7b9                	bnez	a5,800010ae <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    80001062:	ce21                	beqz	a2,800010ba <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001064:	77fd                	lui	a5,0xfffff
    80001066:	963e                	add	a2,a2,a5
    80001068:	00b609b3          	add	s3,a2,a1
  a = va;
    8000106c:	892e                	mv	s2,a1
    8000106e:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001072:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001074:	6c05                	lui	s8,0x1
    80001076:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	865e                	mv	a2,s7
    8000107c:	85ca                	mv	a1,s2
    8000107e:	8556                	mv	a0,s5
    80001080:	ee3ff0ef          	jal	80000f62 <walk>
    80001084:	c539                	beqz	a0,800010d2 <mappages+0x98>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef95                	bnez	a5,800010c6 <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	05390963          	beq	s2,s3,800010ec <mappages+0xb2>
    a += PGSIZE;
    8000109e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfd9                	j	80001076 <mappages+0x3c>
    panic("mappages: va not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	01650513          	addi	a0,a0,22 # 800070b8 <etext+0xb8>
    800010aa:	ef4ff0ef          	jal	8000079e <panic>
    panic("mappages: size not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	02a50513          	addi	a0,a0,42 # 800070d8 <etext+0xd8>
    800010b6:	ee8ff0ef          	jal	8000079e <panic>
    panic("mappages: size");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	03e50513          	addi	a0,a0,62 # 800070f8 <etext+0xf8>
    800010c2:	edcff0ef          	jal	8000079e <panic>
      panic("mappages: remap");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	04250513          	addi	a0,a0,66 # 80007108 <etext+0x108>
    800010ce:	ed0ff0ef          	jal	8000079e <panic>
      return -1;
    800010d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d4:	60a6                	ld	ra,72(sp)
    800010d6:	6406                	ld	s0,64(sp)
    800010d8:	74e2                	ld	s1,56(sp)
    800010da:	7942                	ld	s2,48(sp)
    800010dc:	79a2                	ld	s3,40(sp)
    800010de:	7a02                	ld	s4,32(sp)
    800010e0:	6ae2                	ld	s5,24(sp)
    800010e2:	6b42                	ld	s6,16(sp)
    800010e4:	6ba2                	ld	s7,8(sp)
    800010e6:	6c02                	ld	s8,0(sp)
    800010e8:	6161                	addi	sp,sp,80
    800010ea:	8082                	ret
  return 0;
    800010ec:	4501                	li	a0,0
    800010ee:	b7dd                	j	800010d4 <mappages+0x9a>

00000000800010f0 <kvmmap>:
{
    800010f0:	1141                	addi	sp,sp,-16
    800010f2:	e406                	sd	ra,8(sp)
    800010f4:	e022                	sd	s0,0(sp)
    800010f6:	0800                	addi	s0,sp,16
    800010f8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010fa:	86b2                	mv	a3,a2
    800010fc:	863e                	mv	a2,a5
    800010fe:	f3dff0ef          	jal	8000103a <mappages>
    80001102:	e509                	bnez	a0,8000110c <kvmmap+0x1c>
}
    80001104:	60a2                	ld	ra,8(sp)
    80001106:	6402                	ld	s0,0(sp)
    80001108:	0141                	addi	sp,sp,16
    8000110a:	8082                	ret
    panic("kvmmap");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	00c50513          	addi	a0,a0,12 # 80007118 <etext+0x118>
    80001114:	e8aff0ef          	jal	8000079e <panic>

0000000080001118 <kvmmake>:
{
    80001118:	1101                	addi	sp,sp,-32
    8000111a:	ec06                	sd	ra,24(sp)
    8000111c:	e822                	sd	s0,16(sp)
    8000111e:	e426                	sd	s1,8(sp)
    80001120:	e04a                	sd	s2,0(sp)
    80001122:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001124:	a07ff0ef          	jal	80000b2a <kalloc>
    80001128:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000112a:	6605                	lui	a2,0x1
    8000112c:	4581                	li	a1,0
    8000112e:	ba1ff0ef          	jal	80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001132:	4719                	li	a4,6
    80001134:	6685                	lui	a3,0x1
    80001136:	10000637          	lui	a2,0x10000
    8000113a:	85b2                	mv	a1,a2
    8000113c:	8526                	mv	a0,s1
    8000113e:	fb3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001142:	4719                	li	a4,6
    80001144:	6685                	lui	a3,0x1
    80001146:	10001637          	lui	a2,0x10001
    8000114a:	85b2                	mv	a1,a2
    8000114c:	8526                	mv	a0,s1
    8000114e:	fa3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001152:	4719                	li	a4,6
    80001154:	040006b7          	lui	a3,0x4000
    80001158:	0c000637          	lui	a2,0xc000
    8000115c:	85b2                	mv	a1,a2
    8000115e:	8526                	mv	a0,s1
    80001160:	f91ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001164:	00006917          	auipc	s2,0x6
    80001168:	e9c90913          	addi	s2,s2,-356 # 80007000 <etext>
    8000116c:	4729                	li	a4,10
    8000116e:	80006697          	auipc	a3,0x80006
    80001172:	e9268693          	addi	a3,a3,-366 # 7000 <_entry-0x7fff9000>
    80001176:	4605                	li	a2,1
    80001178:	067e                	slli	a2,a2,0x1f
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f73ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	46c5                	li	a3,17
    80001186:	06ee                	slli	a3,a3,0x1b
    80001188:	412686b3          	sub	a3,a3,s2
    8000118c:	864a                	mv	a2,s2
    8000118e:	85ca                	mv	a1,s2
    80001190:	8526                	mv	a0,s1
    80001192:	f5fff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001196:	4729                	li	a4,10
    80001198:	6685                	lui	a3,0x1
    8000119a:	00005617          	auipc	a2,0x5
    8000119e:	e6660613          	addi	a2,a2,-410 # 80006000 <_trampoline>
    800011a2:	040005b7          	lui	a1,0x4000
    800011a6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011a8:	05b2                	slli	a1,a1,0xc
    800011aa:	8526                	mv	a0,s1
    800011ac:	f45ff0ef          	jal	800010f0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011b0:	8526                	mv	a0,s1
    800011b2:	5a8000ef          	jal	8000175a <proc_mapstacks>
}
    800011b6:	8526                	mv	a0,s1
    800011b8:	60e2                	ld	ra,24(sp)
    800011ba:	6442                	ld	s0,16(sp)
    800011bc:	64a2                	ld	s1,8(sp)
    800011be:	6902                	ld	s2,0(sp)
    800011c0:	6105                	addi	sp,sp,32
    800011c2:	8082                	ret

00000000800011c4 <kvminit>:
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011cc:	f4dff0ef          	jal	80001118 <kvmmake>
    800011d0:	00006797          	auipc	a5,0x6
    800011d4:	72a7b023          	sd	a0,1824(a5) # 800078f0 <kernel_pagetable>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	715d                	addi	sp,sp,-80
    800011e2:	e486                	sd	ra,72(sp)
    800011e4:	e0a2                	sd	s0,64(sp)
    800011e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e39d                	bnez	a5,80001212 <uvmunmap+0x32>
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    800011fa:	8a2a                	mv	s4,a0
    800011fc:	892e                	mv	s2,a1
    800011fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001200:	0632                	slli	a2,a2,0xc
    80001202:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001206:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001208:	6b05                	lui	s6,0x1
    8000120a:	0735ff63          	bgeu	a1,s3,80001288 <uvmunmap+0xa8>
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	a0a9                	j	8000125a <uvmunmap+0x7a>
    80001212:	fc26                	sd	s1,56(sp)
    80001214:	f84a                	sd	s2,48(sp)
    80001216:	f44e                	sd	s3,40(sp)
    80001218:	f052                	sd	s4,32(sp)
    8000121a:	ec56                	sd	s5,24(sp)
    8000121c:	e85a                	sd	s6,16(sp)
    8000121e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001220:	00006517          	auipc	a0,0x6
    80001224:	f0050513          	addi	a0,a0,-256 # 80007120 <etext+0x120>
    80001228:	d76ff0ef          	jal	8000079e <panic>
      panic("uvmunmap: walk");
    8000122c:	00006517          	auipc	a0,0x6
    80001230:	f0c50513          	addi	a0,a0,-244 # 80007138 <etext+0x138>
    80001234:	d6aff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not mapped");
    80001238:	00006517          	auipc	a0,0x6
    8000123c:	f1050513          	addi	a0,a0,-240 # 80007148 <etext+0x148>
    80001240:	d5eff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not a leaf");
    80001244:	00006517          	auipc	a0,0x6
    80001248:	f1c50513          	addi	a0,a0,-228 # 80007160 <etext+0x160>
    8000124c:	d52ff0ef          	jal	8000079e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001250:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001254:	995a                	add	s2,s2,s6
    80001256:	03397863          	bgeu	s2,s3,80001286 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125a:	4601                	li	a2,0
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8552                	mv	a0,s4
    80001260:	d03ff0ef          	jal	80000f62 <walk>
    80001264:	84aa                	mv	s1,a0
    80001266:	d179                	beqz	a0,8000122c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001268:	6108                	ld	a0,0(a0)
    8000126a:	00157793          	andi	a5,a0,1
    8000126e:	d7e9                	beqz	a5,80001238 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001270:	3ff57793          	andi	a5,a0,1023
    80001274:	fd7788e3          	beq	a5,s7,80001244 <uvmunmap+0x64>
    if(do_free){
    80001278:	fc0a8ce3          	beqz	s5,80001250 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000127c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000127e:	0532                	slli	a0,a0,0xc
    80001280:	fc8ff0ef          	jal	80000a48 <kfree>
    80001284:	b7f1                	j	80001250 <uvmunmap+0x70>
    80001286:	74e2                	ld	s1,56(sp)
    80001288:	7942                	ld	s2,48(sp)
    8000128a:	79a2                	ld	s3,40(sp)
    8000128c:	7a02                	ld	s4,32(sp)
    8000128e:	6ae2                	ld	s5,24(sp)
    80001290:	6b42                	ld	s6,16(sp)
    80001292:	6ba2                	ld	s7,8(sp)
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret

000000008000129c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000129c:	1101                	addi	sp,sp,-32
    8000129e:	ec06                	sd	ra,24(sp)
    800012a0:	e822                	sd	s0,16(sp)
    800012a2:	e426                	sd	s1,8(sp)
    800012a4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012a6:	885ff0ef          	jal	80000b2a <kalloc>
    800012aa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012ac:	c509                	beqz	a0,800012b6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012ae:	6605                	lui	a2,0x1
    800012b0:	4581                	li	a1,0
    800012b2:	a1dff0ef          	jal	80000cce <memset>
  return pagetable;
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret

00000000800012c2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012c2:	7179                	addi	sp,sp,-48
    800012c4:	f406                	sd	ra,40(sp)
    800012c6:	f022                	sd	s0,32(sp)
    800012c8:	ec26                	sd	s1,24(sp)
    800012ca:	e84a                	sd	s2,16(sp)
    800012cc:	e44e                	sd	s3,8(sp)
    800012ce:	e052                	sd	s4,0(sp)
    800012d0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012d2:	6785                	lui	a5,0x1
    800012d4:	04f67063          	bgeu	a2,a5,80001314 <uvmfirst+0x52>
    800012d8:	8a2a                	mv	s4,a0
    800012da:	89ae                	mv	s3,a1
    800012dc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012de:	84dff0ef          	jal	80000b2a <kalloc>
    800012e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e4:	6605                	lui	a2,0x1
    800012e6:	4581                	li	a1,0
    800012e8:	9e7ff0ef          	jal	80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012ec:	4779                	li	a4,30
    800012ee:	86ca                	mv	a3,s2
    800012f0:	6605                	lui	a2,0x1
    800012f2:	4581                	li	a1,0
    800012f4:	8552                	mv	a0,s4
    800012f6:	d45ff0ef          	jal	8000103a <mappages>
  memmove(mem, src, sz);
    800012fa:	8626                	mv	a2,s1
    800012fc:	85ce                	mv	a1,s3
    800012fe:	854a                	mv	a0,s2
    80001300:	a33ff0ef          	jal	80000d32 <memmove>
}
    80001304:	70a2                	ld	ra,40(sp)
    80001306:	7402                	ld	s0,32(sp)
    80001308:	64e2                	ld	s1,24(sp)
    8000130a:	6942                	ld	s2,16(sp)
    8000130c:	69a2                	ld	s3,8(sp)
    8000130e:	6a02                	ld	s4,0(sp)
    80001310:	6145                	addi	sp,sp,48
    80001312:	8082                	ret
    panic("uvmfirst: more than a page");
    80001314:	00006517          	auipc	a0,0x6
    80001318:	e6450513          	addi	a0,a0,-412 # 80007178 <etext+0x178>
    8000131c:	c82ff0ef          	jal	8000079e <panic>

0000000080001320 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000132a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000132c:	00b67d63          	bgeu	a2,a1,80001346 <uvmdealloc+0x26>
    80001330:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001332:	6785                	lui	a5,0x1
    80001334:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001336:	00f60733          	add	a4,a2,a5
    8000133a:	76fd                	lui	a3,0xfffff
    8000133c:	8f75                	and	a4,a4,a3
    8000133e:	97ae                	add	a5,a5,a1
    80001340:	8ff5                	and	a5,a5,a3
    80001342:	00f76863          	bltu	a4,a5,80001352 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001346:	8526                	mv	a0,s1
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001352:	8f99                	sub	a5,a5,a4
    80001354:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001356:	4685                	li	a3,1
    80001358:	0007861b          	sext.w	a2,a5
    8000135c:	85ba                	mv	a1,a4
    8000135e:	e83ff0ef          	jal	800011e0 <uvmunmap>
    80001362:	b7d5                	j	80001346 <uvmdealloc+0x26>

0000000080001364 <uvmalloc>:
  if(newsz < oldsz)
    80001364:	0ab66363          	bltu	a2,a1,8000140a <uvmalloc+0xa6>
{
    80001368:	715d                	addi	sp,sp,-80
    8000136a:	e486                	sd	ra,72(sp)
    8000136c:	e0a2                	sd	s0,64(sp)
    8000136e:	f052                	sd	s4,32(sp)
    80001370:	ec56                	sd	s5,24(sp)
    80001372:	e85a                	sd	s6,16(sp)
    80001374:	0880                	addi	s0,sp,80
    80001376:	8b2a                	mv	s6,a0
    80001378:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    8000137a:	6785                	lui	a5,0x1
    8000137c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000137e:	95be                	add	a1,a1,a5
    80001380:	77fd                	lui	a5,0xfffff
    80001382:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001386:	08ca7463          	bgeu	s4,a2,8000140e <uvmalloc+0xaa>
    8000138a:	fc26                	sd	s1,56(sp)
    8000138c:	f84a                	sd	s2,48(sp)
    8000138e:	f44e                	sd	s3,40(sp)
    80001390:	e45e                	sd	s7,8(sp)
    80001392:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    80001394:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    8000139a:	f90ff0ef          	jal	80000b2a <kalloc>
    8000139e:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a0:	c515                	beqz	a0,800013cc <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800013a2:	864e                	mv	a2,s3
    800013a4:	4581                	li	a1,0
    800013a6:	929ff0ef          	jal	80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013aa:	875e                	mv	a4,s7
    800013ac:	86a6                	mv	a3,s1
    800013ae:	864e                	mv	a2,s3
    800013b0:	85ca                	mv	a1,s2
    800013b2:	855a                	mv	a0,s6
    800013b4:	c87ff0ef          	jal	8000103a <mappages>
    800013b8:	e91d                	bnez	a0,800013ee <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ba:	994e                	add	s2,s2,s3
    800013bc:	fd596fe3          	bltu	s2,s5,8000139a <uvmalloc+0x36>
  return newsz;
    800013c0:	8556                	mv	a0,s5
    800013c2:	74e2                	ld	s1,56(sp)
    800013c4:	7942                	ld	s2,48(sp)
    800013c6:	79a2                	ld	s3,40(sp)
    800013c8:	6ba2                	ld	s7,8(sp)
    800013ca:	a819                	j	800013e0 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	8652                	mv	a2,s4
    800013ce:	85ca                	mv	a1,s2
    800013d0:	855a                	mv	a0,s6
    800013d2:	f4fff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	6ba2                	ld	s7,8(sp)
}
    800013e0:	60a6                	ld	ra,72(sp)
    800013e2:	6406                	ld	s0,64(sp)
    800013e4:	7a02                	ld	s4,32(sp)
    800013e6:	6ae2                	ld	s5,24(sp)
    800013e8:	6b42                	ld	s6,16(sp)
    800013ea:	6161                	addi	sp,sp,80
    800013ec:	8082                	ret
      kfree(mem);
    800013ee:	8526                	mv	a0,s1
    800013f0:	e58ff0ef          	jal	80000a48 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f4:	8652                	mv	a2,s4
    800013f6:	85ca                	mv	a1,s2
    800013f8:	855a                	mv	a0,s6
    800013fa:	f27ff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013fe:	4501                	li	a0,0
    80001400:	74e2                	ld	s1,56(sp)
    80001402:	7942                	ld	s2,48(sp)
    80001404:	79a2                	ld	s3,40(sp)
    80001406:	6ba2                	ld	s7,8(sp)
    80001408:	bfe1                	j	800013e0 <uvmalloc+0x7c>
    return oldsz;
    8000140a:	852e                	mv	a0,a1
}
    8000140c:	8082                	ret
  return newsz;
    8000140e:	8532                	mv	a0,a2
    80001410:	bfc1                	j	800013e0 <uvmalloc+0x7c>

0000000080001412 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001412:	7179                	addi	sp,sp,-48
    80001414:	f406                	sd	ra,40(sp)
    80001416:	f022                	sd	s0,32(sp)
    80001418:	ec26                	sd	s1,24(sp)
    8000141a:	e84a                	sd	s2,16(sp)
    8000141c:	e44e                	sd	s3,8(sp)
    8000141e:	e052                	sd	s4,0(sp)
    80001420:	1800                	addi	s0,sp,48
    80001422:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001424:	84aa                	mv	s1,a0
    80001426:	6905                	lui	s2,0x1
    80001428:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000142a:	4985                	li	s3,1
    8000142c:	a819                	j	80001442 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000142e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001430:	00c79513          	slli	a0,a5,0xc
    80001434:	fdfff0ef          	jal	80001412 <freewalk>
      pagetable[i] = 0;
    80001438:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000143c:	04a1                	addi	s1,s1,8
    8000143e:	01248f63          	beq	s1,s2,8000145c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001442:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001444:	00f7f713          	andi	a4,a5,15
    80001448:	ff3703e3          	beq	a4,s3,8000142e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000144c:	8b85                	andi	a5,a5,1
    8000144e:	d7fd                	beqz	a5,8000143c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001450:	00006517          	auipc	a0,0x6
    80001454:	d4850513          	addi	a0,a0,-696 # 80007198 <etext+0x198>
    80001458:	b46ff0ef          	jal	8000079e <panic>
    }
  }
  kfree((void*)pagetable);
    8000145c:	8552                	mv	a0,s4
    8000145e:	deaff0ef          	jal	80000a48 <kfree>
}
    80001462:	70a2                	ld	ra,40(sp)
    80001464:	7402                	ld	s0,32(sp)
    80001466:	64e2                	ld	s1,24(sp)
    80001468:	6942                	ld	s2,16(sp)
    8000146a:	69a2                	ld	s3,8(sp)
    8000146c:	6a02                	ld	s4,0(sp)
    8000146e:	6145                	addi	sp,sp,48
    80001470:	8082                	ret

0000000080001472 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001472:	1101                	addi	sp,sp,-32
    80001474:	ec06                	sd	ra,24(sp)
    80001476:	e822                	sd	s0,16(sp)
    80001478:	e426                	sd	s1,8(sp)
    8000147a:	1000                	addi	s0,sp,32
    8000147c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000147e:	e989                	bnez	a1,80001490 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001480:	8526                	mv	a0,s1
    80001482:	f91ff0ef          	jal	80001412 <freewalk>
}
    80001486:	60e2                	ld	ra,24(sp)
    80001488:	6442                	ld	s0,16(sp)
    8000148a:	64a2                	ld	s1,8(sp)
    8000148c:	6105                	addi	sp,sp,32
    8000148e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	4685                	li	a3,1
    80001498:	00c5d613          	srli	a2,a1,0xc
    8000149c:	4581                	li	a1,0
    8000149e:	d43ff0ef          	jal	800011e0 <uvmunmap>
    800014a2:	bff9                	j	80001480 <uvmfree+0xe>

00000000800014a4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014a4:	ca4d                	beqz	a2,80001556 <uvmcopy+0xb2>
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	fc26                	sd	s1,56(sp)
    800014ae:	f84a                	sd	s2,48(sp)
    800014b0:	f44e                	sd	s3,40(sp)
    800014b2:	f052                	sd	s4,32(sp)
    800014b4:	ec56                	sd	s5,24(sp)
    800014b6:	e85a                	sd	s6,16(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	e062                	sd	s8,0(sp)
    800014bc:	0880                	addi	s0,sp,80
    800014be:	8baa                	mv	s7,a0
    800014c0:	8b2e                	mv	s6,a1
    800014c2:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c4:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014c6:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    800014c8:	4601                	li	a2,0
    800014ca:	85ce                	mv	a1,s3
    800014cc:	855e                	mv	a0,s7
    800014ce:	a95ff0ef          	jal	80000f62 <walk>
    800014d2:	cd1d                	beqz	a0,80001510 <uvmcopy+0x6c>
    if((*pte & PTE_V) == 0)
    800014d4:	6118                	ld	a4,0(a0)
    800014d6:	00177793          	andi	a5,a4,1
    800014da:	c3a9                	beqz	a5,8000151c <uvmcopy+0x78>
    pa = PTE2PA(*pte);
    800014dc:	00a75593          	srli	a1,a4,0xa
    800014e0:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014e8:	e42ff0ef          	jal	80000b2a <kalloc>
    800014ec:	892a                	mv	s2,a0
    800014ee:	c121                	beqz	a0,8000152e <uvmcopy+0x8a>
    memmove(mem, (char*)pa, PGSIZE);
    800014f0:	8652                	mv	a2,s4
    800014f2:	85e2                	mv	a1,s8
    800014f4:	83fff0ef          	jal	80000d32 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014f8:	8726                	mv	a4,s1
    800014fa:	86ca                	mv	a3,s2
    800014fc:	8652                	mv	a2,s4
    800014fe:	85ce                	mv	a1,s3
    80001500:	855a                	mv	a0,s6
    80001502:	b39ff0ef          	jal	8000103a <mappages>
    80001506:	e10d                	bnez	a0,80001528 <uvmcopy+0x84>
  for(i = 0; i < sz; i += PGSIZE){
    80001508:	99d2                	add	s3,s3,s4
    8000150a:	fb59efe3          	bltu	s3,s5,800014c8 <uvmcopy+0x24>
    8000150e:	a805                	j	8000153e <uvmcopy+0x9a>
      panic("uvmcopy: pte should exist");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	c9850513          	addi	a0,a0,-872 # 800071a8 <etext+0x1a8>
    80001518:	a86ff0ef          	jal	8000079e <panic>
      panic("uvmcopy: page not present");
    8000151c:	00006517          	auipc	a0,0x6
    80001520:	cac50513          	addi	a0,a0,-852 # 800071c8 <etext+0x1c8>
    80001524:	a7aff0ef          	jal	8000079e <panic>
      kfree(mem);
    80001528:	854a                	mv	a0,s2
    8000152a:	d1eff0ef          	jal	80000a48 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152e:	4685                	li	a3,1
    80001530:	00c9d613          	srli	a2,s3,0xc
    80001534:	4581                	li	a1,0
    80001536:	855a                	mv	a0,s6
    80001538:	ca9ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    8000153c:	557d                	li	a0,-1
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6c02                	ld	s8,0(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
  return 0;
    80001556:	4501                	li	a0,0
}
    80001558:	8082                	ret

000000008000155a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001562:	4601                	li	a2,0
    80001564:	9ffff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001568:	c901                	beqz	a0,80001578 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000156a:	611c                	ld	a5,0(a0)
    8000156c:	9bbd                	andi	a5,a5,-17
    8000156e:	e11c                	sd	a5,0(a0)
}
    80001570:	60a2                	ld	ra,8(sp)
    80001572:	6402                	ld	s0,0(sp)
    80001574:	0141                	addi	sp,sp,16
    80001576:	8082                	ret
    panic("uvmclear");
    80001578:	00006517          	auipc	a0,0x6
    8000157c:	c7050513          	addi	a0,a0,-912 # 800071e8 <etext+0x1e8>
    80001580:	a1eff0ef          	jal	8000079e <panic>

0000000080001584 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001584:	c2d9                	beqz	a3,8000160a <copyout+0x86>
{
    80001586:	711d                	addi	sp,sp,-96
    80001588:	ec86                	sd	ra,88(sp)
    8000158a:	e8a2                	sd	s0,80(sp)
    8000158c:	e4a6                	sd	s1,72(sp)
    8000158e:	e0ca                	sd	s2,64(sp)
    80001590:	fc4e                	sd	s3,56(sp)
    80001592:	f852                	sd	s4,48(sp)
    80001594:	f456                	sd	s5,40(sp)
    80001596:	f05a                	sd	s6,32(sp)
    80001598:	ec5e                	sd	s7,24(sp)
    8000159a:	e862                	sd	s8,16(sp)
    8000159c:	e466                	sd	s9,8(sp)
    8000159e:	e06a                	sd	s10,0(sp)
    800015a0:	1080                	addi	s0,sp,96
    800015a2:	8c2a                	mv	s8,a0
    800015a4:	892e                	mv	s2,a1
    800015a6:	8ab2                	mv	s5,a2
    800015a8:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015aa:	7cfd                	lui	s9,0xfffff
    if(va0 >= MAXVA)
    800015ac:	5bfd                	li	s7,-1
    800015ae:	01abdb93          	srli	s7,s7,0x1a
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015b2:	4d55                	li	s10,21
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    800015b4:	6b05                	lui	s6,0x1
    800015b6:	a015                	j	800015da <copyout+0x56>
    pa0 = PTE2PA(*pte);
    800015b8:	83a9                	srli	a5,a5,0xa
    800015ba:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	41390533          	sub	a0,s2,s3
    800015c0:	0004861b          	sext.w	a2,s1
    800015c4:	85d6                	mv	a1,s5
    800015c6:	953e                	add	a0,a0,a5
    800015c8:	f6aff0ef          	jal	80000d32 <memmove>

    len -= n;
    800015cc:	409a0a33          	sub	s4,s4,s1
    src += n;
    800015d0:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800015d2:	01698933          	add	s2,s3,s6
  while(len > 0){
    800015d6:	020a0863          	beqz	s4,80001606 <copyout+0x82>
    va0 = PGROUNDDOWN(dstva);
    800015da:	019979b3          	and	s3,s2,s9
    if(va0 >= MAXVA)
    800015de:	033be863          	bltu	s7,s3,8000160e <copyout+0x8a>
    pte = walk(pagetable, va0, 0);
    800015e2:	4601                	li	a2,0
    800015e4:	85ce                	mv	a1,s3
    800015e6:	8562                	mv	a0,s8
    800015e8:	97bff0ef          	jal	80000f62 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ec:	c121                	beqz	a0,8000162c <copyout+0xa8>
    800015ee:	611c                	ld	a5,0(a0)
    800015f0:	0157f713          	andi	a4,a5,21
    800015f4:	03a71e63          	bne	a4,s10,80001630 <copyout+0xac>
    n = PGSIZE - (dstva - va0);
    800015f8:	412984b3          	sub	s1,s3,s2
    800015fc:	94da                	add	s1,s1,s6
    if(n > len)
    800015fe:	fa9a7de3          	bgeu	s4,s1,800015b8 <copyout+0x34>
    80001602:	84d2                	mv	s1,s4
    80001604:	bf55                	j	800015b8 <copyout+0x34>
  }
  return 0;
    80001606:	4501                	li	a0,0
    80001608:	a021                	j	80001610 <copyout+0x8c>
    8000160a:	4501                	li	a0,0
}
    8000160c:	8082                	ret
      return -1;
    8000160e:	557d                	li	a0,-1
}
    80001610:	60e6                	ld	ra,88(sp)
    80001612:	6446                	ld	s0,80(sp)
    80001614:	64a6                	ld	s1,72(sp)
    80001616:	6906                	ld	s2,64(sp)
    80001618:	79e2                	ld	s3,56(sp)
    8000161a:	7a42                	ld	s4,48(sp)
    8000161c:	7aa2                	ld	s5,40(sp)
    8000161e:	7b02                	ld	s6,32(sp)
    80001620:	6be2                	ld	s7,24(sp)
    80001622:	6c42                	ld	s8,16(sp)
    80001624:	6ca2                	ld	s9,8(sp)
    80001626:	6d02                	ld	s10,0(sp)
    80001628:	6125                	addi	sp,sp,96
    8000162a:	8082                	ret
      return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	b7cd                	j	80001610 <copyout+0x8c>
    80001630:	557d                	li	a0,-1
    80001632:	bff9                	j	80001610 <copyout+0x8c>

0000000080001634 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001634:	c6a5                	beqz	a3,8000169c <copyin+0x68>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	e062                	sd	s8,0(sp)
    8000164c:	0880                	addi	s0,sp,80
    8000164e:	8b2a                	mv	s6,a0
    80001650:	8a2e                	mv	s4,a1
    80001652:	8c32                	mv	s8,a2
    80001654:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001656:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001658:	6a85                	lui	s5,0x1
    8000165a:	a00d                	j	8000167c <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000165c:	018505b3          	add	a1,a0,s8
    80001660:	0004861b          	sext.w	a2,s1
    80001664:	412585b3          	sub	a1,a1,s2
    80001668:	8552                	mv	a0,s4
    8000166a:	ec8ff0ef          	jal	80000d32 <memmove>

    len -= n;
    8000166e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001672:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001674:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001678:	02098063          	beqz	s3,80001698 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000167c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001680:	85ca                	mv	a1,s2
    80001682:	855a                	mv	a0,s6
    80001684:	979ff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001688:	cd01                	beqz	a0,800016a0 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000168a:	418904b3          	sub	s1,s2,s8
    8000168e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001690:	fc99f6e3          	bgeu	s3,s1,8000165c <copyin+0x28>
    80001694:	84ce                	mv	s1,s3
    80001696:	b7d9                	j	8000165c <copyin+0x28>
  }
  return 0;
    80001698:	4501                	li	a0,0
    8000169a:	a021                	j	800016a2 <copyin+0x6e>
    8000169c:	4501                	li	a0,0
}
    8000169e:	8082                	ret
      return -1;
    800016a0:	557d                	li	a0,-1
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret

00000000800016ba <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800016ba:	715d                	addi	sp,sp,-80
    800016bc:	e486                	sd	ra,72(sp)
    800016be:	e0a2                	sd	s0,64(sp)
    800016c0:	fc26                	sd	s1,56(sp)
    800016c2:	f84a                	sd	s2,48(sp)
    800016c4:	f44e                	sd	s3,40(sp)
    800016c6:	f052                	sd	s4,32(sp)
    800016c8:	ec56                	sd	s5,24(sp)
    800016ca:	e85a                	sd	s6,16(sp)
    800016cc:	e45e                	sd	s7,8(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8aaa                	mv	s5,a0
    800016d2:	89ae                	mv	s3,a1
    800016d4:	8bb2                	mv	s7,a2
    800016d6:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    800016d8:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016da:	6a05                	lui	s4,0x1
    800016dc:	a02d                	j	80001706 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016de:	00078023          	sb	zero,0(a5)
    800016e2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016e4:	0017c793          	xori	a5,a5,1
    800016e8:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret
    srcva = va0 + PGSIZE;
    80001702:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001706:	c4b1                	beqz	s1,80001752 <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    80001708:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000170c:	85ca                	mv	a1,s2
    8000170e:	8556                	mv	a0,s5
    80001710:	8edff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001714:	c129                	beqz	a0,80001756 <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    80001716:	41790633          	sub	a2,s2,s7
    8000171a:	9652                	add	a2,a2,s4
    if(n > max)
    8000171c:	00c4f363          	bgeu	s1,a2,80001722 <copyinstr+0x68>
    80001720:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001722:	412b8bb3          	sub	s7,s7,s2
    80001726:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001728:	de69                	beqz	a2,80001702 <copyinstr+0x48>
    8000172a:	87ce                	mv	a5,s3
      if(*p == '\0'){
    8000172c:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001730:	964e                	add	a2,a2,s3
    80001732:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001734:	00f68733          	add	a4,a3,a5
    80001738:	00074703          	lbu	a4,0(a4)
    8000173c:	d34d                	beqz	a4,800016de <copyinstr+0x24>
        *dst = *p;
    8000173e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001742:	0785                	addi	a5,a5,1
    while(n > 0){
    80001744:	fec797e3          	bne	a5,a2,80001732 <copyinstr+0x78>
    80001748:	14fd                	addi	s1,s1,-1
    8000174a:	94ce                	add	s1,s1,s3
      --max;
    8000174c:	8c8d                	sub	s1,s1,a1
    8000174e:	89be                	mv	s3,a5
    80001750:	bf4d                	j	80001702 <copyinstr+0x48>
    80001752:	4781                	li	a5,0
    80001754:	bf41                	j	800016e4 <copyinstr+0x2a>
      return -1;
    80001756:	557d                	li	a0,-1
    80001758:	bf51                	j	800016ec <copyinstr+0x32>

000000008000175a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	e062                	sd	s8,0(sp)
    80001770:	0880                	addi	s0,sp,80
    80001772:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001774:	0000e497          	auipc	s1,0xe
    80001778:	6ec48493          	addi	s1,s1,1772 # 8000fe60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	a4fa57b7          	lui	a5,0xa4fa5
    80001782:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f84365>
    80001786:	4fa50937          	lui	s2,0x4fa50
    8000178a:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179e:	00014a97          	auipc	s5,0x14
    800017a2:	0c2a8a93          	addi	s5,s5,194 # 80015860 <tickslock>
    char *pa = kalloc();
    800017a6:	b84ff0ef          	jal	80000b2a <kalloc>
    800017aa:	862a                	mv	a2,a0
    if(pa == 0)
    800017ac:	c121                	beqz	a0,800017ec <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	418485b3          	sub	a1,s1,s8
    800017b2:	858d                	srai	a1,a1,0x3
    800017b4:	032585b3          	mul	a1,a1,s2
    800017b8:	2585                	addiw	a1,a1,1
    800017ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017be:	875e                	mv	a4,s7
    800017c0:	86da                	mv	a3,s6
    800017c2:	40b985b3          	sub	a1,s3,a1
    800017c6:	8552                	mv	a0,s4
    800017c8:	929ff0ef          	jal	800010f0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	16848493          	addi	s1,s1,360
    800017d0:	fd549be3          	bne	s1,s5,800017a6 <proc_mapstacks+0x4c>
  }
}
    800017d4:	60a6                	ld	ra,72(sp)
    800017d6:	6406                	ld	s0,64(sp)
    800017d8:	74e2                	ld	s1,56(sp)
    800017da:	7942                	ld	s2,48(sp)
    800017dc:	79a2                	ld	s3,40(sp)
    800017de:	7a02                	ld	s4,32(sp)
    800017e0:	6ae2                	ld	s5,24(sp)
    800017e2:	6b42                	ld	s6,16(sp)
    800017e4:	6ba2                	ld	s7,8(sp)
    800017e6:	6c02                	ld	s8,0(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fabfe0ef          	jal	8000079e <panic>

00000000800017f8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	0000e517          	auipc	a0,0xe
    80001818:	21c50513          	addi	a0,a0,540 # 8000fa30 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	22050513          	addi	a0,a0,544 # 8000fa48 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	0000e497          	auipc	s1,0xe
    80001838:	62c48493          	addi	s1,s1,1580 # 8000fe60 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	a4fa57b7          	lui	a5,0xa4fa5
    8000184a:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f84365>
    8000184e:	4fa50937          	lui	s2,0x4fa50
    80001852:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	00014a17          	auipc	s4,0x14
    80001866:	ffea0a13          	addi	s4,s4,-2 # 80015860 <tickslock>
      initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b0cff0ef          	jal	80000b7a <initlock>
      p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	878d                	srai	a5,a5,0x3
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	16848493          	addi	s1,s1,360
    80001890:	fd449de3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret

00000000800018a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a8:	1141                	addi	sp,sp,-16
    800018aa:	e406                	sd	ra,8(sp)
    800018ac:	e022                	sd	s0,0(sp)
    800018ae:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018b0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b2:	2501                	sext.w	a0,a0
    800018b4:	60a2                	ld	ra,8(sp)
    800018b6:	6402                	ld	s0,0(sp)
    800018b8:	0141                	addi	sp,sp,16
    800018ba:	8082                	ret

00000000800018bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018bc:	1141                	addi	sp,sp,-16
    800018be:	e406                	sd	ra,8(sp)
    800018c0:	e022                	sd	s0,0(sp)
    800018c2:	0800                	addi	s0,sp,16
    800018c4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c6:	2781                	sext.w	a5,a5
    800018c8:	079e                	slli	a5,a5,0x7
  return c;
}
    800018ca:	0000e517          	auipc	a0,0xe
    800018ce:	19650513          	addi	a0,a0,406 # 8000fa60 <cpus>
    800018d2:	953e                	add	a0,a0,a5
    800018d4:	60a2                	ld	ra,8(sp)
    800018d6:	6402                	ld	s0,0(sp)
    800018d8:	0141                	addi	sp,sp,16
    800018da:	8082                	ret

00000000800018dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018dc:	1101                	addi	sp,sp,-32
    800018de:	ec06                	sd	ra,24(sp)
    800018e0:	e822                	sd	s0,16(sp)
    800018e2:	e426                	sd	s1,8(sp)
    800018e4:	1000                	addi	s0,sp,32
  push_off();
    800018e6:	ad8ff0ef          	jal	80000bbe <push_off>
    800018ea:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ec:	2781                	sext.w	a5,a5
    800018ee:	079e                	slli	a5,a5,0x7
    800018f0:	0000e717          	auipc	a4,0xe
    800018f4:	14070713          	addi	a4,a4,320 # 8000fa30 <pid_lock>
    800018f8:	97ba                	add	a5,a5,a4
    800018fa:	7b84                	ld	s1,48(a5)
  pop_off();
    800018fc:	b46ff0ef          	jal	80000c42 <pop_off>
  return p;
}
    80001900:	8526                	mv	a0,s1
    80001902:	60e2                	ld	ra,24(sp)
    80001904:	6442                	ld	s0,16(sp)
    80001906:	64a2                	ld	s1,8(sp)
    80001908:	6105                	addi	sp,sp,32
    8000190a:	8082                	ret

000000008000190c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000190c:	1141                	addi	sp,sp,-16
    8000190e:	e406                	sd	ra,8(sp)
    80001910:	e022                	sd	s0,0(sp)
    80001912:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001914:	fc9ff0ef          	jal	800018dc <myproc>
    80001918:	b7aff0ef          	jal	80000c92 <release>

  if (first) {
    8000191c:	00006797          	auipc	a5,0x6
    80001920:	f647a783          	lw	a5,-156(a5) # 80007880 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	2bd000ef          	jal	800023e2 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	624010ef          	jal	80002f58 <fsinit>
    first = 0;
    80001938:	00006797          	auipc	a5,0x6
    8000193c:	f407a423          	sw	zero,-184(a5) # 80007880 <first.1>
    __sync_synchronize();
    80001940:	0330000f          	fence	rw,rw
    80001944:	b7cd                	j	80001926 <forkret+0x1a>

0000000080001946 <allocpid>:
{
    80001946:	1101                	addi	sp,sp,-32
    80001948:	ec06                	sd	ra,24(sp)
    8000194a:	e822                	sd	s0,16(sp)
    8000194c:	e426                	sd	s1,8(sp)
    8000194e:	e04a                	sd	s2,0(sp)
    80001950:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001952:	0000e917          	auipc	s2,0xe
    80001956:	0de90913          	addi	s2,s2,222 # 8000fa30 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00006797          	auipc	a5,0x6
    80001964:	f2478793          	addi	a5,a5,-220 # 80007884 <nextpid>
    80001968:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196a:	0014871b          	addiw	a4,s1,1
    8000196e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001970:	854a                	mv	a0,s2
    80001972:	b20ff0ef          	jal	80000c92 <release>
}
    80001976:	8526                	mv	a0,s1
    80001978:	60e2                	ld	ra,24(sp)
    8000197a:	6442                	ld	s0,16(sp)
    8000197c:	64a2                	ld	s1,8(sp)
    8000197e:	6902                	ld	s2,0(sp)
    80001980:	6105                	addi	sp,sp,32
    80001982:	8082                	ret

0000000080001984 <proc_pagetable>:
{
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	e426                	sd	s1,8(sp)
    8000198c:	e04a                	sd	s2,0(sp)
    8000198e:	1000                	addi	s0,sp,32
    80001990:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001992:	90bff0ef          	jal	8000129c <uvmcreate>
    80001996:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001998:	cd05                	beqz	a0,800019d0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199a:	4729                	li	a4,10
    8000199c:	00004697          	auipc	a3,0x4
    800019a0:	66468693          	addi	a3,a3,1636 # 80006000 <_trampoline>
    800019a4:	6605                	lui	a2,0x1
    800019a6:	040005b7          	lui	a1,0x4000
    800019aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	05b2                	slli	a1,a1,0xc
    800019ae:	e8cff0ef          	jal	8000103a <mappages>
    800019b2:	02054663          	bltz	a0,800019de <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019b6:	4719                	li	a4,6
    800019b8:	05893683          	ld	a3,88(s2)
    800019bc:	6605                	lui	a2,0x1
    800019be:	020005b7          	lui	a1,0x2000
    800019c2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c4:	05b6                	slli	a1,a1,0xd
    800019c6:	8526                	mv	a0,s1
    800019c8:	e72ff0ef          	jal	8000103a <mappages>
    800019cc:	00054f63          	bltz	a0,800019ea <proc_pagetable+0x66>
}
    800019d0:	8526                	mv	a0,s1
    800019d2:	60e2                	ld	ra,24(sp)
    800019d4:	6442                	ld	s0,16(sp)
    800019d6:	64a2                	ld	s1,8(sp)
    800019d8:	6902                	ld	s2,0(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret
    uvmfree(pagetable, 0);
    800019de:	4581                	li	a1,0
    800019e0:	8526                	mv	a0,s1
    800019e2:	a91ff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019e6:	4481                	li	s1,0
    800019e8:	b7e5                	j	800019d0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ea:	4681                	li	a3,0
    800019ec:	4605                	li	a2,1
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	8526                	mv	a0,s1
    800019f8:	fe8ff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    800019fc:	4581                	li	a1,0
    800019fe:	8526                	mv	a0,s1
    80001a00:	a73ff0ef          	jal	80001472 <uvmfree>
    return 0;
    80001a04:	4481                	li	s1,0
    80001a06:	b7e9                	j	800019d0 <proc_pagetable+0x4c>

0000000080001a08 <proc_freepagetable>:
{
    80001a08:	1101                	addi	sp,sp,-32
    80001a0a:	ec06                	sd	ra,24(sp)
    80001a0c:	e822                	sd	s0,16(sp)
    80001a0e:	e426                	sd	s1,8(sp)
    80001a10:	e04a                	sd	s2,0(sp)
    80001a12:	1000                	addi	s0,sp,32
    80001a14:	84aa                	mv	s1,a0
    80001a16:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a18:	4681                	li	a3,0
    80001a1a:	4605                	li	a2,1
    80001a1c:	040005b7          	lui	a1,0x4000
    80001a20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	05b2                	slli	a1,a1,0xc
    80001a24:	fbcff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a28:	4681                	li	a3,0
    80001a2a:	4605                	li	a2,1
    80001a2c:	020005b7          	lui	a1,0x2000
    80001a30:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a32:	05b6                	slli	a1,a1,0xd
    80001a34:	8526                	mv	a0,s1
    80001a36:	faaff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3a:	85ca                	mv	a1,s2
    80001a3c:	8526                	mv	a0,s1
    80001a3e:	a35ff0ef          	jal	80001472 <uvmfree>
}
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <freeproc>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	1000                	addi	s0,sp,32
    80001a58:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c119                	beqz	a0,80001a62 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a5e:	febfe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a62:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a66:	68a8                	ld	a0,80(s1)
    80001a68:	c501                	beqz	a0,80001a70 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6a:	64ac                	ld	a1,72(s1)
    80001a6c:	f9dff0ef          	jal	80001a08 <proc_freepagetable>
  p->pagetable = 0;
    80001a70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a7c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a84:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a88:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a8c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a90:	0004ac23          	sw	zero,24(s1)
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <allocproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	e04a                	sd	s2,0(sp)
    80001aa8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	0000e497          	auipc	s1,0xe
    80001aae:	3b648493          	addi	s1,s1,950 # 8000fe60 <proc>
    80001ab2:	00014917          	auipc	s2,0x14
    80001ab6:	dae90913          	addi	s2,s2,-594 # 80015860 <tickslock>
    acquire(&p->lock);
    80001aba:	8526                	mv	a0,s1
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if(p->state == UNUSED) {
    80001ac0:	4c9c                	lw	a5,24(s1)
    80001ac2:	cb91                	beqz	a5,80001ad6 <allocproc+0x38>
      release(&p->lock);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	9ccff0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aca:	16848493          	addi	s1,s1,360
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a089                	j	80001b16 <allocproc+0x78>
  p->pid = allocpid();
    80001ad6:	e71ff0ef          	jal	80001946 <allocpid>
    80001ada:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001adc:	4785                	li	a5,1
    80001ade:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae0:	84aff0ef          	jal	80000b2a <kalloc>
    80001ae4:	892a                	mv	s2,a0
    80001ae6:	eca8                	sd	a0,88(s1)
    80001ae8:	cd15                	beqz	a0,80001b24 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aea:	8526                	mv	a0,s1
    80001aec:	e99ff0ef          	jal	80001984 <proc_pagetable>
    80001af0:	892a                	mv	s2,a0
    80001af2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af4:	c121                	beqz	a0,80001b34 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001af6:	07000613          	li	a2,112
    80001afa:	4581                	li	a1,0
    80001afc:	06048513          	addi	a0,s1,96
    80001b00:	9ceff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b04:	00000797          	auipc	a5,0x0
    80001b08:	e0878793          	addi	a5,a5,-504 # 8000190c <forkret>
    80001b0c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b0e:	60bc                	ld	a5,64(s1)
    80001b10:	6705                	lui	a4,0x1
    80001b12:	97ba                	add	a5,a5,a4
    80001b14:	f4bc                	sd	a5,104(s1)
}
    80001b16:	8526                	mv	a0,s1
    80001b18:	60e2                	ld	ra,24(sp)
    80001b1a:	6442                	ld	s0,16(sp)
    80001b1c:	64a2                	ld	s1,8(sp)
    80001b1e:	6902                	ld	s2,0(sp)
    80001b20:	6105                	addi	sp,sp,32
    80001b22:	8082                	ret
    freeproc(p);
    80001b24:	8526                	mv	a0,s1
    80001b26:	f29ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	966ff0ef          	jal	80000c92 <release>
    return 0;
    80001b30:	84ca                	mv	s1,s2
    80001b32:	b7d5                	j	80001b16 <allocproc+0x78>
    freeproc(p);
    80001b34:	8526                	mv	a0,s1
    80001b36:	f19ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	956ff0ef          	jal	80000c92 <release>
    return 0;
    80001b40:	84ca                	mv	s1,s2
    80001b42:	bfd1                	j	80001b16 <allocproc+0x78>

0000000080001b44 <userinit>:
{
    80001b44:	1101                	addi	sp,sp,-32
    80001b46:	ec06                	sd	ra,24(sp)
    80001b48:	e822                	sd	s0,16(sp)
    80001b4a:	e426                	sd	s1,8(sp)
    80001b4c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b4e:	f51ff0ef          	jal	80001a9e <allocproc>
    80001b52:	84aa                	mv	s1,a0
  initproc = p;
    80001b54:	00006797          	auipc	a5,0x6
    80001b58:	daa7b223          	sd	a0,-604(a5) # 800078f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b5c:	03400613          	li	a2,52
    80001b60:	00006597          	auipc	a1,0x6
    80001b64:	d3058593          	addi	a1,a1,-720 # 80007890 <initcode>
    80001b68:	6928                	ld	a0,80(a0)
    80001b6a:	f58ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001b6e:	6785                	lui	a5,0x1
    80001b70:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b72:	6cb8                	ld	a4,88(s1)
    80001b74:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b78:	6cb8                	ld	a4,88(s1)
    80001b7a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b7c:	4641                	li	a2,16
    80001b7e:	00005597          	auipc	a1,0x5
    80001b82:	6a258593          	addi	a1,a1,1698 # 80007220 <etext+0x220>
    80001b86:	15848513          	addi	a0,s1,344
    80001b8a:	a96ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001b8e:	00005517          	auipc	a0,0x5
    80001b92:	6a250513          	addi	a0,a0,1698 # 80007230 <etext+0x230>
    80001b96:	4e7010ef          	jal	8000387c <namei>
    80001b9a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b9e:	478d                	li	a5,3
    80001ba0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	8eeff0ef          	jal	80000c92 <release>
}
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <growproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
    80001bbe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc0:	d1dff0ef          	jal	800018dc <myproc>
    80001bc4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bc6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bc8:	01204c63          	bgtz	s2,80001be0 <growproc+0x2e>
  } else if(n < 0){
    80001bcc:	02094463          	bltz	s2,80001bf4 <growproc+0x42>
  p->sz = sz;
    80001bd0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd2:	4501                	li	a0,0
}
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be0:	4691                	li	a3,4
    80001be2:	00b90633          	add	a2,s2,a1
    80001be6:	6928                	ld	a0,80(a0)
    80001be8:	f7cff0ef          	jal	80001364 <uvmalloc>
    80001bec:	85aa                	mv	a1,a0
    80001bee:	f16d                	bnez	a0,80001bd0 <growproc+0x1e>
      return -1;
    80001bf0:	557d                	li	a0,-1
    80001bf2:	b7cd                	j	80001bd4 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf4:	00b90633          	add	a2,s2,a1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f26ff0ef          	jal	80001320 <uvmdealloc>
    80001bfe:	85aa                	mv	a1,a0
    80001c00:	bfc1                	j	80001bd0 <growproc+0x1e>

0000000080001c02 <fork>:
{
    80001c02:	7139                	addi	sp,sp,-64
    80001c04:	fc06                	sd	ra,56(sp)
    80001c06:	f822                	sd	s0,48(sp)
    80001c08:	f04a                	sd	s2,32(sp)
    80001c0a:	e456                	sd	s5,8(sp)
    80001c0c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c0e:	ccfff0ef          	jal	800018dc <myproc>
    80001c12:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c14:	e8bff0ef          	jal	80001a9e <allocproc>
    80001c18:	0e050a63          	beqz	a0,80001d0c <fork+0x10a>
    80001c1c:	e852                	sd	s4,16(sp)
    80001c1e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c20:	048ab603          	ld	a2,72(s5)
    80001c24:	692c                	ld	a1,80(a0)
    80001c26:	050ab503          	ld	a0,80(s5)
    80001c2a:	87bff0ef          	jal	800014a4 <uvmcopy>
    80001c2e:	04054a63          	bltz	a0,80001c82 <fork+0x80>
    80001c32:	f426                	sd	s1,40(sp)
    80001c34:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c36:	048ab783          	ld	a5,72(s5)
    80001c3a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c3e:	058ab683          	ld	a3,88(s5)
    80001c42:	87b6                	mv	a5,a3
    80001c44:	058a3703          	ld	a4,88(s4)
    80001c48:	12068693          	addi	a3,a3,288
    80001c4c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c50:	6788                	ld	a0,8(a5)
    80001c52:	6b8c                	ld	a1,16(a5)
    80001c54:	6f90                	ld	a2,24(a5)
    80001c56:	01073023          	sd	a6,0(a4)
    80001c5a:	e708                	sd	a0,8(a4)
    80001c5c:	eb0c                	sd	a1,16(a4)
    80001c5e:	ef10                	sd	a2,24(a4)
    80001c60:	02078793          	addi	a5,a5,32
    80001c64:	02070713          	addi	a4,a4,32
    80001c68:	fed792e3          	bne	a5,a3,80001c4c <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c6c:	058a3783          	ld	a5,88(s4)
    80001c70:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c74:	0d0a8493          	addi	s1,s5,208
    80001c78:	0d0a0913          	addi	s2,s4,208
    80001c7c:	150a8993          	addi	s3,s5,336
    80001c80:	a831                	j	80001c9c <fork+0x9a>
    freeproc(np);
    80001c82:	8552                	mv	a0,s4
    80001c84:	dcbff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001c88:	8552                	mv	a0,s4
    80001c8a:	808ff0ef          	jal	80000c92 <release>
    return -1;
    80001c8e:	597d                	li	s2,-1
    80001c90:	6a42                	ld	s4,16(sp)
    80001c92:	a0b5                	j	80001cfe <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c94:	04a1                	addi	s1,s1,8
    80001c96:	0921                	addi	s2,s2,8
    80001c98:	01348963          	beq	s1,s3,80001caa <fork+0xa8>
    if(p->ofile[i])
    80001c9c:	6088                	ld	a0,0(s1)
    80001c9e:	d97d                	beqz	a0,80001c94 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca0:	178020ef          	jal	80003e18 <filedup>
    80001ca4:	00a93023          	sd	a0,0(s2)
    80001ca8:	b7f5                	j	80001c94 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001caa:	150ab503          	ld	a0,336(s5)
    80001cae:	4a8010ef          	jal	80003156 <idup>
    80001cb2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cb6:	4641                	li	a2,16
    80001cb8:	158a8593          	addi	a1,s5,344
    80001cbc:	158a0513          	addi	a0,s4,344
    80001cc0:	960ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001cc4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cc8:	8552                	mv	a0,s4
    80001cca:	fc9fe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001cce:	0000e497          	auipc	s1,0xe
    80001cd2:	d7a48493          	addi	s1,s1,-646 # 8000fa48 <wait_lock>
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	f27fe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001cdc:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fb1fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	f17fe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001cec:	478d                	li	a5,3
    80001cee:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf2:	8552                	mv	a0,s4
    80001cf4:	f9ffe0ef          	jal	80000c92 <release>
  return pid;
    80001cf8:	74a2                	ld	s1,40(sp)
    80001cfa:	69e2                	ld	s3,24(sp)
    80001cfc:	6a42                	ld	s4,16(sp)
}
    80001cfe:	854a                	mv	a0,s2
    80001d00:	70e2                	ld	ra,56(sp)
    80001d02:	7442                	ld	s0,48(sp)
    80001d04:	7902                	ld	s2,32(sp)
    80001d06:	6aa2                	ld	s5,8(sp)
    80001d08:	6121                	addi	sp,sp,64
    80001d0a:	8082                	ret
    return -1;
    80001d0c:	597d                	li	s2,-1
    80001d0e:	bfc5                	j	80001cfe <fork+0xfc>

0000000080001d10 <scheduler>:
{
    80001d10:	715d                	addi	sp,sp,-80
    80001d12:	e486                	sd	ra,72(sp)
    80001d14:	e0a2                	sd	s0,64(sp)
    80001d16:	fc26                	sd	s1,56(sp)
    80001d18:	f84a                	sd	s2,48(sp)
    80001d1a:	f44e                	sd	s3,40(sp)
    80001d1c:	f052                	sd	s4,32(sp)
    80001d1e:	ec56                	sd	s5,24(sp)
    80001d20:	e85a                	sd	s6,16(sp)
    80001d22:	e45e                	sd	s7,8(sp)
    80001d24:	e062                	sd	s8,0(sp)
    80001d26:	0880                	addi	s0,sp,80
    80001d28:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d2c:	00779b13          	slli	s6,a5,0x7
    80001d30:	0000e717          	auipc	a4,0xe
    80001d34:	d0070713          	addi	a4,a4,-768 # 8000fa30 <pid_lock>
    80001d38:	975a                	add	a4,a4,s6
    80001d3a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d3e:	0000e717          	auipc	a4,0xe
    80001d42:	d2a70713          	addi	a4,a4,-726 # 8000fa68 <cpus+0x8>
    80001d46:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d48:	4c11                	li	s8,4
        c->proc = p;
    80001d4a:	079e                	slli	a5,a5,0x7
    80001d4c:	0000ea17          	auipc	s4,0xe
    80001d50:	ce4a0a13          	addi	s4,s4,-796 # 8000fa30 <pid_lock>
    80001d54:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d56:	4b85                	li	s7,1
    80001d58:	a0a9                	j	80001da2 <scheduler+0x92>
      release(&p->lock);
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	f37fe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d60:	16848493          	addi	s1,s1,360
    80001d64:	03248563          	beq	s1,s2,80001d8e <scheduler+0x7e>
      acquire(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	e95fe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001d6e:	4c9c                	lw	a5,24(s1)
    80001d70:	ff3795e3          	bne	a5,s3,80001d5a <scheduler+0x4a>
        p->state = RUNNING;
    80001d74:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d78:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d7c:	06048593          	addi	a1,s1,96
    80001d80:	855a                	mv	a0,s6
    80001d82:	5b6000ef          	jal	80002338 <swtch>
        c->proc = 0;
    80001d86:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d8a:	8ade                	mv	s5,s7
    80001d8c:	b7f9                	j	80001d5a <scheduler+0x4a>
    if(found == 0) {
    80001d8e:	000a9a63          	bnez	s5,80001da2 <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d9a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001d9e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001daa:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dae:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db0:	0000e497          	auipc	s1,0xe
    80001db4:	0b048493          	addi	s1,s1,176 # 8000fe60 <proc>
      if(p->state == RUNNABLE) {
    80001db8:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dba:	00014917          	auipc	s2,0x14
    80001dbe:	aa690913          	addi	s2,s2,-1370 # 80015860 <tickslock>
    80001dc2:	b75d                	j	80001d68 <scheduler+0x58>

0000000080001dc4 <sched>:
{
    80001dc4:	7179                	addi	sp,sp,-48
    80001dc6:	f406                	sd	ra,40(sp)
    80001dc8:	f022                	sd	s0,32(sp)
    80001dca:	ec26                	sd	s1,24(sp)
    80001dcc:	e84a                	sd	s2,16(sp)
    80001dce:	e44e                	sd	s3,8(sp)
    80001dd0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd2:	b0bff0ef          	jal	800018dc <myproc>
    80001dd6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dd8:	dbdfe0ef          	jal	80000b94 <holding>
    80001ddc:	c92d                	beqz	a0,80001e4e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de0:	2781                	sext.w	a5,a5
    80001de2:	079e                	slli	a5,a5,0x7
    80001de4:	0000e717          	auipc	a4,0xe
    80001de8:	c4c70713          	addi	a4,a4,-948 # 8000fa30 <pid_lock>
    80001dec:	97ba                	add	a5,a5,a4
    80001dee:	0a87a703          	lw	a4,168(a5)
    80001df2:	4785                	li	a5,1
    80001df4:	06f71363          	bne	a4,a5,80001e5a <sched+0x96>
  if(p->state == RUNNING)
    80001df8:	4c98                	lw	a4,24(s1)
    80001dfa:	4791                	li	a5,4
    80001dfc:	06f70563          	beq	a4,a5,80001e66 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e06:	e7b5                	bnez	a5,80001e72 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0a:	0000e917          	auipc	s2,0xe
    80001e0e:	c2690913          	addi	s2,s2,-986 # 8000fa30 <pid_lock>
    80001e12:	2781                	sext.w	a5,a5
    80001e14:	079e                	slli	a5,a5,0x7
    80001e16:	97ca                	add	a5,a5,s2
    80001e18:	0ac7a983          	lw	s3,172(a5)
    80001e1c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	0000e597          	auipc	a1,0xe
    80001e26:	c4658593          	addi	a1,a1,-954 # 8000fa68 <cpus+0x8>
    80001e2a:	95be                	add	a1,a1,a5
    80001e2c:	06048513          	addi	a0,s1,96
    80001e30:	508000ef          	jal	80002338 <swtch>
    80001e34:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e36:	2781                	sext.w	a5,a5
    80001e38:	079e                	slli	a5,a5,0x7
    80001e3a:	993e                	add	s2,s2,a5
    80001e3c:	0b392623          	sw	s3,172(s2)
}
    80001e40:	70a2                	ld	ra,40(sp)
    80001e42:	7402                	ld	s0,32(sp)
    80001e44:	64e2                	ld	s1,24(sp)
    80001e46:	6942                	ld	s2,16(sp)
    80001e48:	69a2                	ld	s3,8(sp)
    80001e4a:	6145                	addi	sp,sp,48
    80001e4c:	8082                	ret
    panic("sched p->lock");
    80001e4e:	00005517          	auipc	a0,0x5
    80001e52:	3ea50513          	addi	a0,a0,1002 # 80007238 <etext+0x238>
    80001e56:	949fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	3ee50513          	addi	a0,a0,1006 # 80007248 <etext+0x248>
    80001e62:	93dfe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	3f250513          	addi	a0,a0,1010 # 80007258 <etext+0x258>
    80001e6e:	931fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	3f650513          	addi	a0,a0,1014 # 80007268 <etext+0x268>
    80001e7a:	925fe0ef          	jal	8000079e <panic>

0000000080001e7e <yield>:
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e88:	a55ff0ef          	jal	800018dc <myproc>
    80001e8c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e8e:	d71fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001e92:	478d                	li	a5,3
    80001e94:	cc9c                	sw	a5,24(s1)
  sched();
    80001e96:	f2fff0ef          	jal	80001dc4 <sched>
  release(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	df7fe0ef          	jal	80000c92 <release>
}
    80001ea0:	60e2                	ld	ra,24(sp)
    80001ea2:	6442                	ld	s0,16(sp)
    80001ea4:	64a2                	ld	s1,8(sp)
    80001ea6:	6105                	addi	sp,sp,32
    80001ea8:	8082                	ret

0000000080001eaa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eaa:	7179                	addi	sp,sp,-48
    80001eac:	f406                	sd	ra,40(sp)
    80001eae:	f022                	sd	s0,32(sp)
    80001eb0:	ec26                	sd	s1,24(sp)
    80001eb2:	e84a                	sd	s2,16(sp)
    80001eb4:	e44e                	sd	s3,8(sp)
    80001eb6:	1800                	addi	s0,sp,48
    80001eb8:	89aa                	mv	s3,a0
    80001eba:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ebc:	a21ff0ef          	jal	800018dc <myproc>
    80001ec0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec2:	d3dfe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001ec6:	854a                	mv	a0,s2
    80001ec8:	dcbfe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001ecc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed0:	4789                	li	a5,2
    80001ed2:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed4:	ef1ff0ef          	jal	80001dc4 <sched>

  // Tidy up.
  p->chan = 0;
    80001ed8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	db5fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001ee2:	854a                	mv	a0,s2
    80001ee4:	d1bfe0ef          	jal	80000bfe <acquire>
}
    80001ee8:	70a2                	ld	ra,40(sp)
    80001eea:	7402                	ld	s0,32(sp)
    80001eec:	64e2                	ld	s1,24(sp)
    80001eee:	6942                	ld	s2,16(sp)
    80001ef0:	69a2                	ld	s3,8(sp)
    80001ef2:	6145                	addi	sp,sp,48
    80001ef4:	8082                	ret

0000000080001ef6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001ef6:	7139                	addi	sp,sp,-64
    80001ef8:	fc06                	sd	ra,56(sp)
    80001efa:	f822                	sd	s0,48(sp)
    80001efc:	f426                	sd	s1,40(sp)
    80001efe:	f04a                	sd	s2,32(sp)
    80001f00:	ec4e                	sd	s3,24(sp)
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	0080                	addi	s0,sp,64
    80001f08:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0a:	0000e497          	auipc	s1,0xe
    80001f0e:	f5648493          	addi	s1,s1,-170 # 8000fe60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f12:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f14:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	00014917          	auipc	s2,0x14
    80001f1a:	94a90913          	addi	s2,s2,-1718 # 80015860 <tickslock>
    80001f1e:	a801                	j	80001f2e <wakeup+0x38>
      }
      release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	d71fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f26:	16848493          	addi	s1,s1,360
    80001f2a:	03248263          	beq	s1,s2,80001f4e <wakeup+0x58>
    if(p != myproc()){
    80001f2e:	9afff0ef          	jal	800018dc <myproc>
    80001f32:	fea48ae3          	beq	s1,a0,80001f26 <wakeup+0x30>
      acquire(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	cc7fe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f3c:	4c9c                	lw	a5,24(s1)
    80001f3e:	ff3791e3          	bne	a5,s3,80001f20 <wakeup+0x2a>
    80001f42:	709c                	ld	a5,32(s1)
    80001f44:	fd479ee3          	bne	a5,s4,80001f20 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f48:	0154ac23          	sw	s5,24(s1)
    80001f4c:	bfd1                	j	80001f20 <wakeup+0x2a>
    }
  }
}
    80001f4e:	70e2                	ld	ra,56(sp)
    80001f50:	7442                	ld	s0,48(sp)
    80001f52:	74a2                	ld	s1,40(sp)
    80001f54:	7902                	ld	s2,32(sp)
    80001f56:	69e2                	ld	s3,24(sp)
    80001f58:	6a42                	ld	s4,16(sp)
    80001f5a:	6aa2                	ld	s5,8(sp)
    80001f5c:	6121                	addi	sp,sp,64
    80001f5e:	8082                	ret

0000000080001f60 <reparent>:
{
    80001f60:	7179                	addi	sp,sp,-48
    80001f62:	f406                	sd	ra,40(sp)
    80001f64:	f022                	sd	s0,32(sp)
    80001f66:	ec26                	sd	s1,24(sp)
    80001f68:	e84a                	sd	s2,16(sp)
    80001f6a:	e44e                	sd	s3,8(sp)
    80001f6c:	e052                	sd	s4,0(sp)
    80001f6e:	1800                	addi	s0,sp,48
    80001f70:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f72:	0000e497          	auipc	s1,0xe
    80001f76:	eee48493          	addi	s1,s1,-274 # 8000fe60 <proc>
      pp->parent = initproc;
    80001f7a:	00006a17          	auipc	s4,0x6
    80001f7e:	97ea0a13          	addi	s4,s4,-1666 # 800078f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f82:	00014997          	auipc	s3,0x14
    80001f86:	8de98993          	addi	s3,s3,-1826 # 80015860 <tickslock>
    80001f8a:	a029                	j	80001f94 <reparent+0x34>
    80001f8c:	16848493          	addi	s1,s1,360
    80001f90:	01348b63          	beq	s1,s3,80001fa6 <reparent+0x46>
    if(pp->parent == p){
    80001f94:	7c9c                	ld	a5,56(s1)
    80001f96:	ff279be3          	bne	a5,s2,80001f8c <reparent+0x2c>
      pp->parent = initproc;
    80001f9a:	000a3503          	ld	a0,0(s4)
    80001f9e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa0:	f57ff0ef          	jal	80001ef6 <wakeup>
    80001fa4:	b7e5                	j	80001f8c <reparent+0x2c>
}
    80001fa6:	70a2                	ld	ra,40(sp)
    80001fa8:	7402                	ld	s0,32(sp)
    80001faa:	64e2                	ld	s1,24(sp)
    80001fac:	6942                	ld	s2,16(sp)
    80001fae:	69a2                	ld	s3,8(sp)
    80001fb0:	6a02                	ld	s4,0(sp)
    80001fb2:	6145                	addi	sp,sp,48
    80001fb4:	8082                	ret

0000000080001fb6 <exit>:
{
    80001fb6:	7179                	addi	sp,sp,-48
    80001fb8:	f406                	sd	ra,40(sp)
    80001fba:	f022                	sd	s0,32(sp)
    80001fbc:	ec26                	sd	s1,24(sp)
    80001fbe:	e84a                	sd	s2,16(sp)
    80001fc0:	e44e                	sd	s3,8(sp)
    80001fc2:	e052                	sd	s4,0(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fc8:	915ff0ef          	jal	800018dc <myproc>
    80001fcc:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fce:	00006797          	auipc	a5,0x6
    80001fd2:	92a7b783          	ld	a5,-1750(a5) # 800078f8 <initproc>
    80001fd6:	0d050493          	addi	s1,a0,208
    80001fda:	15050913          	addi	s2,a0,336
    80001fde:	00a79b63          	bne	a5,a0,80001ff4 <exit+0x3e>
    panic("init exiting");
    80001fe2:	00005517          	auipc	a0,0x5
    80001fe6:	29e50513          	addi	a0,a0,670 # 80007280 <etext+0x280>
    80001fea:	fb4fe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001fee:	04a1                	addi	s1,s1,8
    80001ff0:	01248963          	beq	s1,s2,80002002 <exit+0x4c>
    if(p->ofile[fd]){
    80001ff4:	6088                	ld	a0,0(s1)
    80001ff6:	dd65                	beqz	a0,80001fee <exit+0x38>
      fileclose(f);
    80001ff8:	667010ef          	jal	80003e5e <fileclose>
      p->ofile[fd] = 0;
    80001ffc:	0004b023          	sd	zero,0(s1)
    80002000:	b7fd                	j	80001fee <exit+0x38>
  begin_op();
    80002002:	23d010ef          	jal	80003a3e <begin_op>
  iput(p->cwd);
    80002006:	1509b503          	ld	a0,336(s3)
    8000200a:	304010ef          	jal	8000330e <iput>
  end_op();
    8000200e:	29b010ef          	jal	80003aa8 <end_op>
  p->cwd = 0;
    80002012:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002016:	0000e497          	auipc	s1,0xe
    8000201a:	a3248493          	addi	s1,s1,-1486 # 8000fa48 <wait_lock>
    8000201e:	8526                	mv	a0,s1
    80002020:	bdffe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002024:	854e                	mv	a0,s3
    80002026:	f3bff0ef          	jal	80001f60 <reparent>
  wakeup(p->parent);
    8000202a:	0389b503          	ld	a0,56(s3)
    8000202e:	ec9ff0ef          	jal	80001ef6 <wakeup>
  acquire(&p->lock);
    80002032:	854e                	mv	a0,s3
    80002034:	bcbfe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002038:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000203c:	4795                	li	a5,5
    8000203e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002042:	8526                	mv	a0,s1
    80002044:	c4ffe0ef          	jal	80000c92 <release>
  sched();
    80002048:	d7dff0ef          	jal	80001dc4 <sched>
  panic("zombie exit");
    8000204c:	00005517          	auipc	a0,0x5
    80002050:	24450513          	addi	a0,a0,580 # 80007290 <etext+0x290>
    80002054:	f4afe0ef          	jal	8000079e <panic>

0000000080002058 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002058:	7179                	addi	sp,sp,-48
    8000205a:	f406                	sd	ra,40(sp)
    8000205c:	f022                	sd	s0,32(sp)
    8000205e:	ec26                	sd	s1,24(sp)
    80002060:	e84a                	sd	s2,16(sp)
    80002062:	e44e                	sd	s3,8(sp)
    80002064:	1800                	addi	s0,sp,48
    80002066:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002068:	0000e497          	auipc	s1,0xe
    8000206c:	df848493          	addi	s1,s1,-520 # 8000fe60 <proc>
    80002070:	00013997          	auipc	s3,0x13
    80002074:	7f098993          	addi	s3,s3,2032 # 80015860 <tickslock>
    acquire(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	b85fe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    8000207e:	589c                	lw	a5,48(s1)
    80002080:	01278b63          	beq	a5,s2,80002096 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	c0dfe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208a:	16848493          	addi	s1,s1,360
    8000208e:	ff3495e3          	bne	s1,s3,80002078 <kill+0x20>
  }
  return -1;
    80002092:	557d                	li	a0,-1
    80002094:	a819                	j	800020aa <kill+0x52>
      p->killed = 1;
    80002096:	4785                	li	a5,1
    80002098:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209a:	4c98                	lw	a4,24(s1)
    8000209c:	4789                	li	a5,2
    8000209e:	00f70d63          	beq	a4,a5,800020b8 <kill+0x60>
      release(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	beffe0ef          	jal	80000c92 <release>
      return 0;
    800020a8:	4501                	li	a0,0
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret
        p->state = RUNNABLE;
    800020b8:	478d                	li	a5,3
    800020ba:	cc9c                	sw	a5,24(s1)
    800020bc:	b7dd                	j	800020a2 <kill+0x4a>

00000000800020be <setkilled>:

void
setkilled(struct proc *p)
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
    800020c8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ca:	b35fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    800020ce:	4785                	li	a5,1
    800020d0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	bbffe0ef          	jal	80000c92 <release>
}
    800020d8:	60e2                	ld	ra,24(sp)
    800020da:	6442                	ld	s0,16(sp)
    800020dc:	64a2                	ld	s1,8(sp)
    800020de:	6105                	addi	sp,sp,32
    800020e0:	8082                	ret

00000000800020e2 <killed>:

int
killed(struct proc *p)
{
    800020e2:	1101                	addi	sp,sp,-32
    800020e4:	ec06                	sd	ra,24(sp)
    800020e6:	e822                	sd	s0,16(sp)
    800020e8:	e426                	sd	s1,8(sp)
    800020ea:	e04a                	sd	s2,0(sp)
    800020ec:	1000                	addi	s0,sp,32
    800020ee:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f0:	b0ffe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    800020f4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b99fe0ef          	jal	80000c92 <release>
  return k;
}
    800020fe:	854a                	mv	a0,s2
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6902                	ld	s2,0(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <wait>:
{
    8000210c:	715d                	addi	sp,sp,-80
    8000210e:	e486                	sd	ra,72(sp)
    80002110:	e0a2                	sd	s0,64(sp)
    80002112:	fc26                	sd	s1,56(sp)
    80002114:	f84a                	sd	s2,48(sp)
    80002116:	f44e                	sd	s3,40(sp)
    80002118:	f052                	sd	s4,32(sp)
    8000211a:	ec56                	sd	s5,24(sp)
    8000211c:	e85a                	sd	s6,16(sp)
    8000211e:	e45e                	sd	s7,8(sp)
    80002120:	0880                	addi	s0,sp,80
    80002122:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002124:	fb8ff0ef          	jal	800018dc <myproc>
    80002128:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000212a:	0000e517          	auipc	a0,0xe
    8000212e:	91e50513          	addi	a0,a0,-1762 # 8000fa48 <wait_lock>
    80002132:	acdfe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002136:	4a15                	li	s4,5
        havekids = 1;
    80002138:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000213a:	00013997          	auipc	s3,0x13
    8000213e:	72698993          	addi	s3,s3,1830 # 80015860 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002142:	0000eb97          	auipc	s7,0xe
    80002146:	906b8b93          	addi	s7,s7,-1786 # 8000fa48 <wait_lock>
    8000214a:	a869                	j	800021e4 <wait+0xd8>
          pid = pp->pid;
    8000214c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002150:	000b0c63          	beqz	s6,80002168 <wait+0x5c>
    80002154:	4691                	li	a3,4
    80002156:	02c48613          	addi	a2,s1,44
    8000215a:	85da                	mv	a1,s6
    8000215c:	05093503          	ld	a0,80(s2)
    80002160:	c24ff0ef          	jal	80001584 <copyout>
    80002164:	02054a63          	bltz	a0,80002198 <wait+0x8c>
          freeproc(pp);
    80002168:	8526                	mv	a0,s1
    8000216a:	8e5ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	b23fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    80002174:	0000e517          	auipc	a0,0xe
    80002178:	8d450513          	addi	a0,a0,-1836 # 8000fa48 <wait_lock>
    8000217c:	b17fe0ef          	jal	80000c92 <release>
}
    80002180:	854e                	mv	a0,s3
    80002182:	60a6                	ld	ra,72(sp)
    80002184:	6406                	ld	s0,64(sp)
    80002186:	74e2                	ld	s1,56(sp)
    80002188:	7942                	ld	s2,48(sp)
    8000218a:	79a2                	ld	s3,40(sp)
    8000218c:	7a02                	ld	s4,32(sp)
    8000218e:	6ae2                	ld	s5,24(sp)
    80002190:	6b42                	ld	s6,16(sp)
    80002192:	6ba2                	ld	s7,8(sp)
    80002194:	6161                	addi	sp,sp,80
    80002196:	8082                	ret
            release(&pp->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	af9fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    8000219e:	0000e517          	auipc	a0,0xe
    800021a2:	8aa50513          	addi	a0,a0,-1878 # 8000fa48 <wait_lock>
    800021a6:	aedfe0ef          	jal	80000c92 <release>
            return -1;
    800021aa:	59fd                	li	s3,-1
    800021ac:	bfd1                	j	80002180 <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ae:	16848493          	addi	s1,s1,360
    800021b2:	03348063          	beq	s1,s3,800021d2 <wait+0xc6>
      if(pp->parent == p){
    800021b6:	7c9c                	ld	a5,56(s1)
    800021b8:	ff279be3          	bne	a5,s2,800021ae <wait+0xa2>
        acquire(&pp->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	a41fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    800021c2:	4c9c                	lw	a5,24(s1)
    800021c4:	f94784e3          	beq	a5,s4,8000214c <wait+0x40>
        release(&pp->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	ac9fe0ef          	jal	80000c92 <release>
        havekids = 1;
    800021ce:	8756                	mv	a4,s5
    800021d0:	bff9                	j	800021ae <wait+0xa2>
    if(!havekids || killed(p)){
    800021d2:	cf19                	beqz	a4,800021f0 <wait+0xe4>
    800021d4:	854a                	mv	a0,s2
    800021d6:	f0dff0ef          	jal	800020e2 <killed>
    800021da:	e919                	bnez	a0,800021f0 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021dc:	85de                	mv	a1,s7
    800021de:	854a                	mv	a0,s2
    800021e0:	ccbff0ef          	jal	80001eaa <sleep>
    havekids = 0;
    800021e4:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	0000e497          	auipc	s1,0xe
    800021ea:	c7a48493          	addi	s1,s1,-902 # 8000fe60 <proc>
    800021ee:	b7e1                	j	800021b6 <wait+0xaa>
      release(&wait_lock);
    800021f0:	0000e517          	auipc	a0,0xe
    800021f4:	85850513          	addi	a0,a0,-1960 # 8000fa48 <wait_lock>
    800021f8:	a9bfe0ef          	jal	80000c92 <release>
      return -1;
    800021fc:	59fd                	li	s3,-1
    800021fe:	b749                	j	80002180 <wait+0x74>

0000000080002200 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	e052                	sd	s4,0(sp)
    8000220e:	1800                	addi	s0,sp,48
    80002210:	84aa                	mv	s1,a0
    80002212:	892e                	mv	s2,a1
    80002214:	89b2                	mv	s3,a2
    80002216:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002218:	ec4ff0ef          	jal	800018dc <myproc>
  if(user_dst){
    8000221c:	cc99                	beqz	s1,8000223a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000221e:	86d2                	mv	a3,s4
    80002220:	864e                	mv	a2,s3
    80002222:	85ca                	mv	a1,s2
    80002224:	6928                	ld	a0,80(a0)
    80002226:	b5eff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000222a:	70a2                	ld	ra,40(sp)
    8000222c:	7402                	ld	s0,32(sp)
    8000222e:	64e2                	ld	s1,24(sp)
    80002230:	6942                	ld	s2,16(sp)
    80002232:	69a2                	ld	s3,8(sp)
    80002234:	6a02                	ld	s4,0(sp)
    80002236:	6145                	addi	sp,sp,48
    80002238:	8082                	ret
    memmove((char *)dst, src, len);
    8000223a:	000a061b          	sext.w	a2,s4
    8000223e:	85ce                	mv	a1,s3
    80002240:	854a                	mv	a0,s2
    80002242:	af1fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002246:	8526                	mv	a0,s1
    80002248:	b7cd                	j	8000222a <either_copyout+0x2a>

000000008000224a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000224a:	7179                	addi	sp,sp,-48
    8000224c:	f406                	sd	ra,40(sp)
    8000224e:	f022                	sd	s0,32(sp)
    80002250:	ec26                	sd	s1,24(sp)
    80002252:	e84a                	sd	s2,16(sp)
    80002254:	e44e                	sd	s3,8(sp)
    80002256:	e052                	sd	s4,0(sp)
    80002258:	1800                	addi	s0,sp,48
    8000225a:	892a                	mv	s2,a0
    8000225c:	84ae                	mv	s1,a1
    8000225e:	89b2                	mv	s3,a2
    80002260:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002262:	e7aff0ef          	jal	800018dc <myproc>
  if(user_src){
    80002266:	cc99                	beqz	s1,80002284 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002268:	86d2                	mv	a3,s4
    8000226a:	864e                	mv	a2,s3
    8000226c:	85ca                	mv	a1,s2
    8000226e:	6928                	ld	a0,80(a0)
    80002270:	bc4ff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002274:	70a2                	ld	ra,40(sp)
    80002276:	7402                	ld	s0,32(sp)
    80002278:	64e2                	ld	s1,24(sp)
    8000227a:	6942                	ld	s2,16(sp)
    8000227c:	69a2                	ld	s3,8(sp)
    8000227e:	6a02                	ld	s4,0(sp)
    80002280:	6145                	addi	sp,sp,48
    80002282:	8082                	ret
    memmove(dst, (char*)src, len);
    80002284:	000a061b          	sext.w	a2,s4
    80002288:	85ce                	mv	a1,s3
    8000228a:	854a                	mv	a0,s2
    8000228c:	aa7fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002290:	8526                	mv	a0,s1
    80002292:	b7cd                	j	80002274 <either_copyin+0x2a>

0000000080002294 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002294:	715d                	addi	sp,sp,-80
    80002296:	e486                	sd	ra,72(sp)
    80002298:	e0a2                	sd	s0,64(sp)
    8000229a:	fc26                	sd	s1,56(sp)
    8000229c:	f84a                	sd	s2,48(sp)
    8000229e:	f44e                	sd	s3,40(sp)
    800022a0:	f052                	sd	s4,32(sp)
    800022a2:	ec56                	sd	s5,24(sp)
    800022a4:	e85a                	sd	s6,16(sp)
    800022a6:	e45e                	sd	s7,8(sp)
    800022a8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022aa:	00005517          	auipc	a0,0x5
    800022ae:	dce50513          	addi	a0,a0,-562 # 80007078 <etext+0x78>
    800022b2:	a1cfe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b6:	0000e497          	auipc	s1,0xe
    800022ba:	d0248493          	addi	s1,s1,-766 # 8000ffb8 <proc+0x158>
    800022be:	00013917          	auipc	s2,0x13
    800022c2:	6fa90913          	addi	s2,s2,1786 # 800159b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022c6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022c8:	00005997          	auipc	s3,0x5
    800022cc:	fd898993          	addi	s3,s3,-40 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022d0:	00005a97          	auipc	s5,0x5
    800022d4:	fd8a8a93          	addi	s5,s5,-40 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022d8:	00005a17          	auipc	s4,0x5
    800022dc:	da0a0a13          	addi	s4,s4,-608 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e0:	00005b97          	auipc	s7,0x5
    800022e4:	4a8b8b93          	addi	s7,s7,1192 # 80007788 <states.0>
    800022e8:	a829                	j	80002302 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022ea:	ed86a583          	lw	a1,-296(a3)
    800022ee:	8556                	mv	a0,s5
    800022f0:	9defe0ef          	jal	800004ce <printf>
    printf("\n");
    800022f4:	8552                	mv	a0,s4
    800022f6:	9d8fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022fa:	16848493          	addi	s1,s1,360
    800022fe:	03248263          	beq	s1,s2,80002322 <procdump+0x8e>
    if(p->state == UNUSED)
    80002302:	86a6                	mv	a3,s1
    80002304:	ec04a783          	lw	a5,-320(s1)
    80002308:	dbed                	beqz	a5,800022fa <procdump+0x66>
      state = "???";
    8000230a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230c:	fcfb6fe3          	bltu	s6,a5,800022ea <procdump+0x56>
    80002310:	02079713          	slli	a4,a5,0x20
    80002314:	01d75793          	srli	a5,a4,0x1d
    80002318:	97de                	add	a5,a5,s7
    8000231a:	6390                	ld	a2,0(a5)
    8000231c:	f679                	bnez	a2,800022ea <procdump+0x56>
      state = "???";
    8000231e:	864e                	mv	a2,s3
    80002320:	b7e9                	j	800022ea <procdump+0x56>
  }
}
    80002322:	60a6                	ld	ra,72(sp)
    80002324:	6406                	ld	s0,64(sp)
    80002326:	74e2                	ld	s1,56(sp)
    80002328:	7942                	ld	s2,48(sp)
    8000232a:	79a2                	ld	s3,40(sp)
    8000232c:	7a02                	ld	s4,32(sp)
    8000232e:	6ae2                	ld	s5,24(sp)
    80002330:	6b42                	ld	s6,16(sp)
    80002332:	6ba2                	ld	s7,8(sp)
    80002334:	6161                	addi	sp,sp,80
    80002336:	8082                	ret

0000000080002338 <swtch>:
    80002338:	00153023          	sd	ra,0(a0)
    8000233c:	00253423          	sd	sp,8(a0)
    80002340:	e900                	sd	s0,16(a0)
    80002342:	ed04                	sd	s1,24(a0)
    80002344:	03253023          	sd	s2,32(a0)
    80002348:	03353423          	sd	s3,40(a0)
    8000234c:	03453823          	sd	s4,48(a0)
    80002350:	03553c23          	sd	s5,56(a0)
    80002354:	05653023          	sd	s6,64(a0)
    80002358:	05753423          	sd	s7,72(a0)
    8000235c:	05853823          	sd	s8,80(a0)
    80002360:	05953c23          	sd	s9,88(a0)
    80002364:	07a53023          	sd	s10,96(a0)
    80002368:	07b53423          	sd	s11,104(a0)
    8000236c:	0005b083          	ld	ra,0(a1)
    80002370:	0085b103          	ld	sp,8(a1)
    80002374:	6980                	ld	s0,16(a1)
    80002376:	6d84                	ld	s1,24(a1)
    80002378:	0205b903          	ld	s2,32(a1)
    8000237c:	0285b983          	ld	s3,40(a1)
    80002380:	0305ba03          	ld	s4,48(a1)
    80002384:	0385ba83          	ld	s5,56(a1)
    80002388:	0405bb03          	ld	s6,64(a1)
    8000238c:	0485bb83          	ld	s7,72(a1)
    80002390:	0505bc03          	ld	s8,80(a1)
    80002394:	0585bc83          	ld	s9,88(a1)
    80002398:	0605bd03          	ld	s10,96(a1)
    8000239c:	0685bd83          	ld	s11,104(a1)
    800023a0:	8082                	ret

00000000800023a2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023a2:	1141                	addi	sp,sp,-16
    800023a4:	e406                	sd	ra,8(sp)
    800023a6:	e022                	sd	s0,0(sp)
    800023a8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023aa:	00005597          	auipc	a1,0x5
    800023ae:	f3e58593          	addi	a1,a1,-194 # 800072e8 <etext+0x2e8>
    800023b2:	00013517          	auipc	a0,0x13
    800023b6:	4ae50513          	addi	a0,a0,1198 # 80015860 <tickslock>
    800023ba:	fc0fe0ef          	jal	80000b7a <initlock>
}
    800023be:	60a2                	ld	ra,8(sp)
    800023c0:	6402                	ld	s0,0(sp)
    800023c2:	0141                	addi	sp,sp,16
    800023c4:	8082                	ret

00000000800023c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023c6:	1141                	addi	sp,sp,-16
    800023c8:	e406                	sd	ra,8(sp)
    800023ca:	e022                	sd	s0,0(sp)
    800023cc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023ce:	00003797          	auipc	a5,0x3
    800023d2:	e4278793          	addi	a5,a5,-446 # 80005210 <kernelvec>
    800023d6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023da:	60a2                	ld	ra,8(sp)
    800023dc:	6402                	ld	s0,0(sp)
    800023de:	0141                	addi	sp,sp,16
    800023e0:	8082                	ret

00000000800023e2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023e2:	1141                	addi	sp,sp,-16
    800023e4:	e406                	sd	ra,8(sp)
    800023e6:	e022                	sd	s0,0(sp)
    800023e8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023ea:	cf2ff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023f8:	00004697          	auipc	a3,0x4
    800023fc:	c0868693          	addi	a3,a3,-1016 # 80006000 <_trampoline>
    80002400:	00004717          	auipc	a4,0x4
    80002404:	c0070713          	addi	a4,a4,-1024 # 80006000 <_trampoline>
    80002408:	8f15                	sub	a4,a4,a3
    8000240a:	040007b7          	lui	a5,0x4000
    8000240e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002410:	07b2                	slli	a5,a5,0xc
    80002412:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002414:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002418:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000241a:	18002673          	csrr	a2,satp
    8000241e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002420:	6d30                	ld	a2,88(a0)
    80002422:	6138                	ld	a4,64(a0)
    80002424:	6585                	lui	a1,0x1
    80002426:	972e                	add	a4,a4,a1
    80002428:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000242a:	6d38                	ld	a4,88(a0)
    8000242c:	00000617          	auipc	a2,0x0
    80002430:	11060613          	addi	a2,a2,272 # 8000253c <usertrap>
    80002434:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002436:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002438:	8612                	mv	a2,tp
    8000243a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002440:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002444:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002448:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000244c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000244e:	6f18                	ld	a4,24(a4)
    80002450:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002454:	6928                	ld	a0,80(a0)
    80002456:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002458:	00004717          	auipc	a4,0x4
    8000245c:	c4470713          	addi	a4,a4,-956 # 8000609c <userret>
    80002460:	8f15                	sub	a4,a4,a3
    80002462:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002464:	577d                	li	a4,-1
    80002466:	177e                	slli	a4,a4,0x3f
    80002468:	8d59                	or	a0,a0,a4
    8000246a:	9782                	jalr	a5
}
    8000246c:	60a2                	ld	ra,8(sp)
    8000246e:	6402                	ld	s0,0(sp)
    80002470:	0141                	addi	sp,sp,16
    80002472:	8082                	ret

0000000080002474 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002474:	1101                	addi	sp,sp,-32
    80002476:	ec06                	sd	ra,24(sp)
    80002478:	e822                	sd	s0,16(sp)
    8000247a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000247c:	c2cff0ef          	jal	800018a8 <cpuid>
    80002480:	cd11                	beqz	a0,8000249c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002482:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002486:	000f4737          	lui	a4,0xf4
    8000248a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000248e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002490:	14d79073          	csrw	stimecmp,a5
}
    80002494:	60e2                	ld	ra,24(sp)
    80002496:	6442                	ld	s0,16(sp)
    80002498:	6105                	addi	sp,sp,32
    8000249a:	8082                	ret
    8000249c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000249e:	00013497          	auipc	s1,0x13
    800024a2:	3c248493          	addi	s1,s1,962 # 80015860 <tickslock>
    800024a6:	8526                	mv	a0,s1
    800024a8:	f56fe0ef          	jal	80000bfe <acquire>
    ticks++;
    800024ac:	00005517          	auipc	a0,0x5
    800024b0:	45450513          	addi	a0,a0,1108 # 80007900 <ticks>
    800024b4:	411c                	lw	a5,0(a0)
    800024b6:	2785                	addiw	a5,a5,1
    800024b8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024ba:	a3dff0ef          	jal	80001ef6 <wakeup>
    release(&tickslock);
    800024be:	8526                	mv	a0,s1
    800024c0:	fd2fe0ef          	jal	80000c92 <release>
    800024c4:	64a2                	ld	s1,8(sp)
    800024c6:	bf75                	j	80002482 <clockintr+0xe>

00000000800024c8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024c8:	1101                	addi	sp,sp,-32
    800024ca:	ec06                	sd	ra,24(sp)
    800024cc:	e822                	sd	s0,16(sp)
    800024ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024d4:	57fd                	li	a5,-1
    800024d6:	17fe                	slli	a5,a5,0x3f
    800024d8:	07a5                	addi	a5,a5,9
    800024da:	00f70c63          	beq	a4,a5,800024f2 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024de:	57fd                	li	a5,-1
    800024e0:	17fe                	slli	a5,a5,0x3f
    800024e2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024e4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024e6:	04f70763          	beq	a4,a5,80002534 <devintr+0x6c>
  }
}
    800024ea:	60e2                	ld	ra,24(sp)
    800024ec:	6442                	ld	s0,16(sp)
    800024ee:	6105                	addi	sp,sp,32
    800024f0:	8082                	ret
    800024f2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024f4:	5c9020ef          	jal	800052bc <plic_claim>
    800024f8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800024fa:	47a9                	li	a5,10
    800024fc:	00f50963          	beq	a0,a5,8000250e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002500:	4785                	li	a5,1
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x4c>
    return 1;
    80002506:	4505                	li	a0,1
    } else if(irq){
    80002508:	e889                	bnez	s1,8000251a <devintr+0x52>
    8000250a:	64a2                	ld	s1,8(sp)
    8000250c:	bff9                	j	800024ea <devintr+0x22>
      uartintr();
    8000250e:	cfefe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002512:	a819                	j	80002528 <devintr+0x60>
      virtio_disk_intr();
    80002514:	238030ef          	jal	8000574c <virtio_disk_intr>
    if(irq)
    80002518:	a801                	j	80002528 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000251a:	85a6                	mv	a1,s1
    8000251c:	00005517          	auipc	a0,0x5
    80002520:	dd450513          	addi	a0,a0,-556 # 800072f0 <etext+0x2f0>
    80002524:	fabfd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002528:	8526                	mv	a0,s1
    8000252a:	5b3020ef          	jal	800052dc <plic_complete>
    return 1;
    8000252e:	4505                	li	a0,1
    80002530:	64a2                	ld	s1,8(sp)
    80002532:	bf65                	j	800024ea <devintr+0x22>
    clockintr();
    80002534:	f41ff0ef          	jal	80002474 <clockintr>
    return 2;
    80002538:	4509                	li	a0,2
    8000253a:	bf45                	j	800024ea <devintr+0x22>

000000008000253c <usertrap>:
{
    8000253c:	1101                	addi	sp,sp,-32
    8000253e:	ec06                	sd	ra,24(sp)
    80002540:	e822                	sd	s0,16(sp)
    80002542:	e426                	sd	s1,8(sp)
    80002544:	e04a                	sd	s2,0(sp)
    80002546:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002548:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000254c:	1007f793          	andi	a5,a5,256
    80002550:	ef85                	bnez	a5,80002588 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002552:	00003797          	auipc	a5,0x3
    80002556:	cbe78793          	addi	a5,a5,-834 # 80005210 <kernelvec>
    8000255a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000255e:	b7eff0ef          	jal	800018dc <myproc>
    80002562:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002564:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002566:	14102773          	csrr	a4,sepc
    8000256a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000256c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002570:	47a1                	li	a5,8
    80002572:	02f70163          	beq	a4,a5,80002594 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002576:	f53ff0ef          	jal	800024c8 <devintr>
    8000257a:	892a                	mv	s2,a0
    8000257c:	c135                	beqz	a0,800025e0 <usertrap+0xa4>
  if(killed(p))
    8000257e:	8526                	mv	a0,s1
    80002580:	b63ff0ef          	jal	800020e2 <killed>
    80002584:	cd1d                	beqz	a0,800025c2 <usertrap+0x86>
    80002586:	a81d                	j	800025bc <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002588:	00005517          	auipc	a0,0x5
    8000258c:	d8850513          	addi	a0,a0,-632 # 80007310 <etext+0x310>
    80002590:	a0efe0ef          	jal	8000079e <panic>
    if(killed(p))
    80002594:	b4fff0ef          	jal	800020e2 <killed>
    80002598:	e121                	bnez	a0,800025d8 <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000259a:	6cb8                	ld	a4,88(s1)
    8000259c:	6f1c                	ld	a5,24(a4)
    8000259e:	0791                	addi	a5,a5,4
    800025a0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025aa:	10079073          	csrw	sstatus,a5
    syscall();
    800025ae:	240000ef          	jal	800027ee <syscall>
  if(killed(p))
    800025b2:	8526                	mv	a0,s1
    800025b4:	b2fff0ef          	jal	800020e2 <killed>
    800025b8:	c901                	beqz	a0,800025c8 <usertrap+0x8c>
    800025ba:	4901                	li	s2,0
    exit(-1);
    800025bc:	557d                	li	a0,-1
    800025be:	9f9ff0ef          	jal	80001fb6 <exit>
  if(which_dev == 2)
    800025c2:	4789                	li	a5,2
    800025c4:	04f90563          	beq	s2,a5,8000260e <usertrap+0xd2>
  usertrapret();
    800025c8:	e1bff0ef          	jal	800023e2 <usertrapret>
}
    800025cc:	60e2                	ld	ra,24(sp)
    800025ce:	6442                	ld	s0,16(sp)
    800025d0:	64a2                	ld	s1,8(sp)
    800025d2:	6902                	ld	s2,0(sp)
    800025d4:	6105                	addi	sp,sp,32
    800025d6:	8082                	ret
      exit(-1);
    800025d8:	557d                	li	a0,-1
    800025da:	9ddff0ef          	jal	80001fb6 <exit>
    800025de:	bf75                	j	8000259a <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025e4:	5890                	lw	a2,48(s1)
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	d4a50513          	addi	a0,a0,-694 # 80007330 <etext+0x330>
    800025ee:	ee1fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f6:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025fa:	00005517          	auipc	a0,0x5
    800025fe:	d6650513          	addi	a0,a0,-666 # 80007360 <etext+0x360>
    80002602:	ecdfd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002606:	8526                	mv	a0,s1
    80002608:	ab7ff0ef          	jal	800020be <setkilled>
    8000260c:	b75d                	j	800025b2 <usertrap+0x76>
    yield();
    8000260e:	871ff0ef          	jal	80001e7e <yield>
    80002612:	bf5d                	j	800025c8 <usertrap+0x8c>

0000000080002614 <kerneltrap>:
{
    80002614:	7179                	addi	sp,sp,-48
    80002616:	f406                	sd	ra,40(sp)
    80002618:	f022                	sd	s0,32(sp)
    8000261a:	ec26                	sd	s1,24(sp)
    8000261c:	e84a                	sd	s2,16(sp)
    8000261e:	e44e                	sd	s3,8(sp)
    80002620:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002622:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000262a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000262e:	1004f793          	andi	a5,s1,256
    80002632:	c795                	beqz	a5,8000265e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002634:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002638:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000263a:	eb85                	bnez	a5,8000266a <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000263c:	e8dff0ef          	jal	800024c8 <devintr>
    80002640:	c91d                	beqz	a0,80002676 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002642:	4789                	li	a5,2
    80002644:	04f50a63          	beq	a0,a5,80002698 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002648:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000264c:	10049073          	csrw	sstatus,s1
}
    80002650:	70a2                	ld	ra,40(sp)
    80002652:	7402                	ld	s0,32(sp)
    80002654:	64e2                	ld	s1,24(sp)
    80002656:	6942                	ld	s2,16(sp)
    80002658:	69a2                	ld	s3,8(sp)
    8000265a:	6145                	addi	sp,sp,48
    8000265c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000265e:	00005517          	auipc	a0,0x5
    80002662:	d2a50513          	addi	a0,a0,-726 # 80007388 <etext+0x388>
    80002666:	938fe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    8000266a:	00005517          	auipc	a0,0x5
    8000266e:	d4650513          	addi	a0,a0,-698 # 800073b0 <etext+0x3b0>
    80002672:	92cfe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002676:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000267a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000267e:	85ce                	mv	a1,s3
    80002680:	00005517          	auipc	a0,0x5
    80002684:	d5050513          	addi	a0,a0,-688 # 800073d0 <etext+0x3d0>
    80002688:	e47fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    8000268c:	00005517          	auipc	a0,0x5
    80002690:	d6c50513          	addi	a0,a0,-660 # 800073f8 <etext+0x3f8>
    80002694:	90afe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    80002698:	a44ff0ef          	jal	800018dc <myproc>
    8000269c:	d555                	beqz	a0,80002648 <kerneltrap+0x34>
    yield();
    8000269e:	fe0ff0ef          	jal	80001e7e <yield>
    800026a2:	b75d                	j	80002648 <kerneltrap+0x34>

00000000800026a4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026a4:	1101                	addi	sp,sp,-32
    800026a6:	ec06                	sd	ra,24(sp)
    800026a8:	e822                	sd	s0,16(sp)
    800026aa:	e426                	sd	s1,8(sp)
    800026ac:	1000                	addi	s0,sp,32
    800026ae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026b0:	a2cff0ef          	jal	800018dc <myproc>
  switch (n) {
    800026b4:	4795                	li	a5,5
    800026b6:	0497e163          	bltu	a5,s1,800026f8 <argraw+0x54>
    800026ba:	048a                	slli	s1,s1,0x2
    800026bc:	00005717          	auipc	a4,0x5
    800026c0:	0fc70713          	addi	a4,a4,252 # 800077b8 <states.0+0x30>
    800026c4:	94ba                	add	s1,s1,a4
    800026c6:	409c                	lw	a5,0(s1)
    800026c8:	97ba                	add	a5,a5,a4
    800026ca:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026cc:	6d3c                	ld	a5,88(a0)
    800026ce:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026d0:	60e2                	ld	ra,24(sp)
    800026d2:	6442                	ld	s0,16(sp)
    800026d4:	64a2                	ld	s1,8(sp)
    800026d6:	6105                	addi	sp,sp,32
    800026d8:	8082                	ret
    return p->trapframe->a1;
    800026da:	6d3c                	ld	a5,88(a0)
    800026dc:	7fa8                	ld	a0,120(a5)
    800026de:	bfcd                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a2;
    800026e0:	6d3c                	ld	a5,88(a0)
    800026e2:	63c8                	ld	a0,128(a5)
    800026e4:	b7f5                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a3;
    800026e6:	6d3c                	ld	a5,88(a0)
    800026e8:	67c8                	ld	a0,136(a5)
    800026ea:	b7dd                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a4;
    800026ec:	6d3c                	ld	a5,88(a0)
    800026ee:	6bc8                	ld	a0,144(a5)
    800026f0:	b7c5                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a5;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	6fc8                	ld	a0,152(a5)
    800026f6:	bfe9                	j	800026d0 <argraw+0x2c>
  panic("argraw");
    800026f8:	00005517          	auipc	a0,0x5
    800026fc:	d1050513          	addi	a0,a0,-752 # 80007408 <etext+0x408>
    80002700:	89efe0ef          	jal	8000079e <panic>

0000000080002704 <fetchaddr>:
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	e04a                	sd	s2,0(sp)
    8000270e:	1000                	addi	s0,sp,32
    80002710:	84aa                	mv	s1,a0
    80002712:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002714:	9c8ff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002718:	653c                	ld	a5,72(a0)
    8000271a:	02f4f663          	bgeu	s1,a5,80002746 <fetchaddr+0x42>
    8000271e:	00848713          	addi	a4,s1,8
    80002722:	02e7e463          	bltu	a5,a4,8000274a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002726:	46a1                	li	a3,8
    80002728:	8626                	mv	a2,s1
    8000272a:	85ca                	mv	a1,s2
    8000272c:	6928                	ld	a0,80(a0)
    8000272e:	f07fe0ef          	jal	80001634 <copyin>
    80002732:	00a03533          	snez	a0,a0
    80002736:	40a0053b          	negw	a0,a0
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6902                	ld	s2,0(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    return -1;
    80002746:	557d                	li	a0,-1
    80002748:	bfcd                	j	8000273a <fetchaddr+0x36>
    8000274a:	557d                	li	a0,-1
    8000274c:	b7fd                	j	8000273a <fetchaddr+0x36>

000000008000274e <fetchstr>:
{
    8000274e:	7179                	addi	sp,sp,-48
    80002750:	f406                	sd	ra,40(sp)
    80002752:	f022                	sd	s0,32(sp)
    80002754:	ec26                	sd	s1,24(sp)
    80002756:	e84a                	sd	s2,16(sp)
    80002758:	e44e                	sd	s3,8(sp)
    8000275a:	1800                	addi	s0,sp,48
    8000275c:	892a                	mv	s2,a0
    8000275e:	84ae                	mv	s1,a1
    80002760:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002762:	97aff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002766:	86ce                	mv	a3,s3
    80002768:	864a                	mv	a2,s2
    8000276a:	85a6                	mv	a1,s1
    8000276c:	6928                	ld	a0,80(a0)
    8000276e:	f4dfe0ef          	jal	800016ba <copyinstr>
    80002772:	00054c63          	bltz	a0,8000278a <fetchstr+0x3c>
  return strlen(buf);
    80002776:	8526                	mv	a0,s1
    80002778:	edefe0ef          	jal	80000e56 <strlen>
}
    8000277c:	70a2                	ld	ra,40(sp)
    8000277e:	7402                	ld	s0,32(sp)
    80002780:	64e2                	ld	s1,24(sp)
    80002782:	6942                	ld	s2,16(sp)
    80002784:	69a2                	ld	s3,8(sp)
    80002786:	6145                	addi	sp,sp,48
    80002788:	8082                	ret
    return -1;
    8000278a:	557d                	li	a0,-1
    8000278c:	bfc5                	j	8000277c <fetchstr+0x2e>

000000008000278e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	1000                	addi	s0,sp,32
    80002798:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000279a:	f0bff0ef          	jal	800026a4 <argraw>
    8000279e:	c088                	sw	a0,0(s1)
}
    800027a0:	60e2                	ld	ra,24(sp)
    800027a2:	6442                	ld	s0,16(sp)
    800027a4:	64a2                	ld	s1,8(sp)
    800027a6:	6105                	addi	sp,sp,32
    800027a8:	8082                	ret

00000000800027aa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027aa:	1101                	addi	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	1000                	addi	s0,sp,32
    800027b4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027b6:	eefff0ef          	jal	800026a4 <argraw>
    800027ba:	e088                	sd	a0,0(s1)
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6105                	addi	sp,sp,32
    800027c4:	8082                	ret

00000000800027c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027c6:	1101                	addi	sp,sp,-32
    800027c8:	ec06                	sd	ra,24(sp)
    800027ca:	e822                	sd	s0,16(sp)
    800027cc:	e426                	sd	s1,8(sp)
    800027ce:	e04a                	sd	s2,0(sp)
    800027d0:	1000                	addi	s0,sp,32
    800027d2:	84ae                	mv	s1,a1
    800027d4:	8932                	mv	s2,a2
  *ip = argraw(n);
    800027d6:	ecfff0ef          	jal	800026a4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800027da:	864a                	mv	a2,s2
    800027dc:	85a6                	mv	a1,s1
    800027de:	f71ff0ef          	jal	8000274e <fetchstr>
}
    800027e2:	60e2                	ld	ra,24(sp)
    800027e4:	6442                	ld	s0,16(sp)
    800027e6:	64a2                	ld	s1,8(sp)
    800027e8:	6902                	ld	s2,0(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret

00000000800027ee <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	e04a                	sd	s2,0(sp)
    800027f8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800027fa:	8e2ff0ef          	jal	800018dc <myproc>
    800027fe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002800:	05853903          	ld	s2,88(a0)
    80002804:	0a893783          	ld	a5,168(s2)
    80002808:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000280c:	37fd                	addiw	a5,a5,-1
    8000280e:	4751                	li	a4,20
    80002810:	00f76f63          	bltu	a4,a5,8000282e <syscall+0x40>
    80002814:	00369713          	slli	a4,a3,0x3
    80002818:	00005797          	auipc	a5,0x5
    8000281c:	fb878793          	addi	a5,a5,-72 # 800077d0 <syscalls>
    80002820:	97ba                	add	a5,a5,a4
    80002822:	639c                	ld	a5,0(a5)
    80002824:	c789                	beqz	a5,8000282e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002826:	9782                	jalr	a5
    80002828:	06a93823          	sd	a0,112(s2)
    8000282c:	a829                	j	80002846 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000282e:	15848613          	addi	a2,s1,344
    80002832:	588c                	lw	a1,48(s1)
    80002834:	00005517          	auipc	a0,0x5
    80002838:	bdc50513          	addi	a0,a0,-1060 # 80007410 <etext+0x410>
    8000283c:	c93fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002840:	6cbc                	ld	a5,88(s1)
    80002842:	577d                	li	a4,-1
    80002844:	fbb8                	sd	a4,112(a5)
  }
}
    80002846:	60e2                	ld	ra,24(sp)
    80002848:	6442                	ld	s0,16(sp)
    8000284a:	64a2                	ld	s1,8(sp)
    8000284c:	6902                	ld	s2,0(sp)
    8000284e:	6105                	addi	sp,sp,32
    80002850:	8082                	ret

0000000080002852 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002852:	1101                	addi	sp,sp,-32
    80002854:	ec06                	sd	ra,24(sp)
    80002856:	e822                	sd	s0,16(sp)
    80002858:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000285a:	fec40593          	addi	a1,s0,-20
    8000285e:	4501                	li	a0,0
    80002860:	f2fff0ef          	jal	8000278e <argint>
  exit(n);
    80002864:	fec42503          	lw	a0,-20(s0)
    80002868:	f4eff0ef          	jal	80001fb6 <exit>
  return 0;  // not reached
}
    8000286c:	4501                	li	a0,0
    8000286e:	60e2                	ld	ra,24(sp)
    80002870:	6442                	ld	s0,16(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002876:	1141                	addi	sp,sp,-16
    80002878:	e406                	sd	ra,8(sp)
    8000287a:	e022                	sd	s0,0(sp)
    8000287c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000287e:	85eff0ef          	jal	800018dc <myproc>
}
    80002882:	5908                	lw	a0,48(a0)
    80002884:	60a2                	ld	ra,8(sp)
    80002886:	6402                	ld	s0,0(sp)
    80002888:	0141                	addi	sp,sp,16
    8000288a:	8082                	ret

000000008000288c <sys_fork>:

uint64
sys_fork(void)
{
    8000288c:	1141                	addi	sp,sp,-16
    8000288e:	e406                	sd	ra,8(sp)
    80002890:	e022                	sd	s0,0(sp)
    80002892:	0800                	addi	s0,sp,16
  return fork();
    80002894:	b6eff0ef          	jal	80001c02 <fork>
}
    80002898:	60a2                	ld	ra,8(sp)
    8000289a:	6402                	ld	s0,0(sp)
    8000289c:	0141                	addi	sp,sp,16
    8000289e:	8082                	ret

00000000800028a0 <sys_wait>:

uint64
sys_wait(void)
{
    800028a0:	1101                	addi	sp,sp,-32
    800028a2:	ec06                	sd	ra,24(sp)
    800028a4:	e822                	sd	s0,16(sp)
    800028a6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028a8:	fe840593          	addi	a1,s0,-24
    800028ac:	4501                	li	a0,0
    800028ae:	efdff0ef          	jal	800027aa <argaddr>
  return wait(p);
    800028b2:	fe843503          	ld	a0,-24(s0)
    800028b6:	857ff0ef          	jal	8000210c <wait>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret

00000000800028c2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028c2:	7179                	addi	sp,sp,-48
    800028c4:	f406                	sd	ra,40(sp)
    800028c6:	f022                	sd	s0,32(sp)
    800028c8:	ec26                	sd	s1,24(sp)
    800028ca:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800028cc:	fdc40593          	addi	a1,s0,-36
    800028d0:	4501                	li	a0,0
    800028d2:	ebdff0ef          	jal	8000278e <argint>
  addr = myproc()->sz;
    800028d6:	806ff0ef          	jal	800018dc <myproc>
    800028da:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800028dc:	fdc42503          	lw	a0,-36(s0)
    800028e0:	ad2ff0ef          	jal	80001bb2 <growproc>
    800028e4:	00054863          	bltz	a0,800028f4 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800028e8:	8526                	mv	a0,s1
    800028ea:	70a2                	ld	ra,40(sp)
    800028ec:	7402                	ld	s0,32(sp)
    800028ee:	64e2                	ld	s1,24(sp)
    800028f0:	6145                	addi	sp,sp,48
    800028f2:	8082                	ret
    return -1;
    800028f4:	54fd                	li	s1,-1
    800028f6:	bfcd                	j	800028e8 <sys_sbrk+0x26>

00000000800028f8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800028f8:	7139                	addi	sp,sp,-64
    800028fa:	fc06                	sd	ra,56(sp)
    800028fc:	f822                	sd	s0,48(sp)
    800028fe:	f04a                	sd	s2,32(sp)
    80002900:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002902:	fcc40593          	addi	a1,s0,-52
    80002906:	4501                	li	a0,0
    80002908:	e87ff0ef          	jal	8000278e <argint>
  if(n < 0)
    8000290c:	fcc42783          	lw	a5,-52(s0)
    80002910:	0607c763          	bltz	a5,8000297e <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002914:	00013517          	auipc	a0,0x13
    80002918:	f4c50513          	addi	a0,a0,-180 # 80015860 <tickslock>
    8000291c:	ae2fe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002920:	00005917          	auipc	s2,0x5
    80002924:	fe092903          	lw	s2,-32(s2) # 80007900 <ticks>
  while(ticks - ticks0 < n){
    80002928:	fcc42783          	lw	a5,-52(s0)
    8000292c:	cf8d                	beqz	a5,80002966 <sys_sleep+0x6e>
    8000292e:	f426                	sd	s1,40(sp)
    80002930:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002932:	00013997          	auipc	s3,0x13
    80002936:	f2e98993          	addi	s3,s3,-210 # 80015860 <tickslock>
    8000293a:	00005497          	auipc	s1,0x5
    8000293e:	fc648493          	addi	s1,s1,-58 # 80007900 <ticks>
    if(killed(myproc())){
    80002942:	f9bfe0ef          	jal	800018dc <myproc>
    80002946:	f9cff0ef          	jal	800020e2 <killed>
    8000294a:	ed0d                	bnez	a0,80002984 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000294c:	85ce                	mv	a1,s3
    8000294e:	8526                	mv	a0,s1
    80002950:	d5aff0ef          	jal	80001eaa <sleep>
  while(ticks - ticks0 < n){
    80002954:	409c                	lw	a5,0(s1)
    80002956:	412787bb          	subw	a5,a5,s2
    8000295a:	fcc42703          	lw	a4,-52(s0)
    8000295e:	fee7e2e3          	bltu	a5,a4,80002942 <sys_sleep+0x4a>
    80002962:	74a2                	ld	s1,40(sp)
    80002964:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002966:	00013517          	auipc	a0,0x13
    8000296a:	efa50513          	addi	a0,a0,-262 # 80015860 <tickslock>
    8000296e:	b24fe0ef          	jal	80000c92 <release>
  return 0;
    80002972:	4501                	li	a0,0
}
    80002974:	70e2                	ld	ra,56(sp)
    80002976:	7442                	ld	s0,48(sp)
    80002978:	7902                	ld	s2,32(sp)
    8000297a:	6121                	addi	sp,sp,64
    8000297c:	8082                	ret
    n = 0;
    8000297e:	fc042623          	sw	zero,-52(s0)
    80002982:	bf49                	j	80002914 <sys_sleep+0x1c>
      release(&tickslock);
    80002984:	00013517          	auipc	a0,0x13
    80002988:	edc50513          	addi	a0,a0,-292 # 80015860 <tickslock>
    8000298c:	b06fe0ef          	jal	80000c92 <release>
      return -1;
    80002990:	557d                	li	a0,-1
    80002992:	74a2                	ld	s1,40(sp)
    80002994:	69e2                	ld	s3,24(sp)
    80002996:	bff9                	j	80002974 <sys_sleep+0x7c>

0000000080002998 <sys_kill>:

uint64
sys_kill(void)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029a0:	fec40593          	addi	a1,s0,-20
    800029a4:	4501                	li	a0,0
    800029a6:	de9ff0ef          	jal	8000278e <argint>
  return kill(pid);
    800029aa:	fec42503          	lw	a0,-20(s0)
    800029ae:	eaaff0ef          	jal	80002058 <kill>
}
    800029b2:	60e2                	ld	ra,24(sp)
    800029b4:	6442                	ld	s0,16(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029c4:	00013517          	auipc	a0,0x13
    800029c8:	e9c50513          	addi	a0,a0,-356 # 80015860 <tickslock>
    800029cc:	a32fe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    800029d0:	00005497          	auipc	s1,0x5
    800029d4:	f304a483          	lw	s1,-208(s1) # 80007900 <ticks>
  release(&tickslock);
    800029d8:	00013517          	auipc	a0,0x13
    800029dc:	e8850513          	addi	a0,a0,-376 # 80015860 <tickslock>
    800029e0:	ab2fe0ef          	jal	80000c92 <release>
  return xticks;
}
    800029e4:	02049513          	slli	a0,s1,0x20
    800029e8:	9101                	srli	a0,a0,0x20
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800029f4:	7179                	addi	sp,sp,-48
    800029f6:	f406                	sd	ra,40(sp)
    800029f8:	f022                	sd	s0,32(sp)
    800029fa:	ec26                	sd	s1,24(sp)
    800029fc:	e84a                	sd	s2,16(sp)
    800029fe:	e44e                	sd	s3,8(sp)
    80002a00:	e052                	sd	s4,0(sp)
    80002a02:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a04:	00005597          	auipc	a1,0x5
    80002a08:	a2c58593          	addi	a1,a1,-1492 # 80007430 <etext+0x430>
    80002a0c:	00013517          	auipc	a0,0x13
    80002a10:	e6c50513          	addi	a0,a0,-404 # 80015878 <bcache>
    80002a14:	966fe0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a18:	0001b797          	auipc	a5,0x1b
    80002a1c:	e6078793          	addi	a5,a5,-416 # 8001d878 <bcache+0x8000>
    80002a20:	0001b717          	auipc	a4,0x1b
    80002a24:	0c070713          	addi	a4,a4,192 # 8001dae0 <bcache+0x8268>
    80002a28:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a2c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a30:	00013497          	auipc	s1,0x13
    80002a34:	e6048493          	addi	s1,s1,-416 # 80015890 <bcache+0x18>
    b->next = bcache.head.next;
    80002a38:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a3a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a3c:	00005a17          	auipc	s4,0x5
    80002a40:	9fca0a13          	addi	s4,s4,-1540 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002a44:	2b893783          	ld	a5,696(s2)
    80002a48:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002a4a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002a4e:	85d2                	mv	a1,s4
    80002a50:	01048513          	addi	a0,s1,16
    80002a54:	244010ef          	jal	80003c98 <initsleeplock>
    bcache.head.next->prev = b;
    80002a58:	2b893783          	ld	a5,696(s2)
    80002a5c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a5e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a62:	45848493          	addi	s1,s1,1112
    80002a66:	fd349fe3          	bne	s1,s3,80002a44 <binit+0x50>
  }
}
    80002a6a:	70a2                	ld	ra,40(sp)
    80002a6c:	7402                	ld	s0,32(sp)
    80002a6e:	64e2                	ld	s1,24(sp)
    80002a70:	6942                	ld	s2,16(sp)
    80002a72:	69a2                	ld	s3,8(sp)
    80002a74:	6a02                	ld	s4,0(sp)
    80002a76:	6145                	addi	sp,sp,48
    80002a78:	8082                	ret

0000000080002a7a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002a7a:	7179                	addi	sp,sp,-48
    80002a7c:	f406                	sd	ra,40(sp)
    80002a7e:	f022                	sd	s0,32(sp)
    80002a80:	ec26                	sd	s1,24(sp)
    80002a82:	e84a                	sd	s2,16(sp)
    80002a84:	e44e                	sd	s3,8(sp)
    80002a86:	1800                	addi	s0,sp,48
    80002a88:	892a                	mv	s2,a0
    80002a8a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002a8c:	00013517          	auipc	a0,0x13
    80002a90:	dec50513          	addi	a0,a0,-532 # 80015878 <bcache>
    80002a94:	96afe0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002a98:	0001b497          	auipc	s1,0x1b
    80002a9c:	0984b483          	ld	s1,152(s1) # 8001db30 <bcache+0x82b8>
    80002aa0:	0001b797          	auipc	a5,0x1b
    80002aa4:	04078793          	addi	a5,a5,64 # 8001dae0 <bcache+0x8268>
    80002aa8:	02f48b63          	beq	s1,a5,80002ade <bread+0x64>
    80002aac:	873e                	mv	a4,a5
    80002aae:	a021                	j	80002ab6 <bread+0x3c>
    80002ab0:	68a4                	ld	s1,80(s1)
    80002ab2:	02e48663          	beq	s1,a4,80002ade <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ab6:	449c                	lw	a5,8(s1)
    80002ab8:	ff279ce3          	bne	a5,s2,80002ab0 <bread+0x36>
    80002abc:	44dc                	lw	a5,12(s1)
    80002abe:	ff3799e3          	bne	a5,s3,80002ab0 <bread+0x36>
      b->refcnt++;
    80002ac2:	40bc                	lw	a5,64(s1)
    80002ac4:	2785                	addiw	a5,a5,1
    80002ac6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ac8:	00013517          	auipc	a0,0x13
    80002acc:	db050513          	addi	a0,a0,-592 # 80015878 <bcache>
    80002ad0:	9c2fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002ad4:	01048513          	addi	a0,s1,16
    80002ad8:	1f6010ef          	jal	80003cce <acquiresleep>
      return b;
    80002adc:	a889                	j	80002b2e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ade:	0001b497          	auipc	s1,0x1b
    80002ae2:	04a4b483          	ld	s1,74(s1) # 8001db28 <bcache+0x82b0>
    80002ae6:	0001b797          	auipc	a5,0x1b
    80002aea:	ffa78793          	addi	a5,a5,-6 # 8001dae0 <bcache+0x8268>
    80002aee:	00f48863          	beq	s1,a5,80002afe <bread+0x84>
    80002af2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002af4:	40bc                	lw	a5,64(s1)
    80002af6:	cb91                	beqz	a5,80002b0a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002af8:	64a4                	ld	s1,72(s1)
    80002afa:	fee49de3          	bne	s1,a4,80002af4 <bread+0x7a>
  panic("bget: no buffers");
    80002afe:	00005517          	auipc	a0,0x5
    80002b02:	94250513          	addi	a0,a0,-1726 # 80007440 <etext+0x440>
    80002b06:	c99fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002b0a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b0e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b12:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b16:	4785                	li	a5,1
    80002b18:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b1a:	00013517          	auipc	a0,0x13
    80002b1e:	d5e50513          	addi	a0,a0,-674 # 80015878 <bcache>
    80002b22:	970fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002b26:	01048513          	addi	a0,s1,16
    80002b2a:	1a4010ef          	jal	80003cce <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002b2e:	409c                	lw	a5,0(s1)
    80002b30:	cb89                	beqz	a5,80002b42 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002b32:	8526                	mv	a0,s1
    80002b34:	70a2                	ld	ra,40(sp)
    80002b36:	7402                	ld	s0,32(sp)
    80002b38:	64e2                	ld	s1,24(sp)
    80002b3a:	6942                	ld	s2,16(sp)
    80002b3c:	69a2                	ld	s3,8(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b42:	4581                	li	a1,0
    80002b44:	8526                	mv	a0,s1
    80002b46:	1fb020ef          	jal	80005540 <virtio_disk_rw>
    b->valid = 1;
    80002b4a:	4785                	li	a5,1
    80002b4c:	c09c                	sw	a5,0(s1)
  return b;
    80002b4e:	b7d5                	j	80002b32 <bread+0xb8>

0000000080002b50 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	1000                	addi	s0,sp,32
    80002b5a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b5c:	0541                	addi	a0,a0,16
    80002b5e:	1ee010ef          	jal	80003d4c <holdingsleep>
    80002b62:	c911                	beqz	a0,80002b76 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b64:	4585                	li	a1,1
    80002b66:	8526                	mv	a0,s1
    80002b68:	1d9020ef          	jal	80005540 <virtio_disk_rw>
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret
    panic("bwrite");
    80002b76:	00005517          	auipc	a0,0x5
    80002b7a:	8e250513          	addi	a0,a0,-1822 # 80007458 <etext+0x458>
    80002b7e:	c21fd0ef          	jal	8000079e <panic>

0000000080002b82 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002b82:	1101                	addi	sp,sp,-32
    80002b84:	ec06                	sd	ra,24(sp)
    80002b86:	e822                	sd	s0,16(sp)
    80002b88:	e426                	sd	s1,8(sp)
    80002b8a:	e04a                	sd	s2,0(sp)
    80002b8c:	1000                	addi	s0,sp,32
    80002b8e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b90:	01050913          	addi	s2,a0,16
    80002b94:	854a                	mv	a0,s2
    80002b96:	1b6010ef          	jal	80003d4c <holdingsleep>
    80002b9a:	c125                	beqz	a0,80002bfa <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002b9c:	854a                	mv	a0,s2
    80002b9e:	176010ef          	jal	80003d14 <releasesleep>

  acquire(&bcache.lock);
    80002ba2:	00013517          	auipc	a0,0x13
    80002ba6:	cd650513          	addi	a0,a0,-810 # 80015878 <bcache>
    80002baa:	854fe0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002bae:	40bc                	lw	a5,64(s1)
    80002bb0:	37fd                	addiw	a5,a5,-1
    80002bb2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002bb4:	e79d                	bnez	a5,80002be2 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002bb6:	68b8                	ld	a4,80(s1)
    80002bb8:	64bc                	ld	a5,72(s1)
    80002bba:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002bbc:	68b8                	ld	a4,80(s1)
    80002bbe:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002bc0:	0001b797          	auipc	a5,0x1b
    80002bc4:	cb878793          	addi	a5,a5,-840 # 8001d878 <bcache+0x8000>
    80002bc8:	2b87b703          	ld	a4,696(a5)
    80002bcc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002bce:	0001b717          	auipc	a4,0x1b
    80002bd2:	f1270713          	addi	a4,a4,-238 # 8001dae0 <bcache+0x8268>
    80002bd6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002bd8:	2b87b703          	ld	a4,696(a5)
    80002bdc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002bde:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002be2:	00013517          	auipc	a0,0x13
    80002be6:	c9650513          	addi	a0,a0,-874 # 80015878 <bcache>
    80002bea:	8a8fe0ef          	jal	80000c92 <release>
}
    80002bee:	60e2                	ld	ra,24(sp)
    80002bf0:	6442                	ld	s0,16(sp)
    80002bf2:	64a2                	ld	s1,8(sp)
    80002bf4:	6902                	ld	s2,0(sp)
    80002bf6:	6105                	addi	sp,sp,32
    80002bf8:	8082                	ret
    panic("brelse");
    80002bfa:	00005517          	auipc	a0,0x5
    80002bfe:	86650513          	addi	a0,a0,-1946 # 80007460 <etext+0x460>
    80002c02:	b9dfd0ef          	jal	8000079e <panic>

0000000080002c06 <bpin>:

void
bpin(struct buf *b) {
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c12:	00013517          	auipc	a0,0x13
    80002c16:	c6650513          	addi	a0,a0,-922 # 80015878 <bcache>
    80002c1a:	fe5fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002c1e:	40bc                	lw	a5,64(s1)
    80002c20:	2785                	addiw	a5,a5,1
    80002c22:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c24:	00013517          	auipc	a0,0x13
    80002c28:	c5450513          	addi	a0,a0,-940 # 80015878 <bcache>
    80002c2c:	866fe0ef          	jal	80000c92 <release>
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6105                	addi	sp,sp,32
    80002c38:	8082                	ret

0000000080002c3a <bunpin>:

void
bunpin(struct buf *b) {
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	1000                	addi	s0,sp,32
    80002c44:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c46:	00013517          	auipc	a0,0x13
    80002c4a:	c3250513          	addi	a0,a0,-974 # 80015878 <bcache>
    80002c4e:	fb1fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002c52:	40bc                	lw	a5,64(s1)
    80002c54:	37fd                	addiw	a5,a5,-1
    80002c56:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c58:	00013517          	auipc	a0,0x13
    80002c5c:	c2050513          	addi	a0,a0,-992 # 80015878 <bcache>
    80002c60:	832fe0ef          	jal	80000c92 <release>
}
    80002c64:	60e2                	ld	ra,24(sp)
    80002c66:	6442                	ld	s0,16(sp)
    80002c68:	64a2                	ld	s1,8(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	e04a                	sd	s2,0(sp)
    80002c78:	1000                	addi	s0,sp,32
    80002c7a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002c7c:	00d5d79b          	srliw	a5,a1,0xd
    80002c80:	0001b597          	auipc	a1,0x1b
    80002c84:	2d45a583          	lw	a1,724(a1) # 8001df54 <sb+0x1c>
    80002c88:	9dbd                	addw	a1,a1,a5
    80002c8a:	df1ff0ef          	jal	80002a7a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002c8e:	0074f713          	andi	a4,s1,7
    80002c92:	4785                	li	a5,1
    80002c94:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002c98:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002c9a:	90d9                	srli	s1,s1,0x36
    80002c9c:	00950733          	add	a4,a0,s1
    80002ca0:	05874703          	lbu	a4,88(a4)
    80002ca4:	00e7f6b3          	and	a3,a5,a4
    80002ca8:	c29d                	beqz	a3,80002cce <bfree+0x60>
    80002caa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002cac:	94aa                	add	s1,s1,a0
    80002cae:	fff7c793          	not	a5,a5
    80002cb2:	8f7d                	and	a4,a4,a5
    80002cb4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002cb8:	711000ef          	jal	80003bc8 <log_write>
  brelse(bp);
    80002cbc:	854a                	mv	a0,s2
    80002cbe:	ec5ff0ef          	jal	80002b82 <brelse>
}
    80002cc2:	60e2                	ld	ra,24(sp)
    80002cc4:	6442                	ld	s0,16(sp)
    80002cc6:	64a2                	ld	s1,8(sp)
    80002cc8:	6902                	ld	s2,0(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret
    panic("freeing free block");
    80002cce:	00004517          	auipc	a0,0x4
    80002cd2:	79a50513          	addi	a0,a0,1946 # 80007468 <etext+0x468>
    80002cd6:	ac9fd0ef          	jal	8000079e <panic>

0000000080002cda <balloc>:
{
    80002cda:	715d                	addi	sp,sp,-80
    80002cdc:	e486                	sd	ra,72(sp)
    80002cde:	e0a2                	sd	s0,64(sp)
    80002ce0:	fc26                	sd	s1,56(sp)
    80002ce2:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002ce4:	0001b797          	auipc	a5,0x1b
    80002ce8:	2587a783          	lw	a5,600(a5) # 8001df3c <sb+0x4>
    80002cec:	0e078863          	beqz	a5,80002ddc <balloc+0x102>
    80002cf0:	f84a                	sd	s2,48(sp)
    80002cf2:	f44e                	sd	s3,40(sp)
    80002cf4:	f052                	sd	s4,32(sp)
    80002cf6:	ec56                	sd	s5,24(sp)
    80002cf8:	e85a                	sd	s6,16(sp)
    80002cfa:	e45e                	sd	s7,8(sp)
    80002cfc:	e062                	sd	s8,0(sp)
    80002cfe:	8baa                	mv	s7,a0
    80002d00:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d02:	0001bb17          	auipc	s6,0x1b
    80002d06:	236b0b13          	addi	s6,s6,566 # 8001df38 <sb>
      m = 1 << (bi % 8);
    80002d0a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d0c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002d0e:	6c09                	lui	s8,0x2
    80002d10:	a09d                	j	80002d76 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002d12:	97ca                	add	a5,a5,s2
    80002d14:	8e55                	or	a2,a2,a3
    80002d16:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d1a:	854a                	mv	a0,s2
    80002d1c:	6ad000ef          	jal	80003bc8 <log_write>
        brelse(bp);
    80002d20:	854a                	mv	a0,s2
    80002d22:	e61ff0ef          	jal	80002b82 <brelse>
  bp = bread(dev, bno);
    80002d26:	85a6                	mv	a1,s1
    80002d28:	855e                	mv	a0,s7
    80002d2a:	d51ff0ef          	jal	80002a7a <bread>
    80002d2e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002d30:	40000613          	li	a2,1024
    80002d34:	4581                	li	a1,0
    80002d36:	05850513          	addi	a0,a0,88
    80002d3a:	f95fd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002d3e:	854a                	mv	a0,s2
    80002d40:	689000ef          	jal	80003bc8 <log_write>
  brelse(bp);
    80002d44:	854a                	mv	a0,s2
    80002d46:	e3dff0ef          	jal	80002b82 <brelse>
}
    80002d4a:	7942                	ld	s2,48(sp)
    80002d4c:	79a2                	ld	s3,40(sp)
    80002d4e:	7a02                	ld	s4,32(sp)
    80002d50:	6ae2                	ld	s5,24(sp)
    80002d52:	6b42                	ld	s6,16(sp)
    80002d54:	6ba2                	ld	s7,8(sp)
    80002d56:	6c02                	ld	s8,0(sp)
}
    80002d58:	8526                	mv	a0,s1
    80002d5a:	60a6                	ld	ra,72(sp)
    80002d5c:	6406                	ld	s0,64(sp)
    80002d5e:	74e2                	ld	s1,56(sp)
    80002d60:	6161                	addi	sp,sp,80
    80002d62:	8082                	ret
    brelse(bp);
    80002d64:	854a                	mv	a0,s2
    80002d66:	e1dff0ef          	jal	80002b82 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002d6a:	015c0abb          	addw	s5,s8,s5
    80002d6e:	004b2783          	lw	a5,4(s6)
    80002d72:	04fafe63          	bgeu	s5,a5,80002dce <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002d76:	41fad79b          	sraiw	a5,s5,0x1f
    80002d7a:	0137d79b          	srliw	a5,a5,0x13
    80002d7e:	015787bb          	addw	a5,a5,s5
    80002d82:	40d7d79b          	sraiw	a5,a5,0xd
    80002d86:	01cb2583          	lw	a1,28(s6)
    80002d8a:	9dbd                	addw	a1,a1,a5
    80002d8c:	855e                	mv	a0,s7
    80002d8e:	cedff0ef          	jal	80002a7a <bread>
    80002d92:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d94:	004b2503          	lw	a0,4(s6)
    80002d98:	84d6                	mv	s1,s5
    80002d9a:	4701                	li	a4,0
    80002d9c:	fca4f4e3          	bgeu	s1,a0,80002d64 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002da0:	00777693          	andi	a3,a4,7
    80002da4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002da8:	41f7579b          	sraiw	a5,a4,0x1f
    80002dac:	01d7d79b          	srliw	a5,a5,0x1d
    80002db0:	9fb9                	addw	a5,a5,a4
    80002db2:	4037d79b          	sraiw	a5,a5,0x3
    80002db6:	00f90633          	add	a2,s2,a5
    80002dba:	05864603          	lbu	a2,88(a2)
    80002dbe:	00c6f5b3          	and	a1,a3,a2
    80002dc2:	d9a1                	beqz	a1,80002d12 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dc4:	2705                	addiw	a4,a4,1
    80002dc6:	2485                	addiw	s1,s1,1
    80002dc8:	fd471ae3          	bne	a4,s4,80002d9c <balloc+0xc2>
    80002dcc:	bf61                	j	80002d64 <balloc+0x8a>
    80002dce:	7942                	ld	s2,48(sp)
    80002dd0:	79a2                	ld	s3,40(sp)
    80002dd2:	7a02                	ld	s4,32(sp)
    80002dd4:	6ae2                	ld	s5,24(sp)
    80002dd6:	6b42                	ld	s6,16(sp)
    80002dd8:	6ba2                	ld	s7,8(sp)
    80002dda:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002ddc:	00004517          	auipc	a0,0x4
    80002de0:	6a450513          	addi	a0,a0,1700 # 80007480 <etext+0x480>
    80002de4:	eeafd0ef          	jal	800004ce <printf>
  return 0;
    80002de8:	4481                	li	s1,0
    80002dea:	b7bd                	j	80002d58 <balloc+0x7e>

0000000080002dec <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002dec:	7179                	addi	sp,sp,-48
    80002dee:	f406                	sd	ra,40(sp)
    80002df0:	f022                	sd	s0,32(sp)
    80002df2:	ec26                	sd	s1,24(sp)
    80002df4:	e84a                	sd	s2,16(sp)
    80002df6:	e44e                	sd	s3,8(sp)
    80002df8:	1800                	addi	s0,sp,48
    80002dfa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002dfc:	47ad                	li	a5,11
    80002dfe:	02b7e363          	bltu	a5,a1,80002e24 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002e02:	02059793          	slli	a5,a1,0x20
    80002e06:	01e7d593          	srli	a1,a5,0x1e
    80002e0a:	00b504b3          	add	s1,a0,a1
    80002e0e:	0504a903          	lw	s2,80(s1)
    80002e12:	06091363          	bnez	s2,80002e78 <bmap+0x8c>
      addr = balloc(ip->dev);
    80002e16:	4108                	lw	a0,0(a0)
    80002e18:	ec3ff0ef          	jal	80002cda <balloc>
    80002e1c:	892a                	mv	s2,a0
      if(addr == 0)
    80002e1e:	cd29                	beqz	a0,80002e78 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002e20:	c8a8                	sw	a0,80(s1)
    80002e22:	a899                	j	80002e78 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e24:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002e28:	0ff00793          	li	a5,255
    80002e2c:	0697e963          	bltu	a5,s1,80002e9e <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002e30:	08052903          	lw	s2,128(a0)
    80002e34:	00091b63          	bnez	s2,80002e4a <bmap+0x5e>
      addr = balloc(ip->dev);
    80002e38:	4108                	lw	a0,0(a0)
    80002e3a:	ea1ff0ef          	jal	80002cda <balloc>
    80002e3e:	892a                	mv	s2,a0
      if(addr == 0)
    80002e40:	cd05                	beqz	a0,80002e78 <bmap+0x8c>
    80002e42:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002e44:	08a9a023          	sw	a0,128(s3)
    80002e48:	a011                	j	80002e4c <bmap+0x60>
    80002e4a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002e4c:	85ca                	mv	a1,s2
    80002e4e:	0009a503          	lw	a0,0(s3)
    80002e52:	c29ff0ef          	jal	80002a7a <bread>
    80002e56:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002e58:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002e5c:	02049713          	slli	a4,s1,0x20
    80002e60:	01e75593          	srli	a1,a4,0x1e
    80002e64:	00b784b3          	add	s1,a5,a1
    80002e68:	0004a903          	lw	s2,0(s1)
    80002e6c:	00090e63          	beqz	s2,80002e88 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002e70:	8552                	mv	a0,s4
    80002e72:	d11ff0ef          	jal	80002b82 <brelse>
    return addr;
    80002e76:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002e78:	854a                	mv	a0,s2
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6942                	ld	s2,16(sp)
    80002e82:	69a2                	ld	s3,8(sp)
    80002e84:	6145                	addi	sp,sp,48
    80002e86:	8082                	ret
      addr = balloc(ip->dev);
    80002e88:	0009a503          	lw	a0,0(s3)
    80002e8c:	e4fff0ef          	jal	80002cda <balloc>
    80002e90:	892a                	mv	s2,a0
      if(addr){
    80002e92:	dd79                	beqz	a0,80002e70 <bmap+0x84>
        a[bn] = addr;
    80002e94:	c088                	sw	a0,0(s1)
        log_write(bp);
    80002e96:	8552                	mv	a0,s4
    80002e98:	531000ef          	jal	80003bc8 <log_write>
    80002e9c:	bfd1                	j	80002e70 <bmap+0x84>
    80002e9e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ea0:	00004517          	auipc	a0,0x4
    80002ea4:	5f850513          	addi	a0,a0,1528 # 80007498 <etext+0x498>
    80002ea8:	8f7fd0ef          	jal	8000079e <panic>

0000000080002eac <iget>:
{
    80002eac:	7179                	addi	sp,sp,-48
    80002eae:	f406                	sd	ra,40(sp)
    80002eb0:	f022                	sd	s0,32(sp)
    80002eb2:	ec26                	sd	s1,24(sp)
    80002eb4:	e84a                	sd	s2,16(sp)
    80002eb6:	e44e                	sd	s3,8(sp)
    80002eb8:	e052                	sd	s4,0(sp)
    80002eba:	1800                	addi	s0,sp,48
    80002ebc:	89aa                	mv	s3,a0
    80002ebe:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002ec0:	0001b517          	auipc	a0,0x1b
    80002ec4:	09850513          	addi	a0,a0,152 # 8001df58 <itable>
    80002ec8:	d37fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80002ecc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002ece:	0001b497          	auipc	s1,0x1b
    80002ed2:	0a248493          	addi	s1,s1,162 # 8001df70 <itable+0x18>
    80002ed6:	0001d697          	auipc	a3,0x1d
    80002eda:	b2a68693          	addi	a3,a3,-1238 # 8001fa00 <log>
    80002ede:	a039                	j	80002eec <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ee0:	02090963          	beqz	s2,80002f12 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002ee4:	08848493          	addi	s1,s1,136
    80002ee8:	02d48863          	beq	s1,a3,80002f18 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002eec:	449c                	lw	a5,8(s1)
    80002eee:	fef059e3          	blez	a5,80002ee0 <iget+0x34>
    80002ef2:	4098                	lw	a4,0(s1)
    80002ef4:	ff3716e3          	bne	a4,s3,80002ee0 <iget+0x34>
    80002ef8:	40d8                	lw	a4,4(s1)
    80002efa:	ff4713e3          	bne	a4,s4,80002ee0 <iget+0x34>
      ip->ref++;
    80002efe:	2785                	addiw	a5,a5,1
    80002f00:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f02:	0001b517          	auipc	a0,0x1b
    80002f06:	05650513          	addi	a0,a0,86 # 8001df58 <itable>
    80002f0a:	d89fd0ef          	jal	80000c92 <release>
      return ip;
    80002f0e:	8926                	mv	s2,s1
    80002f10:	a02d                	j	80002f3a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f12:	fbe9                	bnez	a5,80002ee4 <iget+0x38>
      empty = ip;
    80002f14:	8926                	mv	s2,s1
    80002f16:	b7f9                	j	80002ee4 <iget+0x38>
  if(empty == 0)
    80002f18:	02090a63          	beqz	s2,80002f4c <iget+0xa0>
  ip->dev = dev;
    80002f1c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f20:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002f24:	4785                	li	a5,1
    80002f26:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002f2a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002f2e:	0001b517          	auipc	a0,0x1b
    80002f32:	02a50513          	addi	a0,a0,42 # 8001df58 <itable>
    80002f36:	d5dfd0ef          	jal	80000c92 <release>
}
    80002f3a:	854a                	mv	a0,s2
    80002f3c:	70a2                	ld	ra,40(sp)
    80002f3e:	7402                	ld	s0,32(sp)
    80002f40:	64e2                	ld	s1,24(sp)
    80002f42:	6942                	ld	s2,16(sp)
    80002f44:	69a2                	ld	s3,8(sp)
    80002f46:	6a02                	ld	s4,0(sp)
    80002f48:	6145                	addi	sp,sp,48
    80002f4a:	8082                	ret
    panic("iget: no inodes");
    80002f4c:	00004517          	auipc	a0,0x4
    80002f50:	56450513          	addi	a0,a0,1380 # 800074b0 <etext+0x4b0>
    80002f54:	84bfd0ef          	jal	8000079e <panic>

0000000080002f58 <fsinit>:
fsinit(int dev) {
    80002f58:	7179                	addi	sp,sp,-48
    80002f5a:	f406                	sd	ra,40(sp)
    80002f5c:	f022                	sd	s0,32(sp)
    80002f5e:	ec26                	sd	s1,24(sp)
    80002f60:	e84a                	sd	s2,16(sp)
    80002f62:	e44e                	sd	s3,8(sp)
    80002f64:	1800                	addi	s0,sp,48
    80002f66:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002f68:	4585                	li	a1,1
    80002f6a:	b11ff0ef          	jal	80002a7a <bread>
    80002f6e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002f70:	0001b997          	auipc	s3,0x1b
    80002f74:	fc898993          	addi	s3,s3,-56 # 8001df38 <sb>
    80002f78:	02000613          	li	a2,32
    80002f7c:	05850593          	addi	a1,a0,88
    80002f80:	854e                	mv	a0,s3
    80002f82:	db1fd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    80002f86:	8526                	mv	a0,s1
    80002f88:	bfbff0ef          	jal	80002b82 <brelse>
  if(sb.magic != FSMAGIC)
    80002f8c:	0009a703          	lw	a4,0(s3)
    80002f90:	102037b7          	lui	a5,0x10203
    80002f94:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002f98:	02f71063          	bne	a4,a5,80002fb8 <fsinit+0x60>
  initlog(dev, &sb);
    80002f9c:	0001b597          	auipc	a1,0x1b
    80002fa0:	f9c58593          	addi	a1,a1,-100 # 8001df38 <sb>
    80002fa4:	854a                	mv	a0,s2
    80002fa6:	215000ef          	jal	800039ba <initlog>
}
    80002faa:	70a2                	ld	ra,40(sp)
    80002fac:	7402                	ld	s0,32(sp)
    80002fae:	64e2                	ld	s1,24(sp)
    80002fb0:	6942                	ld	s2,16(sp)
    80002fb2:	69a2                	ld	s3,8(sp)
    80002fb4:	6145                	addi	sp,sp,48
    80002fb6:	8082                	ret
    panic("invalid file system");
    80002fb8:	00004517          	auipc	a0,0x4
    80002fbc:	50850513          	addi	a0,a0,1288 # 800074c0 <etext+0x4c0>
    80002fc0:	fdefd0ef          	jal	8000079e <panic>

0000000080002fc4 <iinit>:
{
    80002fc4:	7179                	addi	sp,sp,-48
    80002fc6:	f406                	sd	ra,40(sp)
    80002fc8:	f022                	sd	s0,32(sp)
    80002fca:	ec26                	sd	s1,24(sp)
    80002fcc:	e84a                	sd	s2,16(sp)
    80002fce:	e44e                	sd	s3,8(sp)
    80002fd0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002fd2:	00004597          	auipc	a1,0x4
    80002fd6:	50658593          	addi	a1,a1,1286 # 800074d8 <etext+0x4d8>
    80002fda:	0001b517          	auipc	a0,0x1b
    80002fde:	f7e50513          	addi	a0,a0,-130 # 8001df58 <itable>
    80002fe2:	b99fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80002fe6:	0001b497          	auipc	s1,0x1b
    80002fea:	f9a48493          	addi	s1,s1,-102 # 8001df80 <itable+0x28>
    80002fee:	0001d997          	auipc	s3,0x1d
    80002ff2:	a2298993          	addi	s3,s3,-1502 # 8001fa10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002ff6:	00004917          	auipc	s2,0x4
    80002ffa:	4ea90913          	addi	s2,s2,1258 # 800074e0 <etext+0x4e0>
    80002ffe:	85ca                	mv	a1,s2
    80003000:	8526                	mv	a0,s1
    80003002:	497000ef          	jal	80003c98 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003006:	08848493          	addi	s1,s1,136
    8000300a:	ff349ae3          	bne	s1,s3,80002ffe <iinit+0x3a>
}
    8000300e:	70a2                	ld	ra,40(sp)
    80003010:	7402                	ld	s0,32(sp)
    80003012:	64e2                	ld	s1,24(sp)
    80003014:	6942                	ld	s2,16(sp)
    80003016:	69a2                	ld	s3,8(sp)
    80003018:	6145                	addi	sp,sp,48
    8000301a:	8082                	ret

000000008000301c <ialloc>:
{
    8000301c:	7139                	addi	sp,sp,-64
    8000301e:	fc06                	sd	ra,56(sp)
    80003020:	f822                	sd	s0,48(sp)
    80003022:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003024:	0001b717          	auipc	a4,0x1b
    80003028:	f2072703          	lw	a4,-224(a4) # 8001df44 <sb+0xc>
    8000302c:	4785                	li	a5,1
    8000302e:	06e7f063          	bgeu	a5,a4,8000308e <ialloc+0x72>
    80003032:	f426                	sd	s1,40(sp)
    80003034:	f04a                	sd	s2,32(sp)
    80003036:	ec4e                	sd	s3,24(sp)
    80003038:	e852                	sd	s4,16(sp)
    8000303a:	e456                	sd	s5,8(sp)
    8000303c:	e05a                	sd	s6,0(sp)
    8000303e:	8aaa                	mv	s5,a0
    80003040:	8b2e                	mv	s6,a1
    80003042:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003044:	0001ba17          	auipc	s4,0x1b
    80003048:	ef4a0a13          	addi	s4,s4,-268 # 8001df38 <sb>
    8000304c:	00495593          	srli	a1,s2,0x4
    80003050:	018a2783          	lw	a5,24(s4)
    80003054:	9dbd                	addw	a1,a1,a5
    80003056:	8556                	mv	a0,s5
    80003058:	a23ff0ef          	jal	80002a7a <bread>
    8000305c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000305e:	05850993          	addi	s3,a0,88
    80003062:	00f97793          	andi	a5,s2,15
    80003066:	079a                	slli	a5,a5,0x6
    80003068:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000306a:	00099783          	lh	a5,0(s3)
    8000306e:	cb9d                	beqz	a5,800030a4 <ialloc+0x88>
    brelse(bp);
    80003070:	b13ff0ef          	jal	80002b82 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003074:	0905                	addi	s2,s2,1
    80003076:	00ca2703          	lw	a4,12(s4)
    8000307a:	0009079b          	sext.w	a5,s2
    8000307e:	fce7e7e3          	bltu	a5,a4,8000304c <ialloc+0x30>
    80003082:	74a2                	ld	s1,40(sp)
    80003084:	7902                	ld	s2,32(sp)
    80003086:	69e2                	ld	s3,24(sp)
    80003088:	6a42                	ld	s4,16(sp)
    8000308a:	6aa2                	ld	s5,8(sp)
    8000308c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000308e:	00004517          	auipc	a0,0x4
    80003092:	45a50513          	addi	a0,a0,1114 # 800074e8 <etext+0x4e8>
    80003096:	c38fd0ef          	jal	800004ce <printf>
  return 0;
    8000309a:	4501                	li	a0,0
}
    8000309c:	70e2                	ld	ra,56(sp)
    8000309e:	7442                	ld	s0,48(sp)
    800030a0:	6121                	addi	sp,sp,64
    800030a2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030a4:	04000613          	li	a2,64
    800030a8:	4581                	li	a1,0
    800030aa:	854e                	mv	a0,s3
    800030ac:	c23fd0ef          	jal	80000cce <memset>
      dip->type = type;
    800030b0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800030b4:	8526                	mv	a0,s1
    800030b6:	313000ef          	jal	80003bc8 <log_write>
      brelse(bp);
    800030ba:	8526                	mv	a0,s1
    800030bc:	ac7ff0ef          	jal	80002b82 <brelse>
      return iget(dev, inum);
    800030c0:	0009059b          	sext.w	a1,s2
    800030c4:	8556                	mv	a0,s5
    800030c6:	de7ff0ef          	jal	80002eac <iget>
    800030ca:	74a2                	ld	s1,40(sp)
    800030cc:	7902                	ld	s2,32(sp)
    800030ce:	69e2                	ld	s3,24(sp)
    800030d0:	6a42                	ld	s4,16(sp)
    800030d2:	6aa2                	ld	s5,8(sp)
    800030d4:	6b02                	ld	s6,0(sp)
    800030d6:	b7d9                	j	8000309c <ialloc+0x80>

00000000800030d8 <iupdate>:
{
    800030d8:	1101                	addi	sp,sp,-32
    800030da:	ec06                	sd	ra,24(sp)
    800030dc:	e822                	sd	s0,16(sp)
    800030de:	e426                	sd	s1,8(sp)
    800030e0:	e04a                	sd	s2,0(sp)
    800030e2:	1000                	addi	s0,sp,32
    800030e4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800030e6:	415c                	lw	a5,4(a0)
    800030e8:	0047d79b          	srliw	a5,a5,0x4
    800030ec:	0001b597          	auipc	a1,0x1b
    800030f0:	e645a583          	lw	a1,-412(a1) # 8001df50 <sb+0x18>
    800030f4:	9dbd                	addw	a1,a1,a5
    800030f6:	4108                	lw	a0,0(a0)
    800030f8:	983ff0ef          	jal	80002a7a <bread>
    800030fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800030fe:	05850793          	addi	a5,a0,88
    80003102:	40d8                	lw	a4,4(s1)
    80003104:	8b3d                	andi	a4,a4,15
    80003106:	071a                	slli	a4,a4,0x6
    80003108:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000310a:	04449703          	lh	a4,68(s1)
    8000310e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003112:	04649703          	lh	a4,70(s1)
    80003116:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000311a:	04849703          	lh	a4,72(s1)
    8000311e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003122:	04a49703          	lh	a4,74(s1)
    80003126:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000312a:	44f8                	lw	a4,76(s1)
    8000312c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000312e:	03400613          	li	a2,52
    80003132:	05048593          	addi	a1,s1,80
    80003136:	00c78513          	addi	a0,a5,12
    8000313a:	bf9fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    8000313e:	854a                	mv	a0,s2
    80003140:	289000ef          	jal	80003bc8 <log_write>
  brelse(bp);
    80003144:	854a                	mv	a0,s2
    80003146:	a3dff0ef          	jal	80002b82 <brelse>
}
    8000314a:	60e2                	ld	ra,24(sp)
    8000314c:	6442                	ld	s0,16(sp)
    8000314e:	64a2                	ld	s1,8(sp)
    80003150:	6902                	ld	s2,0(sp)
    80003152:	6105                	addi	sp,sp,32
    80003154:	8082                	ret

0000000080003156 <idup>:
{
    80003156:	1101                	addi	sp,sp,-32
    80003158:	ec06                	sd	ra,24(sp)
    8000315a:	e822                	sd	s0,16(sp)
    8000315c:	e426                	sd	s1,8(sp)
    8000315e:	1000                	addi	s0,sp,32
    80003160:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003162:	0001b517          	auipc	a0,0x1b
    80003166:	df650513          	addi	a0,a0,-522 # 8001df58 <itable>
    8000316a:	a95fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    8000316e:	449c                	lw	a5,8(s1)
    80003170:	2785                	addiw	a5,a5,1
    80003172:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003174:	0001b517          	auipc	a0,0x1b
    80003178:	de450513          	addi	a0,a0,-540 # 8001df58 <itable>
    8000317c:	b17fd0ef          	jal	80000c92 <release>
}
    80003180:	8526                	mv	a0,s1
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret

000000008000318c <ilock>:
{
    8000318c:	1101                	addi	sp,sp,-32
    8000318e:	ec06                	sd	ra,24(sp)
    80003190:	e822                	sd	s0,16(sp)
    80003192:	e426                	sd	s1,8(sp)
    80003194:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003196:	cd19                	beqz	a0,800031b4 <ilock+0x28>
    80003198:	84aa                	mv	s1,a0
    8000319a:	451c                	lw	a5,8(a0)
    8000319c:	00f05c63          	blez	a5,800031b4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800031a0:	0541                	addi	a0,a0,16
    800031a2:	32d000ef          	jal	80003cce <acquiresleep>
  if(ip->valid == 0){
    800031a6:	40bc                	lw	a5,64(s1)
    800031a8:	cf89                	beqz	a5,800031c2 <ilock+0x36>
}
    800031aa:	60e2                	ld	ra,24(sp)
    800031ac:	6442                	ld	s0,16(sp)
    800031ae:	64a2                	ld	s1,8(sp)
    800031b0:	6105                	addi	sp,sp,32
    800031b2:	8082                	ret
    800031b4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800031b6:	00004517          	auipc	a0,0x4
    800031ba:	34a50513          	addi	a0,a0,842 # 80007500 <etext+0x500>
    800031be:	de0fd0ef          	jal	8000079e <panic>
    800031c2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031c4:	40dc                	lw	a5,4(s1)
    800031c6:	0047d79b          	srliw	a5,a5,0x4
    800031ca:	0001b597          	auipc	a1,0x1b
    800031ce:	d865a583          	lw	a1,-634(a1) # 8001df50 <sb+0x18>
    800031d2:	9dbd                	addw	a1,a1,a5
    800031d4:	4088                	lw	a0,0(s1)
    800031d6:	8a5ff0ef          	jal	80002a7a <bread>
    800031da:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031dc:	05850593          	addi	a1,a0,88
    800031e0:	40dc                	lw	a5,4(s1)
    800031e2:	8bbd                	andi	a5,a5,15
    800031e4:	079a                	slli	a5,a5,0x6
    800031e6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800031e8:	00059783          	lh	a5,0(a1)
    800031ec:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800031f0:	00259783          	lh	a5,2(a1)
    800031f4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800031f8:	00459783          	lh	a5,4(a1)
    800031fc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003200:	00659783          	lh	a5,6(a1)
    80003204:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003208:	459c                	lw	a5,8(a1)
    8000320a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000320c:	03400613          	li	a2,52
    80003210:	05b1                	addi	a1,a1,12
    80003212:	05048513          	addi	a0,s1,80
    80003216:	b1dfd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    8000321a:	854a                	mv	a0,s2
    8000321c:	967ff0ef          	jal	80002b82 <brelse>
    ip->valid = 1;
    80003220:	4785                	li	a5,1
    80003222:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003224:	04449783          	lh	a5,68(s1)
    80003228:	c399                	beqz	a5,8000322e <ilock+0xa2>
    8000322a:	6902                	ld	s2,0(sp)
    8000322c:	bfbd                	j	800031aa <ilock+0x1e>
      panic("ilock: no type");
    8000322e:	00004517          	auipc	a0,0x4
    80003232:	2da50513          	addi	a0,a0,730 # 80007508 <etext+0x508>
    80003236:	d68fd0ef          	jal	8000079e <panic>

000000008000323a <iunlock>:
{
    8000323a:	1101                	addi	sp,sp,-32
    8000323c:	ec06                	sd	ra,24(sp)
    8000323e:	e822                	sd	s0,16(sp)
    80003240:	e426                	sd	s1,8(sp)
    80003242:	e04a                	sd	s2,0(sp)
    80003244:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003246:	c505                	beqz	a0,8000326e <iunlock+0x34>
    80003248:	84aa                	mv	s1,a0
    8000324a:	01050913          	addi	s2,a0,16
    8000324e:	854a                	mv	a0,s2
    80003250:	2fd000ef          	jal	80003d4c <holdingsleep>
    80003254:	cd09                	beqz	a0,8000326e <iunlock+0x34>
    80003256:	449c                	lw	a5,8(s1)
    80003258:	00f05b63          	blez	a5,8000326e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000325c:	854a                	mv	a0,s2
    8000325e:	2b7000ef          	jal	80003d14 <releasesleep>
}
    80003262:	60e2                	ld	ra,24(sp)
    80003264:	6442                	ld	s0,16(sp)
    80003266:	64a2                	ld	s1,8(sp)
    80003268:	6902                	ld	s2,0(sp)
    8000326a:	6105                	addi	sp,sp,32
    8000326c:	8082                	ret
    panic("iunlock");
    8000326e:	00004517          	auipc	a0,0x4
    80003272:	2aa50513          	addi	a0,a0,682 # 80007518 <etext+0x518>
    80003276:	d28fd0ef          	jal	8000079e <panic>

000000008000327a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000327a:	7179                	addi	sp,sp,-48
    8000327c:	f406                	sd	ra,40(sp)
    8000327e:	f022                	sd	s0,32(sp)
    80003280:	ec26                	sd	s1,24(sp)
    80003282:	e84a                	sd	s2,16(sp)
    80003284:	e44e                	sd	s3,8(sp)
    80003286:	1800                	addi	s0,sp,48
    80003288:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000328a:	05050493          	addi	s1,a0,80
    8000328e:	08050913          	addi	s2,a0,128
    80003292:	a021                	j	8000329a <itrunc+0x20>
    80003294:	0491                	addi	s1,s1,4
    80003296:	01248b63          	beq	s1,s2,800032ac <itrunc+0x32>
    if(ip->addrs[i]){
    8000329a:	408c                	lw	a1,0(s1)
    8000329c:	dde5                	beqz	a1,80003294 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000329e:	0009a503          	lw	a0,0(s3)
    800032a2:	9cdff0ef          	jal	80002c6e <bfree>
      ip->addrs[i] = 0;
    800032a6:	0004a023          	sw	zero,0(s1)
    800032aa:	b7ed                	j	80003294 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800032ac:	0809a583          	lw	a1,128(s3)
    800032b0:	ed89                	bnez	a1,800032ca <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800032b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800032b6:	854e                	mv	a0,s3
    800032b8:	e21ff0ef          	jal	800030d8 <iupdate>
}
    800032bc:	70a2                	ld	ra,40(sp)
    800032be:	7402                	ld	s0,32(sp)
    800032c0:	64e2                	ld	s1,24(sp)
    800032c2:	6942                	ld	s2,16(sp)
    800032c4:	69a2                	ld	s3,8(sp)
    800032c6:	6145                	addi	sp,sp,48
    800032c8:	8082                	ret
    800032ca:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800032cc:	0009a503          	lw	a0,0(s3)
    800032d0:	faaff0ef          	jal	80002a7a <bread>
    800032d4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800032d6:	05850493          	addi	s1,a0,88
    800032da:	45850913          	addi	s2,a0,1112
    800032de:	a021                	j	800032e6 <itrunc+0x6c>
    800032e0:	0491                	addi	s1,s1,4
    800032e2:	01248963          	beq	s1,s2,800032f4 <itrunc+0x7a>
      if(a[j])
    800032e6:	408c                	lw	a1,0(s1)
    800032e8:	dde5                	beqz	a1,800032e0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800032ea:	0009a503          	lw	a0,0(s3)
    800032ee:	981ff0ef          	jal	80002c6e <bfree>
    800032f2:	b7fd                	j	800032e0 <itrunc+0x66>
    brelse(bp);
    800032f4:	8552                	mv	a0,s4
    800032f6:	88dff0ef          	jal	80002b82 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800032fa:	0809a583          	lw	a1,128(s3)
    800032fe:	0009a503          	lw	a0,0(s3)
    80003302:	96dff0ef          	jal	80002c6e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003306:	0809a023          	sw	zero,128(s3)
    8000330a:	6a02                	ld	s4,0(sp)
    8000330c:	b75d                	j	800032b2 <itrunc+0x38>

000000008000330e <iput>:
{
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	1000                	addi	s0,sp,32
    80003318:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000331a:	0001b517          	auipc	a0,0x1b
    8000331e:	c3e50513          	addi	a0,a0,-962 # 8001df58 <itable>
    80003322:	8ddfd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003326:	4498                	lw	a4,8(s1)
    80003328:	4785                	li	a5,1
    8000332a:	02f70063          	beq	a4,a5,8000334a <iput+0x3c>
  ip->ref--;
    8000332e:	449c                	lw	a5,8(s1)
    80003330:	37fd                	addiw	a5,a5,-1
    80003332:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003334:	0001b517          	auipc	a0,0x1b
    80003338:	c2450513          	addi	a0,a0,-988 # 8001df58 <itable>
    8000333c:	957fd0ef          	jal	80000c92 <release>
}
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6105                	addi	sp,sp,32
    80003348:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000334a:	40bc                	lw	a5,64(s1)
    8000334c:	d3ed                	beqz	a5,8000332e <iput+0x20>
    8000334e:	04a49783          	lh	a5,74(s1)
    80003352:	fff1                	bnez	a5,8000332e <iput+0x20>
    80003354:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003356:	01048913          	addi	s2,s1,16
    8000335a:	854a                	mv	a0,s2
    8000335c:	173000ef          	jal	80003cce <acquiresleep>
    release(&itable.lock);
    80003360:	0001b517          	auipc	a0,0x1b
    80003364:	bf850513          	addi	a0,a0,-1032 # 8001df58 <itable>
    80003368:	92bfd0ef          	jal	80000c92 <release>
    itrunc(ip);
    8000336c:	8526                	mv	a0,s1
    8000336e:	f0dff0ef          	jal	8000327a <itrunc>
    ip->type = 0;
    80003372:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003376:	8526                	mv	a0,s1
    80003378:	d61ff0ef          	jal	800030d8 <iupdate>
    ip->valid = 0;
    8000337c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003380:	854a                	mv	a0,s2
    80003382:	193000ef          	jal	80003d14 <releasesleep>
    acquire(&itable.lock);
    80003386:	0001b517          	auipc	a0,0x1b
    8000338a:	bd250513          	addi	a0,a0,-1070 # 8001df58 <itable>
    8000338e:	871fd0ef          	jal	80000bfe <acquire>
    80003392:	6902                	ld	s2,0(sp)
    80003394:	bf69                	j	8000332e <iput+0x20>

0000000080003396 <iunlockput>:
{
    80003396:	1101                	addi	sp,sp,-32
    80003398:	ec06                	sd	ra,24(sp)
    8000339a:	e822                	sd	s0,16(sp)
    8000339c:	e426                	sd	s1,8(sp)
    8000339e:	1000                	addi	s0,sp,32
    800033a0:	84aa                	mv	s1,a0
  iunlock(ip);
    800033a2:	e99ff0ef          	jal	8000323a <iunlock>
  iput(ip);
    800033a6:	8526                	mv	a0,s1
    800033a8:	f67ff0ef          	jal	8000330e <iput>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800033b6:	1141                	addi	sp,sp,-16
    800033b8:	e406                	sd	ra,8(sp)
    800033ba:	e022                	sd	s0,0(sp)
    800033bc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800033be:	411c                	lw	a5,0(a0)
    800033c0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800033c2:	415c                	lw	a5,4(a0)
    800033c4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800033c6:	04451783          	lh	a5,68(a0)
    800033ca:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800033ce:	04a51783          	lh	a5,74(a0)
    800033d2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800033d6:	04c56783          	lwu	a5,76(a0)
    800033da:	e99c                	sd	a5,16(a1)
}
    800033dc:	60a2                	ld	ra,8(sp)
    800033de:	6402                	ld	s0,0(sp)
    800033e0:	0141                	addi	sp,sp,16
    800033e2:	8082                	ret

00000000800033e4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800033e4:	457c                	lw	a5,76(a0)
    800033e6:	0ed7e663          	bltu	a5,a3,800034d2 <readi+0xee>
{
    800033ea:	7159                	addi	sp,sp,-112
    800033ec:	f486                	sd	ra,104(sp)
    800033ee:	f0a2                	sd	s0,96(sp)
    800033f0:	eca6                	sd	s1,88(sp)
    800033f2:	e0d2                	sd	s4,64(sp)
    800033f4:	fc56                	sd	s5,56(sp)
    800033f6:	f85a                	sd	s6,48(sp)
    800033f8:	f45e                	sd	s7,40(sp)
    800033fa:	1880                	addi	s0,sp,112
    800033fc:	8b2a                	mv	s6,a0
    800033fe:	8bae                	mv	s7,a1
    80003400:	8a32                	mv	s4,a2
    80003402:	84b6                	mv	s1,a3
    80003404:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003406:	9f35                	addw	a4,a4,a3
    return 0;
    80003408:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000340a:	0ad76b63          	bltu	a4,a3,800034c0 <readi+0xdc>
    8000340e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003410:	00e7f463          	bgeu	a5,a4,80003418 <readi+0x34>
    n = ip->size - off;
    80003414:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003418:	080a8b63          	beqz	s5,800034ae <readi+0xca>
    8000341c:	e8ca                	sd	s2,80(sp)
    8000341e:	f062                	sd	s8,32(sp)
    80003420:	ec66                	sd	s9,24(sp)
    80003422:	e86a                	sd	s10,16(sp)
    80003424:	e46e                	sd	s11,8(sp)
    80003426:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003428:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000342c:	5c7d                	li	s8,-1
    8000342e:	a80d                	j	80003460 <readi+0x7c>
    80003430:	020d1d93          	slli	s11,s10,0x20
    80003434:	020ddd93          	srli	s11,s11,0x20
    80003438:	05890613          	addi	a2,s2,88
    8000343c:	86ee                	mv	a3,s11
    8000343e:	963e                	add	a2,a2,a5
    80003440:	85d2                	mv	a1,s4
    80003442:	855e                	mv	a0,s7
    80003444:	dbdfe0ef          	jal	80002200 <either_copyout>
    80003448:	05850363          	beq	a0,s8,8000348e <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000344c:	854a                	mv	a0,s2
    8000344e:	f34ff0ef          	jal	80002b82 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003452:	013d09bb          	addw	s3,s10,s3
    80003456:	009d04bb          	addw	s1,s10,s1
    8000345a:	9a6e                	add	s4,s4,s11
    8000345c:	0559f363          	bgeu	s3,s5,800034a2 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003460:	00a4d59b          	srliw	a1,s1,0xa
    80003464:	855a                	mv	a0,s6
    80003466:	987ff0ef          	jal	80002dec <bmap>
    8000346a:	85aa                	mv	a1,a0
    if(addr == 0)
    8000346c:	c139                	beqz	a0,800034b2 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000346e:	000b2503          	lw	a0,0(s6)
    80003472:	e08ff0ef          	jal	80002a7a <bread>
    80003476:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003478:	3ff4f793          	andi	a5,s1,1023
    8000347c:	40fc873b          	subw	a4,s9,a5
    80003480:	413a86bb          	subw	a3,s5,s3
    80003484:	8d3a                	mv	s10,a4
    80003486:	fae6f5e3          	bgeu	a3,a4,80003430 <readi+0x4c>
    8000348a:	8d36                	mv	s10,a3
    8000348c:	b755                	j	80003430 <readi+0x4c>
      brelse(bp);
    8000348e:	854a                	mv	a0,s2
    80003490:	ef2ff0ef          	jal	80002b82 <brelse>
      tot = -1;
    80003494:	59fd                	li	s3,-1
      break;
    80003496:	6946                	ld	s2,80(sp)
    80003498:	7c02                	ld	s8,32(sp)
    8000349a:	6ce2                	ld	s9,24(sp)
    8000349c:	6d42                	ld	s10,16(sp)
    8000349e:	6da2                	ld	s11,8(sp)
    800034a0:	a831                	j	800034bc <readi+0xd8>
    800034a2:	6946                	ld	s2,80(sp)
    800034a4:	7c02                	ld	s8,32(sp)
    800034a6:	6ce2                	ld	s9,24(sp)
    800034a8:	6d42                	ld	s10,16(sp)
    800034aa:	6da2                	ld	s11,8(sp)
    800034ac:	a801                	j	800034bc <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ae:	89d6                	mv	s3,s5
    800034b0:	a031                	j	800034bc <readi+0xd8>
    800034b2:	6946                	ld	s2,80(sp)
    800034b4:	7c02                	ld	s8,32(sp)
    800034b6:	6ce2                	ld	s9,24(sp)
    800034b8:	6d42                	ld	s10,16(sp)
    800034ba:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800034bc:	854e                	mv	a0,s3
    800034be:	69a6                	ld	s3,72(sp)
}
    800034c0:	70a6                	ld	ra,104(sp)
    800034c2:	7406                	ld	s0,96(sp)
    800034c4:	64e6                	ld	s1,88(sp)
    800034c6:	6a06                	ld	s4,64(sp)
    800034c8:	7ae2                	ld	s5,56(sp)
    800034ca:	7b42                	ld	s6,48(sp)
    800034cc:	7ba2                	ld	s7,40(sp)
    800034ce:	6165                	addi	sp,sp,112
    800034d0:	8082                	ret
    return 0;
    800034d2:	4501                	li	a0,0
}
    800034d4:	8082                	ret

00000000800034d6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800034d6:	457c                	lw	a5,76(a0)
    800034d8:	0ed7eb63          	bltu	a5,a3,800035ce <writei+0xf8>
{
    800034dc:	7159                	addi	sp,sp,-112
    800034de:	f486                	sd	ra,104(sp)
    800034e0:	f0a2                	sd	s0,96(sp)
    800034e2:	e8ca                	sd	s2,80(sp)
    800034e4:	e0d2                	sd	s4,64(sp)
    800034e6:	fc56                	sd	s5,56(sp)
    800034e8:	f85a                	sd	s6,48(sp)
    800034ea:	f45e                	sd	s7,40(sp)
    800034ec:	1880                	addi	s0,sp,112
    800034ee:	8aaa                	mv	s5,a0
    800034f0:	8bae                	mv	s7,a1
    800034f2:	8a32                	mv	s4,a2
    800034f4:	8936                	mv	s2,a3
    800034f6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800034f8:	00e687bb          	addw	a5,a3,a4
    800034fc:	0cd7eb63          	bltu	a5,a3,800035d2 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003500:	00043737          	lui	a4,0x43
    80003504:	0cf76963          	bltu	a4,a5,800035d6 <writei+0x100>
    80003508:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000350a:	0a0b0a63          	beqz	s6,800035be <writei+0xe8>
    8000350e:	eca6                	sd	s1,88(sp)
    80003510:	f062                	sd	s8,32(sp)
    80003512:	ec66                	sd	s9,24(sp)
    80003514:	e86a                	sd	s10,16(sp)
    80003516:	e46e                	sd	s11,8(sp)
    80003518:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000351a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000351e:	5c7d                	li	s8,-1
    80003520:	a825                	j	80003558 <writei+0x82>
    80003522:	020d1d93          	slli	s11,s10,0x20
    80003526:	020ddd93          	srli	s11,s11,0x20
    8000352a:	05848513          	addi	a0,s1,88
    8000352e:	86ee                	mv	a3,s11
    80003530:	8652                	mv	a2,s4
    80003532:	85de                	mv	a1,s7
    80003534:	953e                	add	a0,a0,a5
    80003536:	d15fe0ef          	jal	8000224a <either_copyin>
    8000353a:	05850663          	beq	a0,s8,80003586 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000353e:	8526                	mv	a0,s1
    80003540:	688000ef          	jal	80003bc8 <log_write>
    brelse(bp);
    80003544:	8526                	mv	a0,s1
    80003546:	e3cff0ef          	jal	80002b82 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000354a:	013d09bb          	addw	s3,s10,s3
    8000354e:	012d093b          	addw	s2,s10,s2
    80003552:	9a6e                	add	s4,s4,s11
    80003554:	0369fc63          	bgeu	s3,s6,8000358c <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003558:	00a9559b          	srliw	a1,s2,0xa
    8000355c:	8556                	mv	a0,s5
    8000355e:	88fff0ef          	jal	80002dec <bmap>
    80003562:	85aa                	mv	a1,a0
    if(addr == 0)
    80003564:	c505                	beqz	a0,8000358c <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003566:	000aa503          	lw	a0,0(s5)
    8000356a:	d10ff0ef          	jal	80002a7a <bread>
    8000356e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003570:	3ff97793          	andi	a5,s2,1023
    80003574:	40fc873b          	subw	a4,s9,a5
    80003578:	413b06bb          	subw	a3,s6,s3
    8000357c:	8d3a                	mv	s10,a4
    8000357e:	fae6f2e3          	bgeu	a3,a4,80003522 <writei+0x4c>
    80003582:	8d36                	mv	s10,a3
    80003584:	bf79                	j	80003522 <writei+0x4c>
      brelse(bp);
    80003586:	8526                	mv	a0,s1
    80003588:	dfaff0ef          	jal	80002b82 <brelse>
  }

  if(off > ip->size)
    8000358c:	04caa783          	lw	a5,76(s5)
    80003590:	0327f963          	bgeu	a5,s2,800035c2 <writei+0xec>
    ip->size = off;
    80003594:	052aa623          	sw	s2,76(s5)
    80003598:	64e6                	ld	s1,88(sp)
    8000359a:	7c02                	ld	s8,32(sp)
    8000359c:	6ce2                	ld	s9,24(sp)
    8000359e:	6d42                	ld	s10,16(sp)
    800035a0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800035a2:	8556                	mv	a0,s5
    800035a4:	b35ff0ef          	jal	800030d8 <iupdate>

  return tot;
    800035a8:	854e                	mv	a0,s3
    800035aa:	69a6                	ld	s3,72(sp)
}
    800035ac:	70a6                	ld	ra,104(sp)
    800035ae:	7406                	ld	s0,96(sp)
    800035b0:	6946                	ld	s2,80(sp)
    800035b2:	6a06                	ld	s4,64(sp)
    800035b4:	7ae2                	ld	s5,56(sp)
    800035b6:	7b42                	ld	s6,48(sp)
    800035b8:	7ba2                	ld	s7,40(sp)
    800035ba:	6165                	addi	sp,sp,112
    800035bc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035be:	89da                	mv	s3,s6
    800035c0:	b7cd                	j	800035a2 <writei+0xcc>
    800035c2:	64e6                	ld	s1,88(sp)
    800035c4:	7c02                	ld	s8,32(sp)
    800035c6:	6ce2                	ld	s9,24(sp)
    800035c8:	6d42                	ld	s10,16(sp)
    800035ca:	6da2                	ld	s11,8(sp)
    800035cc:	bfd9                	j	800035a2 <writei+0xcc>
    return -1;
    800035ce:	557d                	li	a0,-1
}
    800035d0:	8082                	ret
    return -1;
    800035d2:	557d                	li	a0,-1
    800035d4:	bfe1                	j	800035ac <writei+0xd6>
    return -1;
    800035d6:	557d                	li	a0,-1
    800035d8:	bfd1                	j	800035ac <writei+0xd6>

00000000800035da <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800035da:	1141                	addi	sp,sp,-16
    800035dc:	e406                	sd	ra,8(sp)
    800035de:	e022                	sd	s0,0(sp)
    800035e0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800035e2:	4639                	li	a2,14
    800035e4:	fc2fd0ef          	jal	80000da6 <strncmp>
}
    800035e8:	60a2                	ld	ra,8(sp)
    800035ea:	6402                	ld	s0,0(sp)
    800035ec:	0141                	addi	sp,sp,16
    800035ee:	8082                	ret

00000000800035f0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800035f0:	711d                	addi	sp,sp,-96
    800035f2:	ec86                	sd	ra,88(sp)
    800035f4:	e8a2                	sd	s0,80(sp)
    800035f6:	e4a6                	sd	s1,72(sp)
    800035f8:	e0ca                	sd	s2,64(sp)
    800035fa:	fc4e                	sd	s3,56(sp)
    800035fc:	f852                	sd	s4,48(sp)
    800035fe:	f456                	sd	s5,40(sp)
    80003600:	f05a                	sd	s6,32(sp)
    80003602:	ec5e                	sd	s7,24(sp)
    80003604:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003606:	04451703          	lh	a4,68(a0)
    8000360a:	4785                	li	a5,1
    8000360c:	00f71f63          	bne	a4,a5,8000362a <dirlookup+0x3a>
    80003610:	892a                	mv	s2,a0
    80003612:	8aae                	mv	s5,a1
    80003614:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003616:	457c                	lw	a5,76(a0)
    80003618:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000361a:	fa040a13          	addi	s4,s0,-96
    8000361e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003620:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003624:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003626:	e39d                	bnez	a5,8000364c <dirlookup+0x5c>
    80003628:	a8b9                	j	80003686 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000362a:	00004517          	auipc	a0,0x4
    8000362e:	ef650513          	addi	a0,a0,-266 # 80007520 <etext+0x520>
    80003632:	96cfd0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    80003636:	00004517          	auipc	a0,0x4
    8000363a:	f0250513          	addi	a0,a0,-254 # 80007538 <etext+0x538>
    8000363e:	960fd0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003642:	24c1                	addiw	s1,s1,16
    80003644:	04c92783          	lw	a5,76(s2)
    80003648:	02f4fe63          	bgeu	s1,a5,80003684 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000364c:	874e                	mv	a4,s3
    8000364e:	86a6                	mv	a3,s1
    80003650:	8652                	mv	a2,s4
    80003652:	4581                	li	a1,0
    80003654:	854a                	mv	a0,s2
    80003656:	d8fff0ef          	jal	800033e4 <readi>
    8000365a:	fd351ee3          	bne	a0,s3,80003636 <dirlookup+0x46>
    if(de.inum == 0)
    8000365e:	fa045783          	lhu	a5,-96(s0)
    80003662:	d3e5                	beqz	a5,80003642 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003664:	85da                	mv	a1,s6
    80003666:	8556                	mv	a0,s5
    80003668:	f73ff0ef          	jal	800035da <namecmp>
    8000366c:	f979                	bnez	a0,80003642 <dirlookup+0x52>
      if(poff)
    8000366e:	000b8463          	beqz	s7,80003676 <dirlookup+0x86>
        *poff = off;
    80003672:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003676:	fa045583          	lhu	a1,-96(s0)
    8000367a:	00092503          	lw	a0,0(s2)
    8000367e:	82fff0ef          	jal	80002eac <iget>
    80003682:	a011                	j	80003686 <dirlookup+0x96>
  return 0;
    80003684:	4501                	li	a0,0
}
    80003686:	60e6                	ld	ra,88(sp)
    80003688:	6446                	ld	s0,80(sp)
    8000368a:	64a6                	ld	s1,72(sp)
    8000368c:	6906                	ld	s2,64(sp)
    8000368e:	79e2                	ld	s3,56(sp)
    80003690:	7a42                	ld	s4,48(sp)
    80003692:	7aa2                	ld	s5,40(sp)
    80003694:	7b02                	ld	s6,32(sp)
    80003696:	6be2                	ld	s7,24(sp)
    80003698:	6125                	addi	sp,sp,96
    8000369a:	8082                	ret

000000008000369c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000369c:	711d                	addi	sp,sp,-96
    8000369e:	ec86                	sd	ra,88(sp)
    800036a0:	e8a2                	sd	s0,80(sp)
    800036a2:	e4a6                	sd	s1,72(sp)
    800036a4:	e0ca                	sd	s2,64(sp)
    800036a6:	fc4e                	sd	s3,56(sp)
    800036a8:	f852                	sd	s4,48(sp)
    800036aa:	f456                	sd	s5,40(sp)
    800036ac:	f05a                	sd	s6,32(sp)
    800036ae:	ec5e                	sd	s7,24(sp)
    800036b0:	e862                	sd	s8,16(sp)
    800036b2:	e466                	sd	s9,8(sp)
    800036b4:	e06a                	sd	s10,0(sp)
    800036b6:	1080                	addi	s0,sp,96
    800036b8:	84aa                	mv	s1,a0
    800036ba:	8b2e                	mv	s6,a1
    800036bc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800036be:	00054703          	lbu	a4,0(a0)
    800036c2:	02f00793          	li	a5,47
    800036c6:	00f70f63          	beq	a4,a5,800036e4 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800036ca:	a12fe0ef          	jal	800018dc <myproc>
    800036ce:	15053503          	ld	a0,336(a0)
    800036d2:	a85ff0ef          	jal	80003156 <idup>
    800036d6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800036d8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800036dc:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800036de:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800036e0:	4b85                	li	s7,1
    800036e2:	a879                	j	80003780 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800036e4:	4585                	li	a1,1
    800036e6:	852e                	mv	a0,a1
    800036e8:	fc4ff0ef          	jal	80002eac <iget>
    800036ec:	8a2a                	mv	s4,a0
    800036ee:	b7ed                	j	800036d8 <namex+0x3c>
      iunlockput(ip);
    800036f0:	8552                	mv	a0,s4
    800036f2:	ca5ff0ef          	jal	80003396 <iunlockput>
      return 0;
    800036f6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800036f8:	8552                	mv	a0,s4
    800036fa:	60e6                	ld	ra,88(sp)
    800036fc:	6446                	ld	s0,80(sp)
    800036fe:	64a6                	ld	s1,72(sp)
    80003700:	6906                	ld	s2,64(sp)
    80003702:	79e2                	ld	s3,56(sp)
    80003704:	7a42                	ld	s4,48(sp)
    80003706:	7aa2                	ld	s5,40(sp)
    80003708:	7b02                	ld	s6,32(sp)
    8000370a:	6be2                	ld	s7,24(sp)
    8000370c:	6c42                	ld	s8,16(sp)
    8000370e:	6ca2                	ld	s9,8(sp)
    80003710:	6d02                	ld	s10,0(sp)
    80003712:	6125                	addi	sp,sp,96
    80003714:	8082                	ret
      iunlock(ip);
    80003716:	8552                	mv	a0,s4
    80003718:	b23ff0ef          	jal	8000323a <iunlock>
      return ip;
    8000371c:	bff1                	j	800036f8 <namex+0x5c>
      iunlockput(ip);
    8000371e:	8552                	mv	a0,s4
    80003720:	c77ff0ef          	jal	80003396 <iunlockput>
      return 0;
    80003724:	8a4e                	mv	s4,s3
    80003726:	bfc9                	j	800036f8 <namex+0x5c>
  len = path - s;
    80003728:	40998633          	sub	a2,s3,s1
    8000372c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003730:	09ac5063          	bge	s8,s10,800037b0 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003734:	8666                	mv	a2,s9
    80003736:	85a6                	mv	a1,s1
    80003738:	8556                	mv	a0,s5
    8000373a:	df8fd0ef          	jal	80000d32 <memmove>
    8000373e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003740:	0004c783          	lbu	a5,0(s1)
    80003744:	01279763          	bne	a5,s2,80003752 <namex+0xb6>
    path++;
    80003748:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000374a:	0004c783          	lbu	a5,0(s1)
    8000374e:	ff278de3          	beq	a5,s2,80003748 <namex+0xac>
    ilock(ip);
    80003752:	8552                	mv	a0,s4
    80003754:	a39ff0ef          	jal	8000318c <ilock>
    if(ip->type != T_DIR){
    80003758:	044a1783          	lh	a5,68(s4)
    8000375c:	f9779ae3          	bne	a5,s7,800036f0 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003760:	000b0563          	beqz	s6,8000376a <namex+0xce>
    80003764:	0004c783          	lbu	a5,0(s1)
    80003768:	d7dd                	beqz	a5,80003716 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000376a:	4601                	li	a2,0
    8000376c:	85d6                	mv	a1,s5
    8000376e:	8552                	mv	a0,s4
    80003770:	e81ff0ef          	jal	800035f0 <dirlookup>
    80003774:	89aa                	mv	s3,a0
    80003776:	d545                	beqz	a0,8000371e <namex+0x82>
    iunlockput(ip);
    80003778:	8552                	mv	a0,s4
    8000377a:	c1dff0ef          	jal	80003396 <iunlockput>
    ip = next;
    8000377e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003780:	0004c783          	lbu	a5,0(s1)
    80003784:	01279763          	bne	a5,s2,80003792 <namex+0xf6>
    path++;
    80003788:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000378a:	0004c783          	lbu	a5,0(s1)
    8000378e:	ff278de3          	beq	a5,s2,80003788 <namex+0xec>
  if(*path == 0)
    80003792:	cb8d                	beqz	a5,800037c4 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003794:	0004c783          	lbu	a5,0(s1)
    80003798:	89a6                	mv	s3,s1
  len = path - s;
    8000379a:	4d01                	li	s10,0
    8000379c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000379e:	01278963          	beq	a5,s2,800037b0 <namex+0x114>
    800037a2:	d3d9                	beqz	a5,80003728 <namex+0x8c>
    path++;
    800037a4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800037a6:	0009c783          	lbu	a5,0(s3)
    800037aa:	ff279ce3          	bne	a5,s2,800037a2 <namex+0x106>
    800037ae:	bfad                	j	80003728 <namex+0x8c>
    memmove(name, s, len);
    800037b0:	2601                	sext.w	a2,a2
    800037b2:	85a6                	mv	a1,s1
    800037b4:	8556                	mv	a0,s5
    800037b6:	d7cfd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    800037ba:	9d56                	add	s10,s10,s5
    800037bc:	000d0023          	sb	zero,0(s10)
    800037c0:	84ce                	mv	s1,s3
    800037c2:	bfbd                	j	80003740 <namex+0xa4>
  if(nameiparent){
    800037c4:	f20b0ae3          	beqz	s6,800036f8 <namex+0x5c>
    iput(ip);
    800037c8:	8552                	mv	a0,s4
    800037ca:	b45ff0ef          	jal	8000330e <iput>
    return 0;
    800037ce:	4a01                	li	s4,0
    800037d0:	b725                	j	800036f8 <namex+0x5c>

00000000800037d2 <dirlink>:
{
    800037d2:	715d                	addi	sp,sp,-80
    800037d4:	e486                	sd	ra,72(sp)
    800037d6:	e0a2                	sd	s0,64(sp)
    800037d8:	f84a                	sd	s2,48(sp)
    800037da:	ec56                	sd	s5,24(sp)
    800037dc:	e85a                	sd	s6,16(sp)
    800037de:	0880                	addi	s0,sp,80
    800037e0:	892a                	mv	s2,a0
    800037e2:	8aae                	mv	s5,a1
    800037e4:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800037e6:	4601                	li	a2,0
    800037e8:	e09ff0ef          	jal	800035f0 <dirlookup>
    800037ec:	ed1d                	bnez	a0,8000382a <dirlink+0x58>
    800037ee:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037f0:	04c92483          	lw	s1,76(s2)
    800037f4:	c4b9                	beqz	s1,80003842 <dirlink+0x70>
    800037f6:	f44e                	sd	s3,40(sp)
    800037f8:	f052                	sd	s4,32(sp)
    800037fa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037fc:	fb040a13          	addi	s4,s0,-80
    80003800:	49c1                	li	s3,16
    80003802:	874e                	mv	a4,s3
    80003804:	86a6                	mv	a3,s1
    80003806:	8652                	mv	a2,s4
    80003808:	4581                	li	a1,0
    8000380a:	854a                	mv	a0,s2
    8000380c:	bd9ff0ef          	jal	800033e4 <readi>
    80003810:	03351163          	bne	a0,s3,80003832 <dirlink+0x60>
    if(de.inum == 0)
    80003814:	fb045783          	lhu	a5,-80(s0)
    80003818:	c39d                	beqz	a5,8000383e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000381a:	24c1                	addiw	s1,s1,16
    8000381c:	04c92783          	lw	a5,76(s2)
    80003820:	fef4e1e3          	bltu	s1,a5,80003802 <dirlink+0x30>
    80003824:	79a2                	ld	s3,40(sp)
    80003826:	7a02                	ld	s4,32(sp)
    80003828:	a829                	j	80003842 <dirlink+0x70>
    iput(ip);
    8000382a:	ae5ff0ef          	jal	8000330e <iput>
    return -1;
    8000382e:	557d                	li	a0,-1
    80003830:	a83d                	j	8000386e <dirlink+0x9c>
      panic("dirlink read");
    80003832:	00004517          	auipc	a0,0x4
    80003836:	d1650513          	addi	a0,a0,-746 # 80007548 <etext+0x548>
    8000383a:	f65fc0ef          	jal	8000079e <panic>
    8000383e:	79a2                	ld	s3,40(sp)
    80003840:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003842:	4639                	li	a2,14
    80003844:	85d6                	mv	a1,s5
    80003846:	fb240513          	addi	a0,s0,-78
    8000384a:	d96fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    8000384e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003852:	4741                	li	a4,16
    80003854:	86a6                	mv	a3,s1
    80003856:	fb040613          	addi	a2,s0,-80
    8000385a:	4581                	li	a1,0
    8000385c:	854a                	mv	a0,s2
    8000385e:	c79ff0ef          	jal	800034d6 <writei>
    80003862:	1541                	addi	a0,a0,-16
    80003864:	00a03533          	snez	a0,a0
    80003868:	40a0053b          	negw	a0,a0
    8000386c:	74e2                	ld	s1,56(sp)
}
    8000386e:	60a6                	ld	ra,72(sp)
    80003870:	6406                	ld	s0,64(sp)
    80003872:	7942                	ld	s2,48(sp)
    80003874:	6ae2                	ld	s5,24(sp)
    80003876:	6b42                	ld	s6,16(sp)
    80003878:	6161                	addi	sp,sp,80
    8000387a:	8082                	ret

000000008000387c <namei>:

struct inode*
namei(char *path)
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003884:	fe040613          	addi	a2,s0,-32
    80003888:	4581                	li	a1,0
    8000388a:	e13ff0ef          	jal	8000369c <namex>
}
    8000388e:	60e2                	ld	ra,24(sp)
    80003890:	6442                	ld	s0,16(sp)
    80003892:	6105                	addi	sp,sp,32
    80003894:	8082                	ret

0000000080003896 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003896:	1141                	addi	sp,sp,-16
    80003898:	e406                	sd	ra,8(sp)
    8000389a:	e022                	sd	s0,0(sp)
    8000389c:	0800                	addi	s0,sp,16
    8000389e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800038a0:	4585                	li	a1,1
    800038a2:	dfbff0ef          	jal	8000369c <namex>
}
    800038a6:	60a2                	ld	ra,8(sp)
    800038a8:	6402                	ld	s0,0(sp)
    800038aa:	0141                	addi	sp,sp,16
    800038ac:	8082                	ret

00000000800038ae <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800038ae:	1101                	addi	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	e04a                	sd	s2,0(sp)
    800038b8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800038ba:	0001c917          	auipc	s2,0x1c
    800038be:	14690913          	addi	s2,s2,326 # 8001fa00 <log>
    800038c2:	01892583          	lw	a1,24(s2)
    800038c6:	02892503          	lw	a0,40(s2)
    800038ca:	9b0ff0ef          	jal	80002a7a <bread>
    800038ce:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800038d0:	02c92603          	lw	a2,44(s2)
    800038d4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800038d6:	00c05f63          	blez	a2,800038f4 <write_head+0x46>
    800038da:	0001c717          	auipc	a4,0x1c
    800038de:	15670713          	addi	a4,a4,342 # 8001fa30 <log+0x30>
    800038e2:	87aa                	mv	a5,a0
    800038e4:	060a                	slli	a2,a2,0x2
    800038e6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800038e8:	4314                	lw	a3,0(a4)
    800038ea:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800038ec:	0711                	addi	a4,a4,4
    800038ee:	0791                	addi	a5,a5,4
    800038f0:	fec79ce3          	bne	a5,a2,800038e8 <write_head+0x3a>
  }
  bwrite(buf);
    800038f4:	8526                	mv	a0,s1
    800038f6:	a5aff0ef          	jal	80002b50 <bwrite>
  brelse(buf);
    800038fa:	8526                	mv	a0,s1
    800038fc:	a86ff0ef          	jal	80002b82 <brelse>
}
    80003900:	60e2                	ld	ra,24(sp)
    80003902:	6442                	ld	s0,16(sp)
    80003904:	64a2                	ld	s1,8(sp)
    80003906:	6902                	ld	s2,0(sp)
    80003908:	6105                	addi	sp,sp,32
    8000390a:	8082                	ret

000000008000390c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000390c:	0001c797          	auipc	a5,0x1c
    80003910:	1207a783          	lw	a5,288(a5) # 8001fa2c <log+0x2c>
    80003914:	0af05263          	blez	a5,800039b8 <install_trans+0xac>
{
    80003918:	715d                	addi	sp,sp,-80
    8000391a:	e486                	sd	ra,72(sp)
    8000391c:	e0a2                	sd	s0,64(sp)
    8000391e:	fc26                	sd	s1,56(sp)
    80003920:	f84a                	sd	s2,48(sp)
    80003922:	f44e                	sd	s3,40(sp)
    80003924:	f052                	sd	s4,32(sp)
    80003926:	ec56                	sd	s5,24(sp)
    80003928:	e85a                	sd	s6,16(sp)
    8000392a:	e45e                	sd	s7,8(sp)
    8000392c:	0880                	addi	s0,sp,80
    8000392e:	8b2a                	mv	s6,a0
    80003930:	0001ca97          	auipc	s5,0x1c
    80003934:	100a8a93          	addi	s5,s5,256 # 8001fa30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003938:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000393a:	0001c997          	auipc	s3,0x1c
    8000393e:	0c698993          	addi	s3,s3,198 # 8001fa00 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003942:	40000b93          	li	s7,1024
    80003946:	a829                	j	80003960 <install_trans+0x54>
    brelse(lbuf);
    80003948:	854a                	mv	a0,s2
    8000394a:	a38ff0ef          	jal	80002b82 <brelse>
    brelse(dbuf);
    8000394e:	8526                	mv	a0,s1
    80003950:	a32ff0ef          	jal	80002b82 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003954:	2a05                	addiw	s4,s4,1
    80003956:	0a91                	addi	s5,s5,4
    80003958:	02c9a783          	lw	a5,44(s3)
    8000395c:	04fa5363          	bge	s4,a5,800039a2 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003960:	0189a583          	lw	a1,24(s3)
    80003964:	014585bb          	addw	a1,a1,s4
    80003968:	2585                	addiw	a1,a1,1
    8000396a:	0289a503          	lw	a0,40(s3)
    8000396e:	90cff0ef          	jal	80002a7a <bread>
    80003972:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003974:	000aa583          	lw	a1,0(s5)
    80003978:	0289a503          	lw	a0,40(s3)
    8000397c:	8feff0ef          	jal	80002a7a <bread>
    80003980:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003982:	865e                	mv	a2,s7
    80003984:	05890593          	addi	a1,s2,88
    80003988:	05850513          	addi	a0,a0,88
    8000398c:	ba6fd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003990:	8526                	mv	a0,s1
    80003992:	9beff0ef          	jal	80002b50 <bwrite>
    if(recovering == 0)
    80003996:	fa0b19e3          	bnez	s6,80003948 <install_trans+0x3c>
      bunpin(dbuf);
    8000399a:	8526                	mv	a0,s1
    8000399c:	a9eff0ef          	jal	80002c3a <bunpin>
    800039a0:	b765                	j	80003948 <install_trans+0x3c>
}
    800039a2:	60a6                	ld	ra,72(sp)
    800039a4:	6406                	ld	s0,64(sp)
    800039a6:	74e2                	ld	s1,56(sp)
    800039a8:	7942                	ld	s2,48(sp)
    800039aa:	79a2                	ld	s3,40(sp)
    800039ac:	7a02                	ld	s4,32(sp)
    800039ae:	6ae2                	ld	s5,24(sp)
    800039b0:	6b42                	ld	s6,16(sp)
    800039b2:	6ba2                	ld	s7,8(sp)
    800039b4:	6161                	addi	sp,sp,80
    800039b6:	8082                	ret
    800039b8:	8082                	ret

00000000800039ba <initlog>:
{
    800039ba:	7179                	addi	sp,sp,-48
    800039bc:	f406                	sd	ra,40(sp)
    800039be:	f022                	sd	s0,32(sp)
    800039c0:	ec26                	sd	s1,24(sp)
    800039c2:	e84a                	sd	s2,16(sp)
    800039c4:	e44e                	sd	s3,8(sp)
    800039c6:	1800                	addi	s0,sp,48
    800039c8:	892a                	mv	s2,a0
    800039ca:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800039cc:	0001c497          	auipc	s1,0x1c
    800039d0:	03448493          	addi	s1,s1,52 # 8001fa00 <log>
    800039d4:	00004597          	auipc	a1,0x4
    800039d8:	b8458593          	addi	a1,a1,-1148 # 80007558 <etext+0x558>
    800039dc:	8526                	mv	a0,s1
    800039de:	99cfd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    800039e2:	0149a583          	lw	a1,20(s3)
    800039e6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800039e8:	0109a783          	lw	a5,16(s3)
    800039ec:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800039ee:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800039f2:	854a                	mv	a0,s2
    800039f4:	886ff0ef          	jal	80002a7a <bread>
  log.lh.n = lh->n;
    800039f8:	4d30                	lw	a2,88(a0)
    800039fa:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800039fc:	00c05f63          	blez	a2,80003a1a <initlog+0x60>
    80003a00:	87aa                	mv	a5,a0
    80003a02:	0001c717          	auipc	a4,0x1c
    80003a06:	02e70713          	addi	a4,a4,46 # 8001fa30 <log+0x30>
    80003a0a:	060a                	slli	a2,a2,0x2
    80003a0c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003a0e:	4ff4                	lw	a3,92(a5)
    80003a10:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a12:	0791                	addi	a5,a5,4
    80003a14:	0711                	addi	a4,a4,4
    80003a16:	fec79ce3          	bne	a5,a2,80003a0e <initlog+0x54>
  brelse(buf);
    80003a1a:	968ff0ef          	jal	80002b82 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a1e:	4505                	li	a0,1
    80003a20:	eedff0ef          	jal	8000390c <install_trans>
  log.lh.n = 0;
    80003a24:	0001c797          	auipc	a5,0x1c
    80003a28:	0007a423          	sw	zero,8(a5) # 8001fa2c <log+0x2c>
  write_head(); // clear the log
    80003a2c:	e83ff0ef          	jal	800038ae <write_head>
}
    80003a30:	70a2                	ld	ra,40(sp)
    80003a32:	7402                	ld	s0,32(sp)
    80003a34:	64e2                	ld	s1,24(sp)
    80003a36:	6942                	ld	s2,16(sp)
    80003a38:	69a2                	ld	s3,8(sp)
    80003a3a:	6145                	addi	sp,sp,48
    80003a3c:	8082                	ret

0000000080003a3e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003a3e:	1101                	addi	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	e04a                	sd	s2,0(sp)
    80003a48:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003a4a:	0001c517          	auipc	a0,0x1c
    80003a4e:	fb650513          	addi	a0,a0,-74 # 8001fa00 <log>
    80003a52:	9acfd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003a56:	0001c497          	auipc	s1,0x1c
    80003a5a:	faa48493          	addi	s1,s1,-86 # 8001fa00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003a5e:	4979                	li	s2,30
    80003a60:	a029                	j	80003a6a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003a62:	85a6                	mv	a1,s1
    80003a64:	8526                	mv	a0,s1
    80003a66:	c44fe0ef          	jal	80001eaa <sleep>
    if(log.committing){
    80003a6a:	50dc                	lw	a5,36(s1)
    80003a6c:	fbfd                	bnez	a5,80003a62 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003a6e:	5098                	lw	a4,32(s1)
    80003a70:	2705                	addiw	a4,a4,1
    80003a72:	0027179b          	slliw	a5,a4,0x2
    80003a76:	9fb9                	addw	a5,a5,a4
    80003a78:	0017979b          	slliw	a5,a5,0x1
    80003a7c:	54d4                	lw	a3,44(s1)
    80003a7e:	9fb5                	addw	a5,a5,a3
    80003a80:	00f95763          	bge	s2,a5,80003a8e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003a84:	85a6                	mv	a1,s1
    80003a86:	8526                	mv	a0,s1
    80003a88:	c22fe0ef          	jal	80001eaa <sleep>
    80003a8c:	bff9                	j	80003a6a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003a8e:	0001c517          	auipc	a0,0x1c
    80003a92:	f7250513          	addi	a0,a0,-142 # 8001fa00 <log>
    80003a96:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003a98:	9fafd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003a9c:	60e2                	ld	ra,24(sp)
    80003a9e:	6442                	ld	s0,16(sp)
    80003aa0:	64a2                	ld	s1,8(sp)
    80003aa2:	6902                	ld	s2,0(sp)
    80003aa4:	6105                	addi	sp,sp,32
    80003aa6:	8082                	ret

0000000080003aa8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003aa8:	7139                	addi	sp,sp,-64
    80003aaa:	fc06                	sd	ra,56(sp)
    80003aac:	f822                	sd	s0,48(sp)
    80003aae:	f426                	sd	s1,40(sp)
    80003ab0:	f04a                	sd	s2,32(sp)
    80003ab2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ab4:	0001c497          	auipc	s1,0x1c
    80003ab8:	f4c48493          	addi	s1,s1,-180 # 8001fa00 <log>
    80003abc:	8526                	mv	a0,s1
    80003abe:	940fd0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003ac2:	509c                	lw	a5,32(s1)
    80003ac4:	37fd                	addiw	a5,a5,-1
    80003ac6:	893e                	mv	s2,a5
    80003ac8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003aca:	50dc                	lw	a5,36(s1)
    80003acc:	ef9d                	bnez	a5,80003b0a <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ace:	04091863          	bnez	s2,80003b1e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003ad2:	0001c497          	auipc	s1,0x1c
    80003ad6:	f2e48493          	addi	s1,s1,-210 # 8001fa00 <log>
    80003ada:	4785                	li	a5,1
    80003adc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ade:	8526                	mv	a0,s1
    80003ae0:	9b2fd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ae4:	54dc                	lw	a5,44(s1)
    80003ae6:	04f04c63          	bgtz	a5,80003b3e <end_op+0x96>
    acquire(&log.lock);
    80003aea:	0001c497          	auipc	s1,0x1c
    80003aee:	f1648493          	addi	s1,s1,-234 # 8001fa00 <log>
    80003af2:	8526                	mv	a0,s1
    80003af4:	90afd0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003af8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003afc:	8526                	mv	a0,s1
    80003afe:	bf8fe0ef          	jal	80001ef6 <wakeup>
    release(&log.lock);
    80003b02:	8526                	mv	a0,s1
    80003b04:	98efd0ef          	jal	80000c92 <release>
}
    80003b08:	a02d                	j	80003b32 <end_op+0x8a>
    80003b0a:	ec4e                	sd	s3,24(sp)
    80003b0c:	e852                	sd	s4,16(sp)
    80003b0e:	e456                	sd	s5,8(sp)
    80003b10:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003b12:	00004517          	auipc	a0,0x4
    80003b16:	a4e50513          	addi	a0,a0,-1458 # 80007560 <etext+0x560>
    80003b1a:	c85fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003b1e:	0001c497          	auipc	s1,0x1c
    80003b22:	ee248493          	addi	s1,s1,-286 # 8001fa00 <log>
    80003b26:	8526                	mv	a0,s1
    80003b28:	bcefe0ef          	jal	80001ef6 <wakeup>
  release(&log.lock);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	964fd0ef          	jal	80000c92 <release>
}
    80003b32:	70e2                	ld	ra,56(sp)
    80003b34:	7442                	ld	s0,48(sp)
    80003b36:	74a2                	ld	s1,40(sp)
    80003b38:	7902                	ld	s2,32(sp)
    80003b3a:	6121                	addi	sp,sp,64
    80003b3c:	8082                	ret
    80003b3e:	ec4e                	sd	s3,24(sp)
    80003b40:	e852                	sd	s4,16(sp)
    80003b42:	e456                	sd	s5,8(sp)
    80003b44:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b46:	0001ca97          	auipc	s5,0x1c
    80003b4a:	eeaa8a93          	addi	s5,s5,-278 # 8001fa30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003b4e:	0001ca17          	auipc	s4,0x1c
    80003b52:	eb2a0a13          	addi	s4,s4,-334 # 8001fa00 <log>
    memmove(to->data, from->data, BSIZE);
    80003b56:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003b5a:	018a2583          	lw	a1,24(s4)
    80003b5e:	012585bb          	addw	a1,a1,s2
    80003b62:	2585                	addiw	a1,a1,1
    80003b64:	028a2503          	lw	a0,40(s4)
    80003b68:	f13fe0ef          	jal	80002a7a <bread>
    80003b6c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003b6e:	000aa583          	lw	a1,0(s5)
    80003b72:	028a2503          	lw	a0,40(s4)
    80003b76:	f05fe0ef          	jal	80002a7a <bread>
    80003b7a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003b7c:	865a                	mv	a2,s6
    80003b7e:	05850593          	addi	a1,a0,88
    80003b82:	05848513          	addi	a0,s1,88
    80003b86:	9acfd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	fc5fe0ef          	jal	80002b50 <bwrite>
    brelse(from);
    80003b90:	854e                	mv	a0,s3
    80003b92:	ff1fe0ef          	jal	80002b82 <brelse>
    brelse(to);
    80003b96:	8526                	mv	a0,s1
    80003b98:	febfe0ef          	jal	80002b82 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b9c:	2905                	addiw	s2,s2,1
    80003b9e:	0a91                	addi	s5,s5,4
    80003ba0:	02ca2783          	lw	a5,44(s4)
    80003ba4:	faf94be3          	blt	s2,a5,80003b5a <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ba8:	d07ff0ef          	jal	800038ae <write_head>
    install_trans(0); // Now install writes to home locations
    80003bac:	4501                	li	a0,0
    80003bae:	d5fff0ef          	jal	8000390c <install_trans>
    log.lh.n = 0;
    80003bb2:	0001c797          	auipc	a5,0x1c
    80003bb6:	e607ad23          	sw	zero,-390(a5) # 8001fa2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003bba:	cf5ff0ef          	jal	800038ae <write_head>
    80003bbe:	69e2                	ld	s3,24(sp)
    80003bc0:	6a42                	ld	s4,16(sp)
    80003bc2:	6aa2                	ld	s5,8(sp)
    80003bc4:	6b02                	ld	s6,0(sp)
    80003bc6:	b715                	j	80003aea <end_op+0x42>

0000000080003bc8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003bc8:	1101                	addi	sp,sp,-32
    80003bca:	ec06                	sd	ra,24(sp)
    80003bcc:	e822                	sd	s0,16(sp)
    80003bce:	e426                	sd	s1,8(sp)
    80003bd0:	e04a                	sd	s2,0(sp)
    80003bd2:	1000                	addi	s0,sp,32
    80003bd4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003bd6:	0001c917          	auipc	s2,0x1c
    80003bda:	e2a90913          	addi	s2,s2,-470 # 8001fa00 <log>
    80003bde:	854a                	mv	a0,s2
    80003be0:	81efd0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003be4:	02c92603          	lw	a2,44(s2)
    80003be8:	47f5                	li	a5,29
    80003bea:	06c7c363          	blt	a5,a2,80003c50 <log_write+0x88>
    80003bee:	0001c797          	auipc	a5,0x1c
    80003bf2:	e2e7a783          	lw	a5,-466(a5) # 8001fa1c <log+0x1c>
    80003bf6:	37fd                	addiw	a5,a5,-1
    80003bf8:	04f65c63          	bge	a2,a5,80003c50 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003bfc:	0001c797          	auipc	a5,0x1c
    80003c00:	e247a783          	lw	a5,-476(a5) # 8001fa20 <log+0x20>
    80003c04:	04f05c63          	blez	a5,80003c5c <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c08:	4781                	li	a5,0
    80003c0a:	04c05f63          	blez	a2,80003c68 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c0e:	44cc                	lw	a1,12(s1)
    80003c10:	0001c717          	auipc	a4,0x1c
    80003c14:	e2070713          	addi	a4,a4,-480 # 8001fa30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003c18:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c1a:	4314                	lw	a3,0(a4)
    80003c1c:	04b68663          	beq	a3,a1,80003c68 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003c20:	2785                	addiw	a5,a5,1
    80003c22:	0711                	addi	a4,a4,4
    80003c24:	fef61be3          	bne	a2,a5,80003c1a <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c28:	0621                	addi	a2,a2,8
    80003c2a:	060a                	slli	a2,a2,0x2
    80003c2c:	0001c797          	auipc	a5,0x1c
    80003c30:	dd478793          	addi	a5,a5,-556 # 8001fa00 <log>
    80003c34:	97b2                	add	a5,a5,a2
    80003c36:	44d8                	lw	a4,12(s1)
    80003c38:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	fcbfe0ef          	jal	80002c06 <bpin>
    log.lh.n++;
    80003c40:	0001c717          	auipc	a4,0x1c
    80003c44:	dc070713          	addi	a4,a4,-576 # 8001fa00 <log>
    80003c48:	575c                	lw	a5,44(a4)
    80003c4a:	2785                	addiw	a5,a5,1
    80003c4c:	d75c                	sw	a5,44(a4)
    80003c4e:	a80d                	j	80003c80 <log_write+0xb8>
    panic("too big a transaction");
    80003c50:	00004517          	auipc	a0,0x4
    80003c54:	92050513          	addi	a0,a0,-1760 # 80007570 <etext+0x570>
    80003c58:	b47fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003c5c:	00004517          	auipc	a0,0x4
    80003c60:	92c50513          	addi	a0,a0,-1748 # 80007588 <etext+0x588>
    80003c64:	b3bfc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003c68:	00878693          	addi	a3,a5,8
    80003c6c:	068a                	slli	a3,a3,0x2
    80003c6e:	0001c717          	auipc	a4,0x1c
    80003c72:	d9270713          	addi	a4,a4,-622 # 8001fa00 <log>
    80003c76:	9736                	add	a4,a4,a3
    80003c78:	44d4                	lw	a3,12(s1)
    80003c7a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003c7c:	faf60fe3          	beq	a2,a5,80003c3a <log_write+0x72>
  }
  release(&log.lock);
    80003c80:	0001c517          	auipc	a0,0x1c
    80003c84:	d8050513          	addi	a0,a0,-640 # 8001fa00 <log>
    80003c88:	80afd0ef          	jal	80000c92 <release>
}
    80003c8c:	60e2                	ld	ra,24(sp)
    80003c8e:	6442                	ld	s0,16(sp)
    80003c90:	64a2                	ld	s1,8(sp)
    80003c92:	6902                	ld	s2,0(sp)
    80003c94:	6105                	addi	sp,sp,32
    80003c96:	8082                	ret

0000000080003c98 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003c98:	1101                	addi	sp,sp,-32
    80003c9a:	ec06                	sd	ra,24(sp)
    80003c9c:	e822                	sd	s0,16(sp)
    80003c9e:	e426                	sd	s1,8(sp)
    80003ca0:	e04a                	sd	s2,0(sp)
    80003ca2:	1000                	addi	s0,sp,32
    80003ca4:	84aa                	mv	s1,a0
    80003ca6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ca8:	00004597          	auipc	a1,0x4
    80003cac:	90058593          	addi	a1,a1,-1792 # 800075a8 <etext+0x5a8>
    80003cb0:	0521                	addi	a0,a0,8
    80003cb2:	ec9fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003cb6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003cba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003cbe:	0204a423          	sw	zero,40(s1)
}
    80003cc2:	60e2                	ld	ra,24(sp)
    80003cc4:	6442                	ld	s0,16(sp)
    80003cc6:	64a2                	ld	s1,8(sp)
    80003cc8:	6902                	ld	s2,0(sp)
    80003cca:	6105                	addi	sp,sp,32
    80003ccc:	8082                	ret

0000000080003cce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003cce:	1101                	addi	sp,sp,-32
    80003cd0:	ec06                	sd	ra,24(sp)
    80003cd2:	e822                	sd	s0,16(sp)
    80003cd4:	e426                	sd	s1,8(sp)
    80003cd6:	e04a                	sd	s2,0(sp)
    80003cd8:	1000                	addi	s0,sp,32
    80003cda:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003cdc:	00850913          	addi	s2,a0,8
    80003ce0:	854a                	mv	a0,s2
    80003ce2:	f1dfc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003ce6:	409c                	lw	a5,0(s1)
    80003ce8:	c799                	beqz	a5,80003cf6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003cea:	85ca                	mv	a1,s2
    80003cec:	8526                	mv	a0,s1
    80003cee:	9bcfe0ef          	jal	80001eaa <sleep>
  while (lk->locked) {
    80003cf2:	409c                	lw	a5,0(s1)
    80003cf4:	fbfd                	bnez	a5,80003cea <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003cf6:	4785                	li	a5,1
    80003cf8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003cfa:	be3fd0ef          	jal	800018dc <myproc>
    80003cfe:	591c                	lw	a5,48(a0)
    80003d00:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d02:	854a                	mv	a0,s2
    80003d04:	f8ffc0ef          	jal	80000c92 <release>
}
    80003d08:	60e2                	ld	ra,24(sp)
    80003d0a:	6442                	ld	s0,16(sp)
    80003d0c:	64a2                	ld	s1,8(sp)
    80003d0e:	6902                	ld	s2,0(sp)
    80003d10:	6105                	addi	sp,sp,32
    80003d12:	8082                	ret

0000000080003d14 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d14:	1101                	addi	sp,sp,-32
    80003d16:	ec06                	sd	ra,24(sp)
    80003d18:	e822                	sd	s0,16(sp)
    80003d1a:	e426                	sd	s1,8(sp)
    80003d1c:	e04a                	sd	s2,0(sp)
    80003d1e:	1000                	addi	s0,sp,32
    80003d20:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d22:	00850913          	addi	s2,a0,8
    80003d26:	854a                	mv	a0,s2
    80003d28:	ed7fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003d2c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d30:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003d34:	8526                	mv	a0,s1
    80003d36:	9c0fe0ef          	jal	80001ef6 <wakeup>
  release(&lk->lk);
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	f57fc0ef          	jal	80000c92 <release>
}
    80003d40:	60e2                	ld	ra,24(sp)
    80003d42:	6442                	ld	s0,16(sp)
    80003d44:	64a2                	ld	s1,8(sp)
    80003d46:	6902                	ld	s2,0(sp)
    80003d48:	6105                	addi	sp,sp,32
    80003d4a:	8082                	ret

0000000080003d4c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003d4c:	7179                	addi	sp,sp,-48
    80003d4e:	f406                	sd	ra,40(sp)
    80003d50:	f022                	sd	s0,32(sp)
    80003d52:	ec26                	sd	s1,24(sp)
    80003d54:	e84a                	sd	s2,16(sp)
    80003d56:	1800                	addi	s0,sp,48
    80003d58:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003d5a:	00850913          	addi	s2,a0,8
    80003d5e:	854a                	mv	a0,s2
    80003d60:	e9ffc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003d64:	409c                	lw	a5,0(s1)
    80003d66:	ef81                	bnez	a5,80003d7e <holdingsleep+0x32>
    80003d68:	4481                	li	s1,0
  release(&lk->lk);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	f27fc0ef          	jal	80000c92 <release>
  return r;
}
    80003d70:	8526                	mv	a0,s1
    80003d72:	70a2                	ld	ra,40(sp)
    80003d74:	7402                	ld	s0,32(sp)
    80003d76:	64e2                	ld	s1,24(sp)
    80003d78:	6942                	ld	s2,16(sp)
    80003d7a:	6145                	addi	sp,sp,48
    80003d7c:	8082                	ret
    80003d7e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003d80:	0284a983          	lw	s3,40(s1)
    80003d84:	b59fd0ef          	jal	800018dc <myproc>
    80003d88:	5904                	lw	s1,48(a0)
    80003d8a:	413484b3          	sub	s1,s1,s3
    80003d8e:	0014b493          	seqz	s1,s1
    80003d92:	69a2                	ld	s3,8(sp)
    80003d94:	bfd9                	j	80003d6a <holdingsleep+0x1e>

0000000080003d96 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003d96:	1141                	addi	sp,sp,-16
    80003d98:	e406                	sd	ra,8(sp)
    80003d9a:	e022                	sd	s0,0(sp)
    80003d9c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003d9e:	00004597          	auipc	a1,0x4
    80003da2:	81a58593          	addi	a1,a1,-2022 # 800075b8 <etext+0x5b8>
    80003da6:	0001c517          	auipc	a0,0x1c
    80003daa:	da250513          	addi	a0,a0,-606 # 8001fb48 <ftable>
    80003dae:	dcdfc0ef          	jal	80000b7a <initlock>
}
    80003db2:	60a2                	ld	ra,8(sp)
    80003db4:	6402                	ld	s0,0(sp)
    80003db6:	0141                	addi	sp,sp,16
    80003db8:	8082                	ret

0000000080003dba <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	e426                	sd	s1,8(sp)
    80003dc2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003dc4:	0001c517          	auipc	a0,0x1c
    80003dc8:	d8450513          	addi	a0,a0,-636 # 8001fb48 <ftable>
    80003dcc:	e33fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003dd0:	0001c497          	auipc	s1,0x1c
    80003dd4:	d9048493          	addi	s1,s1,-624 # 8001fb60 <ftable+0x18>
    80003dd8:	0001d717          	auipc	a4,0x1d
    80003ddc:	d2870713          	addi	a4,a4,-728 # 80020b00 <disk>
    if(f->ref == 0){
    80003de0:	40dc                	lw	a5,4(s1)
    80003de2:	cf89                	beqz	a5,80003dfc <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003de4:	02848493          	addi	s1,s1,40
    80003de8:	fee49ce3          	bne	s1,a4,80003de0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003dec:	0001c517          	auipc	a0,0x1c
    80003df0:	d5c50513          	addi	a0,a0,-676 # 8001fb48 <ftable>
    80003df4:	e9ffc0ef          	jal	80000c92 <release>
  return 0;
    80003df8:	4481                	li	s1,0
    80003dfa:	a809                	j	80003e0c <filealloc+0x52>
      f->ref = 1;
    80003dfc:	4785                	li	a5,1
    80003dfe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e00:	0001c517          	auipc	a0,0x1c
    80003e04:	d4850513          	addi	a0,a0,-696 # 8001fb48 <ftable>
    80003e08:	e8bfc0ef          	jal	80000c92 <release>
}
    80003e0c:	8526                	mv	a0,s1
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	64a2                	ld	s1,8(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret

0000000080003e18 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	e426                	sd	s1,8(sp)
    80003e20:	1000                	addi	s0,sp,32
    80003e22:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003e24:	0001c517          	auipc	a0,0x1c
    80003e28:	d2450513          	addi	a0,a0,-732 # 8001fb48 <ftable>
    80003e2c:	dd3fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003e30:	40dc                	lw	a5,4(s1)
    80003e32:	02f05063          	blez	a5,80003e52 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003e36:	2785                	addiw	a5,a5,1
    80003e38:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003e3a:	0001c517          	auipc	a0,0x1c
    80003e3e:	d0e50513          	addi	a0,a0,-754 # 8001fb48 <ftable>
    80003e42:	e51fc0ef          	jal	80000c92 <release>
  return f;
}
    80003e46:	8526                	mv	a0,s1
    80003e48:	60e2                	ld	ra,24(sp)
    80003e4a:	6442                	ld	s0,16(sp)
    80003e4c:	64a2                	ld	s1,8(sp)
    80003e4e:	6105                	addi	sp,sp,32
    80003e50:	8082                	ret
    panic("filedup");
    80003e52:	00003517          	auipc	a0,0x3
    80003e56:	76e50513          	addi	a0,a0,1902 # 800075c0 <etext+0x5c0>
    80003e5a:	945fc0ef          	jal	8000079e <panic>

0000000080003e5e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003e5e:	7139                	addi	sp,sp,-64
    80003e60:	fc06                	sd	ra,56(sp)
    80003e62:	f822                	sd	s0,48(sp)
    80003e64:	f426                	sd	s1,40(sp)
    80003e66:	0080                	addi	s0,sp,64
    80003e68:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003e6a:	0001c517          	auipc	a0,0x1c
    80003e6e:	cde50513          	addi	a0,a0,-802 # 8001fb48 <ftable>
    80003e72:	d8dfc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003e76:	40dc                	lw	a5,4(s1)
    80003e78:	04f05863          	blez	a5,80003ec8 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80003e7c:	37fd                	addiw	a5,a5,-1
    80003e7e:	c0dc                	sw	a5,4(s1)
    80003e80:	04f04e63          	bgtz	a5,80003edc <fileclose+0x7e>
    80003e84:	f04a                	sd	s2,32(sp)
    80003e86:	ec4e                	sd	s3,24(sp)
    80003e88:	e852                	sd	s4,16(sp)
    80003e8a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003e8c:	0004a903          	lw	s2,0(s1)
    80003e90:	0094ca83          	lbu	s5,9(s1)
    80003e94:	0104ba03          	ld	s4,16(s1)
    80003e98:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003e9c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003ea0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003ea4:	0001c517          	auipc	a0,0x1c
    80003ea8:	ca450513          	addi	a0,a0,-860 # 8001fb48 <ftable>
    80003eac:	de7fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80003eb0:	4785                	li	a5,1
    80003eb2:	04f90063          	beq	s2,a5,80003ef2 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003eb6:	3979                	addiw	s2,s2,-2
    80003eb8:	4785                	li	a5,1
    80003eba:	0527f563          	bgeu	a5,s2,80003f04 <fileclose+0xa6>
    80003ebe:	7902                	ld	s2,32(sp)
    80003ec0:	69e2                	ld	s3,24(sp)
    80003ec2:	6a42                	ld	s4,16(sp)
    80003ec4:	6aa2                	ld	s5,8(sp)
    80003ec6:	a00d                	j	80003ee8 <fileclose+0x8a>
    80003ec8:	f04a                	sd	s2,32(sp)
    80003eca:	ec4e                	sd	s3,24(sp)
    80003ecc:	e852                	sd	s4,16(sp)
    80003ece:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003ed0:	00003517          	auipc	a0,0x3
    80003ed4:	6f850513          	addi	a0,a0,1784 # 800075c8 <etext+0x5c8>
    80003ed8:	8c7fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80003edc:	0001c517          	auipc	a0,0x1c
    80003ee0:	c6c50513          	addi	a0,a0,-916 # 8001fb48 <ftable>
    80003ee4:	daffc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003ee8:	70e2                	ld	ra,56(sp)
    80003eea:	7442                	ld	s0,48(sp)
    80003eec:	74a2                	ld	s1,40(sp)
    80003eee:	6121                	addi	sp,sp,64
    80003ef0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003ef2:	85d6                	mv	a1,s5
    80003ef4:	8552                	mv	a0,s4
    80003ef6:	340000ef          	jal	80004236 <pipeclose>
    80003efa:	7902                	ld	s2,32(sp)
    80003efc:	69e2                	ld	s3,24(sp)
    80003efe:	6a42                	ld	s4,16(sp)
    80003f00:	6aa2                	ld	s5,8(sp)
    80003f02:	b7dd                	j	80003ee8 <fileclose+0x8a>
    begin_op();
    80003f04:	b3bff0ef          	jal	80003a3e <begin_op>
    iput(ff.ip);
    80003f08:	854e                	mv	a0,s3
    80003f0a:	c04ff0ef          	jal	8000330e <iput>
    end_op();
    80003f0e:	b9bff0ef          	jal	80003aa8 <end_op>
    80003f12:	7902                	ld	s2,32(sp)
    80003f14:	69e2                	ld	s3,24(sp)
    80003f16:	6a42                	ld	s4,16(sp)
    80003f18:	6aa2                	ld	s5,8(sp)
    80003f1a:	b7f9                	j	80003ee8 <fileclose+0x8a>

0000000080003f1c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f1c:	715d                	addi	sp,sp,-80
    80003f1e:	e486                	sd	ra,72(sp)
    80003f20:	e0a2                	sd	s0,64(sp)
    80003f22:	fc26                	sd	s1,56(sp)
    80003f24:	f44e                	sd	s3,40(sp)
    80003f26:	0880                	addi	s0,sp,80
    80003f28:	84aa                	mv	s1,a0
    80003f2a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f2c:	9b1fd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003f30:	409c                	lw	a5,0(s1)
    80003f32:	37f9                	addiw	a5,a5,-2
    80003f34:	4705                	li	a4,1
    80003f36:	04f76263          	bltu	a4,a5,80003f7a <filestat+0x5e>
    80003f3a:	f84a                	sd	s2,48(sp)
    80003f3c:	f052                	sd	s4,32(sp)
    80003f3e:	892a                	mv	s2,a0
    ilock(f->ip);
    80003f40:	6c88                	ld	a0,24(s1)
    80003f42:	a4aff0ef          	jal	8000318c <ilock>
    stati(f->ip, &st);
    80003f46:	fb840a13          	addi	s4,s0,-72
    80003f4a:	85d2                	mv	a1,s4
    80003f4c:	6c88                	ld	a0,24(s1)
    80003f4e:	c68ff0ef          	jal	800033b6 <stati>
    iunlock(f->ip);
    80003f52:	6c88                	ld	a0,24(s1)
    80003f54:	ae6ff0ef          	jal	8000323a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003f58:	46e1                	li	a3,24
    80003f5a:	8652                	mv	a2,s4
    80003f5c:	85ce                	mv	a1,s3
    80003f5e:	05093503          	ld	a0,80(s2)
    80003f62:	e22fd0ef          	jal	80001584 <copyout>
    80003f66:	41f5551b          	sraiw	a0,a0,0x1f
    80003f6a:	7942                	ld	s2,48(sp)
    80003f6c:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003f6e:	60a6                	ld	ra,72(sp)
    80003f70:	6406                	ld	s0,64(sp)
    80003f72:	74e2                	ld	s1,56(sp)
    80003f74:	79a2                	ld	s3,40(sp)
    80003f76:	6161                	addi	sp,sp,80
    80003f78:	8082                	ret
  return -1;
    80003f7a:	557d                	li	a0,-1
    80003f7c:	bfcd                	j	80003f6e <filestat+0x52>

0000000080003f7e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003f7e:	7179                	addi	sp,sp,-48
    80003f80:	f406                	sd	ra,40(sp)
    80003f82:	f022                	sd	s0,32(sp)
    80003f84:	e84a                	sd	s2,16(sp)
    80003f86:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003f88:	00854783          	lbu	a5,8(a0)
    80003f8c:	cfd1                	beqz	a5,80004028 <fileread+0xaa>
    80003f8e:	ec26                	sd	s1,24(sp)
    80003f90:	e44e                	sd	s3,8(sp)
    80003f92:	84aa                	mv	s1,a0
    80003f94:	89ae                	mv	s3,a1
    80003f96:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003f98:	411c                	lw	a5,0(a0)
    80003f9a:	4705                	li	a4,1
    80003f9c:	04e78363          	beq	a5,a4,80003fe2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003fa0:	470d                	li	a4,3
    80003fa2:	04e78763          	beq	a5,a4,80003ff0 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003fa6:	4709                	li	a4,2
    80003fa8:	06e79a63          	bne	a5,a4,8000401c <fileread+0x9e>
    ilock(f->ip);
    80003fac:	6d08                	ld	a0,24(a0)
    80003fae:	9deff0ef          	jal	8000318c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003fb2:	874a                	mv	a4,s2
    80003fb4:	5094                	lw	a3,32(s1)
    80003fb6:	864e                	mv	a2,s3
    80003fb8:	4585                	li	a1,1
    80003fba:	6c88                	ld	a0,24(s1)
    80003fbc:	c28ff0ef          	jal	800033e4 <readi>
    80003fc0:	892a                	mv	s2,a0
    80003fc2:	00a05563          	blez	a0,80003fcc <fileread+0x4e>
      f->off += r;
    80003fc6:	509c                	lw	a5,32(s1)
    80003fc8:	9fa9                	addw	a5,a5,a0
    80003fca:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003fcc:	6c88                	ld	a0,24(s1)
    80003fce:	a6cff0ef          	jal	8000323a <iunlock>
    80003fd2:	64e2                	ld	s1,24(sp)
    80003fd4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003fd6:	854a                	mv	a0,s2
    80003fd8:	70a2                	ld	ra,40(sp)
    80003fda:	7402                	ld	s0,32(sp)
    80003fdc:	6942                	ld	s2,16(sp)
    80003fde:	6145                	addi	sp,sp,48
    80003fe0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003fe2:	6908                	ld	a0,16(a0)
    80003fe4:	3a2000ef          	jal	80004386 <piperead>
    80003fe8:	892a                	mv	s2,a0
    80003fea:	64e2                	ld	s1,24(sp)
    80003fec:	69a2                	ld	s3,8(sp)
    80003fee:	b7e5                	j	80003fd6 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003ff0:	02451783          	lh	a5,36(a0)
    80003ff4:	03079693          	slli	a3,a5,0x30
    80003ff8:	92c1                	srli	a3,a3,0x30
    80003ffa:	4725                	li	a4,9
    80003ffc:	02d76863          	bltu	a4,a3,8000402c <fileread+0xae>
    80004000:	0792                	slli	a5,a5,0x4
    80004002:	0001c717          	auipc	a4,0x1c
    80004006:	aa670713          	addi	a4,a4,-1370 # 8001faa8 <devsw>
    8000400a:	97ba                	add	a5,a5,a4
    8000400c:	639c                	ld	a5,0(a5)
    8000400e:	c39d                	beqz	a5,80004034 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004010:	4505                	li	a0,1
    80004012:	9782                	jalr	a5
    80004014:	892a                	mv	s2,a0
    80004016:	64e2                	ld	s1,24(sp)
    80004018:	69a2                	ld	s3,8(sp)
    8000401a:	bf75                	j	80003fd6 <fileread+0x58>
    panic("fileread");
    8000401c:	00003517          	auipc	a0,0x3
    80004020:	5bc50513          	addi	a0,a0,1468 # 800075d8 <etext+0x5d8>
    80004024:	f7afc0ef          	jal	8000079e <panic>
    return -1;
    80004028:	597d                	li	s2,-1
    8000402a:	b775                	j	80003fd6 <fileread+0x58>
      return -1;
    8000402c:	597d                	li	s2,-1
    8000402e:	64e2                	ld	s1,24(sp)
    80004030:	69a2                	ld	s3,8(sp)
    80004032:	b755                	j	80003fd6 <fileread+0x58>
    80004034:	597d                	li	s2,-1
    80004036:	64e2                	ld	s1,24(sp)
    80004038:	69a2                	ld	s3,8(sp)
    8000403a:	bf71                	j	80003fd6 <fileread+0x58>

000000008000403c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000403c:	00954783          	lbu	a5,9(a0)
    80004040:	10078e63          	beqz	a5,8000415c <filewrite+0x120>
{
    80004044:	711d                	addi	sp,sp,-96
    80004046:	ec86                	sd	ra,88(sp)
    80004048:	e8a2                	sd	s0,80(sp)
    8000404a:	e0ca                	sd	s2,64(sp)
    8000404c:	f456                	sd	s5,40(sp)
    8000404e:	f05a                	sd	s6,32(sp)
    80004050:	1080                	addi	s0,sp,96
    80004052:	892a                	mv	s2,a0
    80004054:	8b2e                	mv	s6,a1
    80004056:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004058:	411c                	lw	a5,0(a0)
    8000405a:	4705                	li	a4,1
    8000405c:	02e78963          	beq	a5,a4,8000408e <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004060:	470d                	li	a4,3
    80004062:	02e78a63          	beq	a5,a4,80004096 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004066:	4709                	li	a4,2
    80004068:	0ce79e63          	bne	a5,a4,80004144 <filewrite+0x108>
    8000406c:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000406e:	0ac05963          	blez	a2,80004120 <filewrite+0xe4>
    80004072:	e4a6                	sd	s1,72(sp)
    80004074:	fc4e                	sd	s3,56(sp)
    80004076:	ec5e                	sd	s7,24(sp)
    80004078:	e862                	sd	s8,16(sp)
    8000407a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000407c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000407e:	6b85                	lui	s7,0x1
    80004080:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004084:	6c85                	lui	s9,0x1
    80004086:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000408a:	4c05                	li	s8,1
    8000408c:	a8ad                	j	80004106 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    8000408e:	6908                	ld	a0,16(a0)
    80004090:	1fe000ef          	jal	8000428e <pipewrite>
    80004094:	a04d                	j	80004136 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004096:	02451783          	lh	a5,36(a0)
    8000409a:	03079693          	slli	a3,a5,0x30
    8000409e:	92c1                	srli	a3,a3,0x30
    800040a0:	4725                	li	a4,9
    800040a2:	0ad76f63          	bltu	a4,a3,80004160 <filewrite+0x124>
    800040a6:	0792                	slli	a5,a5,0x4
    800040a8:	0001c717          	auipc	a4,0x1c
    800040ac:	a0070713          	addi	a4,a4,-1536 # 8001faa8 <devsw>
    800040b0:	97ba                	add	a5,a5,a4
    800040b2:	679c                	ld	a5,8(a5)
    800040b4:	cbc5                	beqz	a5,80004164 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800040b6:	4505                	li	a0,1
    800040b8:	9782                	jalr	a5
    800040ba:	a8b5                	j	80004136 <filewrite+0xfa>
      if(n1 > max)
    800040bc:	2981                	sext.w	s3,s3
      begin_op();
    800040be:	981ff0ef          	jal	80003a3e <begin_op>
      ilock(f->ip);
    800040c2:	01893503          	ld	a0,24(s2)
    800040c6:	8c6ff0ef          	jal	8000318c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800040ca:	874e                	mv	a4,s3
    800040cc:	02092683          	lw	a3,32(s2)
    800040d0:	016a0633          	add	a2,s4,s6
    800040d4:	85e2                	mv	a1,s8
    800040d6:	01893503          	ld	a0,24(s2)
    800040da:	bfcff0ef          	jal	800034d6 <writei>
    800040de:	84aa                	mv	s1,a0
    800040e0:	00a05763          	blez	a0,800040ee <filewrite+0xb2>
        f->off += r;
    800040e4:	02092783          	lw	a5,32(s2)
    800040e8:	9fa9                	addw	a5,a5,a0
    800040ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800040ee:	01893503          	ld	a0,24(s2)
    800040f2:	948ff0ef          	jal	8000323a <iunlock>
      end_op();
    800040f6:	9b3ff0ef          	jal	80003aa8 <end_op>

      if(r != n1){
    800040fa:	02999563          	bne	s3,s1,80004124 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    800040fe:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004102:	015a5963          	bge	s4,s5,80004114 <filewrite+0xd8>
      int n1 = n - i;
    80004106:	414a87bb          	subw	a5,s5,s4
    8000410a:	89be                	mv	s3,a5
      if(n1 > max)
    8000410c:	fafbd8e3          	bge	s7,a5,800040bc <filewrite+0x80>
    80004110:	89e6                	mv	s3,s9
    80004112:	b76d                	j	800040bc <filewrite+0x80>
    80004114:	64a6                	ld	s1,72(sp)
    80004116:	79e2                	ld	s3,56(sp)
    80004118:	6be2                	ld	s7,24(sp)
    8000411a:	6c42                	ld	s8,16(sp)
    8000411c:	6ca2                	ld	s9,8(sp)
    8000411e:	a801                	j	8000412e <filewrite+0xf2>
    int i = 0;
    80004120:	4a01                	li	s4,0
    80004122:	a031                	j	8000412e <filewrite+0xf2>
    80004124:	64a6                	ld	s1,72(sp)
    80004126:	79e2                	ld	s3,56(sp)
    80004128:	6be2                	ld	s7,24(sp)
    8000412a:	6c42                	ld	s8,16(sp)
    8000412c:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000412e:	034a9d63          	bne	s5,s4,80004168 <filewrite+0x12c>
    80004132:	8556                	mv	a0,s5
    80004134:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004136:	60e6                	ld	ra,88(sp)
    80004138:	6446                	ld	s0,80(sp)
    8000413a:	6906                	ld	s2,64(sp)
    8000413c:	7aa2                	ld	s5,40(sp)
    8000413e:	7b02                	ld	s6,32(sp)
    80004140:	6125                	addi	sp,sp,96
    80004142:	8082                	ret
    80004144:	e4a6                	sd	s1,72(sp)
    80004146:	fc4e                	sd	s3,56(sp)
    80004148:	f852                	sd	s4,48(sp)
    8000414a:	ec5e                	sd	s7,24(sp)
    8000414c:	e862                	sd	s8,16(sp)
    8000414e:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004150:	00003517          	auipc	a0,0x3
    80004154:	49850513          	addi	a0,a0,1176 # 800075e8 <etext+0x5e8>
    80004158:	e46fc0ef          	jal	8000079e <panic>
    return -1;
    8000415c:	557d                	li	a0,-1
}
    8000415e:	8082                	ret
      return -1;
    80004160:	557d                	li	a0,-1
    80004162:	bfd1                	j	80004136 <filewrite+0xfa>
    80004164:	557d                	li	a0,-1
    80004166:	bfc1                	j	80004136 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004168:	557d                	li	a0,-1
    8000416a:	7a42                	ld	s4,48(sp)
    8000416c:	b7e9                	j	80004136 <filewrite+0xfa>

000000008000416e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000416e:	7179                	addi	sp,sp,-48
    80004170:	f406                	sd	ra,40(sp)
    80004172:	f022                	sd	s0,32(sp)
    80004174:	ec26                	sd	s1,24(sp)
    80004176:	e052                	sd	s4,0(sp)
    80004178:	1800                	addi	s0,sp,48
    8000417a:	84aa                	mv	s1,a0
    8000417c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000417e:	0005b023          	sd	zero,0(a1)
    80004182:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004186:	c35ff0ef          	jal	80003dba <filealloc>
    8000418a:	e088                	sd	a0,0(s1)
    8000418c:	c549                	beqz	a0,80004216 <pipealloc+0xa8>
    8000418e:	c2dff0ef          	jal	80003dba <filealloc>
    80004192:	00aa3023          	sd	a0,0(s4)
    80004196:	cd25                	beqz	a0,8000420e <pipealloc+0xa0>
    80004198:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000419a:	991fc0ef          	jal	80000b2a <kalloc>
    8000419e:	892a                	mv	s2,a0
    800041a0:	c12d                	beqz	a0,80004202 <pipealloc+0x94>
    800041a2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800041a4:	4985                	li	s3,1
    800041a6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041aa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800041ae:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800041b2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800041b6:	00003597          	auipc	a1,0x3
    800041ba:	44258593          	addi	a1,a1,1090 # 800075f8 <etext+0x5f8>
    800041be:	9bdfc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    800041c2:	609c                	ld	a5,0(s1)
    800041c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800041c8:	609c                	ld	a5,0(s1)
    800041ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800041ce:	609c                	ld	a5,0(s1)
    800041d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800041d4:	609c                	ld	a5,0(s1)
    800041d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800041da:	000a3783          	ld	a5,0(s4)
    800041de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800041e2:	000a3783          	ld	a5,0(s4)
    800041e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800041ea:	000a3783          	ld	a5,0(s4)
    800041ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800041f2:	000a3783          	ld	a5,0(s4)
    800041f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800041fa:	4501                	li	a0,0
    800041fc:	6942                	ld	s2,16(sp)
    800041fe:	69a2                	ld	s3,8(sp)
    80004200:	a01d                	j	80004226 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004202:	6088                	ld	a0,0(s1)
    80004204:	c119                	beqz	a0,8000420a <pipealloc+0x9c>
    80004206:	6942                	ld	s2,16(sp)
    80004208:	a029                	j	80004212 <pipealloc+0xa4>
    8000420a:	6942                	ld	s2,16(sp)
    8000420c:	a029                	j	80004216 <pipealloc+0xa8>
    8000420e:	6088                	ld	a0,0(s1)
    80004210:	c10d                	beqz	a0,80004232 <pipealloc+0xc4>
    fileclose(*f0);
    80004212:	c4dff0ef          	jal	80003e5e <fileclose>
  if(*f1)
    80004216:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000421a:	557d                	li	a0,-1
  if(*f1)
    8000421c:	c789                	beqz	a5,80004226 <pipealloc+0xb8>
    fileclose(*f1);
    8000421e:	853e                	mv	a0,a5
    80004220:	c3fff0ef          	jal	80003e5e <fileclose>
  return -1;
    80004224:	557d                	li	a0,-1
}
    80004226:	70a2                	ld	ra,40(sp)
    80004228:	7402                	ld	s0,32(sp)
    8000422a:	64e2                	ld	s1,24(sp)
    8000422c:	6a02                	ld	s4,0(sp)
    8000422e:	6145                	addi	sp,sp,48
    80004230:	8082                	ret
  return -1;
    80004232:	557d                	li	a0,-1
    80004234:	bfcd                	j	80004226 <pipealloc+0xb8>

0000000080004236 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004236:	1101                	addi	sp,sp,-32
    80004238:	ec06                	sd	ra,24(sp)
    8000423a:	e822                	sd	s0,16(sp)
    8000423c:	e426                	sd	s1,8(sp)
    8000423e:	e04a                	sd	s2,0(sp)
    80004240:	1000                	addi	s0,sp,32
    80004242:	84aa                	mv	s1,a0
    80004244:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004246:	9b9fc0ef          	jal	80000bfe <acquire>
  if(writable){
    8000424a:	02090763          	beqz	s2,80004278 <pipeclose+0x42>
    pi->writeopen = 0;
    8000424e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004252:	21848513          	addi	a0,s1,536
    80004256:	ca1fd0ef          	jal	80001ef6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000425a:	2204b783          	ld	a5,544(s1)
    8000425e:	e785                	bnez	a5,80004286 <pipeclose+0x50>
    release(&pi->lock);
    80004260:	8526                	mv	a0,s1
    80004262:	a31fc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    80004266:	8526                	mv	a0,s1
    80004268:	fe0fc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    8000426c:	60e2                	ld	ra,24(sp)
    8000426e:	6442                	ld	s0,16(sp)
    80004270:	64a2                	ld	s1,8(sp)
    80004272:	6902                	ld	s2,0(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret
    pi->readopen = 0;
    80004278:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000427c:	21c48513          	addi	a0,s1,540
    80004280:	c77fd0ef          	jal	80001ef6 <wakeup>
    80004284:	bfd9                	j	8000425a <pipeclose+0x24>
    release(&pi->lock);
    80004286:	8526                	mv	a0,s1
    80004288:	a0bfc0ef          	jal	80000c92 <release>
}
    8000428c:	b7c5                	j	8000426c <pipeclose+0x36>

000000008000428e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000428e:	7159                	addi	sp,sp,-112
    80004290:	f486                	sd	ra,104(sp)
    80004292:	f0a2                	sd	s0,96(sp)
    80004294:	eca6                	sd	s1,88(sp)
    80004296:	e8ca                	sd	s2,80(sp)
    80004298:	e4ce                	sd	s3,72(sp)
    8000429a:	e0d2                	sd	s4,64(sp)
    8000429c:	fc56                	sd	s5,56(sp)
    8000429e:	1880                	addi	s0,sp,112
    800042a0:	84aa                	mv	s1,a0
    800042a2:	8aae                	mv	s5,a1
    800042a4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042a6:	e36fd0ef          	jal	800018dc <myproc>
    800042aa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800042ac:	8526                	mv	a0,s1
    800042ae:	951fc0ef          	jal	80000bfe <acquire>
  while(i < n){
    800042b2:	0d405263          	blez	s4,80004376 <pipewrite+0xe8>
    800042b6:	f85a                	sd	s6,48(sp)
    800042b8:	f45e                	sd	s7,40(sp)
    800042ba:	f062                	sd	s8,32(sp)
    800042bc:	ec66                	sd	s9,24(sp)
    800042be:	e86a                	sd	s10,16(sp)
  int i = 0;
    800042c0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800042c2:	f9f40c13          	addi	s8,s0,-97
    800042c6:	4b85                	li	s7,1
    800042c8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800042ca:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800042ce:	21c48c93          	addi	s9,s1,540
    800042d2:	a82d                	j	8000430c <pipewrite+0x7e>
      release(&pi->lock);
    800042d4:	8526                	mv	a0,s1
    800042d6:	9bdfc0ef          	jal	80000c92 <release>
      return -1;
    800042da:	597d                	li	s2,-1
    800042dc:	7b42                	ld	s6,48(sp)
    800042de:	7ba2                	ld	s7,40(sp)
    800042e0:	7c02                	ld	s8,32(sp)
    800042e2:	6ce2                	ld	s9,24(sp)
    800042e4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800042e6:	854a                	mv	a0,s2
    800042e8:	70a6                	ld	ra,104(sp)
    800042ea:	7406                	ld	s0,96(sp)
    800042ec:	64e6                	ld	s1,88(sp)
    800042ee:	6946                	ld	s2,80(sp)
    800042f0:	69a6                	ld	s3,72(sp)
    800042f2:	6a06                	ld	s4,64(sp)
    800042f4:	7ae2                	ld	s5,56(sp)
    800042f6:	6165                	addi	sp,sp,112
    800042f8:	8082                	ret
      wakeup(&pi->nread);
    800042fa:	856a                	mv	a0,s10
    800042fc:	bfbfd0ef          	jal	80001ef6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004300:	85a6                	mv	a1,s1
    80004302:	8566                	mv	a0,s9
    80004304:	ba7fd0ef          	jal	80001eaa <sleep>
  while(i < n){
    80004308:	05495a63          	bge	s2,s4,8000435c <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000430c:	2204a783          	lw	a5,544(s1)
    80004310:	d3f1                	beqz	a5,800042d4 <pipewrite+0x46>
    80004312:	854e                	mv	a0,s3
    80004314:	dcffd0ef          	jal	800020e2 <killed>
    80004318:	fd55                	bnez	a0,800042d4 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000431a:	2184a783          	lw	a5,536(s1)
    8000431e:	21c4a703          	lw	a4,540(s1)
    80004322:	2007879b          	addiw	a5,a5,512
    80004326:	fcf70ae3          	beq	a4,a5,800042fa <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000432a:	86de                	mv	a3,s7
    8000432c:	01590633          	add	a2,s2,s5
    80004330:	85e2                	mv	a1,s8
    80004332:	0509b503          	ld	a0,80(s3)
    80004336:	afefd0ef          	jal	80001634 <copyin>
    8000433a:	05650063          	beq	a0,s6,8000437a <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000433e:	21c4a783          	lw	a5,540(s1)
    80004342:	0017871b          	addiw	a4,a5,1
    80004346:	20e4ae23          	sw	a4,540(s1)
    8000434a:	1ff7f793          	andi	a5,a5,511
    8000434e:	97a6                	add	a5,a5,s1
    80004350:	f9f44703          	lbu	a4,-97(s0)
    80004354:	00e78c23          	sb	a4,24(a5)
      i++;
    80004358:	2905                	addiw	s2,s2,1
    8000435a:	b77d                	j	80004308 <pipewrite+0x7a>
    8000435c:	7b42                	ld	s6,48(sp)
    8000435e:	7ba2                	ld	s7,40(sp)
    80004360:	7c02                	ld	s8,32(sp)
    80004362:	6ce2                	ld	s9,24(sp)
    80004364:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004366:	21848513          	addi	a0,s1,536
    8000436a:	b8dfd0ef          	jal	80001ef6 <wakeup>
  release(&pi->lock);
    8000436e:	8526                	mv	a0,s1
    80004370:	923fc0ef          	jal	80000c92 <release>
  return i;
    80004374:	bf8d                	j	800042e6 <pipewrite+0x58>
  int i = 0;
    80004376:	4901                	li	s2,0
    80004378:	b7fd                	j	80004366 <pipewrite+0xd8>
    8000437a:	7b42                	ld	s6,48(sp)
    8000437c:	7ba2                	ld	s7,40(sp)
    8000437e:	7c02                	ld	s8,32(sp)
    80004380:	6ce2                	ld	s9,24(sp)
    80004382:	6d42                	ld	s10,16(sp)
    80004384:	b7cd                	j	80004366 <pipewrite+0xd8>

0000000080004386 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004386:	711d                	addi	sp,sp,-96
    80004388:	ec86                	sd	ra,88(sp)
    8000438a:	e8a2                	sd	s0,80(sp)
    8000438c:	e4a6                	sd	s1,72(sp)
    8000438e:	e0ca                	sd	s2,64(sp)
    80004390:	fc4e                	sd	s3,56(sp)
    80004392:	f852                	sd	s4,48(sp)
    80004394:	f456                	sd	s5,40(sp)
    80004396:	1080                	addi	s0,sp,96
    80004398:	84aa                	mv	s1,a0
    8000439a:	892e                	mv	s2,a1
    8000439c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000439e:	d3efd0ef          	jal	800018dc <myproc>
    800043a2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800043a4:	8526                	mv	a0,s1
    800043a6:	859fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043aa:	2184a703          	lw	a4,536(s1)
    800043ae:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043b2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043b6:	02f71763          	bne	a4,a5,800043e4 <piperead+0x5e>
    800043ba:	2244a783          	lw	a5,548(s1)
    800043be:	cf85                	beqz	a5,800043f6 <piperead+0x70>
    if(killed(pr)){
    800043c0:	8552                	mv	a0,s4
    800043c2:	d21fd0ef          	jal	800020e2 <killed>
    800043c6:	e11d                	bnez	a0,800043ec <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043c8:	85a6                	mv	a1,s1
    800043ca:	854e                	mv	a0,s3
    800043cc:	adffd0ef          	jal	80001eaa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043d0:	2184a703          	lw	a4,536(s1)
    800043d4:	21c4a783          	lw	a5,540(s1)
    800043d8:	fef701e3          	beq	a4,a5,800043ba <piperead+0x34>
    800043dc:	f05a                	sd	s6,32(sp)
    800043de:	ec5e                	sd	s7,24(sp)
    800043e0:	e862                	sd	s8,16(sp)
    800043e2:	a829                	j	800043fc <piperead+0x76>
    800043e4:	f05a                	sd	s6,32(sp)
    800043e6:	ec5e                	sd	s7,24(sp)
    800043e8:	e862                	sd	s8,16(sp)
    800043ea:	a809                	j	800043fc <piperead+0x76>
      release(&pi->lock);
    800043ec:	8526                	mv	a0,s1
    800043ee:	8a5fc0ef          	jal	80000c92 <release>
      return -1;
    800043f2:	59fd                	li	s3,-1
    800043f4:	a0a5                	j	8000445c <piperead+0xd6>
    800043f6:	f05a                	sd	s6,32(sp)
    800043f8:	ec5e                	sd	s7,24(sp)
    800043fa:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043fc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800043fe:	faf40c13          	addi	s8,s0,-81
    80004402:	4b85                	li	s7,1
    80004404:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004406:	05505163          	blez	s5,80004448 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000440a:	2184a783          	lw	a5,536(s1)
    8000440e:	21c4a703          	lw	a4,540(s1)
    80004412:	02f70b63          	beq	a4,a5,80004448 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004416:	0017871b          	addiw	a4,a5,1
    8000441a:	20e4ac23          	sw	a4,536(s1)
    8000441e:	1ff7f793          	andi	a5,a5,511
    80004422:	97a6                	add	a5,a5,s1
    80004424:	0187c783          	lbu	a5,24(a5)
    80004428:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000442c:	86de                	mv	a3,s7
    8000442e:	8662                	mv	a2,s8
    80004430:	85ca                	mv	a1,s2
    80004432:	050a3503          	ld	a0,80(s4)
    80004436:	94efd0ef          	jal	80001584 <copyout>
    8000443a:	01650763          	beq	a0,s6,80004448 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000443e:	2985                	addiw	s3,s3,1
    80004440:	0905                	addi	s2,s2,1
    80004442:	fd3a94e3          	bne	s5,s3,8000440a <piperead+0x84>
    80004446:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004448:	21c48513          	addi	a0,s1,540
    8000444c:	aabfd0ef          	jal	80001ef6 <wakeup>
  release(&pi->lock);
    80004450:	8526                	mv	a0,s1
    80004452:	841fc0ef          	jal	80000c92 <release>
    80004456:	7b02                	ld	s6,32(sp)
    80004458:	6be2                	ld	s7,24(sp)
    8000445a:	6c42                	ld	s8,16(sp)
  return i;
}
    8000445c:	854e                	mv	a0,s3
    8000445e:	60e6                	ld	ra,88(sp)
    80004460:	6446                	ld	s0,80(sp)
    80004462:	64a6                	ld	s1,72(sp)
    80004464:	6906                	ld	s2,64(sp)
    80004466:	79e2                	ld	s3,56(sp)
    80004468:	7a42                	ld	s4,48(sp)
    8000446a:	7aa2                	ld	s5,40(sp)
    8000446c:	6125                	addi	sp,sp,96
    8000446e:	8082                	ret

0000000080004470 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004470:	1141                	addi	sp,sp,-16
    80004472:	e406                	sd	ra,8(sp)
    80004474:	e022                	sd	s0,0(sp)
    80004476:	0800                	addi	s0,sp,16
    80004478:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000447a:	0035151b          	slliw	a0,a0,0x3
    8000447e:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004480:	8b89                	andi	a5,a5,2
    80004482:	c399                	beqz	a5,80004488 <flags2perm+0x18>
      perm |= PTE_W;
    80004484:	00456513          	ori	a0,a0,4
    return perm;
}
    80004488:	60a2                	ld	ra,8(sp)
    8000448a:	6402                	ld	s0,0(sp)
    8000448c:	0141                	addi	sp,sp,16
    8000448e:	8082                	ret

0000000080004490 <exec>:

int
exec(char *path, char **argv)
{
    80004490:	de010113          	addi	sp,sp,-544
    80004494:	20113c23          	sd	ra,536(sp)
    80004498:	20813823          	sd	s0,528(sp)
    8000449c:	20913423          	sd	s1,520(sp)
    800044a0:	21213023          	sd	s2,512(sp)
    800044a4:	1400                	addi	s0,sp,544
    800044a6:	892a                	mv	s2,a0
    800044a8:	dea43823          	sd	a0,-528(s0)
    800044ac:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800044b0:	c2cfd0ef          	jal	800018dc <myproc>
    800044b4:	84aa                	mv	s1,a0

  begin_op();
    800044b6:	d88ff0ef          	jal	80003a3e <begin_op>

  if((ip = namei(path)) == 0){
    800044ba:	854a                	mv	a0,s2
    800044bc:	bc0ff0ef          	jal	8000387c <namei>
    800044c0:	cd21                	beqz	a0,80004518 <exec+0x88>
    800044c2:	fbd2                	sd	s4,496(sp)
    800044c4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044c6:	cc7fe0ef          	jal	8000318c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044ca:	04000713          	li	a4,64
    800044ce:	4681                	li	a3,0
    800044d0:	e5040613          	addi	a2,s0,-432
    800044d4:	4581                	li	a1,0
    800044d6:	8552                	mv	a0,s4
    800044d8:	f0dfe0ef          	jal	800033e4 <readi>
    800044dc:	04000793          	li	a5,64
    800044e0:	00f51a63          	bne	a0,a5,800044f4 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800044e4:	e5042703          	lw	a4,-432(s0)
    800044e8:	464c47b7          	lui	a5,0x464c4
    800044ec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800044f0:	02f70863          	beq	a4,a5,80004520 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800044f4:	8552                	mv	a0,s4
    800044f6:	ea1fe0ef          	jal	80003396 <iunlockput>
    end_op();
    800044fa:	daeff0ef          	jal	80003aa8 <end_op>
  }
  return -1;
    800044fe:	557d                	li	a0,-1
    80004500:	7a5e                	ld	s4,496(sp)
}
    80004502:	21813083          	ld	ra,536(sp)
    80004506:	21013403          	ld	s0,528(sp)
    8000450a:	20813483          	ld	s1,520(sp)
    8000450e:	20013903          	ld	s2,512(sp)
    80004512:	22010113          	addi	sp,sp,544
    80004516:	8082                	ret
    end_op();
    80004518:	d90ff0ef          	jal	80003aa8 <end_op>
    return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	b7d5                	j	80004502 <exec+0x72>
    80004520:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004522:	8526                	mv	a0,s1
    80004524:	c60fd0ef          	jal	80001984 <proc_pagetable>
    80004528:	8b2a                	mv	s6,a0
    8000452a:	26050d63          	beqz	a0,800047a4 <exec+0x314>
    8000452e:	ffce                	sd	s3,504(sp)
    80004530:	f7d6                	sd	s5,488(sp)
    80004532:	efde                	sd	s7,472(sp)
    80004534:	ebe2                	sd	s8,464(sp)
    80004536:	e7e6                	sd	s9,456(sp)
    80004538:	e3ea                	sd	s10,448(sp)
    8000453a:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000453c:	e7042683          	lw	a3,-400(s0)
    80004540:	e8845783          	lhu	a5,-376(s0)
    80004544:	0e078763          	beqz	a5,80004632 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004548:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000454a:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000454c:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004550:	6c85                	lui	s9,0x1
    80004552:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004556:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000455a:	6a85                	lui	s5,0x1
    8000455c:	a085                	j	800045bc <exec+0x12c>
      panic("loadseg: address should exist");
    8000455e:	00003517          	auipc	a0,0x3
    80004562:	0a250513          	addi	a0,a0,162 # 80007600 <etext+0x600>
    80004566:	a38fc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    8000456a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000456c:	874a                	mv	a4,s2
    8000456e:	009c06bb          	addw	a3,s8,s1
    80004572:	4581                	li	a1,0
    80004574:	8552                	mv	a0,s4
    80004576:	e6ffe0ef          	jal	800033e4 <readi>
    8000457a:	22a91963          	bne	s2,a0,800047ac <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    8000457e:	009a84bb          	addw	s1,s5,s1
    80004582:	0334f263          	bgeu	s1,s3,800045a6 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004586:	02049593          	slli	a1,s1,0x20
    8000458a:	9181                	srli	a1,a1,0x20
    8000458c:	95de                	add	a1,a1,s7
    8000458e:	855a                	mv	a0,s6
    80004590:	a6dfc0ef          	jal	80000ffc <walkaddr>
    80004594:	862a                	mv	a2,a0
    if(pa == 0)
    80004596:	d561                	beqz	a0,8000455e <exec+0xce>
    if(sz - i < PGSIZE)
    80004598:	409987bb          	subw	a5,s3,s1
    8000459c:	893e                	mv	s2,a5
    8000459e:	fcfcf6e3          	bgeu	s9,a5,8000456a <exec+0xda>
    800045a2:	8956                	mv	s2,s5
    800045a4:	b7d9                	j	8000456a <exec+0xda>
    sz = sz1;
    800045a6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045aa:	2d05                	addiw	s10,s10,1
    800045ac:	e0843783          	ld	a5,-504(s0)
    800045b0:	0387869b          	addiw	a3,a5,56
    800045b4:	e8845783          	lhu	a5,-376(s0)
    800045b8:	06fd5e63          	bge	s10,a5,80004634 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045bc:	e0d43423          	sd	a3,-504(s0)
    800045c0:	876e                	mv	a4,s11
    800045c2:	e1840613          	addi	a2,s0,-488
    800045c6:	4581                	li	a1,0
    800045c8:	8552                	mv	a0,s4
    800045ca:	e1bfe0ef          	jal	800033e4 <readi>
    800045ce:	1db51d63          	bne	a0,s11,800047a8 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    800045d2:	e1842783          	lw	a5,-488(s0)
    800045d6:	4705                	li	a4,1
    800045d8:	fce799e3          	bne	a5,a4,800045aa <exec+0x11a>
    if(ph.memsz < ph.filesz)
    800045dc:	e4043483          	ld	s1,-448(s0)
    800045e0:	e3843783          	ld	a5,-456(s0)
    800045e4:	1ef4e263          	bltu	s1,a5,800047c8 <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800045e8:	e2843783          	ld	a5,-472(s0)
    800045ec:	94be                	add	s1,s1,a5
    800045ee:	1ef4e063          	bltu	s1,a5,800047ce <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    800045f2:	de843703          	ld	a4,-536(s0)
    800045f6:	8ff9                	and	a5,a5,a4
    800045f8:	1c079e63          	bnez	a5,800047d4 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045fc:	e1c42503          	lw	a0,-484(s0)
    80004600:	e71ff0ef          	jal	80004470 <flags2perm>
    80004604:	86aa                	mv	a3,a0
    80004606:	8626                	mv	a2,s1
    80004608:	85ca                	mv	a1,s2
    8000460a:	855a                	mv	a0,s6
    8000460c:	d59fc0ef          	jal	80001364 <uvmalloc>
    80004610:	dea43c23          	sd	a0,-520(s0)
    80004614:	1c050363          	beqz	a0,800047da <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004618:	e2843b83          	ld	s7,-472(s0)
    8000461c:	e2042c03          	lw	s8,-480(s0)
    80004620:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004624:	00098463          	beqz	s3,8000462c <exec+0x19c>
    80004628:	4481                	li	s1,0
    8000462a:	bfb1                	j	80004586 <exec+0xf6>
    sz = sz1;
    8000462c:	df843903          	ld	s2,-520(s0)
    80004630:	bfad                	j	800045aa <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004632:	4901                	li	s2,0
  iunlockput(ip);
    80004634:	8552                	mv	a0,s4
    80004636:	d61fe0ef          	jal	80003396 <iunlockput>
  end_op();
    8000463a:	c6eff0ef          	jal	80003aa8 <end_op>
  p = myproc();
    8000463e:	a9efd0ef          	jal	800018dc <myproc>
    80004642:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004644:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004648:	6985                	lui	s3,0x1
    8000464a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000464c:	99ca                	add	s3,s3,s2
    8000464e:	77fd                	lui	a5,0xfffff
    80004650:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004654:	4691                	li	a3,4
    80004656:	6609                	lui	a2,0x2
    80004658:	964e                	add	a2,a2,s3
    8000465a:	85ce                	mv	a1,s3
    8000465c:	855a                	mv	a0,s6
    8000465e:	d07fc0ef          	jal	80001364 <uvmalloc>
    80004662:	8a2a                	mv	s4,a0
    80004664:	e105                	bnez	a0,80004684 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004666:	85ce                	mv	a1,s3
    80004668:	855a                	mv	a0,s6
    8000466a:	b9efd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    8000466e:	557d                	li	a0,-1
    80004670:	79fe                	ld	s3,504(sp)
    80004672:	7a5e                	ld	s4,496(sp)
    80004674:	7abe                	ld	s5,488(sp)
    80004676:	7b1e                	ld	s6,480(sp)
    80004678:	6bfe                	ld	s7,472(sp)
    8000467a:	6c5e                	ld	s8,464(sp)
    8000467c:	6cbe                	ld	s9,456(sp)
    8000467e:	6d1e                	ld	s10,448(sp)
    80004680:	7dfa                	ld	s11,440(sp)
    80004682:	b541                	j	80004502 <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004684:	75f9                	lui	a1,0xffffe
    80004686:	95aa                	add	a1,a1,a0
    80004688:	855a                	mv	a0,s6
    8000468a:	ed1fc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000468e:	7bfd                	lui	s7,0xfffff
    80004690:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80004692:	e0043783          	ld	a5,-512(s0)
    80004696:	6388                	ld	a0,0(a5)
  sp = sz;
    80004698:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000469a:	4481                	li	s1,0
    ustack[argc] = sp;
    8000469c:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800046a0:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800046a4:	cd21                	beqz	a0,800046fc <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    800046a6:	fb0fc0ef          	jal	80000e56 <strlen>
    800046aa:	0015079b          	addiw	a5,a0,1
    800046ae:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800046b2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800046b6:	13796563          	bltu	s2,s7,800047e0 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800046ba:	e0043d83          	ld	s11,-512(s0)
    800046be:	000db983          	ld	s3,0(s11)
    800046c2:	854e                	mv	a0,s3
    800046c4:	f92fc0ef          	jal	80000e56 <strlen>
    800046c8:	0015069b          	addiw	a3,a0,1
    800046cc:	864e                	mv	a2,s3
    800046ce:	85ca                	mv	a1,s2
    800046d0:	855a                	mv	a0,s6
    800046d2:	eb3fc0ef          	jal	80001584 <copyout>
    800046d6:	10054763          	bltz	a0,800047e4 <exec+0x354>
    ustack[argc] = sp;
    800046da:	00349793          	slli	a5,s1,0x3
    800046de:	97e6                	add	a5,a5,s9
    800046e0:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde3c0>
  for(argc = 0; argv[argc]; argc++) {
    800046e4:	0485                	addi	s1,s1,1
    800046e6:	008d8793          	addi	a5,s11,8
    800046ea:	e0f43023          	sd	a5,-512(s0)
    800046ee:	008db503          	ld	a0,8(s11)
    800046f2:	c509                	beqz	a0,800046fc <exec+0x26c>
    if(argc >= MAXARG)
    800046f4:	fb8499e3          	bne	s1,s8,800046a6 <exec+0x216>
  sz = sz1;
    800046f8:	89d2                	mv	s3,s4
    800046fa:	b7b5                	j	80004666 <exec+0x1d6>
  ustack[argc] = 0;
    800046fc:	00349793          	slli	a5,s1,0x3
    80004700:	f9078793          	addi	a5,a5,-112
    80004704:	97a2                	add	a5,a5,s0
    80004706:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000470a:	00148693          	addi	a3,s1,1
    8000470e:	068e                	slli	a3,a3,0x3
    80004710:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004714:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004718:	89d2                	mv	s3,s4
  if(sp < stackbase)
    8000471a:	f57966e3          	bltu	s2,s7,80004666 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000471e:	e9040613          	addi	a2,s0,-368
    80004722:	85ca                	mv	a1,s2
    80004724:	855a                	mv	a0,s6
    80004726:	e5ffc0ef          	jal	80001584 <copyout>
    8000472a:	f2054ee3          	bltz	a0,80004666 <exec+0x1d6>
  p->trapframe->a1 = sp;
    8000472e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004732:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004736:	df043783          	ld	a5,-528(s0)
    8000473a:	0007c703          	lbu	a4,0(a5)
    8000473e:	cf11                	beqz	a4,8000475a <exec+0x2ca>
    80004740:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004742:	02f00693          	li	a3,47
    80004746:	a029                	j	80004750 <exec+0x2c0>
  for(last=s=path; *s; s++)
    80004748:	0785                	addi	a5,a5,1
    8000474a:	fff7c703          	lbu	a4,-1(a5)
    8000474e:	c711                	beqz	a4,8000475a <exec+0x2ca>
    if(*s == '/')
    80004750:	fed71ce3          	bne	a4,a3,80004748 <exec+0x2b8>
      last = s+1;
    80004754:	def43823          	sd	a5,-528(s0)
    80004758:	bfc5                	j	80004748 <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    8000475a:	4641                	li	a2,16
    8000475c:	df043583          	ld	a1,-528(s0)
    80004760:	158a8513          	addi	a0,s5,344
    80004764:	ebcfc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    80004768:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000476c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004770:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004774:	058ab783          	ld	a5,88(s5)
    80004778:	e6843703          	ld	a4,-408(s0)
    8000477c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000477e:	058ab783          	ld	a5,88(s5)
    80004782:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004786:	85ea                	mv	a1,s10
    80004788:	a80fd0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000478c:	0004851b          	sext.w	a0,s1
    80004790:	79fe                	ld	s3,504(sp)
    80004792:	7a5e                	ld	s4,496(sp)
    80004794:	7abe                	ld	s5,488(sp)
    80004796:	7b1e                	ld	s6,480(sp)
    80004798:	6bfe                	ld	s7,472(sp)
    8000479a:	6c5e                	ld	s8,464(sp)
    8000479c:	6cbe                	ld	s9,456(sp)
    8000479e:	6d1e                	ld	s10,448(sp)
    800047a0:	7dfa                	ld	s11,440(sp)
    800047a2:	b385                	j	80004502 <exec+0x72>
    800047a4:	7b1e                	ld	s6,480(sp)
    800047a6:	b3b9                	j	800044f4 <exec+0x64>
    800047a8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800047ac:	df843583          	ld	a1,-520(s0)
    800047b0:	855a                	mv	a0,s6
    800047b2:	a56fd0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    800047b6:	79fe                	ld	s3,504(sp)
    800047b8:	7abe                	ld	s5,488(sp)
    800047ba:	7b1e                	ld	s6,480(sp)
    800047bc:	6bfe                	ld	s7,472(sp)
    800047be:	6c5e                	ld	s8,464(sp)
    800047c0:	6cbe                	ld	s9,456(sp)
    800047c2:	6d1e                	ld	s10,448(sp)
    800047c4:	7dfa                	ld	s11,440(sp)
    800047c6:	b33d                	j	800044f4 <exec+0x64>
    800047c8:	df243c23          	sd	s2,-520(s0)
    800047cc:	b7c5                	j	800047ac <exec+0x31c>
    800047ce:	df243c23          	sd	s2,-520(s0)
    800047d2:	bfe9                	j	800047ac <exec+0x31c>
    800047d4:	df243c23          	sd	s2,-520(s0)
    800047d8:	bfd1                	j	800047ac <exec+0x31c>
    800047da:	df243c23          	sd	s2,-520(s0)
    800047de:	b7f9                	j	800047ac <exec+0x31c>
  sz = sz1;
    800047e0:	89d2                	mv	s3,s4
    800047e2:	b551                	j	80004666 <exec+0x1d6>
    800047e4:	89d2                	mv	s3,s4
    800047e6:	b541                	j	80004666 <exec+0x1d6>

00000000800047e8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800047e8:	7179                	addi	sp,sp,-48
    800047ea:	f406                	sd	ra,40(sp)
    800047ec:	f022                	sd	s0,32(sp)
    800047ee:	ec26                	sd	s1,24(sp)
    800047f0:	e84a                	sd	s2,16(sp)
    800047f2:	1800                	addi	s0,sp,48
    800047f4:	892e                	mv	s2,a1
    800047f6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800047f8:	fdc40593          	addi	a1,s0,-36
    800047fc:	f93fd0ef          	jal	8000278e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004800:	fdc42703          	lw	a4,-36(s0)
    80004804:	47bd                	li	a5,15
    80004806:	02e7e963          	bltu	a5,a4,80004838 <argfd+0x50>
    8000480a:	8d2fd0ef          	jal	800018dc <myproc>
    8000480e:	fdc42703          	lw	a4,-36(s0)
    80004812:	01a70793          	addi	a5,a4,26
    80004816:	078e                	slli	a5,a5,0x3
    80004818:	953e                	add	a0,a0,a5
    8000481a:	611c                	ld	a5,0(a0)
    8000481c:	c385                	beqz	a5,8000483c <argfd+0x54>
    return -1;
  if(pfd)
    8000481e:	00090463          	beqz	s2,80004826 <argfd+0x3e>
    *pfd = fd;
    80004822:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004826:	4501                	li	a0,0
  if(pf)
    80004828:	c091                	beqz	s1,8000482c <argfd+0x44>
    *pf = f;
    8000482a:	e09c                	sd	a5,0(s1)
}
    8000482c:	70a2                	ld	ra,40(sp)
    8000482e:	7402                	ld	s0,32(sp)
    80004830:	64e2                	ld	s1,24(sp)
    80004832:	6942                	ld	s2,16(sp)
    80004834:	6145                	addi	sp,sp,48
    80004836:	8082                	ret
    return -1;
    80004838:	557d                	li	a0,-1
    8000483a:	bfcd                	j	8000482c <argfd+0x44>
    8000483c:	557d                	li	a0,-1
    8000483e:	b7fd                	j	8000482c <argfd+0x44>

0000000080004840 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004840:	1101                	addi	sp,sp,-32
    80004842:	ec06                	sd	ra,24(sp)
    80004844:	e822                	sd	s0,16(sp)
    80004846:	e426                	sd	s1,8(sp)
    80004848:	1000                	addi	s0,sp,32
    8000484a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000484c:	890fd0ef          	jal	800018dc <myproc>
    80004850:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004852:	0d050793          	addi	a5,a0,208
    80004856:	4501                	li	a0,0
    80004858:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000485a:	6398                	ld	a4,0(a5)
    8000485c:	cb19                	beqz	a4,80004872 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000485e:	2505                	addiw	a0,a0,1
    80004860:	07a1                	addi	a5,a5,8
    80004862:	fed51ce3          	bne	a0,a3,8000485a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004866:	557d                	li	a0,-1
}
    80004868:	60e2                	ld	ra,24(sp)
    8000486a:	6442                	ld	s0,16(sp)
    8000486c:	64a2                	ld	s1,8(sp)
    8000486e:	6105                	addi	sp,sp,32
    80004870:	8082                	ret
      p->ofile[fd] = f;
    80004872:	01a50793          	addi	a5,a0,26
    80004876:	078e                	slli	a5,a5,0x3
    80004878:	963e                	add	a2,a2,a5
    8000487a:	e204                	sd	s1,0(a2)
      return fd;
    8000487c:	b7f5                	j	80004868 <fdalloc+0x28>

000000008000487e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000487e:	715d                	addi	sp,sp,-80
    80004880:	e486                	sd	ra,72(sp)
    80004882:	e0a2                	sd	s0,64(sp)
    80004884:	fc26                	sd	s1,56(sp)
    80004886:	f84a                	sd	s2,48(sp)
    80004888:	f44e                	sd	s3,40(sp)
    8000488a:	ec56                	sd	s5,24(sp)
    8000488c:	e85a                	sd	s6,16(sp)
    8000488e:	0880                	addi	s0,sp,80
    80004890:	8b2e                	mv	s6,a1
    80004892:	89b2                	mv	s3,a2
    80004894:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004896:	fb040593          	addi	a1,s0,-80
    8000489a:	ffdfe0ef          	jal	80003896 <nameiparent>
    8000489e:	84aa                	mv	s1,a0
    800048a0:	10050a63          	beqz	a0,800049b4 <create+0x136>
    return 0;

  ilock(dp);
    800048a4:	8e9fe0ef          	jal	8000318c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800048a8:	4601                	li	a2,0
    800048aa:	fb040593          	addi	a1,s0,-80
    800048ae:	8526                	mv	a0,s1
    800048b0:	d41fe0ef          	jal	800035f0 <dirlookup>
    800048b4:	8aaa                	mv	s5,a0
    800048b6:	c129                	beqz	a0,800048f8 <create+0x7a>
    iunlockput(dp);
    800048b8:	8526                	mv	a0,s1
    800048ba:	addfe0ef          	jal	80003396 <iunlockput>
    ilock(ip);
    800048be:	8556                	mv	a0,s5
    800048c0:	8cdfe0ef          	jal	8000318c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800048c4:	4789                	li	a5,2
    800048c6:	02fb1463          	bne	s6,a5,800048ee <create+0x70>
    800048ca:	044ad783          	lhu	a5,68(s5)
    800048ce:	37f9                	addiw	a5,a5,-2
    800048d0:	17c2                	slli	a5,a5,0x30
    800048d2:	93c1                	srli	a5,a5,0x30
    800048d4:	4705                	li	a4,1
    800048d6:	00f76c63          	bltu	a4,a5,800048ee <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800048da:	8556                	mv	a0,s5
    800048dc:	60a6                	ld	ra,72(sp)
    800048de:	6406                	ld	s0,64(sp)
    800048e0:	74e2                	ld	s1,56(sp)
    800048e2:	7942                	ld	s2,48(sp)
    800048e4:	79a2                	ld	s3,40(sp)
    800048e6:	6ae2                	ld	s5,24(sp)
    800048e8:	6b42                	ld	s6,16(sp)
    800048ea:	6161                	addi	sp,sp,80
    800048ec:	8082                	ret
    iunlockput(ip);
    800048ee:	8556                	mv	a0,s5
    800048f0:	aa7fe0ef          	jal	80003396 <iunlockput>
    return 0;
    800048f4:	4a81                	li	s5,0
    800048f6:	b7d5                	j	800048da <create+0x5c>
    800048f8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800048fa:	85da                	mv	a1,s6
    800048fc:	4088                	lw	a0,0(s1)
    800048fe:	f1efe0ef          	jal	8000301c <ialloc>
    80004902:	8a2a                	mv	s4,a0
    80004904:	cd15                	beqz	a0,80004940 <create+0xc2>
  ilock(ip);
    80004906:	887fe0ef          	jal	8000318c <ilock>
  ip->major = major;
    8000490a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000490e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004912:	4905                	li	s2,1
    80004914:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004918:	8552                	mv	a0,s4
    8000491a:	fbefe0ef          	jal	800030d8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000491e:	032b0763          	beq	s6,s2,8000494c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004922:	004a2603          	lw	a2,4(s4)
    80004926:	fb040593          	addi	a1,s0,-80
    8000492a:	8526                	mv	a0,s1
    8000492c:	ea7fe0ef          	jal	800037d2 <dirlink>
    80004930:	06054563          	bltz	a0,8000499a <create+0x11c>
  iunlockput(dp);
    80004934:	8526                	mv	a0,s1
    80004936:	a61fe0ef          	jal	80003396 <iunlockput>
  return ip;
    8000493a:	8ad2                	mv	s5,s4
    8000493c:	7a02                	ld	s4,32(sp)
    8000493e:	bf71                	j	800048da <create+0x5c>
    iunlockput(dp);
    80004940:	8526                	mv	a0,s1
    80004942:	a55fe0ef          	jal	80003396 <iunlockput>
    return 0;
    80004946:	8ad2                	mv	s5,s4
    80004948:	7a02                	ld	s4,32(sp)
    8000494a:	bf41                	j	800048da <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000494c:	004a2603          	lw	a2,4(s4)
    80004950:	00003597          	auipc	a1,0x3
    80004954:	cd058593          	addi	a1,a1,-816 # 80007620 <etext+0x620>
    80004958:	8552                	mv	a0,s4
    8000495a:	e79fe0ef          	jal	800037d2 <dirlink>
    8000495e:	02054e63          	bltz	a0,8000499a <create+0x11c>
    80004962:	40d0                	lw	a2,4(s1)
    80004964:	00003597          	auipc	a1,0x3
    80004968:	cc458593          	addi	a1,a1,-828 # 80007628 <etext+0x628>
    8000496c:	8552                	mv	a0,s4
    8000496e:	e65fe0ef          	jal	800037d2 <dirlink>
    80004972:	02054463          	bltz	a0,8000499a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004976:	004a2603          	lw	a2,4(s4)
    8000497a:	fb040593          	addi	a1,s0,-80
    8000497e:	8526                	mv	a0,s1
    80004980:	e53fe0ef          	jal	800037d2 <dirlink>
    80004984:	00054b63          	bltz	a0,8000499a <create+0x11c>
    dp->nlink++;  // for ".."
    80004988:	04a4d783          	lhu	a5,74(s1)
    8000498c:	2785                	addiw	a5,a5,1
    8000498e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004992:	8526                	mv	a0,s1
    80004994:	f44fe0ef          	jal	800030d8 <iupdate>
    80004998:	bf71                	j	80004934 <create+0xb6>
  ip->nlink = 0;
    8000499a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000499e:	8552                	mv	a0,s4
    800049a0:	f38fe0ef          	jal	800030d8 <iupdate>
  iunlockput(ip);
    800049a4:	8552                	mv	a0,s4
    800049a6:	9f1fe0ef          	jal	80003396 <iunlockput>
  iunlockput(dp);
    800049aa:	8526                	mv	a0,s1
    800049ac:	9ebfe0ef          	jal	80003396 <iunlockput>
  return 0;
    800049b0:	7a02                	ld	s4,32(sp)
    800049b2:	b725                	j	800048da <create+0x5c>
    return 0;
    800049b4:	8aaa                	mv	s5,a0
    800049b6:	b715                	j	800048da <create+0x5c>

00000000800049b8 <sys_dup>:
{
    800049b8:	7179                	addi	sp,sp,-48
    800049ba:	f406                	sd	ra,40(sp)
    800049bc:	f022                	sd	s0,32(sp)
    800049be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800049c0:	fd840613          	addi	a2,s0,-40
    800049c4:	4581                	li	a1,0
    800049c6:	4501                	li	a0,0
    800049c8:	e21ff0ef          	jal	800047e8 <argfd>
    return -1;
    800049cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800049ce:	02054363          	bltz	a0,800049f4 <sys_dup+0x3c>
    800049d2:	ec26                	sd	s1,24(sp)
    800049d4:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800049d6:	fd843903          	ld	s2,-40(s0)
    800049da:	854a                	mv	a0,s2
    800049dc:	e65ff0ef          	jal	80004840 <fdalloc>
    800049e0:	84aa                	mv	s1,a0
    return -1;
    800049e2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800049e4:	00054d63          	bltz	a0,800049fe <sys_dup+0x46>
  filedup(f);
    800049e8:	854a                	mv	a0,s2
    800049ea:	c2eff0ef          	jal	80003e18 <filedup>
  return fd;
    800049ee:	87a6                	mv	a5,s1
    800049f0:	64e2                	ld	s1,24(sp)
    800049f2:	6942                	ld	s2,16(sp)
}
    800049f4:	853e                	mv	a0,a5
    800049f6:	70a2                	ld	ra,40(sp)
    800049f8:	7402                	ld	s0,32(sp)
    800049fa:	6145                	addi	sp,sp,48
    800049fc:	8082                	ret
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	6942                	ld	s2,16(sp)
    80004a02:	bfcd                	j	800049f4 <sys_dup+0x3c>

0000000080004a04 <sys_read>:
{
    80004a04:	7179                	addi	sp,sp,-48
    80004a06:	f406                	sd	ra,40(sp)
    80004a08:	f022                	sd	s0,32(sp)
    80004a0a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a0c:	fd840593          	addi	a1,s0,-40
    80004a10:	4505                	li	a0,1
    80004a12:	d99fd0ef          	jal	800027aa <argaddr>
  argint(2, &n);
    80004a16:	fe440593          	addi	a1,s0,-28
    80004a1a:	4509                	li	a0,2
    80004a1c:	d73fd0ef          	jal	8000278e <argint>
  if(argfd(0, 0, &f) < 0)
    80004a20:	fe840613          	addi	a2,s0,-24
    80004a24:	4581                	li	a1,0
    80004a26:	4501                	li	a0,0
    80004a28:	dc1ff0ef          	jal	800047e8 <argfd>
    80004a2c:	87aa                	mv	a5,a0
    return -1;
    80004a2e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a30:	0007ca63          	bltz	a5,80004a44 <sys_read+0x40>
  return fileread(f, p, n);
    80004a34:	fe442603          	lw	a2,-28(s0)
    80004a38:	fd843583          	ld	a1,-40(s0)
    80004a3c:	fe843503          	ld	a0,-24(s0)
    80004a40:	d3eff0ef          	jal	80003f7e <fileread>
}
    80004a44:	70a2                	ld	ra,40(sp)
    80004a46:	7402                	ld	s0,32(sp)
    80004a48:	6145                	addi	sp,sp,48
    80004a4a:	8082                	ret

0000000080004a4c <sys_write>:
{
    80004a4c:	7179                	addi	sp,sp,-48
    80004a4e:	f406                	sd	ra,40(sp)
    80004a50:	f022                	sd	s0,32(sp)
    80004a52:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a54:	fd840593          	addi	a1,s0,-40
    80004a58:	4505                	li	a0,1
    80004a5a:	d51fd0ef          	jal	800027aa <argaddr>
  argint(2, &n);
    80004a5e:	fe440593          	addi	a1,s0,-28
    80004a62:	4509                	li	a0,2
    80004a64:	d2bfd0ef          	jal	8000278e <argint>
  if(argfd(0, 0, &f) < 0)
    80004a68:	fe840613          	addi	a2,s0,-24
    80004a6c:	4581                	li	a1,0
    80004a6e:	4501                	li	a0,0
    80004a70:	d79ff0ef          	jal	800047e8 <argfd>
    80004a74:	87aa                	mv	a5,a0
    return -1;
    80004a76:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a78:	0007ca63          	bltz	a5,80004a8c <sys_write+0x40>
  return filewrite(f, p, n);
    80004a7c:	fe442603          	lw	a2,-28(s0)
    80004a80:	fd843583          	ld	a1,-40(s0)
    80004a84:	fe843503          	ld	a0,-24(s0)
    80004a88:	db4ff0ef          	jal	8000403c <filewrite>
}
    80004a8c:	70a2                	ld	ra,40(sp)
    80004a8e:	7402                	ld	s0,32(sp)
    80004a90:	6145                	addi	sp,sp,48
    80004a92:	8082                	ret

0000000080004a94 <sys_close>:
{
    80004a94:	1101                	addi	sp,sp,-32
    80004a96:	ec06                	sd	ra,24(sp)
    80004a98:	e822                	sd	s0,16(sp)
    80004a9a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004a9c:	fe040613          	addi	a2,s0,-32
    80004aa0:	fec40593          	addi	a1,s0,-20
    80004aa4:	4501                	li	a0,0
    80004aa6:	d43ff0ef          	jal	800047e8 <argfd>
    return -1;
    80004aaa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004aac:	02054063          	bltz	a0,80004acc <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ab0:	e2dfc0ef          	jal	800018dc <myproc>
    80004ab4:	fec42783          	lw	a5,-20(s0)
    80004ab8:	07e9                	addi	a5,a5,26
    80004aba:	078e                	slli	a5,a5,0x3
    80004abc:	953e                	add	a0,a0,a5
    80004abe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ac2:	fe043503          	ld	a0,-32(s0)
    80004ac6:	b98ff0ef          	jal	80003e5e <fileclose>
  return 0;
    80004aca:	4781                	li	a5,0
}
    80004acc:	853e                	mv	a0,a5
    80004ace:	60e2                	ld	ra,24(sp)
    80004ad0:	6442                	ld	s0,16(sp)
    80004ad2:	6105                	addi	sp,sp,32
    80004ad4:	8082                	ret

0000000080004ad6 <sys_fstat>:
{
    80004ad6:	1101                	addi	sp,sp,-32
    80004ad8:	ec06                	sd	ra,24(sp)
    80004ada:	e822                	sd	s0,16(sp)
    80004adc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ade:	fe040593          	addi	a1,s0,-32
    80004ae2:	4505                	li	a0,1
    80004ae4:	cc7fd0ef          	jal	800027aa <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ae8:	fe840613          	addi	a2,s0,-24
    80004aec:	4581                	li	a1,0
    80004aee:	4501                	li	a0,0
    80004af0:	cf9ff0ef          	jal	800047e8 <argfd>
    80004af4:	87aa                	mv	a5,a0
    return -1;
    80004af6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004af8:	0007c863          	bltz	a5,80004b08 <sys_fstat+0x32>
  return filestat(f, st);
    80004afc:	fe043583          	ld	a1,-32(s0)
    80004b00:	fe843503          	ld	a0,-24(s0)
    80004b04:	c18ff0ef          	jal	80003f1c <filestat>
}
    80004b08:	60e2                	ld	ra,24(sp)
    80004b0a:	6442                	ld	s0,16(sp)
    80004b0c:	6105                	addi	sp,sp,32
    80004b0e:	8082                	ret

0000000080004b10 <sys_link>:
{
    80004b10:	7169                	addi	sp,sp,-304
    80004b12:	f606                	sd	ra,296(sp)
    80004b14:	f222                	sd	s0,288(sp)
    80004b16:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b18:	08000613          	li	a2,128
    80004b1c:	ed040593          	addi	a1,s0,-304
    80004b20:	4501                	li	a0,0
    80004b22:	ca5fd0ef          	jal	800027c6 <argstr>
    return -1;
    80004b26:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b28:	0c054e63          	bltz	a0,80004c04 <sys_link+0xf4>
    80004b2c:	08000613          	li	a2,128
    80004b30:	f5040593          	addi	a1,s0,-176
    80004b34:	4505                	li	a0,1
    80004b36:	c91fd0ef          	jal	800027c6 <argstr>
    return -1;
    80004b3a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b3c:	0c054463          	bltz	a0,80004c04 <sys_link+0xf4>
    80004b40:	ee26                	sd	s1,280(sp)
  begin_op();
    80004b42:	efdfe0ef          	jal	80003a3e <begin_op>
  if((ip = namei(old)) == 0){
    80004b46:	ed040513          	addi	a0,s0,-304
    80004b4a:	d33fe0ef          	jal	8000387c <namei>
    80004b4e:	84aa                	mv	s1,a0
    80004b50:	c53d                	beqz	a0,80004bbe <sys_link+0xae>
  ilock(ip);
    80004b52:	e3afe0ef          	jal	8000318c <ilock>
  if(ip->type == T_DIR){
    80004b56:	04449703          	lh	a4,68(s1)
    80004b5a:	4785                	li	a5,1
    80004b5c:	06f70663          	beq	a4,a5,80004bc8 <sys_link+0xb8>
    80004b60:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004b62:	04a4d783          	lhu	a5,74(s1)
    80004b66:	2785                	addiw	a5,a5,1
    80004b68:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	d6afe0ef          	jal	800030d8 <iupdate>
  iunlock(ip);
    80004b72:	8526                	mv	a0,s1
    80004b74:	ec6fe0ef          	jal	8000323a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b78:	fd040593          	addi	a1,s0,-48
    80004b7c:	f5040513          	addi	a0,s0,-176
    80004b80:	d17fe0ef          	jal	80003896 <nameiparent>
    80004b84:	892a                	mv	s2,a0
    80004b86:	cd21                	beqz	a0,80004bde <sys_link+0xce>
  ilock(dp);
    80004b88:	e04fe0ef          	jal	8000318c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004b8c:	00092703          	lw	a4,0(s2)
    80004b90:	409c                	lw	a5,0(s1)
    80004b92:	04f71363          	bne	a4,a5,80004bd8 <sys_link+0xc8>
    80004b96:	40d0                	lw	a2,4(s1)
    80004b98:	fd040593          	addi	a1,s0,-48
    80004b9c:	854a                	mv	a0,s2
    80004b9e:	c35fe0ef          	jal	800037d2 <dirlink>
    80004ba2:	02054b63          	bltz	a0,80004bd8 <sys_link+0xc8>
  iunlockput(dp);
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	feefe0ef          	jal	80003396 <iunlockput>
  iput(ip);
    80004bac:	8526                	mv	a0,s1
    80004bae:	f60fe0ef          	jal	8000330e <iput>
  end_op();
    80004bb2:	ef7fe0ef          	jal	80003aa8 <end_op>
  return 0;
    80004bb6:	4781                	li	a5,0
    80004bb8:	64f2                	ld	s1,280(sp)
    80004bba:	6952                	ld	s2,272(sp)
    80004bbc:	a0a1                	j	80004c04 <sys_link+0xf4>
    end_op();
    80004bbe:	eebfe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004bc2:	57fd                	li	a5,-1
    80004bc4:	64f2                	ld	s1,280(sp)
    80004bc6:	a83d                	j	80004c04 <sys_link+0xf4>
    iunlockput(ip);
    80004bc8:	8526                	mv	a0,s1
    80004bca:	fccfe0ef          	jal	80003396 <iunlockput>
    end_op();
    80004bce:	edbfe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004bd2:	57fd                	li	a5,-1
    80004bd4:	64f2                	ld	s1,280(sp)
    80004bd6:	a03d                	j	80004c04 <sys_link+0xf4>
    iunlockput(dp);
    80004bd8:	854a                	mv	a0,s2
    80004bda:	fbcfe0ef          	jal	80003396 <iunlockput>
  ilock(ip);
    80004bde:	8526                	mv	a0,s1
    80004be0:	dacfe0ef          	jal	8000318c <ilock>
  ip->nlink--;
    80004be4:	04a4d783          	lhu	a5,74(s1)
    80004be8:	37fd                	addiw	a5,a5,-1
    80004bea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ce8fe0ef          	jal	800030d8 <iupdate>
  iunlockput(ip);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	fa0fe0ef          	jal	80003396 <iunlockput>
  end_op();
    80004bfa:	eaffe0ef          	jal	80003aa8 <end_op>
  return -1;
    80004bfe:	57fd                	li	a5,-1
    80004c00:	64f2                	ld	s1,280(sp)
    80004c02:	6952                	ld	s2,272(sp)
}
    80004c04:	853e                	mv	a0,a5
    80004c06:	70b2                	ld	ra,296(sp)
    80004c08:	7412                	ld	s0,288(sp)
    80004c0a:	6155                	addi	sp,sp,304
    80004c0c:	8082                	ret

0000000080004c0e <sys_unlink>:
{
    80004c0e:	7111                	addi	sp,sp,-256
    80004c10:	fd86                	sd	ra,248(sp)
    80004c12:	f9a2                	sd	s0,240(sp)
    80004c14:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004c16:	08000613          	li	a2,128
    80004c1a:	f2040593          	addi	a1,s0,-224
    80004c1e:	4501                	li	a0,0
    80004c20:	ba7fd0ef          	jal	800027c6 <argstr>
    80004c24:	16054663          	bltz	a0,80004d90 <sys_unlink+0x182>
    80004c28:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004c2a:	e15fe0ef          	jal	80003a3e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c2e:	fa040593          	addi	a1,s0,-96
    80004c32:	f2040513          	addi	a0,s0,-224
    80004c36:	c61fe0ef          	jal	80003896 <nameiparent>
    80004c3a:	84aa                	mv	s1,a0
    80004c3c:	c955                	beqz	a0,80004cf0 <sys_unlink+0xe2>
  ilock(dp);
    80004c3e:	d4efe0ef          	jal	8000318c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c42:	00003597          	auipc	a1,0x3
    80004c46:	9de58593          	addi	a1,a1,-1570 # 80007620 <etext+0x620>
    80004c4a:	fa040513          	addi	a0,s0,-96
    80004c4e:	98dfe0ef          	jal	800035da <namecmp>
    80004c52:	12050463          	beqz	a0,80004d7a <sys_unlink+0x16c>
    80004c56:	00003597          	auipc	a1,0x3
    80004c5a:	9d258593          	addi	a1,a1,-1582 # 80007628 <etext+0x628>
    80004c5e:	fa040513          	addi	a0,s0,-96
    80004c62:	979fe0ef          	jal	800035da <namecmp>
    80004c66:	10050a63          	beqz	a0,80004d7a <sys_unlink+0x16c>
    80004c6a:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c6c:	f1c40613          	addi	a2,s0,-228
    80004c70:	fa040593          	addi	a1,s0,-96
    80004c74:	8526                	mv	a0,s1
    80004c76:	97bfe0ef          	jal	800035f0 <dirlookup>
    80004c7a:	892a                	mv	s2,a0
    80004c7c:	0e050e63          	beqz	a0,80004d78 <sys_unlink+0x16a>
    80004c80:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004c82:	d0afe0ef          	jal	8000318c <ilock>
  if(ip->nlink < 1)
    80004c86:	04a91783          	lh	a5,74(s2)
    80004c8a:	06f05863          	blez	a5,80004cfa <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c8e:	04491703          	lh	a4,68(s2)
    80004c92:	4785                	li	a5,1
    80004c94:	06f70b63          	beq	a4,a5,80004d0a <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004c98:	fb040993          	addi	s3,s0,-80
    80004c9c:	4641                	li	a2,16
    80004c9e:	4581                	li	a1,0
    80004ca0:	854e                	mv	a0,s3
    80004ca2:	82cfc0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ca6:	4741                	li	a4,16
    80004ca8:	f1c42683          	lw	a3,-228(s0)
    80004cac:	864e                	mv	a2,s3
    80004cae:	4581                	li	a1,0
    80004cb0:	8526                	mv	a0,s1
    80004cb2:	825fe0ef          	jal	800034d6 <writei>
    80004cb6:	47c1                	li	a5,16
    80004cb8:	08f51f63          	bne	a0,a5,80004d56 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004cbc:	04491703          	lh	a4,68(s2)
    80004cc0:	4785                	li	a5,1
    80004cc2:	0af70263          	beq	a4,a5,80004d66 <sys_unlink+0x158>
  iunlockput(dp);
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	ecefe0ef          	jal	80003396 <iunlockput>
  ip->nlink--;
    80004ccc:	04a95783          	lhu	a5,74(s2)
    80004cd0:	37fd                	addiw	a5,a5,-1
    80004cd2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004cd6:	854a                	mv	a0,s2
    80004cd8:	c00fe0ef          	jal	800030d8 <iupdate>
  iunlockput(ip);
    80004cdc:	854a                	mv	a0,s2
    80004cde:	eb8fe0ef          	jal	80003396 <iunlockput>
  end_op();
    80004ce2:	dc7fe0ef          	jal	80003aa8 <end_op>
  return 0;
    80004ce6:	4501                	li	a0,0
    80004ce8:	74ae                	ld	s1,232(sp)
    80004cea:	790e                	ld	s2,224(sp)
    80004cec:	69ee                	ld	s3,216(sp)
    80004cee:	a869                	j	80004d88 <sys_unlink+0x17a>
    end_op();
    80004cf0:	db9fe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004cf4:	557d                	li	a0,-1
    80004cf6:	74ae                	ld	s1,232(sp)
    80004cf8:	a841                	j	80004d88 <sys_unlink+0x17a>
    80004cfa:	e9d2                	sd	s4,208(sp)
    80004cfc:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004cfe:	00003517          	auipc	a0,0x3
    80004d02:	93250513          	addi	a0,a0,-1742 # 80007630 <etext+0x630>
    80004d06:	a99fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d0a:	04c92703          	lw	a4,76(s2)
    80004d0e:	02000793          	li	a5,32
    80004d12:	f8e7f3e3          	bgeu	a5,a4,80004c98 <sys_unlink+0x8a>
    80004d16:	e9d2                	sd	s4,208(sp)
    80004d18:	e5d6                	sd	s5,200(sp)
    80004d1a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d1c:	f0840a93          	addi	s5,s0,-248
    80004d20:	4a41                	li	s4,16
    80004d22:	8752                	mv	a4,s4
    80004d24:	86ce                	mv	a3,s3
    80004d26:	8656                	mv	a2,s5
    80004d28:	4581                	li	a1,0
    80004d2a:	854a                	mv	a0,s2
    80004d2c:	eb8fe0ef          	jal	800033e4 <readi>
    80004d30:	01451d63          	bne	a0,s4,80004d4a <sys_unlink+0x13c>
    if(de.inum != 0)
    80004d34:	f0845783          	lhu	a5,-248(s0)
    80004d38:	efb1                	bnez	a5,80004d94 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d3a:	29c1                	addiw	s3,s3,16
    80004d3c:	04c92783          	lw	a5,76(s2)
    80004d40:	fef9e1e3          	bltu	s3,a5,80004d22 <sys_unlink+0x114>
    80004d44:	6a4e                	ld	s4,208(sp)
    80004d46:	6aae                	ld	s5,200(sp)
    80004d48:	bf81                	j	80004c98 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004d4a:	00003517          	auipc	a0,0x3
    80004d4e:	8fe50513          	addi	a0,a0,-1794 # 80007648 <etext+0x648>
    80004d52:	a4dfb0ef          	jal	8000079e <panic>
    80004d56:	e9d2                	sd	s4,208(sp)
    80004d58:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004d5a:	00003517          	auipc	a0,0x3
    80004d5e:	90650513          	addi	a0,a0,-1786 # 80007660 <etext+0x660>
    80004d62:	a3dfb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004d66:	04a4d783          	lhu	a5,74(s1)
    80004d6a:	37fd                	addiw	a5,a5,-1
    80004d6c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d70:	8526                	mv	a0,s1
    80004d72:	b66fe0ef          	jal	800030d8 <iupdate>
    80004d76:	bf81                	j	80004cc6 <sys_unlink+0xb8>
    80004d78:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	e1afe0ef          	jal	80003396 <iunlockput>
  end_op();
    80004d80:	d29fe0ef          	jal	80003aa8 <end_op>
  return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	74ae                	ld	s1,232(sp)
}
    80004d88:	70ee                	ld	ra,248(sp)
    80004d8a:	744e                	ld	s0,240(sp)
    80004d8c:	6111                	addi	sp,sp,256
    80004d8e:	8082                	ret
    return -1;
    80004d90:	557d                	li	a0,-1
    80004d92:	bfdd                	j	80004d88 <sys_unlink+0x17a>
    iunlockput(ip);
    80004d94:	854a                	mv	a0,s2
    80004d96:	e00fe0ef          	jal	80003396 <iunlockput>
    goto bad;
    80004d9a:	790e                	ld	s2,224(sp)
    80004d9c:	69ee                	ld	s3,216(sp)
    80004d9e:	6a4e                	ld	s4,208(sp)
    80004da0:	6aae                	ld	s5,200(sp)
    80004da2:	bfe1                	j	80004d7a <sys_unlink+0x16c>

0000000080004da4 <sys_open>:

uint64
sys_open(void)
{
    80004da4:	7131                	addi	sp,sp,-192
    80004da6:	fd06                	sd	ra,184(sp)
    80004da8:	f922                	sd	s0,176(sp)
    80004daa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004dac:	f4c40593          	addi	a1,s0,-180
    80004db0:	4505                	li	a0,1
    80004db2:	9ddfd0ef          	jal	8000278e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004db6:	08000613          	li	a2,128
    80004dba:	f5040593          	addi	a1,s0,-176
    80004dbe:	4501                	li	a0,0
    80004dc0:	a07fd0ef          	jal	800027c6 <argstr>
    80004dc4:	87aa                	mv	a5,a0
    return -1;
    80004dc6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004dc8:	0a07c363          	bltz	a5,80004e6e <sys_open+0xca>
    80004dcc:	f526                	sd	s1,168(sp)

  begin_op();
    80004dce:	c71fe0ef          	jal	80003a3e <begin_op>

  if(omode & O_CREATE){
    80004dd2:	f4c42783          	lw	a5,-180(s0)
    80004dd6:	2007f793          	andi	a5,a5,512
    80004dda:	c3dd                	beqz	a5,80004e80 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004ddc:	4681                	li	a3,0
    80004dde:	4601                	li	a2,0
    80004de0:	4589                	li	a1,2
    80004de2:	f5040513          	addi	a0,s0,-176
    80004de6:	a99ff0ef          	jal	8000487e <create>
    80004dea:	84aa                	mv	s1,a0
    if(ip == 0){
    80004dec:	c549                	beqz	a0,80004e76 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004dee:	04449703          	lh	a4,68(s1)
    80004df2:	478d                	li	a5,3
    80004df4:	00f71763          	bne	a4,a5,80004e02 <sys_open+0x5e>
    80004df8:	0464d703          	lhu	a4,70(s1)
    80004dfc:	47a5                	li	a5,9
    80004dfe:	0ae7ee63          	bltu	a5,a4,80004eba <sys_open+0x116>
    80004e02:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e04:	fb7fe0ef          	jal	80003dba <filealloc>
    80004e08:	892a                	mv	s2,a0
    80004e0a:	c561                	beqz	a0,80004ed2 <sys_open+0x12e>
    80004e0c:	ed4e                	sd	s3,152(sp)
    80004e0e:	a33ff0ef          	jal	80004840 <fdalloc>
    80004e12:	89aa                	mv	s3,a0
    80004e14:	0a054b63          	bltz	a0,80004eca <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e18:	04449703          	lh	a4,68(s1)
    80004e1c:	478d                	li	a5,3
    80004e1e:	0cf70363          	beq	a4,a5,80004ee4 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e22:	4789                	li	a5,2
    80004e24:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004e28:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004e2c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004e30:	f4c42783          	lw	a5,-180(s0)
    80004e34:	0017f713          	andi	a4,a5,1
    80004e38:	00174713          	xori	a4,a4,1
    80004e3c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e40:	0037f713          	andi	a4,a5,3
    80004e44:	00e03733          	snez	a4,a4
    80004e48:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e4c:	4007f793          	andi	a5,a5,1024
    80004e50:	c791                	beqz	a5,80004e5c <sys_open+0xb8>
    80004e52:	04449703          	lh	a4,68(s1)
    80004e56:	4789                	li	a5,2
    80004e58:	08f70d63          	beq	a4,a5,80004ef2 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	bdcfe0ef          	jal	8000323a <iunlock>
  end_op();
    80004e62:	c47fe0ef          	jal	80003aa8 <end_op>

  return fd;
    80004e66:	854e                	mv	a0,s3
    80004e68:	74aa                	ld	s1,168(sp)
    80004e6a:	790a                	ld	s2,160(sp)
    80004e6c:	69ea                	ld	s3,152(sp)
}
    80004e6e:	70ea                	ld	ra,184(sp)
    80004e70:	744a                	ld	s0,176(sp)
    80004e72:	6129                	addi	sp,sp,192
    80004e74:	8082                	ret
      end_op();
    80004e76:	c33fe0ef          	jal	80003aa8 <end_op>
      return -1;
    80004e7a:	557d                	li	a0,-1
    80004e7c:	74aa                	ld	s1,168(sp)
    80004e7e:	bfc5                	j	80004e6e <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80004e80:	f5040513          	addi	a0,s0,-176
    80004e84:	9f9fe0ef          	jal	8000387c <namei>
    80004e88:	84aa                	mv	s1,a0
    80004e8a:	c11d                	beqz	a0,80004eb0 <sys_open+0x10c>
    ilock(ip);
    80004e8c:	b00fe0ef          	jal	8000318c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e90:	04449703          	lh	a4,68(s1)
    80004e94:	4785                	li	a5,1
    80004e96:	f4f71ce3          	bne	a4,a5,80004dee <sys_open+0x4a>
    80004e9a:	f4c42783          	lw	a5,-180(s0)
    80004e9e:	d3b5                	beqz	a5,80004e02 <sys_open+0x5e>
      iunlockput(ip);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	cf4fe0ef          	jal	80003396 <iunlockput>
      end_op();
    80004ea6:	c03fe0ef          	jal	80003aa8 <end_op>
      return -1;
    80004eaa:	557d                	li	a0,-1
    80004eac:	74aa                	ld	s1,168(sp)
    80004eae:	b7c1                	j	80004e6e <sys_open+0xca>
      end_op();
    80004eb0:	bf9fe0ef          	jal	80003aa8 <end_op>
      return -1;
    80004eb4:	557d                	li	a0,-1
    80004eb6:	74aa                	ld	s1,168(sp)
    80004eb8:	bf5d                	j	80004e6e <sys_open+0xca>
    iunlockput(ip);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	cdafe0ef          	jal	80003396 <iunlockput>
    end_op();
    80004ec0:	be9fe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004ec4:	557d                	li	a0,-1
    80004ec6:	74aa                	ld	s1,168(sp)
    80004ec8:	b75d                	j	80004e6e <sys_open+0xca>
      fileclose(f);
    80004eca:	854a                	mv	a0,s2
    80004ecc:	f93fe0ef          	jal	80003e5e <fileclose>
    80004ed0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	cc2fe0ef          	jal	80003396 <iunlockput>
    end_op();
    80004ed8:	bd1fe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004edc:	557d                	li	a0,-1
    80004ede:	74aa                	ld	s1,168(sp)
    80004ee0:	790a                	ld	s2,160(sp)
    80004ee2:	b771                	j	80004e6e <sys_open+0xca>
    f->type = FD_DEVICE;
    80004ee4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004ee8:	04649783          	lh	a5,70(s1)
    80004eec:	02f91223          	sh	a5,36(s2)
    80004ef0:	bf35                	j	80004e2c <sys_open+0x88>
    itrunc(ip);
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	b86fe0ef          	jal	8000327a <itrunc>
    80004ef8:	b795                	j	80004e5c <sys_open+0xb8>

0000000080004efa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004efa:	7175                	addi	sp,sp,-144
    80004efc:	e506                	sd	ra,136(sp)
    80004efe:	e122                	sd	s0,128(sp)
    80004f00:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f02:	b3dfe0ef          	jal	80003a3e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f06:	08000613          	li	a2,128
    80004f0a:	f7040593          	addi	a1,s0,-144
    80004f0e:	4501                	li	a0,0
    80004f10:	8b7fd0ef          	jal	800027c6 <argstr>
    80004f14:	02054363          	bltz	a0,80004f3a <sys_mkdir+0x40>
    80004f18:	4681                	li	a3,0
    80004f1a:	4601                	li	a2,0
    80004f1c:	4585                	li	a1,1
    80004f1e:	f7040513          	addi	a0,s0,-144
    80004f22:	95dff0ef          	jal	8000487e <create>
    80004f26:	c911                	beqz	a0,80004f3a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f28:	c6efe0ef          	jal	80003396 <iunlockput>
  end_op();
    80004f2c:	b7dfe0ef          	jal	80003aa8 <end_op>
  return 0;
    80004f30:	4501                	li	a0,0
}
    80004f32:	60aa                	ld	ra,136(sp)
    80004f34:	640a                	ld	s0,128(sp)
    80004f36:	6149                	addi	sp,sp,144
    80004f38:	8082                	ret
    end_op();
    80004f3a:	b6ffe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004f3e:	557d                	li	a0,-1
    80004f40:	bfcd                	j	80004f32 <sys_mkdir+0x38>

0000000080004f42 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f42:	7135                	addi	sp,sp,-160
    80004f44:	ed06                	sd	ra,152(sp)
    80004f46:	e922                	sd	s0,144(sp)
    80004f48:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f4a:	af5fe0ef          	jal	80003a3e <begin_op>
  argint(1, &major);
    80004f4e:	f6c40593          	addi	a1,s0,-148
    80004f52:	4505                	li	a0,1
    80004f54:	83bfd0ef          	jal	8000278e <argint>
  argint(2, &minor);
    80004f58:	f6840593          	addi	a1,s0,-152
    80004f5c:	4509                	li	a0,2
    80004f5e:	831fd0ef          	jal	8000278e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f62:	08000613          	li	a2,128
    80004f66:	f7040593          	addi	a1,s0,-144
    80004f6a:	4501                	li	a0,0
    80004f6c:	85bfd0ef          	jal	800027c6 <argstr>
    80004f70:	02054563          	bltz	a0,80004f9a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f74:	f6841683          	lh	a3,-152(s0)
    80004f78:	f6c41603          	lh	a2,-148(s0)
    80004f7c:	458d                	li	a1,3
    80004f7e:	f7040513          	addi	a0,s0,-144
    80004f82:	8fdff0ef          	jal	8000487e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f86:	c911                	beqz	a0,80004f9a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f88:	c0efe0ef          	jal	80003396 <iunlockput>
  end_op();
    80004f8c:	b1dfe0ef          	jal	80003aa8 <end_op>
  return 0;
    80004f90:	4501                	li	a0,0
}
    80004f92:	60ea                	ld	ra,152(sp)
    80004f94:	644a                	ld	s0,144(sp)
    80004f96:	610d                	addi	sp,sp,160
    80004f98:	8082                	ret
    end_op();
    80004f9a:	b0ffe0ef          	jal	80003aa8 <end_op>
    return -1;
    80004f9e:	557d                	li	a0,-1
    80004fa0:	bfcd                	j	80004f92 <sys_mknod+0x50>

0000000080004fa2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fa2:	7135                	addi	sp,sp,-160
    80004fa4:	ed06                	sd	ra,152(sp)
    80004fa6:	e922                	sd	s0,144(sp)
    80004fa8:	e14a                	sd	s2,128(sp)
    80004faa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fac:	931fc0ef          	jal	800018dc <myproc>
    80004fb0:	892a                	mv	s2,a0
  
  begin_op();
    80004fb2:	a8dfe0ef          	jal	80003a3e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fb6:	08000613          	li	a2,128
    80004fba:	f6040593          	addi	a1,s0,-160
    80004fbe:	4501                	li	a0,0
    80004fc0:	807fd0ef          	jal	800027c6 <argstr>
    80004fc4:	04054363          	bltz	a0,8000500a <sys_chdir+0x68>
    80004fc8:	e526                	sd	s1,136(sp)
    80004fca:	f6040513          	addi	a0,s0,-160
    80004fce:	8affe0ef          	jal	8000387c <namei>
    80004fd2:	84aa                	mv	s1,a0
    80004fd4:	c915                	beqz	a0,80005008 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004fd6:	9b6fe0ef          	jal	8000318c <ilock>
  if(ip->type != T_DIR){
    80004fda:	04449703          	lh	a4,68(s1)
    80004fde:	4785                	li	a5,1
    80004fe0:	02f71963          	bne	a4,a5,80005012 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	a54fe0ef          	jal	8000323a <iunlock>
  iput(p->cwd);
    80004fea:	15093503          	ld	a0,336(s2)
    80004fee:	b20fe0ef          	jal	8000330e <iput>
  end_op();
    80004ff2:	ab7fe0ef          	jal	80003aa8 <end_op>
  p->cwd = ip;
    80004ff6:	14993823          	sd	s1,336(s2)
  return 0;
    80004ffa:	4501                	li	a0,0
    80004ffc:	64aa                	ld	s1,136(sp)
}
    80004ffe:	60ea                	ld	ra,152(sp)
    80005000:	644a                	ld	s0,144(sp)
    80005002:	690a                	ld	s2,128(sp)
    80005004:	610d                	addi	sp,sp,160
    80005006:	8082                	ret
    80005008:	64aa                	ld	s1,136(sp)
    end_op();
    8000500a:	a9ffe0ef          	jal	80003aa8 <end_op>
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	b7fd                	j	80004ffe <sys_chdir+0x5c>
    iunlockput(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	b82fe0ef          	jal	80003396 <iunlockput>
    end_op();
    80005018:	a91fe0ef          	jal	80003aa8 <end_op>
    return -1;
    8000501c:	557d                	li	a0,-1
    8000501e:	64aa                	ld	s1,136(sp)
    80005020:	bff9                	j	80004ffe <sys_chdir+0x5c>

0000000080005022 <sys_exec>:

uint64
sys_exec(void)
{
    80005022:	7105                	addi	sp,sp,-480
    80005024:	ef86                	sd	ra,472(sp)
    80005026:	eba2                	sd	s0,464(sp)
    80005028:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000502a:	e2840593          	addi	a1,s0,-472
    8000502e:	4505                	li	a0,1
    80005030:	f7afd0ef          	jal	800027aa <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005034:	08000613          	li	a2,128
    80005038:	f3040593          	addi	a1,s0,-208
    8000503c:	4501                	li	a0,0
    8000503e:	f88fd0ef          	jal	800027c6 <argstr>
    80005042:	87aa                	mv	a5,a0
    return -1;
    80005044:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005046:	0e07c063          	bltz	a5,80005126 <sys_exec+0x104>
    8000504a:	e7a6                	sd	s1,456(sp)
    8000504c:	e3ca                	sd	s2,448(sp)
    8000504e:	ff4e                	sd	s3,440(sp)
    80005050:	fb52                	sd	s4,432(sp)
    80005052:	f756                	sd	s5,424(sp)
    80005054:	f35a                	sd	s6,416(sp)
    80005056:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005058:	e3040a13          	addi	s4,s0,-464
    8000505c:	10000613          	li	a2,256
    80005060:	4581                	li	a1,0
    80005062:	8552                	mv	a0,s4
    80005064:	c6bfb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005068:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000506a:	89d2                	mv	s3,s4
    8000506c:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000506e:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005072:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005074:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005078:	00391513          	slli	a0,s2,0x3
    8000507c:	85d6                	mv	a1,s5
    8000507e:	e2843783          	ld	a5,-472(s0)
    80005082:	953e                	add	a0,a0,a5
    80005084:	e80fd0ef          	jal	80002704 <fetchaddr>
    80005088:	02054663          	bltz	a0,800050b4 <sys_exec+0x92>
    if(uarg == 0){
    8000508c:	e2043783          	ld	a5,-480(s0)
    80005090:	c7a1                	beqz	a5,800050d8 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005092:	a99fb0ef          	jal	80000b2a <kalloc>
    80005096:	85aa                	mv	a1,a0
    80005098:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000509c:	cd01                	beqz	a0,800050b4 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000509e:	865a                	mv	a2,s6
    800050a0:	e2043503          	ld	a0,-480(s0)
    800050a4:	eaafd0ef          	jal	8000274e <fetchstr>
    800050a8:	00054663          	bltz	a0,800050b4 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800050ac:	0905                	addi	s2,s2,1
    800050ae:	09a1                	addi	s3,s3,8
    800050b0:	fd7914e3          	bne	s2,s7,80005078 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050b4:	100a0a13          	addi	s4,s4,256
    800050b8:	6088                	ld	a0,0(s1)
    800050ba:	cd31                	beqz	a0,80005116 <sys_exec+0xf4>
    kfree(argv[i]);
    800050bc:	98dfb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050c0:	04a1                	addi	s1,s1,8
    800050c2:	ff449be3          	bne	s1,s4,800050b8 <sys_exec+0x96>
  return -1;
    800050c6:	557d                	li	a0,-1
    800050c8:	64be                	ld	s1,456(sp)
    800050ca:	691e                	ld	s2,448(sp)
    800050cc:	79fa                	ld	s3,440(sp)
    800050ce:	7a5a                	ld	s4,432(sp)
    800050d0:	7aba                	ld	s5,424(sp)
    800050d2:	7b1a                	ld	s6,416(sp)
    800050d4:	6bfa                	ld	s7,408(sp)
    800050d6:	a881                	j	80005126 <sys_exec+0x104>
      argv[i] = 0;
    800050d8:	0009079b          	sext.w	a5,s2
    800050dc:	e3040593          	addi	a1,s0,-464
    800050e0:	078e                	slli	a5,a5,0x3
    800050e2:	97ae                	add	a5,a5,a1
    800050e4:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    800050e8:	f3040513          	addi	a0,s0,-208
    800050ec:	ba4ff0ef          	jal	80004490 <exec>
    800050f0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050f2:	100a0a13          	addi	s4,s4,256
    800050f6:	6088                	ld	a0,0(s1)
    800050f8:	c511                	beqz	a0,80005104 <sys_exec+0xe2>
    kfree(argv[i]);
    800050fa:	94ffb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050fe:	04a1                	addi	s1,s1,8
    80005100:	ff449be3          	bne	s1,s4,800050f6 <sys_exec+0xd4>
  return ret;
    80005104:	854a                	mv	a0,s2
    80005106:	64be                	ld	s1,456(sp)
    80005108:	691e                	ld	s2,448(sp)
    8000510a:	79fa                	ld	s3,440(sp)
    8000510c:	7a5a                	ld	s4,432(sp)
    8000510e:	7aba                	ld	s5,424(sp)
    80005110:	7b1a                	ld	s6,416(sp)
    80005112:	6bfa                	ld	s7,408(sp)
    80005114:	a809                	j	80005126 <sys_exec+0x104>
  return -1;
    80005116:	557d                	li	a0,-1
    80005118:	64be                	ld	s1,456(sp)
    8000511a:	691e                	ld	s2,448(sp)
    8000511c:	79fa                	ld	s3,440(sp)
    8000511e:	7a5a                	ld	s4,432(sp)
    80005120:	7aba                	ld	s5,424(sp)
    80005122:	7b1a                	ld	s6,416(sp)
    80005124:	6bfa                	ld	s7,408(sp)
}
    80005126:	60fe                	ld	ra,472(sp)
    80005128:	645e                	ld	s0,464(sp)
    8000512a:	613d                	addi	sp,sp,480
    8000512c:	8082                	ret

000000008000512e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000512e:	7139                	addi	sp,sp,-64
    80005130:	fc06                	sd	ra,56(sp)
    80005132:	f822                	sd	s0,48(sp)
    80005134:	f426                	sd	s1,40(sp)
    80005136:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005138:	fa4fc0ef          	jal	800018dc <myproc>
    8000513c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000513e:	fd840593          	addi	a1,s0,-40
    80005142:	4501                	li	a0,0
    80005144:	e66fd0ef          	jal	800027aa <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005148:	fc840593          	addi	a1,s0,-56
    8000514c:	fd040513          	addi	a0,s0,-48
    80005150:	81eff0ef          	jal	8000416e <pipealloc>
    return -1;
    80005154:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005156:	0a054463          	bltz	a0,800051fe <sys_pipe+0xd0>
  fd0 = -1;
    8000515a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000515e:	fd043503          	ld	a0,-48(s0)
    80005162:	edeff0ef          	jal	80004840 <fdalloc>
    80005166:	fca42223          	sw	a0,-60(s0)
    8000516a:	08054163          	bltz	a0,800051ec <sys_pipe+0xbe>
    8000516e:	fc843503          	ld	a0,-56(s0)
    80005172:	eceff0ef          	jal	80004840 <fdalloc>
    80005176:	fca42023          	sw	a0,-64(s0)
    8000517a:	06054063          	bltz	a0,800051da <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000517e:	4691                	li	a3,4
    80005180:	fc440613          	addi	a2,s0,-60
    80005184:	fd843583          	ld	a1,-40(s0)
    80005188:	68a8                	ld	a0,80(s1)
    8000518a:	bfafc0ef          	jal	80001584 <copyout>
    8000518e:	00054e63          	bltz	a0,800051aa <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005192:	4691                	li	a3,4
    80005194:	fc040613          	addi	a2,s0,-64
    80005198:	fd843583          	ld	a1,-40(s0)
    8000519c:	95b6                	add	a1,a1,a3
    8000519e:	68a8                	ld	a0,80(s1)
    800051a0:	be4fc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800051a4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051a6:	04055c63          	bgez	a0,800051fe <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800051aa:	fc442783          	lw	a5,-60(s0)
    800051ae:	07e9                	addi	a5,a5,26
    800051b0:	078e                	slli	a5,a5,0x3
    800051b2:	97a6                	add	a5,a5,s1
    800051b4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800051b8:	fc042783          	lw	a5,-64(s0)
    800051bc:	07e9                	addi	a5,a5,26
    800051be:	078e                	slli	a5,a5,0x3
    800051c0:	94be                	add	s1,s1,a5
    800051c2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800051c6:	fd043503          	ld	a0,-48(s0)
    800051ca:	c95fe0ef          	jal	80003e5e <fileclose>
    fileclose(wf);
    800051ce:	fc843503          	ld	a0,-56(s0)
    800051d2:	c8dfe0ef          	jal	80003e5e <fileclose>
    return -1;
    800051d6:	57fd                	li	a5,-1
    800051d8:	a01d                	j	800051fe <sys_pipe+0xd0>
    if(fd0 >= 0)
    800051da:	fc442783          	lw	a5,-60(s0)
    800051de:	0007c763          	bltz	a5,800051ec <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800051e2:	07e9                	addi	a5,a5,26
    800051e4:	078e                	slli	a5,a5,0x3
    800051e6:	97a6                	add	a5,a5,s1
    800051e8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800051ec:	fd043503          	ld	a0,-48(s0)
    800051f0:	c6ffe0ef          	jal	80003e5e <fileclose>
    fileclose(wf);
    800051f4:	fc843503          	ld	a0,-56(s0)
    800051f8:	c67fe0ef          	jal	80003e5e <fileclose>
    return -1;
    800051fc:	57fd                	li	a5,-1
}
    800051fe:	853e                	mv	a0,a5
    80005200:	70e2                	ld	ra,56(sp)
    80005202:	7442                	ld	s0,48(sp)
    80005204:	74a2                	ld	s1,40(sp)
    80005206:	6121                	addi	sp,sp,64
    80005208:	8082                	ret
    8000520a:	0000                	unimp
    8000520c:	0000                	unimp
	...

0000000080005210 <kernelvec>:
    80005210:	7111                	addi	sp,sp,-256
    80005212:	e006                	sd	ra,0(sp)
    80005214:	e40a                	sd	sp,8(sp)
    80005216:	e80e                	sd	gp,16(sp)
    80005218:	ec12                	sd	tp,24(sp)
    8000521a:	f016                	sd	t0,32(sp)
    8000521c:	f41a                	sd	t1,40(sp)
    8000521e:	f81e                	sd	t2,48(sp)
    80005220:	e4aa                	sd	a0,72(sp)
    80005222:	e8ae                	sd	a1,80(sp)
    80005224:	ecb2                	sd	a2,88(sp)
    80005226:	f0b6                	sd	a3,96(sp)
    80005228:	f4ba                	sd	a4,104(sp)
    8000522a:	f8be                	sd	a5,112(sp)
    8000522c:	fcc2                	sd	a6,120(sp)
    8000522e:	e146                	sd	a7,128(sp)
    80005230:	edf2                	sd	t3,216(sp)
    80005232:	f1f6                	sd	t4,224(sp)
    80005234:	f5fa                	sd	t5,232(sp)
    80005236:	f9fe                	sd	t6,240(sp)
    80005238:	bdcfd0ef          	jal	80002614 <kerneltrap>
    8000523c:	6082                	ld	ra,0(sp)
    8000523e:	6122                	ld	sp,8(sp)
    80005240:	61c2                	ld	gp,16(sp)
    80005242:	7282                	ld	t0,32(sp)
    80005244:	7322                	ld	t1,40(sp)
    80005246:	73c2                	ld	t2,48(sp)
    80005248:	6526                	ld	a0,72(sp)
    8000524a:	65c6                	ld	a1,80(sp)
    8000524c:	6666                	ld	a2,88(sp)
    8000524e:	7686                	ld	a3,96(sp)
    80005250:	7726                	ld	a4,104(sp)
    80005252:	77c6                	ld	a5,112(sp)
    80005254:	7866                	ld	a6,120(sp)
    80005256:	688a                	ld	a7,128(sp)
    80005258:	6e6e                	ld	t3,216(sp)
    8000525a:	7e8e                	ld	t4,224(sp)
    8000525c:	7f2e                	ld	t5,232(sp)
    8000525e:	7fce                	ld	t6,240(sp)
    80005260:	6111                	addi	sp,sp,256
    80005262:	10200073          	sret
	...

000000008000526e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000526e:	1141                	addi	sp,sp,-16
    80005270:	e406                	sd	ra,8(sp)
    80005272:	e022                	sd	s0,0(sp)
    80005274:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005276:	0c000737          	lui	a4,0xc000
    8000527a:	4785                	li	a5,1
    8000527c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000527e:	c35c                	sw	a5,4(a4)
}
    80005280:	60a2                	ld	ra,8(sp)
    80005282:	6402                	ld	s0,0(sp)
    80005284:	0141                	addi	sp,sp,16
    80005286:	8082                	ret

0000000080005288 <plicinithart>:

void
plicinithart(void)
{
    80005288:	1141                	addi	sp,sp,-16
    8000528a:	e406                	sd	ra,8(sp)
    8000528c:	e022                	sd	s0,0(sp)
    8000528e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005290:	e18fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005294:	0085171b          	slliw	a4,a0,0x8
    80005298:	0c0027b7          	lui	a5,0xc002
    8000529c:	97ba                	add	a5,a5,a4
    8000529e:	40200713          	li	a4,1026
    800052a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800052a6:	00d5151b          	slliw	a0,a0,0xd
    800052aa:	0c2017b7          	lui	a5,0xc201
    800052ae:	97aa                	add	a5,a5,a0
    800052b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800052b4:	60a2                	ld	ra,8(sp)
    800052b6:	6402                	ld	s0,0(sp)
    800052b8:	0141                	addi	sp,sp,16
    800052ba:	8082                	ret

00000000800052bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800052bc:	1141                	addi	sp,sp,-16
    800052be:	e406                	sd	ra,8(sp)
    800052c0:	e022                	sd	s0,0(sp)
    800052c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052c4:	de4fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800052c8:	00d5151b          	slliw	a0,a0,0xd
    800052cc:	0c2017b7          	lui	a5,0xc201
    800052d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800052d2:	43c8                	lw	a0,4(a5)
    800052d4:	60a2                	ld	ra,8(sp)
    800052d6:	6402                	ld	s0,0(sp)
    800052d8:	0141                	addi	sp,sp,16
    800052da:	8082                	ret

00000000800052dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800052dc:	1101                	addi	sp,sp,-32
    800052de:	ec06                	sd	ra,24(sp)
    800052e0:	e822                	sd	s0,16(sp)
    800052e2:	e426                	sd	s1,8(sp)
    800052e4:	1000                	addi	s0,sp,32
    800052e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800052e8:	dc0fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800052ec:	00d5179b          	slliw	a5,a0,0xd
    800052f0:	0c201737          	lui	a4,0xc201
    800052f4:	97ba                	add	a5,a5,a4
    800052f6:	c3c4                	sw	s1,4(a5)
}
    800052f8:	60e2                	ld	ra,24(sp)
    800052fa:	6442                	ld	s0,16(sp)
    800052fc:	64a2                	ld	s1,8(sp)
    800052fe:	6105                	addi	sp,sp,32
    80005300:	8082                	ret

0000000080005302 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005302:	1141                	addi	sp,sp,-16
    80005304:	e406                	sd	ra,8(sp)
    80005306:	e022                	sd	s0,0(sp)
    80005308:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000530a:	479d                	li	a5,7
    8000530c:	04a7ca63          	blt	a5,a0,80005360 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005310:	0001b797          	auipc	a5,0x1b
    80005314:	7f078793          	addi	a5,a5,2032 # 80020b00 <disk>
    80005318:	97aa                	add	a5,a5,a0
    8000531a:	0187c783          	lbu	a5,24(a5)
    8000531e:	e7b9                	bnez	a5,8000536c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005320:	00451693          	slli	a3,a0,0x4
    80005324:	0001b797          	auipc	a5,0x1b
    80005328:	7dc78793          	addi	a5,a5,2012 # 80020b00 <disk>
    8000532c:	6398                	ld	a4,0(a5)
    8000532e:	9736                	add	a4,a4,a3
    80005330:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005334:	6398                	ld	a4,0(a5)
    80005336:	9736                	add	a4,a4,a3
    80005338:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000533c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005340:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005344:	97aa                	add	a5,a5,a0
    80005346:	4705                	li	a4,1
    80005348:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000534c:	0001b517          	auipc	a0,0x1b
    80005350:	7cc50513          	addi	a0,a0,1996 # 80020b18 <disk+0x18>
    80005354:	ba3fc0ef          	jal	80001ef6 <wakeup>
}
    80005358:	60a2                	ld	ra,8(sp)
    8000535a:	6402                	ld	s0,0(sp)
    8000535c:	0141                	addi	sp,sp,16
    8000535e:	8082                	ret
    panic("free_desc 1");
    80005360:	00002517          	auipc	a0,0x2
    80005364:	31050513          	addi	a0,a0,784 # 80007670 <etext+0x670>
    80005368:	c36fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    8000536c:	00002517          	auipc	a0,0x2
    80005370:	31450513          	addi	a0,a0,788 # 80007680 <etext+0x680>
    80005374:	c2afb0ef          	jal	8000079e <panic>

0000000080005378 <virtio_disk_init>:
{
    80005378:	1101                	addi	sp,sp,-32
    8000537a:	ec06                	sd	ra,24(sp)
    8000537c:	e822                	sd	s0,16(sp)
    8000537e:	e426                	sd	s1,8(sp)
    80005380:	e04a                	sd	s2,0(sp)
    80005382:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005384:	00002597          	auipc	a1,0x2
    80005388:	30c58593          	addi	a1,a1,780 # 80007690 <etext+0x690>
    8000538c:	0001c517          	auipc	a0,0x1c
    80005390:	89c50513          	addi	a0,a0,-1892 # 80020c28 <disk+0x128>
    80005394:	fe6fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005398:	100017b7          	lui	a5,0x10001
    8000539c:	4398                	lw	a4,0(a5)
    8000539e:	2701                	sext.w	a4,a4
    800053a0:	747277b7          	lui	a5,0x74727
    800053a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800053a8:	14f71863          	bne	a4,a5,800054f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053ac:	100017b7          	lui	a5,0x10001
    800053b0:	43dc                	lw	a5,4(a5)
    800053b2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053b4:	4709                	li	a4,2
    800053b6:	14e79163          	bne	a5,a4,800054f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ba:	100017b7          	lui	a5,0x10001
    800053be:	479c                	lw	a5,8(a5)
    800053c0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053c2:	12e79b63          	bne	a5,a4,800054f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053c6:	100017b7          	lui	a5,0x10001
    800053ca:	47d8                	lw	a4,12(a5)
    800053cc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ce:	554d47b7          	lui	a5,0x554d4
    800053d2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053d6:	12f71163          	bne	a4,a5,800054f8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053da:	100017b7          	lui	a5,0x10001
    800053de:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053e2:	4705                	li	a4,1
    800053e4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053e6:	470d                	li	a4,3
    800053e8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800053ea:	10001737          	lui	a4,0x10001
    800053ee:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800053f0:	c7ffe6b7          	lui	a3,0xc7ffe
    800053f4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb1f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800053f8:	8f75                	and	a4,a4,a3
    800053fa:	100016b7          	lui	a3,0x10001
    800053fe:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005400:	472d                	li	a4,11
    80005402:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005404:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005408:	439c                	lw	a5,0(a5)
    8000540a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000540e:	8ba1                	andi	a5,a5,8
    80005410:	0e078a63          	beqz	a5,80005504 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005414:	100017b7          	lui	a5,0x10001
    80005418:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000541c:	43fc                	lw	a5,68(a5)
    8000541e:	2781                	sext.w	a5,a5
    80005420:	0e079863          	bnez	a5,80005510 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005424:	100017b7          	lui	a5,0x10001
    80005428:	5bdc                	lw	a5,52(a5)
    8000542a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000542c:	0e078863          	beqz	a5,8000551c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005430:	471d                	li	a4,7
    80005432:	0ef77b63          	bgeu	a4,a5,80005528 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005436:	ef4fb0ef          	jal	80000b2a <kalloc>
    8000543a:	0001b497          	auipc	s1,0x1b
    8000543e:	6c648493          	addi	s1,s1,1734 # 80020b00 <disk>
    80005442:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005444:	ee6fb0ef          	jal	80000b2a <kalloc>
    80005448:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000544a:	ee0fb0ef          	jal	80000b2a <kalloc>
    8000544e:	87aa                	mv	a5,a0
    80005450:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005452:	6088                	ld	a0,0(s1)
    80005454:	0e050063          	beqz	a0,80005534 <virtio_disk_init+0x1bc>
    80005458:	0001b717          	auipc	a4,0x1b
    8000545c:	6b073703          	ld	a4,1712(a4) # 80020b08 <disk+0x8>
    80005460:	cb71                	beqz	a4,80005534 <virtio_disk_init+0x1bc>
    80005462:	cbe9                	beqz	a5,80005534 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005464:	6605                	lui	a2,0x1
    80005466:	4581                	li	a1,0
    80005468:	867fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    8000546c:	0001b497          	auipc	s1,0x1b
    80005470:	69448493          	addi	s1,s1,1684 # 80020b00 <disk>
    80005474:	6605                	lui	a2,0x1
    80005476:	4581                	li	a1,0
    80005478:	6488                	ld	a0,8(s1)
    8000547a:	855fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    8000547e:	6605                	lui	a2,0x1
    80005480:	4581                	li	a1,0
    80005482:	6888                	ld	a0,16(s1)
    80005484:	84bfb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005488:	100017b7          	lui	a5,0x10001
    8000548c:	4721                	li	a4,8
    8000548e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005490:	4098                	lw	a4,0(s1)
    80005492:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005496:	40d8                	lw	a4,4(s1)
    80005498:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000549c:	649c                	ld	a5,8(s1)
    8000549e:	0007869b          	sext.w	a3,a5
    800054a2:	10001737          	lui	a4,0x10001
    800054a6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800054aa:	9781                	srai	a5,a5,0x20
    800054ac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800054b0:	689c                	ld	a5,16(s1)
    800054b2:	0007869b          	sext.w	a3,a5
    800054b6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800054ba:	9781                	srai	a5,a5,0x20
    800054bc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800054c0:	4785                	li	a5,1
    800054c2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800054c4:	00f48c23          	sb	a5,24(s1)
    800054c8:	00f48ca3          	sb	a5,25(s1)
    800054cc:	00f48d23          	sb	a5,26(s1)
    800054d0:	00f48da3          	sb	a5,27(s1)
    800054d4:	00f48e23          	sb	a5,28(s1)
    800054d8:	00f48ea3          	sb	a5,29(s1)
    800054dc:	00f48f23          	sb	a5,30(s1)
    800054e0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800054e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800054e8:	07272823          	sw	s2,112(a4)
}
    800054ec:	60e2                	ld	ra,24(sp)
    800054ee:	6442                	ld	s0,16(sp)
    800054f0:	64a2                	ld	s1,8(sp)
    800054f2:	6902                	ld	s2,0(sp)
    800054f4:	6105                	addi	sp,sp,32
    800054f6:	8082                	ret
    panic("could not find virtio disk");
    800054f8:	00002517          	auipc	a0,0x2
    800054fc:	1a850513          	addi	a0,a0,424 # 800076a0 <etext+0x6a0>
    80005500:	a9efb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005504:	00002517          	auipc	a0,0x2
    80005508:	1bc50513          	addi	a0,a0,444 # 800076c0 <etext+0x6c0>
    8000550c:	a92fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005510:	00002517          	auipc	a0,0x2
    80005514:	1d050513          	addi	a0,a0,464 # 800076e0 <etext+0x6e0>
    80005518:	a86fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    8000551c:	00002517          	auipc	a0,0x2
    80005520:	1e450513          	addi	a0,a0,484 # 80007700 <etext+0x700>
    80005524:	a7afb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005528:	00002517          	auipc	a0,0x2
    8000552c:	1f850513          	addi	a0,a0,504 # 80007720 <etext+0x720>
    80005530:	a6efb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    80005534:	00002517          	auipc	a0,0x2
    80005538:	20c50513          	addi	a0,a0,524 # 80007740 <etext+0x740>
    8000553c:	a62fb0ef          	jal	8000079e <panic>

0000000080005540 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005540:	711d                	addi	sp,sp,-96
    80005542:	ec86                	sd	ra,88(sp)
    80005544:	e8a2                	sd	s0,80(sp)
    80005546:	e4a6                	sd	s1,72(sp)
    80005548:	e0ca                	sd	s2,64(sp)
    8000554a:	fc4e                	sd	s3,56(sp)
    8000554c:	f852                	sd	s4,48(sp)
    8000554e:	f456                	sd	s5,40(sp)
    80005550:	f05a                	sd	s6,32(sp)
    80005552:	ec5e                	sd	s7,24(sp)
    80005554:	e862                	sd	s8,16(sp)
    80005556:	1080                	addi	s0,sp,96
    80005558:	89aa                	mv	s3,a0
    8000555a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000555c:	00c52b83          	lw	s7,12(a0)
    80005560:	001b9b9b          	slliw	s7,s7,0x1
    80005564:	1b82                	slli	s7,s7,0x20
    80005566:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000556a:	0001b517          	auipc	a0,0x1b
    8000556e:	6be50513          	addi	a0,a0,1726 # 80020c28 <disk+0x128>
    80005572:	e8cfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    80005576:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005578:	0001ba97          	auipc	s5,0x1b
    8000557c:	588a8a93          	addi	s5,s5,1416 # 80020b00 <disk>
  for(int i = 0; i < 3; i++){
    80005580:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005582:	5c7d                	li	s8,-1
    80005584:	a095                	j	800055e8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005586:	00fa8733          	add	a4,s5,a5
    8000558a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000558e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005590:	0207c563          	bltz	a5,800055ba <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005594:	2905                	addiw	s2,s2,1
    80005596:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005598:	05490c63          	beq	s2,s4,800055f0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000559c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000559e:	0001b717          	auipc	a4,0x1b
    800055a2:	56270713          	addi	a4,a4,1378 # 80020b00 <disk>
    800055a6:	4781                	li	a5,0
    if(disk.free[i]){
    800055a8:	01874683          	lbu	a3,24(a4)
    800055ac:	fee9                	bnez	a3,80005586 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800055ae:	2785                	addiw	a5,a5,1
    800055b0:	0705                	addi	a4,a4,1
    800055b2:	fe979be3          	bne	a5,s1,800055a8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800055b6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800055ba:	01205d63          	blez	s2,800055d4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800055be:	fa042503          	lw	a0,-96(s0)
    800055c2:	d41ff0ef          	jal	80005302 <free_desc>
      for(int j = 0; j < i; j++)
    800055c6:	4785                	li	a5,1
    800055c8:	0127d663          	bge	a5,s2,800055d4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800055cc:	fa442503          	lw	a0,-92(s0)
    800055d0:	d33ff0ef          	jal	80005302 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800055d4:	0001b597          	auipc	a1,0x1b
    800055d8:	65458593          	addi	a1,a1,1620 # 80020c28 <disk+0x128>
    800055dc:	0001b517          	auipc	a0,0x1b
    800055e0:	53c50513          	addi	a0,a0,1340 # 80020b18 <disk+0x18>
    800055e4:	8c7fc0ef          	jal	80001eaa <sleep>
  for(int i = 0; i < 3; i++){
    800055e8:	fa040613          	addi	a2,s0,-96
    800055ec:	4901                	li	s2,0
    800055ee:	b77d                	j	8000559c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800055f0:	fa042503          	lw	a0,-96(s0)
    800055f4:	00451693          	slli	a3,a0,0x4

  if(write)
    800055f8:	0001b797          	auipc	a5,0x1b
    800055fc:	50878793          	addi	a5,a5,1288 # 80020b00 <disk>
    80005600:	00a50713          	addi	a4,a0,10
    80005604:	0712                	slli	a4,a4,0x4
    80005606:	973e                	add	a4,a4,a5
    80005608:	01603633          	snez	a2,s6
    8000560c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000560e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005612:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005616:	6398                	ld	a4,0(a5)
    80005618:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000561a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000561e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005620:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005622:	6390                	ld	a2,0(a5)
    80005624:	00d605b3          	add	a1,a2,a3
    80005628:	4741                	li	a4,16
    8000562a:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000562c:	4805                	li	a6,1
    8000562e:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005632:	fa442703          	lw	a4,-92(s0)
    80005636:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000563a:	0712                	slli	a4,a4,0x4
    8000563c:	963a                	add	a2,a2,a4
    8000563e:	05898593          	addi	a1,s3,88
    80005642:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005644:	0007b883          	ld	a7,0(a5)
    80005648:	9746                	add	a4,a4,a7
    8000564a:	40000613          	li	a2,1024
    8000564e:	c710                	sw	a2,8(a4)
  if(write)
    80005650:	001b3613          	seqz	a2,s6
    80005654:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005658:	01066633          	or	a2,a2,a6
    8000565c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005660:	fa842583          	lw	a1,-88(s0)
    80005664:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005668:	00250613          	addi	a2,a0,2
    8000566c:	0612                	slli	a2,a2,0x4
    8000566e:	963e                	add	a2,a2,a5
    80005670:	577d                	li	a4,-1
    80005672:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005676:	0592                	slli	a1,a1,0x4
    80005678:	98ae                	add	a7,a7,a1
    8000567a:	03068713          	addi	a4,a3,48
    8000567e:	973e                	add	a4,a4,a5
    80005680:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005684:	6398                	ld	a4,0(a5)
    80005686:	972e                	add	a4,a4,a1
    80005688:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000568c:	4689                	li	a3,2
    8000568e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005692:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005696:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    8000569a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000569e:	6794                	ld	a3,8(a5)
    800056a0:	0026d703          	lhu	a4,2(a3)
    800056a4:	8b1d                	andi	a4,a4,7
    800056a6:	0706                	slli	a4,a4,0x1
    800056a8:	96ba                	add	a3,a3,a4
    800056aa:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800056ae:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800056b2:	6798                	ld	a4,8(a5)
    800056b4:	00275783          	lhu	a5,2(a4)
    800056b8:	2785                	addiw	a5,a5,1
    800056ba:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800056be:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800056c2:	100017b7          	lui	a5,0x10001
    800056c6:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800056ca:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    800056ce:	0001b917          	auipc	s2,0x1b
    800056d2:	55a90913          	addi	s2,s2,1370 # 80020c28 <disk+0x128>
  while(b->disk == 1) {
    800056d6:	84c2                	mv	s1,a6
    800056d8:	01079a63          	bne	a5,a6,800056ec <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    800056dc:	85ca                	mv	a1,s2
    800056de:	854e                	mv	a0,s3
    800056e0:	fcafc0ef          	jal	80001eaa <sleep>
  while(b->disk == 1) {
    800056e4:	0049a783          	lw	a5,4(s3)
    800056e8:	fe978ae3          	beq	a5,s1,800056dc <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    800056ec:	fa042903          	lw	s2,-96(s0)
    800056f0:	00290713          	addi	a4,s2,2
    800056f4:	0712                	slli	a4,a4,0x4
    800056f6:	0001b797          	auipc	a5,0x1b
    800056fa:	40a78793          	addi	a5,a5,1034 # 80020b00 <disk>
    800056fe:	97ba                	add	a5,a5,a4
    80005700:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005704:	0001b997          	auipc	s3,0x1b
    80005708:	3fc98993          	addi	s3,s3,1020 # 80020b00 <disk>
    8000570c:	00491713          	slli	a4,s2,0x4
    80005710:	0009b783          	ld	a5,0(s3)
    80005714:	97ba                	add	a5,a5,a4
    80005716:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000571a:	854a                	mv	a0,s2
    8000571c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005720:	be3ff0ef          	jal	80005302 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005724:	8885                	andi	s1,s1,1
    80005726:	f0fd                	bnez	s1,8000570c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005728:	0001b517          	auipc	a0,0x1b
    8000572c:	50050513          	addi	a0,a0,1280 # 80020c28 <disk+0x128>
    80005730:	d62fb0ef          	jal	80000c92 <release>
}
    80005734:	60e6                	ld	ra,88(sp)
    80005736:	6446                	ld	s0,80(sp)
    80005738:	64a6                	ld	s1,72(sp)
    8000573a:	6906                	ld	s2,64(sp)
    8000573c:	79e2                	ld	s3,56(sp)
    8000573e:	7a42                	ld	s4,48(sp)
    80005740:	7aa2                	ld	s5,40(sp)
    80005742:	7b02                	ld	s6,32(sp)
    80005744:	6be2                	ld	s7,24(sp)
    80005746:	6c42                	ld	s8,16(sp)
    80005748:	6125                	addi	sp,sp,96
    8000574a:	8082                	ret

000000008000574c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000574c:	1101                	addi	sp,sp,-32
    8000574e:	ec06                	sd	ra,24(sp)
    80005750:	e822                	sd	s0,16(sp)
    80005752:	e426                	sd	s1,8(sp)
    80005754:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005756:	0001b497          	auipc	s1,0x1b
    8000575a:	3aa48493          	addi	s1,s1,938 # 80020b00 <disk>
    8000575e:	0001b517          	auipc	a0,0x1b
    80005762:	4ca50513          	addi	a0,a0,1226 # 80020c28 <disk+0x128>
    80005766:	c98fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000576a:	100017b7          	lui	a5,0x10001
    8000576e:	53bc                	lw	a5,96(a5)
    80005770:	8b8d                	andi	a5,a5,3
    80005772:	10001737          	lui	a4,0x10001
    80005776:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005778:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000577c:	689c                	ld	a5,16(s1)
    8000577e:	0204d703          	lhu	a4,32(s1)
    80005782:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005786:	04f70663          	beq	a4,a5,800057d2 <virtio_disk_intr+0x86>
    __sync_synchronize();
    8000578a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000578e:	6898                	ld	a4,16(s1)
    80005790:	0204d783          	lhu	a5,32(s1)
    80005794:	8b9d                	andi	a5,a5,7
    80005796:	078e                	slli	a5,a5,0x3
    80005798:	97ba                	add	a5,a5,a4
    8000579a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000579c:	00278713          	addi	a4,a5,2
    800057a0:	0712                	slli	a4,a4,0x4
    800057a2:	9726                	add	a4,a4,s1
    800057a4:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800057a8:	e321                	bnez	a4,800057e8 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800057aa:	0789                	addi	a5,a5,2
    800057ac:	0792                	slli	a5,a5,0x4
    800057ae:	97a6                	add	a5,a5,s1
    800057b0:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800057b2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800057b6:	f40fc0ef          	jal	80001ef6 <wakeup>

    disk.used_idx += 1;
    800057ba:	0204d783          	lhu	a5,32(s1)
    800057be:	2785                	addiw	a5,a5,1
    800057c0:	17c2                	slli	a5,a5,0x30
    800057c2:	93c1                	srli	a5,a5,0x30
    800057c4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800057c8:	6898                	ld	a4,16(s1)
    800057ca:	00275703          	lhu	a4,2(a4)
    800057ce:	faf71ee3          	bne	a4,a5,8000578a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800057d2:	0001b517          	auipc	a0,0x1b
    800057d6:	45650513          	addi	a0,a0,1110 # 80020c28 <disk+0x128>
    800057da:	cb8fb0ef          	jal	80000c92 <release>
}
    800057de:	60e2                	ld	ra,24(sp)
    800057e0:	6442                	ld	s0,16(sp)
    800057e2:	64a2                	ld	s1,8(sp)
    800057e4:	6105                	addi	sp,sp,32
    800057e6:	8082                	ret
      panic("virtio_disk_intr status");
    800057e8:	00002517          	auipc	a0,0x2
    800057ec:	f7050513          	addi	a0,a0,-144 # 80007758 <etext+0x758>
    800057f0:	faffa0ef          	jal	8000079e <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
