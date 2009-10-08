#include <autoconf.h>
#include <device/flash.h>
#include <device/flash_id.h>
#include <io.h>
#include <stdio.h>
#include <errno.h>

#ifdef CONFIG_DEBUG
#include <debug.h>
#endif

#ifdef CONFIG_DEBUG
void print_flash_device(struct flash_device *dev)
{
	if(dev){
		printf("flash name is %s\n", dev->name);
		printf("manufact id is %x\n", dev->manufact_id);
		printf("device id is %x\n", dev->device_id);
		printf("sector size is %x KB\n", dev->sector_size * 4);
		printf("flash size is %x KB\n", dev->size * 64);
		printf("flash vaddr is %x\n", dev->vaddr);
	}
}
#else
void print_flash_device(struct flash_device *dev)
{
}
#endif
int boot_flash_init(struct flash_device *dev)
{
#ifdef CONFIG_64BITS
	dev->vaddr = (char *)0xffffffffbfc00000;
#else
	dev->vaddr = (char *)0xbfc00000;
#endif
	return flash_ident(dev);
}

#ifdef CONFIG_SST
extern struct flash_ops sst_flash_ops;
#endif
#ifdef CONFIG_MACRONIX
extern struct flash_ops mx_flash_ops;
#endif

int flash_ident(struct flash_device *dev)
{
	u8 manufactId = 0, deviceId = 0;

#ifdef CONFIG_SST
	outb(dev->vaddr + 0x5555, 0xaa);	
	outb(dev->vaddr + 0x2aaa, 0x55);	
	outb(dev->vaddr + 0x5555, 0x90);	
	manufactId = inb(dev->vaddr);
	deviceId = inb(dev->vaddr + 1);
	outb(dev->vaddr + 0x5555, 0xaa);	
	outb(dev->vaddr + 0x2aaa, 0x55);	
	outb(dev->vaddr + 0x5555, 0xf0);	
	if(manufactId == MANUFACTURER_SST){
		dev->manufact_id = MANUFACTURER_SST;
		dev->device_id = deviceId;
		dev->sector_size = 1; // unit is 4KB
		dev->size = 8; // unit is 64KB
		dev->name = "sst"; 
		dev->ops = &sst_flash_ops;
		return 1;		
	}
#endif

#ifdef CONFIG_MACRONIX
	outb(dev->vaddr + 0x555, 0xaa);	
	outb(dev->vaddr + 0x2aa, 0x55);	
	outb(dev->vaddr + 0x555, 0x90);	
	manufactId = inb(dev->vaddr);
	deviceId = inb(dev->vaddr + 1);
	if(manufactId == MANUFACTURER_MACRONIX){
		dev->manufact_id = MANUFACTURER_MACRONIX;
		dev->device_id = deviceId;
		dev->sector_size = 16; // unit is KB
		dev->size = 8;  // unit is 64KB
		dev->name = "mx"; 
		dev->ops = &mx_flash_ops;
		return 1;		
	}
#endif

	return 0;
}

static inline ulong head_erase_align(struct flash_device *dev, ulong addr)
{
	return (addr & (~((dev->sector_size << 12) - 1))); 
}

static ulong tail_erase_align(struct flash_device *dev, ulong end_addr)
{
	return head_erase_align(dev, end_addr + (dev->sector_size << 12) -1); 
}

/* return 0 unless aligned */
static inline int erase_not_aligned(struct flash_device *dev, ulong addr)
{
	return (addr & ((dev->sector_size << 12) - 1)); 
}

int flash_erase(struct flash_device *dev, ulong start_addr, ulong end_addr)
{
	if(erase_not_aligned(dev, start_addr))		
		start_addr = head_erase_align(dev, start_addr);
	end_addr = tail_erase_align(dev, end_addr);	

	/*first check whether erase the whole chip*/
	if(start_addr == (ulong)dev->vaddr){
		if((end_addr + 1 - start_addr) == ((dev->size << 16))){
			dprintf("starting erase chip ...");	
			dev->ops->flash_erase_chip(dev);
			dprintf(".");	
			while(dev->ops->flash_erase_busy(dev, 0)){
				dprintf(".");	
				//udelay(10);
			}
			dprintf("\n");	
			return 1;
		}
	}
	/*erase some sectors, one by one*/
	{	
		ulong offset = 0; 
		ulong sector_size = dev->sector_size >> 12;

		printf("start addr is %x, end addr is %x\n",start_addr, end_addr);	
		while(start_addr + offset <= end_addr){
			dprintf("erase sector %d ...",(offset >> 12));	
			dev->ops->flash_erase_sector(dev,offset);	
			dprintf(".");	
			while(dev->ops->flash_erase_busy(dev, offset)){	
				dprintf(".");	
				//udelay(10);
			}
			offset += sector_size;
			dprintf("\n");	
		}
		dprintf("erase done1\n");	
		return 1;
	}
}

#define SECTOR_SIZE 0x1000   // 4KB
char tmp_buf[SECTOR_SIZE];


/* program data_addr[0-data_size] to dev, starting addr's offset is flash_offset*/
int flash_program(struct flash_device *dev, u32 flash_offset, char *data_addr, int data_size)
{
	int pre_size;	
	ulong real_start_addr;
	ulong start_addr = (ulong)dev->vaddr + flash_offset;
	
	real_start_addr = head_erase_align(dev, start_addr);  	
	pre_size = start_addr - real_start_addr;
	
	//tmp_buf = malloc(pre_size + data_size); will implement shortly
	if(tmp_buf == NULL)	{
		printf("out of memory!\n");
		return -ENOMEM;
	}
	flash_erase(dev, real_start_addr, (start_addr + data_size));
	return 0;
}
