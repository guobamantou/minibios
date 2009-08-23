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
	lbu v0, reg(v1)

/* use a0 a0 input parameter */
#define IO_OUTB(reg) \
	dli v0, 0xffffffffbfd00000; \
	sbu a0, reg(v0)




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
	and	OFFSET, s1    ### now OFFSET is offset of PHYADDR and VIRTUREADDR in the eye of cpu
	
	bal	init_uart
	nop

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
	CS5536_MSR_WRITE(CS5536_PORT_EN, 0x000f, 0x0)

/*
 * because we will operate smb bus shortly, 
 * set base addr manually now, and gpio base addr
 */

#define DIVIL_BASE_ADDR     0xB000
#define SMB_BASE_ADDR       (DIVIL_BASE_ADDR | 0x320)
#define GPIO_BASE_ADDR      (DIVIL_BASE_ADDR | 0x000)

nop
	nop
	nop
	nop
	dli a0, 0xfffffffff2345678
	nop
	dli a0, 0xf2345678
	nop
	li a0, 0xf2345678
		nop
	nop
	nop
	nop
	nop

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


	CS5536_MSR_WRITE(CS5536_SMB_BASE, SMB_BASE_ADDR, 0Xf001);
	CS5536_MSR_WRITE(CS5536_GPIO_BASE, GPIO_BASE_ADDR, 0Xf001);
	
	/* config gpio14 to be smb_clk and gpio15 to be smb_data */
    GPIO_HI_BIT(SMB_CLK, GPIO_BASE_ADDR | GPIOL_IN_EN);
    GPIO_HI_BIT(SMB_CLK, GPIO_BASE_ADDR | GPIOL_OUT_EN);
    GPIO_HI_BIT(SMB_CLK, GPIO_BASE_ADDR | GPIOL_IN_AUX1_SEL);
    GPIO_HI_BIT(SMB_CLK, GPIO_BASE_ADDR | GPIOL_OUT_AUX1_SEL);

    GPIO_HI_BIT(SMB_DATA, GPIO_BASE_ADDR | GPIOL_IN_EN);
    GPIO_HI_BIT(SMB_DATA, GPIO_BASE_ADDR | GPIOL_OUT_EN);
    GPIO_HI_BIT(SMB_DATA, GPIO_BASE_ADDR | GPIOL_IN_AUX1_SEL);
    GPIO_HI_BIT(SMB_DATA, GPIO_BASE_ADDR | GPIOL_OUT_AUX1_SEL);

#endif	
2:
	b	2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include "uart.S"
