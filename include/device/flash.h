#include <types.h>

struct flash_ops;
typedef struct flash_device {
	char	*name;
	ulong	vaddr;
	u8	manufact_id;
	u8	device_id;
	u8	size;        // unit 64KB
	u8	sector_size; // unit 4KB
	u8	type;
	struct flash_ops	*ops;
} flash_device;

struct flash_ops {
	void (*flash_erase_chip)(struct flash_device *);	
	void (*flash_erase_sector)(struct flash_device *, u32);	
	int  (*flash_erase_busy)(struct flash_device *, u32);	
	int  (*flash_program_busy)(struct flash_device *, u32);	
	void (*flash_program)(struct flash_device *, u32, u8);	
};
