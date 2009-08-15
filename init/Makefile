$(src)/init/start:	$(src)/init/start.S $(src)/init/Makefile
	$(CC) -E $(src)/init/start.S  -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
	$(LD) $(src)/init/start.o -o $(src)/init/start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
