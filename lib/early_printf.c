#include <stdarg.h>
#include <types.h>
#include <uart-driver.h>

#define MAX_UART_PRINT_CHARS	128

char uart_print_buf[MAX_UART_PRINT_CHARS];

extern int parse_string(char buf[], int, const char *, va_list);

int uart_printf(const char * fmt, va_list args)
{
	int print_len;		

	print_len = parse_string(uart_print_buf, MAX_UART_PRINT_CHARS, fmt, args);

	uart_print_buf[print_len] = '\0'; //mark end
	uart_puts(uart_print_buf);	
	return print_len;
}

int early_printf(const char *fmt, ...)
{
	va_list args;
	int r;

	va_start(args, fmt);
	r = uart_printf(fmt, args);
	va_end(args);

	return r;
}

/*same to early_printf now*/
int printf(const char *fmt, ...)
{
	va_list args;
	int r;

	va_start(args, fmt);
	r = uart_printf(fmt, args);
	va_end(args);

	return r;
}


