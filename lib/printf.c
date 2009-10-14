#include <stdarg.h>
#include <string.h>

#define USCHAR	(1 << 0)
#define SCHAR	(1 << 1)
#define USSHORT	(1 << 2)
#define SSHORT	(1 << 3)
#define SINT	(1 << 4) 		
#define USINT	(1 << 5)
#define SLONG	(1 << 6)
#define USLONG	(1 << 7)

#define BASE2	(1 << 16)
#define BASE8	(1 << 17)
#define BASE10  (1 << 18)
#define BASE16  (1 << 19)

static char *number(char *buf, char *end, unsigned long long num, u32 flags) 
{
	static const char digits[16] = "0123456789ABCDEF";
	char tmp[66]; // 1(signed) + 64(digits) + 1 
	int sign = 0, i;

	if(flags & (SINT | SLONG)) {
		sign = 1;
	} 

	i = 0;
	if(flags & BASE10) {
		if(sign && ((signed long)num < 0)) {
			if((buf + 1) < end)
				*buf++ = '-'; 
			num = 0 - num;
		}

		/* NOTICE: if remove u32 in following 3 lines,compiler error*/
		/* this will have problem when long is 64 bits */
		do {
			tmp[i++] = digits[(u32)num % 10];
		} while(num = ((u32)num / 10));	
	} else if(flags & BASE16) {
		do {
			tmp[i++] = digits[num & 0xf];
		} while(num = (num >> 4));		
	}
	
	if (buf + i < end) {
		while(i) {
			*buf++ = tmp[--i];
		}
	}
	return buf;
}
/*
 * parse_string 
 * size feild is means the maximum len of this output transaction
 */
int parse_string(char buf[], int size, const char * fmt, va_list args)
{
	char c;
	char *str, *end ,*output;
	u32 flags ;
	unsigned long long num;
	size_t len;

	str = buf;
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
				memcpy(str, output, len);
			str += len;
			continue;
		case '%':
			if (str < end)
				*str = '%';
			str++;
			continue;
		case 'd':
		case 'i':
			flags = BASE10 | SINT;
			break;
		case 'u':
			flags = BASE10 | USINT;	
			break;
		case 'x':
			flags = BASE16 | USINT;	
			break;
		default:
			flags = (USINT | BASE10);
		}

		/* only to deal with int/unsigned int now */
		/* only to deal with 16/10 base */
		if(flags & USINT) {
			num = (unsigned int)va_arg(args, unsigned int);
		} else {
			num = (signed int)va_arg(args, int);
		}
		
		str = number(str, end, num, flags);
	}	

	return str - buf;
}


