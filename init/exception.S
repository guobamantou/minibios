### every string len is 25 bytes ,dont change ###
#define EXC_STR_LEN		25

exc_int:
.asciz "an interrupt occur    \r\n"
exc_mod:
.asciz "modify TLB exception  \r\n"
exc_tlbl:
.asciz "TLB load exception    \r\n"
exc_tlbs:
.asciz "TLB store exception   \r\n"
exc_adel:
.asciz "addr error when load  \r\n"
exc_ades:
.asciz "addr error when store \r\n"
exc_ibe:
.asciz "bus err:read instruct \r\n"
exc_dbe:
.asciz "bus err:read/wr data  \r\n"	
exc_sys:
.asciz "syscall exception     \r\n"
exc_bp:
.asciz "break point           \r\n"
exc_ri:
.asciz "reserved instruction  \r\n"
exc_cpu:
.asciz "cant use co-processor \r\n"
exc_ov:
.asciz "arithmetic overflow   \r\n"
exc_tr:
.asciz "trap exception\r\n"
exc_fpe:
.asciz "float-point exception\r\n"
exc_watch:
.asciz "watch exception\r\n"

/* in addr 0xbfc00200*/
.align 9
tlb_exc:
	PRINTF("XTLB refill exception!\r\n");

dump_reg:	
	PRINTF("cause reg : 0x");
	mfc0	a0, CP0_CAUSE
	bal		uart_put_hex
	nop
	PRINTF("\r\n      EPC : 0x");
	mfc0	a0, CP0_EPC
	bal		uart_put_hex
	nop
	PRINTF("\r\n Exc-Code : 0x");
	mfc0	s0, CP0_CAUSE
	andi	s0, EXC_CODE 
	srl		s0, s0, 2	
	add		a0, s0, zero
	bal		uart_put_hex
	nop
	PRINTF("\r\n");

detail:
	sltiu	a0, s0, (EXC_TR + 1)		
	beq		a0, zero, 1f	# >EXC_TR
	nop
	la		a0, exc_int 
	li		s1,	EXC_STR_LEN
	mul		s1,	s0, s1
	nop
	add		a0, s1
	bal		uart_puts
	nop
	b	stop
	nop
1:
	li		a0, EXC_FPE
	bne		a0, s0, 1f
	nop
	la		a0, exc_fpe
	bal		uart_puts
	nop
1:
	li		a0, EXC_WATCH
	bne		a0, s0, 1f
	nop
	la		a0, exc_fpe
	bal		uart_puts
	nop
1:
	PRINTF("unknown exception ^.^\r\n");
	b stop
	nop
	
stop:
	b	stop
	nop
/* locate in addr 0xbfc00380*/

.align	7
other_exc:
	PRINTF("other exception !\r\n");
	bal	dump_reg
	nop


