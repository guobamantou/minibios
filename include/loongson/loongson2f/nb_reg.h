#define	NBCFG_HEADER		0x1fe00000 /* NBridge pci config header space*/
#define	NBIO_CTRL_REG		0x1fe00100 /*NBridge register,except pci config header*/
#define PCICFG_SPACE		0x1fe80000/* all pci config space access by rd/wr this space*/

#define PCIMAP_CFG	(NBIO_CTRL_REG + 0x18)		
