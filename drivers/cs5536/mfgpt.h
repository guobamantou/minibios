#define MFGPT0_COMPARATOR_1  0x0
#define MFGPT0_COMPARATOR_2  0x2
#define MFGPT0_UP_COUNTER    0x4
#define MFGPT0_SETUP         0x6

#define MFGPT_CNT_EN_SHIFT  15
#define MFGPT_CMP1MODE_SHIFT 6
#define MFGPT_CMP2MODE_SHIFT 8
#define MFGPT_CLKSEL_SHIFT  4
#define MFGPT_SCALE_SHIFT   0

#define MFGPT_CNT_EN        1

#define MFGPT_CLKSEL_32K    0
#define MFGPT_CLKSEL_14M    1

#define ALWAYS_LOW         0x0
#define COMPARE_ON_EQUAL   0x1
#define COMPARE_ON_GE      0x2
#define EVENT              0x3

