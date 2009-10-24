#include <types.h>
#include <stdio.h>
#include <panic.h>
#include <loongson/addrspace.h>

/* the memory size for heap is 208MB(224 - 16) in total(see Documents/memory-map.txt),
 * here use the simple algorithm */

#define MALLOC_START_ADDR	(PHY_TO_CACHED(16*1024*1024))	
#define MALLOC_END_ADDR		(PHY_TO_CACHED(224*1024*1024))	

struct mem_list {
	ulong next;
	ulong status;
};
#define MEM_USED 1
#define MEM_FREE 0

int malloc_inited = 0;
#define MALLOC_INITED 1

ulong last_addr;    
ulong cur_addr;		// current addr avilable for allocate 

static void malloc_init(void)
{
	struct mem_list *temp;

	if(malloc_inited == MALLOC_INITED)
		return ;	

	temp = (struct mem_list *)(MALLOC_START_ADDR);
	if((ulong)temp & 0Xf) {	// mem_list structure should be 16 byte aligned 
		temp->next = MALLOC_END_ADDR;			
		temp->status = MEM_FREE;			
	} else {
		panic("malloc start addr not aligned!");
	}
	last_addr = 0x0; // invalid addr
	cur_addr  = MALLOC_START_ADDR;
	malloc_inited = MALLOC_INITED;
}

void * malloc(size_t size)
{
	return (void *)NULL;
}

void free(void * ptr)
{

}
