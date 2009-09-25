drivers-y := drivers/uart/uart.o drivers/flash/sst_flash.o

drivers/uart/uart.o:drivers/uart/uart.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@

drivers/flash/sst_flash.o:drivers/flash/sst_flash.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
