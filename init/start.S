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
	li	a0,'U'
	bal	uart_putc
	nop

	li 	s0, 15	
1:
	BUS0_PCICFG_READ(7, 0, 0x0);
	add a0, v0
	bal uart_put_hex
	nop
BUS0_PCICFG_READ(7, 0, 0x14);
	add a0, v0
	bal uart_put_hex
	nop
BUS0_PCICFG_WRITE(7, 0, 0x14, 0xffffff00);
BUS0_PCICFG_READ(7, 0, 0x14);
	add a0, v0
	bal uart_put_hex
	nop


	li	a0,'\r'
	bal	uart_putc
	nop
	li	a0,'\n'
	bal	uart_putc
	nop

	addi s0, s0, -1
	bne s0, zero,1b
	nop

2:
	li a0, 1
	bnez a0, 2b
	nop


/**************************************************************************/
/*******************  procedures used in this file  ***********************/
/**************************************************************************/

#include "uart.S"
