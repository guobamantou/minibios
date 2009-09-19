libs-y += cpu/loongson2f/memcpy.o

%.o:%.c cpu/loongson/loongson2f/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	

