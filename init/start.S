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
/*
#define PRINTSTR(str) \
	.rdata ;\
2009: ;\
	.asciz str ;\
	.text ;\
	la	a0, 2009b ;\
	bal	puts ;\
	nop
*/


/************************   start here  ************************/

	.set	noreorder
	.set 	mips3
	.globl	_start	
//stack = 0x90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	li		s0, STATUS_BEV
	mtc0	s0, CP0_STATUS
//	dli		sp, stack
	
	bal		init_uart
	nop

	li 	s0, 10	
1:
	li a0, 'A'
	bal uart_putc
	nop

	addi s0, s0, -1
	bne s0, zero,1b
	nop

2:
	j 2b
	nop

#if 0
/*********************************************************************/
/*******************  EXCEPTIONS HANDLE ENTRY  ***********************/
/*********************************************************************/

/*
 *  Reboot vector  ,entry addr 0xbfc00000
 */
	.align 8   
ext_reboot:
//	bal	CPU_TLBClear
	PRINTSTR("reboot here\n")
	nop
	li	a0, 0xc0000000

/*
 *   entry addr 0xbfc0200
 */
	.align 9
ext_tlb_refill:
	PRINTSTR("tlb refill\n")

/*
 *   entry addr 0xbfc0300
 */
	.align 8
just_for_padding:	
	PRINTSTR("into bfc00300, thie should not happen!\n")
/*
 *   entry addr 0xbfc0380
 */
	.align 7
exc_others:

#endif

/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include <loongson/loongson2f/uart.h>
init_uart:
	dli	t0, PHY_TO_UNCACHED(UART_ADDR)

/****** set fifo mode *******/

	li	t1, UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR |\
			 UART_FCR_CLEAR_XMIT | UART_FCR_R_TRIG_00
	sb	t1, UART_FCR(t0)

/****** set baud rate ******/

	li	t2, UART_LCR_DLAB
	sb	t2, UART_LCR(t0)
	li	t3, UART_BAUD / (16 * B115200)
	sb	t3, UART_DLL(t0)
	srl t3, 8
	sb	t3, UART_DLH(t0)

/****** set transmit format ******/
	li	t1, UART_LCR_WLEN8
	sb	t1, UART_LCR(t0)	

/******* set modem mode ******/
	li  t2, UART_MCR_RTS | UART_MCR_DTR
	sb	t2, UART_MCR(t0)
	
/******* disable all intrrupt ******/
	j 	ra
	sb	zero, UART_IER(t0)
endof_init_uart:


/************************************************************/
uart_putc:
	dli	t0,	PHY_TO_UNCACHED(UART_ADDR)	
	
	li	v0, 1
	li	t1, 1000  /* try for 1000 times, this times is not strictly test*/
retry:
	addi	t1, t1, -1
	beq	t1, zero, return
	nop
	lbu	t2, UART_LSR(t0)
	and	t2, UART_LSR_THRE
	beq	t2, zero, retry
	nop
/******  can transmit now  *******/	
	li	v0, 0
	sb	a0, UART_TX(t0)
return:
	jr	ra
	nop
endof_uart_putc:


/************************************************************/
/************ input parameter a0, 32bit used ****************/
/************************************************************/
#if 0
uart_put_hex:
	move	a2, ra
	move	a1, a0
	
next_hex:
	and	a0, 

#endif



