#include <io.h>
#include <types.h>

int sst_erase_busy(u32 offset)
{
	u8 poll;
	u32 flash_addr = 0xbfc00000;

	poll = inb(flash_addr + offset);	
	if(poll & 0x80) // see sst flash datasheet Data# Polling (DQ7) 
		return 1;
	return 0;	
}

int sst_program_busy()
{
	u8 poll1, poll2;
	u32 flash_addr = 0xbfc00000;

	poll1 = inb(flash_addr + offset);	
	poll2 = inb(flash_addr + offset);	
	if((poll1 ^ poll2) & 0x40) // set sst flash datasheet Toggle Bit(DQ6)
		return 1;
	return 0;
}

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
