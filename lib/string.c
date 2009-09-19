#include <types.h>

#ifdef CONFIG_HAVE_ARCH_MEMCPY
#ifndef HAVE_ARCH_MEMCPY
#define HAVE_ARCH_MEMCPY
#endif
#endif
size_t strlen(const char *s)
{
	const char *sc;

	for (sc = s; *sc != '\0'; sc++)
		/* nothing */;
	return sc - s;
}

#ifdef HAVE_ARCH_MEMCPY
void* memcpy(void *dest, const void *src, size_t size)
{
	if(!(unsigned long)dest ^ (unsigned long)src) {
		__memcpy_aligned((unsigned long)dest, (unsigned long)src, size);
		return dest;
	}

	__memcpy_unaligned((unsigned long)dest, (unsigned long)src, size);

	return dest;
}

#else 
void* memcpy(void *dest, const void *src, size_t size)
{
	char *tmp = dest;
	const char *s = src;

	while (size--){
		*tmp++ = *s++;
	}
	return dest;
}

#endif
	
