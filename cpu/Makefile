libs-y += cpu/delay.o cpu/get-count.o

cpu/delay.o: cpu/delay.c cpu/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@

cpu/get-count.o: cpu/get-count.c cpu/Makefile
	$(CC) -c $< -mno-abicalls -I $(MINIBIOSINCLUDE) -o $@


