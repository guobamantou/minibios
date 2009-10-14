drivers-y := drivers/uart/uart.o drivers/flash/flash.o drivers/flash/sst_flash.o drivers/flash/mx_flash.o drivers/rtc/cs5536-rtc.o


drivers/uart/uart.o:drivers/uart/uart.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
drivers/flash/sst_flash.o:drivers/flash/sst_flash.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
drivers/flash/mx_flash.o:drivers/flash/mx_flash.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
drivers/flash/flash.o:drivers/flash/flash.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
drivers/rtc/cs5536-rtc.o:drivers/rtc/cs5536-rtc.c drivers/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@

