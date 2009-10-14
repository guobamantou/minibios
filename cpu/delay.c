#include <types.h>
#include <panic.h>
#include <debug.h>
#include <autoconf.h>

u32 cpu_freq; // unit: MHz
u32 ms_overflow;
u32 cycle_per_ms, cycle_per_us;
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
 	ms_overflow = ((8 * 1073 * 1000) / cpu_freq); // 2^30 = 1073741824, ms_overflow should less than the actual number
	cycle_per_ms = 0x80000000 / ms_overflow;  // to avoid overflow
	cycle_per_ms = cycle_per_ms *2 + 2; // cycle_per_ms is bigger than the actual number
	cycle_per_us = cycle_per_ms / 1000 + 1;
	cpu_freq_inited = 1;
}

void delay(u32 ms)
{
	int overflow_times;
	u32 aim_count;
	u32 old_count, new_count;

	old_count = get_count();
	if(ms >= (60 * 60 * 1000)) {
		ms = 36000000;
		early_printf("to long time to delay (>1 hour), delay 1 hours\n");
	}
		
	overflow_times = ms / ms_overflow;	
	ms = ms % ms_overflow;	
	aim_count = ms * cycle_per_ms + old_count;
	if(aim_count < old_count)
		overflow_times++;   // here overflow refer to 0xffffffff -> 0

	while(overflow_times > 0){
		new_count = get_count();
		if(new_count < old_count)
			overflow_times--;
		old_count = new_count;	
	}
	
	do {
		new_count = get_count();
		if(new_count < old_count) // this code is useful when aim_count is near 0xffffffff
			return ;
		old_count = new_count;
	} while(new_count < aim_count);
}

void udelay(u32 us)
{
	u32 aim_count;
	u32 old_count, new_count;

	old_count = get_count();
	if(us > ms_overflow * 1000)
		delay(us / 1000 + 1);

	aim_count = us * cycle_per_us + old_count; // us * cycle_per_us is not bigger than 0xffffffff

	if(aim_count < old_count) {
		while(1){
			new_count = get_count();
			if(new_count < old_count)
				break;		
			old_count = new_count;	
		}
	}
	
	do {
		new_count = get_count();
		if(new_count < old_count) // this code is useful when aim_count is near 0xffffffff
			return ;
		old_count = new_count;
	} while(new_count < aim_count);
}
