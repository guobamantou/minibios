libs-y := lib/early_printf.o lib/printf.o lib/string.o

%.o: %.c lib/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	

