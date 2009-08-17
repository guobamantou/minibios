#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/addrspace.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#endif

#ifdef CONFIG_LOONGSON2F 
#include <loongson/loongson2f/uart.h>
#endif

	.set	noreorder
	.set 	mips3
	.globl	_start	
//stack = 0x90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	li		t0, STATUS_BEV
	mtc0	t0, CP0_STATUS
//	dli		sp, stack
	
	bal		init_uart
	nop

	li 	s0, 20	
1:	li	a0, 'a'
	bal	uart_tx_byte	
	nop

	bal hello	
	nop
	lui	s2, 0xa000
	lb	a0,0(s2)
	bal	uart_tx_byte	
	nop
	lb	a0,1(s2)
	bal	uart_tx_byte	
	nop
	lb	a0,2(s2)
	bal	uart_tx_byte	
	nop
	lb	a0,3(s2)
	bal	uart_tx_byte	
	nop

	li	a0, '\r'
	bal	uart_tx_byte	
	nop
	li	a0, '\n'
	bal	uart_tx_byte	
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

#include <uart.h>
#define CONS_BAUD B115200

/*************************************************************/
/****** uart initialize, no input and output parameters ******/
/*************************************************************/

init_uart:
	dli	t0, PHY_TO_UNCACHED(UART_ADDR)

/****** set fifo mode *******/

	li	t1, UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR |\
			 UART_FCR_CLEAR_XMIT | UART_FCR_R_TRIG_00
	sb	t1, UART_FCR(t0)

/****** set boun rate ******/

	li	t2, UART_LCR_DLAB
	sb	t2, UART_LCR(t0)
	li	t3, UART_BAUD / (16 * CONS_BAUD)
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




/*************************************************************/
/************    uart byte transmit procedure    *************/
/************ input param: a0  return param :v0  *************/
/************     return value 0:OK 1:ERROR      *************/
/*************************************************************/
uart_tx_byte:
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
endof_uart_tx_byte:
