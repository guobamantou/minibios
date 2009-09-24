#include <autoconf.h>
#ifdef CONFIG_64BITS
#define UART_ADDR 0xffffffff1ff003f8
#else
#define UART_ADDR 0x1ff003f8
#endif
#define UART_BAUD 3686400
