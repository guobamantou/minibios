#ifdef CONFIG_64BIT
#define	PHY_TO_UNCACHED(p)	((p)|0xffffffffa0000000)
#define	PHY_TO_CACHED(p)	((p)|0xffffffff80000000)
#else
#define	PHY_TO_UNCACHED(p)	((p)|0xa0000000)
#define	PHY_TO_CACHED(p)	((p)|0x80000000)
#endif
