#include <autoconf.h>
#include <types.h>

u32 get_count()
{
	__asm__(
		".set noreorder\n"
#ifdef CONFIG_LOONGSON2F
		"mfc0 $2, $9\n"
#endif
		".set reorder\n"
	); 
	/* in fact, this function return value direct by v0 regsiter*/	
}
