#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/addrspace.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#endif

#ifdef CONFIG_LOONGSON2F 
#include <loongson/loongson2f/uart.h>
#endif

#define PRINTSTR(str) \
	.rdata ;\
string: ;\
	.asciz str ;\
	.text ;\
	la	a0, string ;\
	bal	puts ;\
	nop

	.set	noreorder
	.set 	mips3
	.globl	_start	
stack = 0x90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	li		t0, STATUS_BEV
	mtc0	t0, CP0_STATUS
	dli		sp, stack
	
	bal		init_uart
	nop

	li 	s0, 20	
1:	PRINTSTR("\nHello, World!      ")
	nop
	dli a0, 0x12345678
	bal putc_hex
	nop
	dli a0, 0xFEDCBA98
	bal putc_hex
	nop
	addi s0, s0, -1
	bne s0, zero,1b
	nop

2:
	j 2b
	nop

	

/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/


