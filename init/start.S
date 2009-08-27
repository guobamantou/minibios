	.set	noreorder
	.set 	mips3
	.globl	_start	

#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/addrspace.h>
#include <loongson/prid.h>
#include <uart.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#include <loongson/loongson2f/nb_reg.h>
#include <loongson/loongson2f/uart.h>
#include <loongson/loongson2f/pciconf.h>
#include <loongson/loongson2f/io.h>
#include <loongson/loongson2f/exc_code.h>
#endif

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)
#include <idsel.h>
#include <cs5536.h>
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
stack = 0x90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	dli		s0, STATUS_BEV
	mtc0	s0, CP0_STATUS
	dli		sp, stack
	
	bal	locate
	nop

#include "exception.S"

########### WARNNING : DONT ADD ANY CODE ABOVE ####################

locate:
	la	s0, _start
	subu	OFFSET, ra, s0
	lui	s1, 0xffff
	and	OFFSET, s1    ### OFFSET is offset of PHYADDR and VIRTUREADDR in the eye of cpu
	
	bal	init_uart
	nop

cpu_detect: 
	mfc0	s0, CP0_PRID
	li	a0,	LOONGSON2F_PRID	
	beq	a0, s0, loongson2f
	nop
	li	a0,	LOONGSON2E_PRID	
	beq	a0, s0, loongson2e
	nop
	li	a0,	LOONGSON2G_PRID	
	beq	a0, s0, loongson2g
	nop
loongson2e:
	PRINTF("LOONGSON 2E founded!\r\n");	
	PRINTF("NOT SUPPORT\r\n");	
	b	init_nb
	nop	
loongson2f:
	PRINTF("LOONGSON 2F founded!\r\n");	
	b	init_nb
	nop	
loongson2g:
	PRINTF("LOONGSON 2G founded!\r\n");	
	b	init_nb
	nop	

init_nb:
	/* init north bridge(virtual?) */
	PRINTF("INIT North Bridge\r\n");
#if 0
	
#endif

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)
detect_cs5536:
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
	PRINTF("Init smbus\r\n");
	bal	init_smb
	nop
	
	li	a0, 0xa0
	li	a1, 0x5
	bal	smb_read
	nop
	add	a0, v0, zero
	bal	uart_put_hex
	nop	
#endif	
2:
	b	2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include "smb.S"

#include "uart.S"

