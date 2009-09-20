libs-y := $(src)/lib/early_printf.o $(src)/lib/printf.o $(src)/lib/string.o

$(src)/lib/early_printf.o: $(src)/lib/early_printf.c $(src)/lib/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/printf.o: $(src)/lib/printf.c $(src)/lib/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/string.o: $(src)/lib/string.c $(src)/lib/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
