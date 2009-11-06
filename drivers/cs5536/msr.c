#include <types.h>
#include <pci-conf.h>
#include <autoconf.h>
#include <idsel.h>
#include <loongson/addrspace.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/nb_reg.h>
#endif

#define PCICONF_TYPE0	0
#define PCICONF_TYPE1	1
#define UNCACHED(reg) (*(volatile u32 *)(PHY_TO_UNCACHED(reg)))

u32 MSR_ADDR  = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xf4;
u32 MSR_DATA0 = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xf8;
u32 MSR_DATA1 = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xfc;

void rdmsr(u32 msr, u32 *hi, u32 *lo)
{
	UNCACHED(PCIMAP_CFG) = (MSR_ADDR >> 16) | PCICONF_TYPE0;
	UNCACHED(PCICFG_SPACE | (MSR_ADDR & 0xfffc)) = msr; 

	UNCACHED(PCIMAP_CFG) = (MSR_DATA0 >> 16) | PCICONF_TYPE0;
	*lo = UNCACHED(PCICFG_SPACE | (MSR_DATA0 & 0xfffc)); 
	
	UNCACHED(PCIMAP_CFG) = (MSR_DATA1 >> 16) | PCICONF_TYPE0;
	*hi = UNCACHED(PCICFG_SPACE | (MSR_DATA1 & 0xfffc)); 
}

void wrmsr(u32 msr, u32 hi, u32 lo)
{
	UNCACHED(PCIMAP_CFG) = (MSR_ADDR >> 16) | PCICONF_TYPE0;
	UNCACHED(PCICFG_SPACE | (MSR_ADDR & 0xfffc)) = msr; 

	UNCACHED(PCIMAP_CFG) = (MSR_DATA0 >> 16) | PCICONF_TYPE0;
	UNCACHED(PCICFG_SPACE | (MSR_DATA0 & 0xfffc)) = lo; 
	
	UNCACHED(PCIMAP_CFG) = (MSR_DATA1 >> 16) | PCICONF_TYPE0;
	UNCACHED(PCICFG_SPACE | (MSR_DATA1 & 0xfffc)) = hi; 
}
