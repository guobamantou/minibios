$(src)/init/start:	$(src)/init/start.o $(src)/init/main.o
	$(LD) $^ -o $(src)/init/start -e _start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
$(src)/init/start.o:$(src)/init/start.S $(src)/init/cache.S $(src)/init/ddr2.S $(src)/init/uart.S $(src)/init/smb.S $(src)/init/exception.S $(src)/init/Makefile 
	$(CC) -E $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
$(src)/init/main.o:$(src)/init/main.c $(src)/init/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
