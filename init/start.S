#include <autoconf.h>
#include <loongson/regdef.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/cp0.h>
#endif





	.set	noreorder
	.globl	_start	
_start:
	mtc0 $0,CP0_STATUS 
