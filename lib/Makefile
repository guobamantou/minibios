libs-y := lib/early_printf.o

lib/early_printf.o: lib/early_printf.c $(src)/include/stdio.h lib/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
