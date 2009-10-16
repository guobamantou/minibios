#include <autoconf.h>
#ifdef CONFIG_32BITS
#define	NBCFG_HEADER		0x1fe00000 /* NBridge pci config header space*/
#define	NBIO_CTRL_REG		0x1fe00100 /*NBridge register,except pci config header*/
#define PCICFG_SPACE		0x1fe80000/* all pci config space access by rd/wr this space*/
#else
#define	NBCFG_HEADER		0xffffffff1fe00000 /* NBridge pci config header space*/
#define	NBIO_CTRL_REG		0xffffffff1fe00100 /*NBridge register,except pci config header*/
#define PCICFG_SPACE		0xffffffff1fe80000/* all pci config space access by rd/wr this space*/
#endif

#define LIO_CFG		(NBIO_CTRL_REG + 0x08)
#define PCIMAP_CFG	(NBIO_CTRL_REG + 0x18)		
#define CHIP_CFG	(NBIO_CTRL_REG + 0X80)

#define NB_PCICMD	(NBCFG_HEADER + 0x04)

/* CHIP_CFG */
#define DISABLE_DDR_CFG		(1 << 8)
