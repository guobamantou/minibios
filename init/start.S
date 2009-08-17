#include <autoconf.h>
#include <loongson/regdef.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#endif

#ifdef CONFIG_LOONGSON2F 
#include <loongson/loongson2f/uart.h>
#endif



	.set	noreorder
	.set 	mips3
	.globl	_start	
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	li		t0, STATUS_BEV
	mtc0	t0, CP0_STATUS

	
	bal		init_uart
	nop

	
	li	t0, 'a'
	dli	t1, UART_ADDR | 0xffffffffa0000000
1:	sb	t0, 0(t1)
	j	1b 
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include <uart.h>
#define CONS_BAUD B115200

/******* no input and output parameters ********/
init_uart:
	dli	t0, UART_ADDR | 0xffffffffa0000000

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
	sb	zero, UART_IER(t0)
	jr 	ra
	nop
end_of_init_uart:


uart_tx_byte:
