#include <stdarg.h>
#include <types.h>

#define MAX_UART_PRINT_CHARS	128

static char uart_print_buf[MAX_UART_PRINT_CHARS];

int early_printf(const char *fmt, ...)
{
	va_list args;
	int r;

	va_start(args, fmt);
	r = uart_printf(fmt, args);
	va_end(args);

	return r;
}

int uart_printf(const char * fmt, va_list args)
{
	int print_len;		

	print_len = parse_string(uart_print_buf, MAX_UART_PRINT_CHARS, fmt, args);

	return 0;
}
