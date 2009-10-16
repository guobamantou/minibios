#include <types.h>
#include <stdio.h>
#include <pci.h>
#include <pci-conf.h>
#include <autoconf.h>
#include <idsel.h>
#include <loongson/addrspace.h>

#ifdef CONFIG_LOONGSON2F
#include <loongson/loongson2f/nb_reg.h>
#endif

/*pci_conf_read() copy from loongson2f user manual P153 14.3*/

static u32 pci_conf_read(pci_reg pcitag, u32 reg, size_t size)
{
	u32 bus, dev, fun;
	u32 addr, type, val = 0xff; // 0xff means invalid sometimes
	
	bus = PCI_BUS(pcitag);					
	dev = PCI_SLOT(pcitag);
	fun = PCI_FUNC(pcitag);

	/*range check is valueless*/

#ifdef CONFIG_CS5536
	extern u32 cs5536_pci_conf_read(pci_reg, u32, size_t);
	if(dev == CS5536_IDSEL){
		if(size != 4){
			printf("must be 4 bytes to read!\n");
			return 0xffffffff;
		}
		return cs5536_pci_conf_read(pcitag, reg, size);	
	}
#endif
	if(bus == 0) {
		addr = ((1 << (dev + 11)) | (fun << 8) | reg);		
		type = 0;
	} else {
		addr = ((bus << 16) | (dev << 11) | (fun << 8) | reg);
		type = 0x10000;
	}		

	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)PHY_TO_UNCACHED(PCIMAP_CFG) = (addr >> 16) | type;

	val = *(volatile u32 *)(PHY_TO_UNCACHED(PCICFG_SPACE)) | (addr & 0xfffc);	
	
	if(size == 4) {
		return val;
	} else if (size == 1){
		val = (val >> ((reg & 3) * 8)) & 0xff;	
	} else if (size == 2){ //caller will ensure reg align is ok
		val = (reg & 2) ? (val >> 16): (val & 0xff);
	} 	
	return val;
}

u32 pci_conf_read32(pci_reg pcitag, u32 reg)
{
	if(reg & 3) {
		printf("unaligned access!\n");	
		return 0xffffffff;
	}
	
	return pci_conf_read(pcitag, reg, 4);
}

u16 pci_conf_read16(pci_reg pcitag, u32 reg)
{
	if(reg & 1) {
		printf("unaligned access!\n");	
		return 0xffff;
	}
	
	return (u16)pci_conf_read(pcitag, reg, 2);
}

u8 pci_conf_read8(pci_reg pcitag, u32 reg)
{
	return (u8)pci_conf_read(pcitag, reg, 1);
}


static void pci_conf_write(pci_reg pcitag, u32 reg, size_t size, u32 val)
{
	u32 bus, dev, fun;
	u32 addr, type, old_val; 	
	u32 shift;

	bus = PCI_BUS(pcitag);					
	dev = PCI_SLOT(pcitag);
	fun = PCI_FUNC(pcitag);

	/*range check is valueless*/

#ifdef CONFIG_CS5536
	extern void cs5536_pci_conf_write(pci_reg, u32, size_t, u32);
	if(dev == CS5536_IDSEL){
		if(size != 4){
			printf("must be 4 bytes to write!\n");
			return ;
		}
		return cs5536_pci_conf_write(pcitag, reg, size, val);	
	}
#endif
	if(bus == 0) {
		addr = ((1 << (dev + 11)) | (fun << 8) | reg);		
		type = 0;
	} else {
		addr = ((bus << 16) | (dev << 11) | (fun << 8) | reg);
		type = 0x10000;
	}		

	*(volatile u32 *)(PHY_TO_UNCACHED(NB_PCICMD)) |= 0x28000000;
	*(volatile u32 *)PHY_TO_UNCACHED(PCIMAP_CFG) = (addr >> 16) | type;

	old_val = *(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (addr & 0xfffc));	
	// if size is 4, not use old_val at all

	if (size == 1){
		shift = (reg & 3) * 8;		
		val = old_val & ~(0xff << shift);	
		val |= val | ((u8)val << shift);
	} else if (size == 2){ //caller will ensure reg align is ok
		if(reg & 2)
			val = (old_val & 0xffff) | ((u16)val << 16);
		else 
			val = (old_val & 0xffff0000) | ((u16)val);
	} 	
	
	*(volatile u32 *)((PHY_TO_UNCACHED(PCICFG_SPACE)) | (addr & 0xfffc)) = val;	
}

void pci_conf_write32(pci_reg pcitag, u32 reg, u32 val)
{
	if(reg & 3){
		printf("unaligned access!\n");
		return ;
	} 

	pci_conf_write(pcitag, reg, 4, val); 
}

void pci_conf_write16(pci_reg pcitag, u32 reg, u16 val)
{
	if(reg & 1){
		printf("unaligned access!\n");
		return ;
	}
	pci_conf_write(pcitag, reg, 2, (u32)val); 
}

void pci_conf_write8(pci_reg pcitag, u32 reg, u8 val)
{
	pci_conf_write(pcitag, reg, 1, (u32)val); 
}

