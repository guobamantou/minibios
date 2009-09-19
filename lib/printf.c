#include <stdarg.h>
#include <string.h>

/*
 * parse_string 
 * size feild is means the maximum len of this output transaction
 */
int parse_string(char str[], int size, const char * fmt, va_list args)
{
	char *end ,*out;
	char c;

	end = str + size;

	for (; *fmt; fmt++) {
		if (*fmt != '%') {
			if(str < end)
				*str = *fmt;
			str++;
			continue;
		}	
	
		fmt++; // skip first '%'

		switch (*fmt) {
		case 'c':
			c = (u8) va_arg(args, int);	
			if (str < end)
				*str = c;
			str++;
			continue;
		case 's':
			out = va_arg(args, char *);
			if(str + strlen(out) < end) ;
				memcpy(out, str, strlen(out));
			str += strlen(out);

		default:
			break;
		}
		
	}	

	return 1;
}
