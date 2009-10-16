#include <types.h>

#define PCI_BUS(A)		((A) >> 16)
#define PCI_SLOT(A)     (((A) >> 11) & 0x1f)
#define PCI_FUNC(A)     (((A) >> 8) & 0x07)

#define MAKE_PCI_DEV(bus, dev, func)	(((bus) << 16) | ((dev) << 11) | ((func) << 8))

u32 pci_conf_read32(pci_reg, u32);
u16 pci_conf_read16(pci_reg, u32);
u8 pci_conf_read8(pci_reg, u32);

void pci_conf_write32(pci_reg, u32, u32);
void pci_conf_write16(pci_reg, u32, u16);
void pci_conf_write8(pci_reg, u32, u8);
