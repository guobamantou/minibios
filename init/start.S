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
	
#endif

	PRINTF("init ddr2 now!\r\n");
ddr2_cfg:
	dli	a0, PHY_TO_UNCACHED(CHIP_CFG)	
	ld	v0, 0(a0)
	dli	v1, 0x4ff
	and	v0, v0, v1
	sd	v0, 0(a0)
/* I dont know the code above ,just follow pmon */

ddr2_reg_write:
	li	s0,	DDR2_CTRL_REG_NUM	
	la	v0, DDR2_CTRL00_LO
	add	v0, v0, OFFSET		# v0 is source data addr 
	dli	s2, PHY_TO_UNCACHED(DDR2_CTRL_REG_BASE) # s2 is config reg base addr
	
next_reg:
	ld	a0, 0(v0)
	sd	a0, 0(s2)
	addiu	v0, v0, 8
	addiu	s2, s2, 0x10 
	addi	s0, s0, -1
	bnez	s0, next_reg
	nop

	dli	s2, PHY_TO_UNCACHED(DDR2_CTRL_REG_BASE) # s2 is config reg base addr
	/* get row address */
	li	a0, 0xa0
	li	a1, 3
	bal	smb_read
	nop
	sll	s0, v0, 8
	
	/* get col address */
	li	a0, 0xa0
	li	a1, 4
	bal	smb_read
	nop
	sll	v0, v0, 24
	or	s0, s0, v0

	dli	s1, ((14 << 24) | (15 << 8))
	sub	s1, s1, s0
	sd	s1, 0x50(s2)

## according to spd standard R1.2, rank num is 1~8 ##
## but loongson2f seem support only 4 rank most ##
	
	/* get rank(not bank) num */
	li	a0, 0xa0
	li	a1, 5
	bal	smb_read
	nop

	li	a0, 0x7
	and	a0, a0, v0 			## low 3 bits represent rank num -1
	li	a1, 0x2
	sllv	a1, a1, a0
	addi	a1, -1 			## DDR2_CTRL_70[19:16] = 2^(rank) -1 
	sll	a1, a1, 16
	lw	v0, 0x70(s2)
	li	v1, 0xfff0ffff
	and v0, v0, v1
	or	v0, v0, a1
	sw	v0, 0x70(s2)

	/* get bank num */
	li	a0, 0xa0
	li	a1, 11 
	bal	smb_read
	nop
	li	v1, 0x8
	bne	v1, v0,1f 
	nop
	li	a0, 1
	sw	a0, 4(s2)
1:


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

############ NOTICE: LITTLE-END #################

	.align 3	## will use ld instruction

DDR2_CTRL00_LO: .word 0x00000101
DDR2_CTRL00_HI: .word 0x01000100 
DDR2_CTRL01_LO: .word 0x00010000
DDR2_CTRL01_HI: .word 0x00000000
DDR2_CTRL02_LO: .word 0x00000000
DDR2_CTRL02_HI: .word 0x01000101
DDR2_CTRL03_LO: .word 0x01000000
DDR2_CTRL03_HI: .word 0x01010000
DDR2_CTRL04_LO: .word 0x01010101
DDR2_CTRL04_HI: .word 0x01000202
DDR2_CTRL05_LO: .word 0x04050202 
DDR2_CTRL05_HI: .word 0x00000000
DDR2_CTRL06_LO: .word 0x03050203 
DDR2_CTRL06_HI: .word 0x0a040306 
DDR2_CTRL07_LO: .word 0x00030a0b 
DDR2_CTRL07_HI: .word 0x00000400 
DDR2_CTRL08_LO: .word 0x00000102
DDR2_CTRL08_HI: .word 0x00000102
DDR2_CTRL09_LO: .word 0x00000000
DDR2_CTRL09_HI: .word 0x0000060c 
DDR2_CTRL10_LO: .word 0x3f1f0200 
DDR2_CTRL10_HI: .word 0x2323233f 
DDR2_CTRL11_LO: .word 0x23232323 
DDR2_CTRL11_HI: .word 0x5f7f2323 
DDR2_CTRL12_LO: .word 0x15000000 
DDR2_CTRL12_HI: .word 0x002a3c06 
DDR2_CTRL13_LO: .word 0x002a002a
DDR2_CTRL13_HI: .word 0x002a002a
DDR2_CTRL14_LO: .word 0x002a002a
DDR2_CTRL14_HI: .word 0x002a002a
DDR2_CTRL15_LO: .word 0x00000004
DDR2_CTRL15_HI: .word 0x00b40020
DDR2_CTRL16_LO: .word 0x00000087
DDR2_CTRL16_HI: .word 0x000007ff 
DDR2_CTRL17_LO: .word 0x0016101f
DDR2_CTRL17_HI: .word 0x00000000
DDR2_CTRL18_LO: .word 0x00000000
DDR2_CTRL18_HI: .word 0x001c0000
DDR2_CTRL19_LO: .word 0x00c8006b
DDR2_CTRL19_HI: .word 0x28e10002 
DDR2_CTRL20_LO: .word 0x00c8002f 
DDR2_CTRL20_HI: .word 0x00000000
DDR2_CTRL21_LO: .word 0x00030d40 
DDR2_CTRL21_HI: .word 0x00000000
DDR2_CTRL22_LO: .word 0x00000000
DDR2_CTRL22_HI: .word 0x00000000
DDR2_CTRL23_LO: .word 0x00000000
DDR2_CTRL23_HI: .word 0x00000000
DDR2_CTRL24_LO: .word 0x00000000
DDR2_CTRL24_HI: .word 0x00000000
DDR2_CTRL25_LO: .word 0x00000000
DDR2_CTRL25_HI: .word 0x00000000
DDR2_CTRL26_LO: .word 0x00000000
DDR2_CTRL26_HI: .word 0x00000000
DDR2_CTRL27_LO: .word 0x00000000
DDR2_CTRL27_HI: .word 0x00000000
DDR2_CTRL28_LO: .word 0x00000000
DDR2_CTRL28_HI: .word 0x00000000


#include "smb.S"

#include "uart.S"

