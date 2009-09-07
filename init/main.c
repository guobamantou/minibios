int test[256];

void main(void)
{
	int i;
	
	i= 0;	
	asm (".set mips3\n dli $2, 0xffffffffbfc00000;jalr $2":::"$2");
}
