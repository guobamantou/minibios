void hello()
{
	int i;
	for(i=0; i<4; i++)
	*(unsigned char *)(0xa0000000+i)= 'A';
}
