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
	li		s0, STATUS_BEV
	mtc0	s0, CP0_STATUS
//	dli		sp, stack
	
	bal	locate
	nop
/*************** I conside *******************/
locate:
	la	s0, _start
	subu	OFFSET, ra, s0
	and	OFFSET, 0xffff0000    ### now OFFSET is offset of PHYADDR and VIRTUREADDR in the eye of cpu
	
	bal	init_uart
	nop

	li 	s0, 30	
1:
	move a0, OFFSET
	bal	uart_put_hex
	nop
	PRINTF("ni meng hao ma?")

	li	a0,'\r'
	bal	uart_putc
	nop
	li	a0,'\n'
	bal	uart_putc
	nop
#if 1
	addi s0, s0, -1
	bne s0, zero,1b
	nop
#endif
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
/********  use t0, t1, t2 ,t3 ra ********/

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
/********** use t0-t3, a0 ra **********/

uart_putc: 
	dli	t0,	PHY_TO_UNCACHED(UART_ADDR)	
	
	li	t1, 1000  /* try for 1000 times, this times is not strictly test*/
retry:
	addi	t1, t1, -1
	beq	t1, zero,11f 
	nop
	lbu	t2, UART_LSR(t0)
	and	t2, UART_LSR_THRE
	beq	t2, zero, retry
	nop
/******  can transmit now  *******/	
	sb	a0, UART_TX(t0)
11:
	jr	ra
	nop
endof_uart_putc:


/************************************************************/
/************ input parameter a0, 32bit used ****************/
/************************************************************/
/******** use a0-a3, v0-v1, ra, t8 **********************/
uart_put_hex:
### store ra first ,because this procedure will call another procedure
	move	a3, ra  
	move	a1, a0
	la	v0, hexchar
	addu v0, v0, OFFSET
	lui v1, 0xf000	
	li	a2, 8

next_hex:
	and	a0, a1, v1
	srl	a0, 28
	addu t8, a0, v0
	lb	a0, 0(t8)
	bal uart_putc
	nop
	sll	a1, 4
	addi a2, -1
	bnez a2, next_hex
	nop
	j a3
	nop
endof_uart_put_hex:
hexchar:
	.ascii "0123456789ABCDEF"


/************************************************************/
/******************** output a string ***********************/
/************************************************************/
/************************************************************/
uart_puts:
	move	a3, ra
	addu 	t8, a0, OFFSET
	lbu	a0, 0(t8)

next_char:
	beqz a0, 11f 
	nop
	bal	uart_putc
	addiu t8, 1
	b next_char
	lbu	a0, 0(t8)
11:
	j	a3
	nop
endof_uart_puts:
