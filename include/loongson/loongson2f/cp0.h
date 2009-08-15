/*
 * according to Loongson2F user manual
 *
 */
#define CP0_TLB_INDEX		$0
#define CP0_TLB_RANDOM		$1
#define CP0_TLB_LO0			$2
#define CP0_TLB_LO1			$3
#define CP0_TLB_CONTEXT		$4
#define CP0_TLB_PG_MASK		$5
#define CP0_TLB_WIRED		$6
/*reg 7 reserved*/
#define CP0_BAD_VADDR		$8
#define CP0_COUNT			$9
#define CP0_TLB_ENTRY_HI	$10
#define CP0_COMPARE			$11
#define CP0_STATUS			$12
#define CP0_CAUSE			$13
#define CP0_EPC				$14
#define CP0_PRID			$15
#define CP0_CONFIG			$16
#define CP0_LLADDR			$17
#define CP0_WATCH			$18
/*reg 19 reserved*/
#define CP0_TLB_XCONTEXT	$20
/*reg 21 reserved*/
#define CP0_DIAGNOSE		$22
/*reg 23 reserved*/
#define CP0_PCLO			$24
#define CP0_PCHI			$25
/*reg 26,27 reserved*/
#define CP0_TAG_LO			$28
#define CP0_TAG_HI			$29
#define CP0_ERROREPC		$30
