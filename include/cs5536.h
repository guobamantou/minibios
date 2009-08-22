#define CS5536ID	0x208f1022
#define MSR_CONTROL 0xF0
#define MSR_ADDR	0xF4
#define MSR_DATA0	0xF8
#define MSR_DATA1	0xFC

/*
 * amd cpu addr convert to amd cs5536 addr
 * cs5536_addr = ((amdcpu_addr[22:13] << 9) || amdcpu_addr[12:0]) 
 * for example, amdcpu_addr 0x51200010 will be translate to 0x40000010
 * loongson2f cpu will not hander rdmsr especially, so submit sb addr directly
*/
#define CS5536_SB_MSR_BASE		(0x00000000)
#define CS5536_GLIU_MSR_BASE	(0x10000000)
#define CS5536_USB_MSR_BASE		(0x40000000)
#define CS5536_IDE_MSR_BASE		(0x60000000)
#define CS5536_DIVIL_MSR_BASE	(0x80000000)
#define CS5536_ACC_MSR_BASE		(0xa0000000)
#define CS5536_GLCP_MSR_BASE	(0xe0000000)

	
