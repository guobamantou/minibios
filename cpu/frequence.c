#include <types.h>
#include <stdio.h>

extern u32 init_mfgpt0_and_detect_freq(void);
extern u32 cpu_freq;
extern void panic(const char *);

void detect_cpu_freq(void)
{
	cpu_freq = init_mfgpt0_and_detect_freq();		
	if(cpu_freq < 1000000)
		panic("cpu freq is too low\n");
	cpu_freq = cpu_freq / 1000000;	
}
