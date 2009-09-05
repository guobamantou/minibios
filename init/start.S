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
#include <loongson/loongson2f/ddr2.h>
#include <loongson/loongson2f/cache.h>
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
	/* rom accelerate */
	dli	v0, PHY_TO_UNCACHED(LIO_CFG)
	lw	v1, 0(v0)
	dli	a0, 0xffffe083
	and	v1, v1, a0
	ori	v1, v1, 0x0f0c
	sw	v1, 0(v0)

	la	s0, _start
	subu	OFFSET, ra, s0
	lui	s1, 0xffff
	bal	init_uart
	and	OFFSET, s1  ## offset of PHYADDR and VIRTUREADDR 

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
	
#endif

	PRINTF("init ddr2 now!\r\n");
	bal	ddr2_cfg
	nop

	PRINTF("init cache now!\r\n");
	bal	init_cache
	nop

#if 0
	mfc0	a0, CP0_CONFIG
	dli		a1, 0xfffffff8	## dont afraid, use 32bit in deed
	and 	a0, a0, a1
	ori		a0, 3
	mtc0	a0, CP0_CONFIG
#endif

#if 1
	PRINTF("write mem to 1\r\n");
	li	s2, 0
	li	s3, 100
start:
	dli	s0, PHY_TO_CACHED(0x0000)
	dli	s1, PHY_TO_CACHED(0x00010000)
	
1:
	dli	v0, 0xffffffffffffffff
	sd	v0, 0(s0) 
	addi	s0, 8
	bne	s0, s1, 1b
	nop 

	add a0, s2, zero
	bal	uart_put_hex
	nop
	PRINTF("times\r\n");
	nop
	addi s2, 1
	bne	s3, s2, start
	nop

#endif

#if 0
get_memsize:
	li	a0, 0xa0
	li	a1, 31
	bal	smb_read
	srl	s0, v0, 5   ### ranksize(byte) = ((val >> 5) | (val & 0x1f)<<3) << 27
	andi s1,v0, 0x1f
	sll s1, s1, 3
	or	s1, s0
	sll	a0, s1, 7
	bal	uart_put_hex
	nop
	PRINTF("MB\r\n");
#endif
2:
	b	2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/
#include "cache.S"

#include "ddr2.S"

#include "smb.S"

#include "uart.S"

