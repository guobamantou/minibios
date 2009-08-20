#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/addrspace.h>
#include <uart.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#endif

#ifdef CONFIG_LOONGSON2F 
#include <loongson/loongson2f/uart.h>
#endif

#define OFFSET t9  /* t9 should not be used for other purpose */

#define PRINTF(str) \
	.rdata ;\
2009: ;\
	.asciz str ;\
	.text ;\
	la	a0, 2009b ;\
	bal	uart_puts ;\
	nop



/************************   start here  ************************/

	.set	noreorder
	.set 	mips3
	.globl	_start	
//stack = 0x90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	dli		s0, STATUS_BEV
	mtc0	s0, CP0_STATUS
//	dli		sp, stack
	
	bal	locate
	nop
/*************** I conside *******************/
locate:
	la	s0, _start
	subu	OFFSET, ra, s0
	lui	s1, 0xffff
	and	OFFSET, s1    ### now OFFSET is offset of PHYADDR and VIRTUREADDR in the eye of cpu
	
	bal	init_uart
	nop
	li	a0,'U'
	bal	uart_putc
	nop

	li 	s0, 15	
1:
	add a0, OFFSET,zero
	bal	uart_put_hex
	nop
	PRINTF("rom?")

	li	a0,'\r'
	bal	uart_putc
	nop
	li	a0,'\n'
	bal	uart_putc
	nop

	addi s0, s0, -1
	bne s0, zero,1b
	nop

2:
	li a0, 1
	bnez a0, 2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include "uart.S"
