libs-y +=  $(src)/mm/malloc.o 

$(src)/mm/malloc.o: $(src)/mm/malloc.c $(src)/mm/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
