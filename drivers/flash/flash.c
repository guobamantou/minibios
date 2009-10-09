#include <autoconf.h>
#include <device/flash.h>
#include <device/flash_id.h>
#include <io.h>
#include <string.h>
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
		printf("sector size is %d KB\n", dev->sector_size * 4);
		printf("flash size is %d KB\n", dev->size * 64);
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
	dev->vaddr = 0xffffffffbfc00000;
#else
	dev->vaddr = 0xbfc00000;
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
		dev->type = 8;
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
		dev->type = 8;
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
	return head_erase_align(dev, end_addr + (dev->sector_size << 12)) -1; 
}

/* return 0 unless aligned */
static inline int erase_not_aligned(struct flash_device *dev, ulong addr)
{
	return (addr & ((dev->sector_size << 12) - 1)); 
}

static int param_check(struct flash_device *dev, ulong start_addr, ulong end_addr)
{
	if(start_addr < dev->vaddr) {
		dprintf("start_addr < dev->vaddr\n");
		return 0;
	}
	if(end_addr > (dev->vaddr + (dev->size << 16))){
		dprintf("end_addr exceed\n");
		return 0;
	}
	if(start_addr > end_addr){
		dprintf("start_addr > end_addr\n");	
		return 0;
	}
	if((dev == NULL) || (dev->ops == NULL)){
		dprintf("dev or dev->ops is NULL");
		return 0;
	}
	return 1;
}

int flash_erase(struct flash_device *dev, ulong start_addr, ulong end_addr)
{
	if(erase_not_aligned(dev, start_addr))		
		start_addr = head_erase_align(dev, start_addr);
	end_addr = tail_erase_align(dev, end_addr);	

	if(!param_check(dev, start_addr, end_addr))
		return 0;
	/*first check whether erase the whole chip*/
	if(start_addr == dev->vaddr){
		if((end_addr + 1 - start_addr) == ((dev->size << 16))){
			dprintf("starting erase chip    ");	
			dev->ops->flash_erase_chip(dev);
			while(dev->ops->flash_erase_busy(dev, 0)){
				poll_output(10);	
				//udelay(10);
			}
			dprintf("\n");	
			dprintf("erase done!\n");	
			return 1;
		}
	}
	/*erase some sectors, one by one*/
	{	
		ulong offset = start_addr - dev->vaddr; 
		ulong sector_size = dev->sector_size << 12;

		printf("start addr is 0x%x, end addr is 0x%x\n",start_addr, end_addr);	
		while(dev->vaddr + offset <= end_addr){
			dprintf("erase sector %d   ",(offset >> 12));	
			dev->ops->flash_erase_sector(dev,offset);	
			while(dev->ops->flash_erase_busy(dev, offset)){	
				poll_output(10);
				//udelay(10);
			}
			offset += sector_size;
			dprintf("\n");	
		}
		dprintf("erase done!\n");	
		return 1;
	}
}

int flash_program(struct flash_device *dev, ulong start_addr, ulong end_addr, char *data_addr)
{
	int i;
	u8 *p = data_addr;

	if(erase_not_aligned(dev, start_addr))		
		start_addr = head_erase_align(dev, start_addr);
	end_addr = tail_erase_align(dev, end_addr);	

	if(!param_check(dev, start_addr, end_addr))
		return 0;
	
	/*we always use 8-bits flash till now, if new flash use 16/24-bits,change here*/

	if(dev->type != 8){
		dprintf("not support 16/24-bits flash now!\n");
		return 0;
	}

	end_addr -= dev->vaddr;	
	start_addr -= dev->vaddr;

	{
		dprintf("starting program flash ...");	
		for(i = start_addr; i <= end_addr; i++){
			dev->ops->flash_program(dev, i, *p++);	
			dprintf(".");	
			while(dev->ops->flash_program_busy(dev, i)){
				//udelay(10);
			}
		}
		dprintf("program done!\n.");	
		return 1;
	}
	return 0;
}

#define SECTOR_SIZE 0x1000   // 4KB
char tmp_buf[SECTOR_SIZE];

/* program data_addr[0-data_size] to dev, starting addr's offset is flash_offset*/
int flash_write(struct flash_device *dev, u32 flash_offset, char *data_addr, size_t data_size)
{
	int ret;
	size_t pre_size;	
	ulong real_start_addr;
	ulong start_addr = dev->vaddr + flash_offset;
	
	real_start_addr = head_erase_align(dev, start_addr);  	
	pre_size = start_addr - real_start_addr;
	
	//tmp_buf = malloc(pre_size + data_size); will implement shortly
	if(tmp_buf == NULL)	{
		printf("out of memory!\n");
		return -ENOMEM;
	}
	/*save the pre data, clear the following data in tht sector*/
	memcpy((void *)tmp_buf, (void *)real_start_addr, pre_size);
	memcpy((void *)tmp_buf + pre_size, (void *)start_addr, data_size);

	ret = flash_erase(dev, real_start_addr, (start_addr + data_size -1));
	if(ret <= 0){
		printf("erase failed, exit!");
		return 0;
	}
	flash_program(dev, real_start_addr, (start_addr + data_size -1), tmp_buf);	
	return 0;
}
