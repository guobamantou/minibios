#include <stdio.h>

void panic(const char *str)
{
	printf("PMON panic!\nerror msg:%s\n", str);
	while(1);
}
