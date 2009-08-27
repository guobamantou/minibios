$(src)/init/start:	$(src)/init/start.o 
	$(LD) $^ -o $(src)/init/start -e _start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
$(src)/init/start.o:$(src)/init/start.S $(src)/init/uart.S $(src)/init/smb.S $(src)/init/exception.S $(src)/init/Makefile 
	$(CC) -E $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
	
