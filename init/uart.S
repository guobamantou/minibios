/********  use t0, t1, t2 ,t3 ra ********/

init_uart:
	li	t0, PHY_TO_UNCACHED(UART_ADDR)

	/* set fifo mode */
	li	t1, UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR |\
			 UART_FCR_CLEAR_XMIT | UART_FCR_R_TRIG_00
	sb	t1, UART_FCR(t0)

	/* set baud rate */
	li	t2, UART_LCR_DLAB  // enable set band rate
	sb	t2, UART_LCR(t0)
	li	t3, UART_BAUD / (16 * B115200)
	sb	t3, UART_DLL(t0)
	srl	t3, 8
	sb	t3, UART_DLH(t0)

	/* set transmit format */
	li	t1, UART_LCR_WLEN8
	sb	t1, UART_LCR(t0)	

	/* set modem mode */
	li	t2, UART_MCR_RTS | UART_MCR_DTR
	sb	t2, UART_MCR(t0)
	
	/* disable all intrrupt */
	j 	ra
	sb	zero, UART_IER(t0)


/************************************************************/
/********** use t0-t3, a0 ra **********/

uart_putc: 
	li	t0, PHY_TO_UNCACHED(UART_ADDR)	
	
	li	t1, 1000  /* try for 1000 times, this times is not strictly test*/
retry:
	beq	t1, zero,11f 
	nop
	lbu	t2, UART_LSR(t0)
	and	t2, UART_LSR_THRE
	beq	t2, zero, retry
	addi	t1, t1, -1

	/* can transmit now */	
	sb	a0, UART_TX(t0)
11:
	jr	ra
	nop


/************************************************************/
/************ input parameter a0, 32bit used ****************/
/************************************************************/
/******** use a0-a3, v0-v1, ra, t8 **********************/
uart_put_hex:
### store ra first ,because uart_put_hex will call uart_putc
	add	a3, ra, zero  
	add	a1, a0, zero
	la	v0, hexchar
	addu	v0, v0, OFFSET
	lui	v1, 0xf000	
	li	a2, 8

next_hex:
	and	a0, a1, v1
	srl	a0, 28
	addu	t8, a0, v0
	lb	a0, 0(t8)
	bal	uart_putc
	nop
	addi	a2, -1
	bnez	a2, next_hex
	sll	a1, 4

	j	a3
	nop
hexchar:
	.ascii "0123456789ABCDEF"


/************************************************************/
/******************** output a string ***********************/
/************************************************************/
/**** a0, a3, ra, t8, use t0-t3 in uart_putc ******/
uart_puts:
	add	a3, ra, zero
	addu 	t8, a0, OFFSET
	lbu	a0, 0(t8)

next_char:
	beq	a0, zero, 11f 
	nop
	bal	uart_putc
	addiu	t8, 1
	b	next_char
	lbu	a0, 0(t8)
11:
	j	a3
	nop
