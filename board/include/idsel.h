#include <autoconf.h>

#ifdef CONFIG_LOONGSON2F_YEELOONG
#define RTL8139_IDSEL	7
#define SM712_IDSEL		8
#define NEC0035_IDSEL 	9  /*I dont know the name exactly,0035 is product id*/
#define CS5536_IDSEL	14
#endif

#ifdef CONFIG_LOONGSON2F_FULOONG
#define CS5536_IDSEL	14
#endif
