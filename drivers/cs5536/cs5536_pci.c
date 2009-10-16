#include <pci.h>
#include <pci-conf.h>

enum {
	CS5536_FUNC_START = -1,
	CS5536_ISA_FUNC,
	CS5536_FLASH_FUNC,
	CS5536_IDE_FUNC,
	CS5536_ACC_FUNC,
	CS5536_OHCI_FUNC,
	CS5536_EHCI_FUNC,
	CS5536_UDC_FUNC,
	CS5536_OTG_FUNC,
	CS5536_FUNC_END,
};

void cs5536_pci_conf_write(pci_reg pcitag, u32 reg, size_t size, u32 val)
{
	u32 bus, dev, fun;

    fun = PCI_FUNC(pcitag);
#if 0
	switch (fun) {
	case CS5536_ISA_FUNC:
		pci_isa_write_reg(reg, val);
		break;
	case CS5536_IDE_FUNC:
		pci_ide_write_reg(reg, val);
		break;
	case CS5536_OHCI_FUNC:
		pci_ohci_write_reg(reg, val);
		break;
	default:
		break;
	}
#endif
	return;
}

/*
 * read PCI config space and transfer it to MSR access.
 */
u32 cs5536_pci_conf_read(pci_reg pcitag, u32 reg, size_t size)
{
	u32 data = 0;

	if ((reg < 0) || ((reg & 0x03) != 0))
		return 0;
#if 0
	switch (function) {
	case CS5536_ISA_FUNC:
		data = pci_isa_read_reg(reg);
		break;
	case CS5536_IDE_FUNC:
		data = pci_ide_read_reg(reg);
		break;
	case CS5536_OHCI_FUNC:
		data = pci_ohci_read_reg(reg);
		break;
	default:
		break;
	}
#endif
	return data;
}
