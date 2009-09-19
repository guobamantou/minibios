typedef char *va_list;

/*storage align*/
#define _AUPBND		(sizeof (unsigned int) - 1)
#define _ADNBND		(sizeof (unsigned int) - 1)

#define _bnd(X, bnd) 	((sizeof(X) + _AUPBND) & (~_AUPBND))

#define va_start(ap, A) (void) ((ap) = ((char *) &(A)) + (_bnd (A, _AUPBND)))
#define va_end(ap)		(void) 0
#define va_arg(ap, T)	(*(T *)((ap) += (_bnd (T, _AUPBND))) - (_bnd (T, _ADNBND)))
