#include <io.h>
#include <types.h>

void sst_erase_sector(u32 offset)
{
	u32 flash_addr = 0xbfc00000;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x80);
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + offset, 0x30);
	
	return ;
}
void sst_erase_chip()
{
	u32 flash_addr = 0xbfc00000;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x80);
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x10);
	
	return ;
}
