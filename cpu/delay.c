#include <types.h>
#include <panic.h>
#include <debug.h>
#include <autoconf.h>

u32 cpu_freq; // unit: MHz
u32 ms_overflow;
int cpu_freq_inited = 0;

void init_cpu_freq()
{
#ifdef CONFIG_STATIC_CPUFREQ
	cpu_freq = CONFIG_STATIC_CPUFREQ;
#else 
	cpu_freq = detect_cpu_freq(); // loongson's cpu frequence will not reach 4G in 5 years
#endif
	if(cpu_freq < 1000000)
		panic("too low cpu freq: less than 1 MHz");	
	cpu_freq = cpu_freq / 1000000; // unit: MHz
	/* ms_overflow = (2 * 2^32 / cpu freq (unit: HZ) * 1000) */
 	ms_overflow = ((8 * 1074 * 1000) / cpu_freq) + 1; 
	dprintf("cpu freq is %d MHz\n", cpu_freq);
	dprintf("ms_overflow is %d\n", ms_overflow);
	cpu_freq_inited = 1;
}

void delay(u32 ms)
{
	
}
