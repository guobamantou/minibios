/****************************************************/
/********* use s5, s6, s7, a0, a1, v0, v1, ra *********/
/****************************************************/
ddr2_cfg:
	add	s5, ra, zero		# store ra to s5

	/* enable memory cfg */
	dli	a0, PHY_TO_UNCACHED(CHIP_CFG)	
	ld	v0, 0(a0)
	andi	v0, v0, 0x4ff
	sd	v0, 0(a0)

ddr2_reg_write:
	li	a0,	DDR2_CTRL_REG_NUM	## counter
	la	v0, DDR2_CTRL00_LO
	add	v0, v0, OFFSET			## v0 is source data addr 
	dli	v1, PHY_TO_UNCACHED(DDR2_CTRL_REG_BASE) # v1 is config reg base addr
	
next_reg:
	ld	a1, 0(v0)
	sd	a1, 0(v1)
	addi	a0, a0, -1
	addiu	v0, v0, 0x08
	bnez	a0, next_reg
	addiu	v1, v1, 0x10 

#### adjust some special ddr2 cfg reg ####

	dli	s6, PHY_TO_UNCACHED(DDR2_CTRL_REG_BASE) # s6 is config reg base addr

	/* get row address */
	li	a0, 0xa0
	li	a1, 3
	bal	smb_read
	nop
	sll	s7, v0, 8
	
	/* get col address */
	li	a0, 0xa0
	li	a1, 4
	bal	smb_read
	nop
	sll	v0, v0, 24
	or	s7, s7, v0

	dli	a0, ((14 << 24) | (15 << 8))
	sub	a0, a0, s7
	sd	a0, 0x50(s6)

## according to spd standard R1.2, rank num is 1~8 ##
## but loongson2f seem support only 4 rank most ##
	
	/* get rank(not bank) num */
	li	a0, 0xa0
	li	a1, 5
	bal	smb_read
	nop

	andi	a0, v0, 0x7 			## low 3 bits represent rank num -1
	li	a1, 0x2
	sllv	a1, a1, a0
	addi	a1, -1 			## DDR2_CTRL_70[19:16] = 2^(rank) -1 
	sll	a1, a1, 16
	lw	v0, 0x70(s6)
	li	v1, 0xfff0ffff
	and v0, v0, v1
	or	v0, v0, a1
	sw	v0, 0x70(s6)		## i test sb ,but not work,sw is ok

	/* get bank num */
	li	a0, 0xa0
	li	a1, 11 
	bal	smb_read
	nop
	li	v1, 0x8
	bne	v1, v0,1f			## check have 8 banks or not
	nop
	ld	a0, 0x10(s6)
	dli	v0, (1 << 32) 
	or	a0, v0
	sd	a0, 0x10(s6)
1:
	/* start ddr2 */
	ld	a0, 0x30(s6)
	dli	v0, (1 << 40)
	or	a0, v0
	sd	a0, 0x30(s6)

not_locked:
	ld	v0, 0x10(s6)
	andi	v0, 1
	beq	v0, zero, not_locked	## memory can accesss until dll locked
	nop

	/* after complete config, disable ddr2 config */
	dli	a0, PHY_TO_UNCACHED(CHIP_CFG)
	ld	v0, 0x0(a0)
	ori	v0, 1
	j	s5
	sd	v0, 0x0(a0)


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
