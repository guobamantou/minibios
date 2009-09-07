asm_file = $(wildcard $(src)/init/*.S)

$(src)/init/start:	$(src)/init/start.o $(src)/init/main.o
	$(LD) $^ -o $(src)/init/start -e _start -T $(minibios-lds)
	@cp $(src)/init/start $(src)/minibios
	$(OBJCOPY) -O binary $(src)/minibios $(src)/minibios.rom 
$(src)/init/start.o: $(asm_file)
	$(CC) -E $(src)/init/start.S -mno-abicalls -I $(MINIBIOSINCLUDE) -o $(src)/init/start.s
	$(AS) -o $(src)/init/start.o $(src)/init/start.s
$(src)/init/main.o:$(src)/init/main.c $(src)/init/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@
