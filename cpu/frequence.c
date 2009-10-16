#include <autoconf.h>
#include <types.h>

#ifdef CONFIG_DYMATIC_CPUFREQ
extern void init_mfgpt0(void);

u32 detect_cpu_freq(void)
{
	init_mfgpt0();		
	return 0xff;
}
#endif
