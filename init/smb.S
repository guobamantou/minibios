/************* init smbus ***********************/
/*** use t5, a0, v0, v1 ,ra,***/
init_smb:
	/* disable smb and set freq */
	li	a0, (((SMB_FREQ & 0x7f) << 1) | SMB_DISABLE) 
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL2);
	li	a0, ((SMB_FREQ & 0x7f80) >> 7)
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL3);

	li	a0, 0x00
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	
	/* disable slave mode */
	li	a0, 0x00
	IO_OUTB(SMB_BASE_ADDR | SMB_ADDR);

	/* clear all error status */
	li	a0, 0xff
	IO_OUTB(SMB_BASE_ADDR | SMB_STS);

	/* clear bus busy bit */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL_STS);
	ori	a0, v0, SMB_BUS_BUSY
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL_STS);
	
	/* enable smb now */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL2);
	ori	a0, v0, SMB_ENABLE
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL2);

	j	ra
	nop
	
/*
 * a0: slave addr
 * a1: index
 * v0: return val
 * follow "random read" sequence description in cs5536 manual
 * use a0, a1, v0, t5, t6, t7, use v1 in io_INB, use t0-t3 v0 in smb_wait
 */
smb_read:
	andi	t5, a0, 0xfe
	add	t6, a1, zero
	add	t7, ra, zero		# store return addr

	/* start */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL1);
	ori	a0, v0, SMB_START
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	bal	smb_wait
	nop
	bnez	v0, error
	nop

	/* send slave addr */
	add	a0, t5, zero		
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA);
	bal	smb_wait
	nop
	bnez	v0, error
	nop

	/* send index */
	add	a0, t6, zero
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA)
	bal	smb_wait
	nop
	bnez	v0, error
	nop
	
	/* restart */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL1);
	ori	a0, v0, SMB_START
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	bal	smb_wait
	nop
	bnez	v0, error
	nop

	/* ack */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL1);
	ori	a0, v0, SMB_ACK
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);

	/* send slave addr */
	ori	a0, t5, 0x01		
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA);
	bal	smb_wait
	nop
	bnez	v0, error
	nop

	/* stop */
	li	a0, SMB_STOP
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	bal	smb_wait
	nop
	bnez	v0, error
	nop

	/* read data */
	IO_INB(SMB_BASE_ADDR | SMB_SDA);
	
error:	
	j	t7
	nop	

/* smb wait and error check */
/* use t1, t2, t3, t4, v0, ra */
/* return 0 means ok, 1 means error */

smb_wait:
	add	t4, ra, zero	# save ra first
	li	t1, 1000		# i dont know how many times is needed
1:		
	li	t2, 100
2:
	addiu	t2, t2, -1
	bnez	t2, 2b		# dont use delay slot here
	nop
	lui	t3, 0xbfd0
	ori	t3, (SMB_BASE_ADDR | SMB_STS)
	lbu	v0, 0(t3)
	andi	v0, SMB_SDAST	# have transmit done or can receive now
	bnez	v0, 3f
	nop
	lbu	v0, 0(t3)
	andi	v0, (SMB_BER | SMB_NEGACK)
	bnez	v0, 4f
	nop
	addiu	t1, t1, -1
	bnez	t1, 1b
	nop
3:
	j	t4
	li	v0, 0
	
4:
	j	t4
	li	v0, 1
