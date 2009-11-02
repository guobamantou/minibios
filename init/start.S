	.set	noreorder
	.set 	mips3
	.globl	_start	

#include <autoconf.h>
#include <loongson/regdef.h>
#include <loongson/prid.h>
#include <idsel.h>
#include <uart.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#include <loongson/loongson2f/nb_reg.h>
#include <loongson/loongson2f/pciconf.h>
#include <loongson/loongson2f/io.h>
#include <loongson/loongson2f/exc_code.h>
#include <loongson/loongson2f/ddr2.h>
#include <loongson/loongson2f/cache.h>
#endif

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)
#include <cs5536.h>
#endif

#define OFFSET t9  /* t9 should not be used for other purpose */

#define	PHY_TO_UNCACHED(p)	((p)|0xffffffffa0000000)
#define	PHY_TO_CACHED(p)	((p)|0xffffffff80000000)

#ifdef CONFIG_LOONGSON2F_YEELOONG
#define PRINTF(str) SAFEPRINTF(str)
#endif

#ifdef CONFIG_LOONGSON2F_FULOONG
#define PRINTF(srt) 
#endif

#define SAFEPRINTF(str) \
	.rdata ;\
2009: ;\
	.asciz str ;\
	.text ;\
	la	a0, 2009b ;\
	bal	uart_puts ;\
	nop

/************************   start here  ************************/
stack = 0xffffffff90000000-0x100000
_start:
	mtc0	zero, CP0_STATUS 
	mtc0	zero, CP0_CAUSE 
	dli		s0, STATUS_BEV
	mtc0	s0, CP0_STATUS
	dli		sp, stack
	
	la	s0, _start
	li	s1, 0xbfc00000
	subu	OFFSET, s1, s0

#ifdef CONFIG_LOONGSON2F
rom_speed:
	/* rom accelerate */
	dli	v0, PHY_TO_UNCACHED(LIO_CFG)
	lw	v1, 0(v0)
	dli	a0, 0xffffe083
	and	v1, v1, a0
	ori	v1, v1, 0x0f0c
	sw	v1, 0(v0)
#endif

	b	next
	nop

#include "exception.S"

########### WARNNING : DONT ADD ANY CODE ABOVE ####################
next:

#ifdef CONFIG_LOONGSON2F_YEELOONG
	bal	init_uart
	nop
#endif

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

#if defined(CONFIG_LOONGSON2F_YEELOONG) || defined(CONFIG_LOONGSON2F_FULOONG)
detect_cs5536:
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0x0);
	dli	a0, CS5536ID
	beq a0, v0, 22f
	nop
/* cs5536 may not ready here in fuloong platform, 
 * and I test, about 5ms after the first instruct executed, 
 * pci configure space can be accessed normally 
 * test in a fuloong 6003 which code is FLF1CCA27000314*/

#ifdef CONFIG_LOONGSON2F_FULOONG 	
	b detect_cs5536
	nop
#endif

11:	
	PRINTF("find unknow south brigde:0x");
	BUS0_PCICFG_READ(CS5536_IDSEL, 0, 0x0);
	add a0, v0, zero
	bal	uart_put_hex
	nop
	PRINTF("\r\n");
	b	11b	
	nop
22:
	PRINTF("find amd cs5536 south brigde\r\n");

	/*enable msr access*/
	BUS0_PCICFG_WRITE(CS5536_IDSEL, 0, MSR_CTRL, MSR_EN);

	/*enable all ports*/
	CS5536_MSR_WRITE(CS5536_PORT_EN, 0xffff, 0x0);
/*
 * because we will operate smb bus shortly, 
 * set base addr manually now, and gpio base addr
 */

#define DIVIL_BASE_ADDR     0xB000
#define SMB_BASE_ADDR       (DIVIL_BASE_ADDR | 0x320)
#define GPIO_BASE_ADDR      (DIVIL_BASE_ADDR | 0x000)

	CS5536_MSR_WRITE(CS5536_SMB_BASE, SMB_BASE_ADDR, 0xf001);
	CS5536_MSR_WRITE(CS5536_GPIO_BASE, GPIO_BASE_ADDR, 0xf001);
	
/* FULOONG use uart2 as default serial, initial now */

#ifdef CONFIG_LOONGSON2F_FULOONG
	/* set uart2 io addr to 0x02f8, default val is 04000003 */
	CS5536_MSR_WRITE(CS5536_LEGACY_IO, 0x04500003, 0); 
	
	/* enable uart2 */
	CS5536_MSR_WRITE(CS5536_UART2_CONF, 2, 0);

	GPIO_HI_BIT(UART2_RX, GPIO_BASE_ADDR | GPIOL_IN_EN); 
	GPIO_HI_BIT(UART2_RX, GPIO_BASE_ADDR | GPIOL_IN_AUX1_SEL); 

	GPIO_HI_BIT(UART2_TX, GPIO_BASE_ADDR | GPIOL_OUT_EN); 
	GPIO_HI_BIT(UART2_TX, GPIO_BASE_ADDR | GPIOL_OUT_AUX1_SEL); 
	
	bal init_uart
	nop	

#endif

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
	SAFEPRINTF("Init smbus\r\n");
	bal	init_smb
	nop
#endif

	SAFEPRINTF("init ddr2 now!\r\n");
	bal	ddr2_cfg
	nop

	SAFEPRINTF("init cache now!\r\n");
	bal	init_cache
	nop

#ifdef CONFIG_ENABLE_CACHE
	/*enable cache*/
	mfc0	a0, CP0_CONFIG
	dli		a1, 0xfffffff8	## dont afraid, use 32bit in deed
	and 	a0, a0, a1
	ori		a0, 3
	mtc0	a0, CP0_CONFIG
#endif

#ifdef CONFIG_CLEAR_TLB
	SAFEPRINTF("init TLB now!\r\n");
	bal	init_tlb
	nop
#endif

	SAFEPRINTF("COPY IMAGE TO MEMORY........\r\n");
	la	v0, _ftext		##  start addr
	la	v1, _edata		##  data end addr(bss is special)

	dli	s0, 0xffffffffbfc00000

	/* copy text and data section */
1:	ld	a0, 0(s0)
	sd	a0, 0(v0)
	addiu	v0, 8
	bne	v0, v1, 1b
	addiu	s0, 8

	/* create bss section */	
	la	v1 , _end		##  data segment end(bss is special)
	beq v0, v1, 2f
	nop
1:	
	sd	zero, 0(v0)	
	addiu	v0, 8
	bne	v0, v1, 1b
	nop
		
2:	
	SAFEPRINTF("start.S done\r\n");
	la	v0, main
	jalr	v0
	nop

######## should never come back ########
2:
	b	2b
	nop

#include "cache.S"

#include "ddr2.S"

#include "smb.S"

#include "uart.S"

#include "tlb.S"
.set reorder
