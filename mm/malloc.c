#include <types.h>
#include <stdio.h>
#include <panic.h>
#include <loongson/addrspace.h>

/* the memory size for heap is 208MB(224 - 16) in total(see Documents/memory-map.txt),
 * here use the simple algorithm */

#define MALLOC_START_ADDR	(PHY_TO_CACHED(16*1024*1024))	
#define MALLOC_END_ADDR		(PHY_TO_CACHED(224*1024*1024))	

struct mem_list {
	char status;
	size_t size; //unit: Byte
	struct mem_list *next;
} __attribute__((aligned(16)));

#define MEM_USED 1
#define MEM_FREE 0

#define SIZEOF_MEMLIST 16		// struct mem_list is 16 Bytes
struct mem_list mem_free_list;	// mem_free_list and mem_used_list are all list header
struct mem_list mem_used_list;

int malloc_inited = 0;
#define MALLOC_INITED 1

ulong cur_addr;		// current addr avilable for allocate 

static void list_add(struct mem_list *, struct mem_list *);
static void list_del(struct mem_list *, struct mem_list *);
static void print_list(struct mem_list *head);

static void malloc_init(void)
{
	struct mem_list *temp;
	if(malloc_inited == MALLOC_INITED)
		return ;	
	
	temp = (struct mem_list *)MALLOC_START_ADDR;
	temp->next = NULL;
	temp->size = MALLOC_END_ADDR - MALLOC_START_ADDR - SIZEOF_MEMLIST; 

	mem_used_list.next = NULL;
	mem_used_list.size = 0;
	mem_free_list.next = temp;
	mem_free_list.size = 0; 
	malloc_inited = MALLOC_INITED;
}

void * malloc(size_t size)
{
	struct mem_list *p, *q;

	if(malloc_inited != MALLOC_INITED)
		malloc_init();	

	if(size < 16)
		size = 16;
	size = (size + 15) & ~(0xf);

	p = mem_free_list.next;
	while(p){
		if(p->size >= size) {
			break;
		} else {
			p = p->next;
		}
	}

	if(p) {
		list_del(&mem_free_list, p);

		if(p->size - size > 128) { // we don't like fragment	
			q = (struct mem_list *)((ulong)p + SIZEOF_MEMLIST + size); 	
			q->size = p->size - 2 * SIZEOF_MEMLIST - size;
			p->size = size;
			list_add(&mem_free_list, q);
		}
		list_add(&mem_used_list, p);
	} else {
	//	reclaim_mem();
		printf("out of memory!");
		return (void *)NULL;
	}
#if 1
	printf("free\n");
	print_list(&mem_free_list);
	printf("used\n");
	print_list(&mem_used_list);
#endif
	return (void *)((ulong)p + SIZEOF_MEMLIST);
}

void free(void * ptr)
{

}

static void list_del(struct mem_list *head, struct mem_list *del)
{
	struct mem_list *p;

	if((del == NULL) || (head == NULL) || (head->next == NULL))
		return;	
	
	for(p = head; p ; p = p->next){
		if(p->next == del){
			p->next = del->next; // not free anything here
			return ;
		}	
	}	
}

static void list_add(struct mem_list *head, struct mem_list *new)
{
	struct mem_list *cur, *pre;

	if((new == NULL) || (head == NULL))
		return;	
	
	pre = head;
	cur = head->next;

	while(1){
		if((cur == NULL) || (cur > new)){
			new->next = pre->next;
			pre->next = new; 
			return ;
		}	
		pre = pre->next;
		cur = cur->next;
	}	
}

static void print_list(struct mem_list *head)
{
	struct mem_list *p;

	if(head && head->next)
		p = head->next;
	else 	
		return ;

	while(p){
		printf("addr is %x\n", p);
		printf("next is %x\n", p->next);
		printf("size is %x\n", p->size);
		p = p->next;
	}
}
