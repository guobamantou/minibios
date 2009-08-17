$(src)/init/start:	$(src)/init/start.o $(src)/init/hello.o
	$(LD) $(src)/init/start.o $(src)/init/hello.o -o $(src)/init/start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
$(src)/init/start.o:$(src)/init/start.S $(src)/init/Makefile
	$(CC) -E $<  -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
$(src)/init/hello.o:$(src)/init/hello.c $(src)/init/Makefile
	$(CC) -c $< -o $@
