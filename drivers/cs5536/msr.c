#include <types.h>
#include <pci-conf.h>
#include <autoconf.h>
#include <idsel.h>
#include <loongson/addrspace.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/nb_reg.h>
#endif


u32 MSR_ADDR  = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xf4;
u32 MSR_DATA0 = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xf8;
u32 MSR_DATA1 = (1 << (11 + CS5536_IDSEL)) | (0 << 8) | 0xfc;

void rdmsr(u32 msr, u32 *hi, u32 *lo)
{
	u32 type = 0x0; // always in bus 0	
	
	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_ADDR >> 16) | type;
	*(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_ADDR & 0xfffc)) = msr; 

	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_DATA0 >> 16) | type;
	*lo = *(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_DATA0 & 0xfffc)); 
	
	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_DATA1 >> 16) | type;
	*hi = *(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_DATA1 & 0xfffc)); 
}

void wrmsr(u32 msr, u32 hi, u32 lo)
{
	u32 type = 0x0; // always in bus 0	
	
	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_ADDR >> 16) | type;
	*(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_ADDR & 0xfffc)) = msr; 

	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_DATA0 >> 16) | type;
	*(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_DATA0 & 0xfffc)) = lo; 
	
	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)(PHY_TO_UNCACHED(PCIMAP_CFG)) = (MSR_DATA1 >> 16) | type;
	*(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (MSR_DATA1 & 0xfffc)) = hi; 
}
