#ifdef CONFIG_LOONGSON2F
#define TLB_TABLE_NUM 64
#endif

#ifndef TLB_TABLE_NUM
#define TLB_TABLE_NUM 64
#endif 

init_tlb:
	li	a0, TLB_TABLE_NUM
	li	a1, 0
	li	v0, PAGE16K_MASK
next_index:
	mtc0	zero, CP0_ENTRYHI
	mtc0	zero, CP0_ENTRYLO0
	mtc0	zero, CP0_ENTRYLO1
	mtc0	a1, CP0_INDEX
	mtc0	v0, CP0_PAGEMASK
	addiu	a1, a1, 1
	tlbwi
	bne	a1, a0, next_index
	nop
	j	ra	
	nop
