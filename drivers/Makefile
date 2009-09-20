drivers-y := drivers/uart/uart.o

drivers/uart/uart.o:drivers/uart/uart.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
