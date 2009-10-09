#include <stdio.h>

void poll_output(int rate)
{
	char *output_array =  "|/-\\";
	static char *output;
	static int tick;

	if(rate < 0)
		return;
	if(tick++ < rate)
		return;
	tick = 0;
	if(!output | !(*output))
		output = output_array;
	printf("\b%c", *output++);	
}
