#include <io.h>
#include <device/flash.h>

/* return non-zero means busy*/
static int sst_erase_busy(struct flash_device *dev, u32 offset)
{
	u8 poll;
	ulong flash_addr = dev->vaddr;

	poll = inb(flash_addr + offset);	
	if(poll & 0x80) // see sst flash datasheet Data# Polling (DQ7) 
		return 0;
	return 1;	
}

/* return non-zero means busy*/
static int sst_program_busy(struct flash_device *dev, u32 offset)
{
	u8 poll1, poll2;
	ulong flash_addr = dev->vaddr;

	poll1 = inb(flash_addr + offset);	
	poll2 = inb(flash_addr + offset);	
	if((poll1 ^ poll2) & 0x40) // set sst flash datasheet Toggle Bit(DQ6)
		return 1;
	return 0;
}

static void sst_flash_program(struct flash_device *dev, u32 offset, u8 val)
{
	ulong flash_addr = dev->vaddr;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0xa0);
	outb(flash_addr + offset, val);
}

static void sst_erase_sector(struct flash_device *dev, u32 offset)
{
	ulong flash_addr = dev->vaddr;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x80);
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + offset, 0x30);
}

static void sst_erase_chip(struct flash_device *dev)
{
	ulong flash_addr = dev->vaddr;
	
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x80);
	outb(flash_addr + 0x5555, 0xaa);
	outb(flash_addr + 0x2aaa, 0x55);
	outb(flash_addr + 0x5555, 0x10);
}

struct flash_ops sst_flash_ops = {
	.flash_erase_chip 	= sst_erase_chip,
	.flash_erase_sector	= sst_erase_sector,
	.flash_erase_busy	= sst_erase_busy,
	.flash_program_busy	= sst_program_busy,
	.flash_program		= sst_flash_program,
};

