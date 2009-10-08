#include <autoconf.h>

#ifdef CONFIG_DEBUG
#define dprintf(fmt, args...)  do {early_printf(fmt, ## args);} while(0)
#else
#define dprintf(fmt, args...)  do{} while(0)
#endif
