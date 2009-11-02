#ifdef CONFIG_LOONGSON2F
#define TLB_TABLE_NUM 64
#endif

#ifndef TLB_TABLE_NUM
#define TLB_TABLE_NUM 64
#endif 

init_tlb:
	li	t0, TLB_TABLE_NUM
	li	t1, 0
	li	t2, PAGE16K_MASK
next_index:
	mtc0	zero, CP0_ENTRYHI
	mtc0	zero, CP0_ENTRYLO0
	mtc0	zero, CP0_ENTRYLO1
	mtc0	t1,	CP0_INDEX
	mtc0	t2,	CP0_PAGEMASK
	addiu	t1, t1, 1
	tlbwi
	bne	t1, t0, next_index
	nop
	
