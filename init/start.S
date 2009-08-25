	.set	noreorder
	.set 	mips3
	.globl	_start	

#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/addrspace.h>
#include <uart.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#include <loongson/loongson2f/nb_reg.h>
#endif

#ifdef CONFIG_LOONGSON2F 
#include <loongson/loongson2f/uart.h>
#endif

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)
#include <cs5536.h>
#endif
#include <idsel.h>

#define OFFSET t9  /* t9 should not be used for other purpose */

#define PRINTF(str) \
	.rdata ;\
2009: ;\
	.asciz str ;\
	.text ;\
	la	a0, 2009b ;\
	bal	uart_puts ;\
	nop

#define BUS0_CFG_ADDR(dev, fun, reg) (1<<((dev) + 11) | (fun)<<8 | (reg))

#define BUS0_PCICFG_READ(dev, fun, reg) \
	dli	a0,	BUS0_CFG_ADDR(dev, fun, reg); \
	srl a1, a0, 16; \
	andi a0, a0, 0xffff; \
	dli a2, PHY_TO_UNCACHED(PCIMAP_CFG); \
	sw	a1, 0(a2); \
	dli a2, PHY_TO_UNCACHED(PCICFG_SPACE); \
	or	a2, a2, a0; \
	lw	v0, 0(a2);

#define BUS0_PCICFG_WRITE(dev, fun, reg, val) \
	dli	a0,	BUS0_CFG_ADDR(dev, fun, reg); \
	srl a1, a0, 16; \
	andi a0, a0, 0xffff; \
	dli a2, PHY_TO_UNCACHED(PCIMAP_CFG); \
	sw	a1, 0(a2); \
	dli a2, PHY_TO_UNCACHED(PCICFG_SPACE); \
	or	a2, a2, a0; \
	dli	v0, val; \
	sw	v0, 0(a2);

#define CS5536_MSR_WRITE(reg, lo, hi) \
    BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_ADDR, reg); \
    BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_DATA0, lo); \
    BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_DATA1, hi);
#if 0
#define CS5536_MSR_READ(reg) \
    BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_ADDR, reg); \
    BUS0_PCICFG_READ(CS5536_IDSEL, 0, MSR_DATA0); \
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, MSR_DATA1);
#endif

#define IO_INB(reg) \
	dli v1, 0xffffffffbfd00000; \
	ori	v1, reg; \
	lbu v0, 0(v1)

/* use a0 as input parameter */
#define IO_OUTB(reg) \
	dli	v0, 0xffffffffbfd00000; \
	ori	v0, reg; \
	sb	a0, 0(v0)

#define IO_INW(reg) \
	dli v1, 0xffffffffbfd00000; \
	ori	v1, reg; \
	lwu	v0, 0(v1)

/* use a0 as input parameter */
#define IO_OUTW(reg) \
	dli v0, 0xffffffffbfd00000; \
	ori	v0, reg; \
	sw a0, 0(v0)





/************************   start here  ************************/
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
	and	OFFSET, s1    ### OFFSET is offset of PHYADDR and VIRTUREADDR in the eye of cpu
	
	bal	init_uart
	nop
 
init_nb:
	/* init north bridge(virtual?) */
	PRINTF("INIT North Bridge\r\n");
#if 0
	dli	v0, PHY_TO_UNCACHED(NBCFG_HEADER + 8)	
	lw	a0, 0(v0)
	bal	uart_put_hex
	nop
#endif

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)

	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0x0);
	dli	a0, CS5536ID
	beq a0, v0, 22f
	nop
11:	
	PRINTF("find unknow south brigde:0x");
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0x0);
	add a0, v0, zero
	bal	uart_put_hex
	nop
	PRINTF("\r\n")
	b	11b	
	nop
22:
	PRINTF("find amd cs5536 south brigde\r\n");
	
	/*enable msr access*/
	BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_CTRL, MSR_EN);

	/*enable all ports*/
	CS5536_MSR_WRITE(CS5536_PORT_EN, 0xffff, 0x0)
/*
 * because we will operate smb bus shortly, 
 * set base addr manually now, and gpio base addr
 */

#define DIVIL_BASE_ADDR     0xB000
#define SMB_BASE_ADDR       (DIVIL_BASE_ADDR | 0x320)
#define GPIO_BASE_ADDR      (DIVIL_BASE_ADDR | 0x000)

/*
 * set two bits relative simultaneous is effect gpio bit set
 * see detail in section "atomic bit programming model" in cs5536 manual 
 */
#define GPIO_HI_BIT(bit, reg)\
	dli	v0, 0xffffffffbfd00000; \
	ori	v0, reg; \
	lw	a0, 0(v0); \
	li	a1, (1 << bit); \
	or	a0, a1; \
	sll a1, 16; \
	not a1; \
	and a0, a1; \
	sw	a0, 0(v0);

#define GPIO_LO_BIT(bit, reg)\
	dli	v0, 0xffffffffbfd00000; \
	ori	v0, reg; \
	lw	a0, 0(v0); \
	sll	a1, (1 << (bit + 16)); \
	or	a0, a1; \
	li	a1, ~(1 << bit); \
	and a0, a1; \
	sw	a0, 0(v0);

init_smb:
	CS5536_MSR_WRITE(CS5536_SMB_BASE, SMB_BASE_ADDR, 0xf001);
	CS5536_MSR_WRITE(CS5536_GPIO_BASE, GPIO_BASE_ADDR, 0xf001);
	
	/* config gpio14 to be smb_clk and gpio15 to be smb_data */
	GPIO_HI_BIT(SMB_CLK_PIN, GPIO_BASE_ADDR | GPIOL_IN_EN);
    GPIO_HI_BIT(SMB_CLK_PIN, GPIO_BASE_ADDR | GPIOL_OUT_EN);
    GPIO_HI_BIT(SMB_CLK_PIN, GPIO_BASE_ADDR | GPIOL_IN_AUX1_SEL);
    GPIO_HI_BIT(SMB_CLK_PIN, GPIO_BASE_ADDR | GPIOL_OUT_AUX1_SEL);

    GPIO_HI_BIT(SMB_DATA_PIN, GPIO_BASE_ADDR | GPIOL_IN_EN);
    GPIO_HI_BIT(SMB_DATA_PIN, GPIO_BASE_ADDR | GPIOL_OUT_EN);
    GPIO_HI_BIT(SMB_DATA_PIN, GPIO_BASE_ADDR | GPIOL_IN_AUX1_SEL);
    GPIO_HI_BIT(SMB_DATA_PIN, GPIO_BASE_ADDR | GPIOL_OUT_AUX1_SEL);

	/* init smbus */

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

	/* enable smb now */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL2);
	ori	a0, v0, SMB_ENABLE
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL2);

	/* clear all error status */
	li	a0, 0xff
	IO_OUTB(SMB_BASE_ADDR | SMB_STS);

	/* clear bus busy bit */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL_STS);
	ori	a0, v0, SMB_BUS_BUSY
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL_STS);
		
#if 1

	/* check spd i2c value now*/

	PRINTF("\r\ni2c 0xa0, index 0:0x");
	li	a0, 0xa0
	li	a1, 0x00
	bal smb_read
	nop
	add	a0, v0, zero
	bal	uart_put_hex
	nop	

#endif

#endif	
2:
	b	2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

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
	li		v1, 0xff
	bnez	v0, error
	nop

	/* send slave addr */
	add a0, t5, zero		
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA);
	bal	smb_wait
	nop
	li		v1, 0xfe
	bnez v0, error
	nop

	/* ack */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL1);
	ori	a0, v0, SMB_ACK
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);

	/* send index */
	add	a0, t6, zero
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA)
	bal	smb_wait
	nop
	li		v1, 0xfd
	bnez	v0, error
	nop
	
	/* restart */
	IO_INB(SMB_BASE_ADDR | SMB_CTRL1);
	ori	a0, v0, SMB_START
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	bal	smb_wait
	nop
	li		v1, 0xfc
	bnez	v0, error
	nop

	/* send slave addr */
	ori a0, t5, 0x01		
	IO_OUTB(SMB_BASE_ADDR | SMB_SDA);
	bal	smb_wait
	nop
	li		v1, 0xfb
	bnez v0, error
	nop

	/* stop */
	li	a0, SMB_STOP
	IO_OUTB(SMB_BASE_ADDR | SMB_CTRL1);
	bal smb_wait
	nop
	li		v1, 0xfa
	bnez	v0, error
	nop

	/* read data */
	li	v1, 0xf9
	IO_INB(SMB_BASE_ADDR | SMB_SDA);
	
error:	
	j	t7
	nop	

endof_smb_read:
/**/
smb_write:


endof_smb_write:

/* smb wait and error check */
/* use t1, t2, t3, t4, v0, ra */
/* return 0 means ok, 1 means error */

smb_wait:
	add	t4, ra, zero	# save ra first
	li	t1, 1000		# this value is big enough
1:		
	li	t2, 1000
2:
	addiu	t2, t2, -1
	bnez	t2, 2b		# dont use delay slot here
	nop
	lui		t3, 0xbfd0
	ori		t3, (SMB_BASE_ADDR | SMB_STS)
	lbu		v0, 0(t3)
	andi	v0, SMB_SDAST	# have transmit done or can receive now
	bnez	v0, 3f
	nop
	lbu		v0, 0(t3)
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

	
endof_smb_wait:

#include "uart.S"


#if 0
	BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, 0xf4, CS5536_SB_MSR_BASE | 0x10);
	PRINTF("\r\n yu:")
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0XF8);	
	add a0, v0, zero
	bal	uart_put_hex
	nop

	PRINTF("\r\n yu:")
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0XFc);	
	add a0, v0, zero
	bal	uart_put_hex
	nop
#endif


