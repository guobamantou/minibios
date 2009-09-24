#include <autoconf.h>

#ifdef CONFIG_32BITS
#define IO_BASE		0xbfd00000 		
#else 
#define IO_BASE		0xffffffffbfd00000 		
#endif

#define io_inb(a) (*(volatile unsigned char *)(IO_BASE + (a)))
#define io_inw(a) (*(volatile unsigned short *)(IO_BASE + (a)))
#define io_inl(a) (*(volatile unsigned long *)(IO_BASE + (a)))

#define io_outb(a, v) (*(volatile unsigned char *)(IO_BASE + (a)) = (v))
#define io_outw(a, v) (*(volatile unsigned short *)(IO_BASE + (a)) = (v))
#define io_outl(a, v) (*(volatile unsigned long *)(IO_BASE + (a)) = (v))

#define inb(a) (*(volatile unsigned char *)(a))
#define inw(a) (*(volatile unsigned short *)(a))
#define inl(a) (*(volatile unsigned long *)(a))

#define outb(a, v) (*(volatile unsigned char *)(a) = (v))
#define outw(a, v) (*(volatile unsigned short *)(a) = (v))
#define outl(a, v) (*(volatile unsigned long *)(a) = (v))
