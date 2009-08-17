$(src)/init/start:	$(src)/init/start.S $(src)/init/Makefile
	$(CC) -E $<  -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
#$(CC) -G 0 -I$(MINIBIOSINCLUDE) -nostdinc -mno-abicalls -mips3 -mmemcpy -c $< -o $(src)/init/start.o
	$(LD) $(src)/init/start.o -o $(src)/init/start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
