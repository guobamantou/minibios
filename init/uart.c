#include <types.h>
#include <uart.h>
#include <loongson/loongson2f/uart.h>
#include <loongson/addrspace.h>

#define CONS_BAUD B115200
u8* UART_BASE = PHY_TO_UNCACHED(UART_ADDR);

void uart_out(u32 port, u8 c)
{
	*(char *)(UART_BASE + port) = c;
}

u8 uart_in(u32 port)
{
	return *(char *)(UART_BASE + port);
}

void init_uart()
{
	uart_out(UART_FCR, UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR | UART_FCR_CLEAR_XMIT | UART_FCR_R_TRIG_00);
	uart_out(UART_LCR, UART_LCR_DLAB);
	uart_out(UART_DLL, UART_BAUD / (16 * CONS_BAUD));
	uart_out(UART_DLH, UART_BAUD / (16 * CONS_BAUD) >> 8);
	uart_out(UART_LCR, UART_LCR_WLEN8);
	uart_out(UART_MCR, UART_MCR_RTS | UART_MCR_DTR);
	uart_out(UART_IER, 0);
}

void putc_hex(u32 val)
{
	int i;
	unsigned char buf[9];

	for(i = 7; i >= 0; i--) {
		buf[i] = "0123456789ABCDEF"[val & 0x0F];
		val >>= 4;
	}
	buf[8] = '\0';
	puts(buf);
}

void putc(u8 c)
{
	int i, timeout = 1000;

	while(timeout-- > 0) {
		if (uart_in(UART_LSR) & UART_LSR_THRE) {
			uart_out(UART_TX, c);
			break;
		}
	}
}

void puts(const char * str)
{
	char c;

	while((c = *str++) != '\0'){
		putc(c);
		if(c == '\n')
			putc('\r');
	}
}
#if 0

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


/*************************************************************/
/****** uart initialize, no input and output parameters ******/
/*************************************************************/

init_uart:
	dli	t0, PHY_TO_UNCACHED(UART_ADDR)

/****** set fifo mode *******/

	li	t1, UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR |\
			 UART_FCR_CLEAR_XMIT | UART_FCR_R_TRIG_00
	sb	t1, UART_FCR(t0)

/****** set baud rate ******/

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

#endif
