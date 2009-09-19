#include <stdarg.h>
#include <string.h>

#define SINT	(1 << 0) 		
#define USINT	(1 << 1)
#define SLONG	(1 << 2)
#define USLONG	(1 << 3)

static char *number(char *buf, char *end, unsigned long long num, int base , u32 flags) 
{
	static const char digits[16] = "0123456789ABCDEF";

	if(flags & SINT) {
		if(1);	
	}

	return buf;
}
/*
 * parse_string 
 * size feild is means the maximum len of this output transaction
 */
int parse_string(char str[], int size, const char * fmt, va_list args)
{
	char c;
	char *end ,*output;
	int base = 10;		// set default base to 10 
	u32 flags = USINT;  // set default flag to unsigned long
	unsigned long long num;
	size_t len;

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
			output = va_arg(args, char *);
			len = strlen(output);
			if(str + len < end) 
				memcpy(output, str, len);
			str += len;
			continue;
		case '%':
			if (str < end)
				*str = '%';
			str++;
			continue;
		case 'd':
		case 'i':
			flags |= SINT;
			break;
		case 'u':
			flags |= USINT;	
			break;
		case 'x':
			base = 16;
		default:
			break;
		}

		/* only to deal with int/unsigned int now */
		/* only to deal with 16/10 base */
		if(flags & USINT) {
			num = (unsigned int)va_arg(args, unsigned int);
		} else {
			num = (signed int)va_arg(args, int);
		}
		
		str = number(str, end, num, base, flags);
	}	

	return 1;
}
