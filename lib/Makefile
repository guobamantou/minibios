libs-y += $(src)/lib/early_printf.o $(src)/lib/printf.o $(src)/lib/string.o $(src)/lib/poll_output.o $(src)/lib/panic.o 

$(src)/lib/early_printf.o: $(src)/lib/early_printf.c $(src)/lib/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/printf.o: $(src)/lib/printf.c $(src)/lib/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/string.o: $(src)/lib/string.c $(src)/lib/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/poll_output.o: $(src)/lib/poll_output.c $(src)/lib/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
$(src)/lib/panic.o: $(src)/lib/panic.c $(src)/lib/Makefile
	$(CC) $(CFLAGS) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@	
