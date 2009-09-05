/************************************************/
/**** use a0, a1, t0, t1, t2, t5, v0, v1, ra ****/
/**** because no meas to get the number of ways, use 4 ****/
/**** NOTICE: loongson's cache instruction is not standard ****/

init_cache:
	add	t5, ra, zero
	mfc0	a0, CP0_CONFIG

init_icache:
	andi	t0, a0, ICACHE_SIZE
	andi	t1, a0, ICACHE_LINE_SIZE
	li	t2, (2 << 6)	## index num = 2^(6 + t0 -t1)
	sub	t0, t0, t1
	sllv	t2, t2, t0	## t2 is index num now
	li	t0, 16
	sllv	t1, t0, t1	## t1 is icache line size 

	li	t0, 0			## t0 use as 'VA'
1:
	cache	I_INDEX_INVALIDATE, 0(t0)	
	cache	I_INDEX_INVALIDATE, 1(t0)	
	cache	I_INDEX_INVALIDATE, 2(t0)	
	cache	I_INDEX_INVALIDATE, 3(t0)	
	addiu	t2, -1
	bnez	t2, 1b
	add	t0, t0, t1		## next index

init_dcache:
	andi	t0, a0, DCACHE_SIZE
	andi	t1, a0, DCACHE_LINE_SIZE
	li	t2, (2 << 6)	## index num = 2^(6 + t0 -t1)
	sub	t0, t0, t1
	sllv	t2, t2, t0	## t2 is index num now
	li	t0, 16
	sllv	t1, t0, t1	## t1 is icache line size 

	li	t0, 0			## t0 use as 'VA'
	mtc0	zero, CP0_TAGHI	
	mtc0	zero, CP0_TAGLO		## set state bits to 00(invalid)
1:
	cache	D_INDEX_STORE_TAG, 0(t0)	
	cache	D_INDEX_STORE_TAG, 1(t0)	
	cache	D_INDEX_STORE_TAG, 2(t0)	
	cache	D_INDEX_STORE_TAG, 3(t0)	
	addiu	t2, -1
	bnez	t2, 1b
	add	t0, t0, t1		## next index

/******/
init_l2cache:
	li	t2, (1 << 12)	## index num = 2^12
	li	t1, 32

	li	t0, 0			## t0 use as 'VA'
	mtc0	zero, CP0_TAGHI	
	mtc0	zero, CP0_TAGLO		## no other purpose, set state bits
1:
	cache	S_INDEX_STORE_TAG, 0(t0)	
	cache	S_INDEX_STORE_TAG, 1(t0)	
	cache	S_INDEX_STORE_TAG, 2(t0)	
	cache	S_INDEX_STORE_TAG, 3(t0)	
	addiu	t2, -1
	bnez	t2, 1b
	add	t0, t0, t1		## next index

	j	t5
	nop

endof_init_cache:
