######## save all registers before any opration, k0 is not use in minibios ,so use for store base addr########

#define SAVE_ALL \
	.set noat;\
	lui	k0, 0x8000;\
	sw	$0,  0(k0);\
	sw	$1,  4(k0);\
	sw	$2,  8(k0);\
	sw	$3, 12(k0);\
	sw	$4, 16(k0);\
	sw	$5, 20(k0);\
	sw	$6, 24(k0);\
	sw	$7, 28(k0);\
	sw	$8, 32(k0);\
	sw	$9, 36(k0);\
	sw	$10,40(k0);\
	sw	$11,44(k0);\
	sw	$12,48(k0);\
	sw	$13,52(k0);\
	sw	$14,56(k0);\
	sw	$15,60(k0);\
	sw	$16,64(k0);\
	sw	$17,68(k0);\
	sw	$18,72(k0);\
	sw	$19,76(k0);\
	sw	$20,80(k0);\
	sw	$21,84(k0);\
	sw	$22,88(k0);\
	sw	$23,92(k0);\
	sw	$24,96(k0);\
	sw	$25,100(k0);\
	sw	$26,104(k0);\
	sw	$27,108(k0);\
	sw	$28,112(k0);\
	sw	$29,116(k0);\
	sw	$30,120(k0);\
	sw	$31,124(k0)

	
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
.asciz "trap exception        \r\n"
exc_reserved:
.asciz "reserved exception ^6^\r\n"
exc_fpe:
.asciz "float-point exception\r\n"
exc_watch:
.asciz "watch exception\r\n"

/* in addr 0xbfc00200*/
.align 9
tlb_exc:
	SAVE_ALL;
	REALPRINTF("XTLB refill exception!\r\n");

dump_reg:	
	REALPRINTF("cause reg : 0x");
	mfc0	a0, CP0_CAUSE
	bal	uart_put_hex
	nop
	REALPRINTF("\r\n      EPC : 0x");
	mfc0	a0, CP0_EPC
	bal	uart_put_hex
	nop
	REALPRINTF("\r\n Exc-Code : 0x");
	mfc0	s0, CP0_CAUSE
	andi	s0, EXC_CODE 
	srl	s0, s0, 2	
	add	a0, s0, zero
	bal	uart_put_hex
	nop
	REALPRINTF("\r\n");

detail:
	sltiu	a0, s0, (EXC_FPE + 1)		
	beq	a0, zero, 1f	# >EXC_TR
	nop
	la	a0, exc_int 
	li	s1, EXC_STR_LEN
	mul	s1, s0, s1
	nop
	add	a0, s1
	bal	uart_puts
	nop
	b	stop
	nop
1:
	li	a0, EXC_WATCH
	bne	a0, s0, 1f
	nop
	la	a0, exc_watch
	bal	uart_puts
	nop
	b	stop
	nop
1:
	REALPRINTF("unknown exception ^.^\r\n"); 
	
	b	stop
	nop
/* locate in addr 0xbfc00380*/

.align	7
other_exc:
	SAVE_ALL;	
	REALPRINTF("other exception !\r\n");
	bal	dump_reg
	nop
stop:
	lui	t6, 0x8000
	li	t7, 0
	li	t5, 31
1:
	add	a0, t7, zero
	bal	uart_put_hex
	addiu	t7, t7, 1
	PRINTF(":");
	lw	a0, 0(t6)
	bal	uart_put_hex
	nop
	PRINTF("\r\n");
	bne	t7, t5, 1b
	addiu	t6, t6, 4
stop1:
	b	stop1	
	nop         /* these nops make other_exc located at 0xbfc00380 */
	nop

