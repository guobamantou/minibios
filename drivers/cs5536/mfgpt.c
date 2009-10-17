#include <types.h>
#include <stdio.h>
#include <delay.h>
#include <io.h>
#include "mfgpt.h"

extern void rdmsr(u32, u32*, u32*);
extern void wrmsr(u32, u32, u32);

#define MFGPT_BASE_ADDR 0xff00

/*
 * init_mfgpt0()'s aim is give a mean to measure 0.1s 
 * ,in order to acculate cpu frequent, we can use 32KHz clock generator,it will
 * generate 32*10^3 cycles, 3200 cycles is equal to 0.1s
 */
extern u32 get_count(void);
u32 init_mfgpt0_and_detect_freq(void)
{
	u32 lo, hi;
	u32 mode;
	u32 old_count, new_count;
	int i;

	rdmsr(0x8000000d, &hi, &lo);	
	if(!(hi & 1) && (lo & 0xffc0))
		printf("WARRING: mfgpt's base address has assigned\n");
	else {
		wrmsr(0x8000000d, 0xf001, MFGPT_BASE_ADDR); // NOTICE: 0xff00 as base asdr, this may has risk,so make sure no other use this addr
	}
	
	rdmsr(0x8000000d, &hi, &lo);	
 	io_outw(lo + MFGPT0_COMPARATOR_2, 0xffff); // 0xffff is the maximum num
	
    /* setup */
    mode =  (COMPARE_ON_GE << MFGPT_CMP2MODE_SHIFT)
             | (MFGPT_CNT_EN << MFGPT_CNT_EN_SHIFT)
             | (MFGPT_CLKSEL_32K << MFGPT_CLKSEL_SHIFT);
    io_outw(lo + MFGPT0_SETUP, mode);
	for(i = 2; i != 0; i--){
		io_outw(lo + MFGPT0_UP_COUNTER, 0);
		while(io_inw(lo + MFGPT0_UP_COUNTER) <= 100){};
		old_count = get_count();		

		while(io_inw(lo + MFGPT0_UP_COUNTER) <= 3377){};
		new_count = get_count();
	}
	if(new_count > old_count)
		return 20 * (new_count - old_count);
	else 
		return 20 * (0 - old_count + new_count); 

}
