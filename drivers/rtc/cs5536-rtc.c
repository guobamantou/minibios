#include <io.h>
#include <time.h>
#include <types.h>
#include <stdio.h>
#include <device/rtc.h>

/* see amd cs5536 manual P363, RTC use legacy i/o addr 70h/71h*/

/* I dont use delay here, because I cant find status reg in RTC and the manual
 * not mention delay time, it seems work now*/
void cmos_write(u8 addr, u8 val)
{
	io_outb(RTC_ADDR_PORT, addr);
	io_outb(RTC_DATA_PORT, val);
}

u8 cmos_read(u8 addr)
{
	io_outb(RTC_ADDR_PORT, addr);
	return io_inb(RTC_DATA_PORT);
}

u8 week_day(u8 year, u8 month, u8 day)
{
	/* 2000-1-1 is Saturday*/	
	int days = 0;
	int i;

	if(year)
		days = (year * 365) + ((year + 3) / 4);
	if(!(year % 4))
		month_day[1] = 29; 
	for(i = 1; i < month; i++)
		days += month_day[i-1];
	days += day; // add one day more
	return ((days + 5) % 7);
}

/*in minibios, I limits year from 2000-2099*/
int set_date(u8 year, u8 month, u8 day, u8 hour, u8 min, u8 sec)
{
	if((year > 99) || (month > 12) || (day > 31) || 
	   (hour > 23) || (min > 59) || (sec > 59)){
		printf("invalid date format\n");
		return -1;	
   	} 

	if((year % 4) && (month == 2) && (day == 29)){
		printf("invalid date format\n");
		return -1;	
   	} 

	cmos_write(RTC_YEAR , year);
    cmos_write(RTC_MONTH, month);
    cmos_write(RTC_DAY  , day);
    cmos_write(RTC_HOUR , hour);
    cmos_write(RTC_MIN  , min);
    cmos_write(RTC_SEC  , sec);
	cmos_write(RTC_WEEK , week_day(year, month, day));   	
	return 0;
}

/* the function name may be not suitable, rtc not need any initial normally*/
int init_cs5536_rtc(void)
{
	u8 year, month, day, hour, min, sec;
#if 0	
	cmos_write(RTC_CTRL_A, 0x20); // normal operation
	cmos_write(RTC_CTRL_B, 0x2|0x4|0x80); // 24HOURS + binary format + access enable
	cmos_write(RTC_CTRL_C, 0);
	cmos_write(RTC_CTRL_D, 0);
#endif
	year  = cmos_read(RTC_YEAR);	
	month = cmos_read(RTC_MONTH);	
	day   = cmos_read(RTC_DAY);	
	hour  = cmos_read(RTC_HOUR);	
	min   = cmos_read(RTC_MIN);	
	sec   = cmos_read(RTC_SEC);	

    if((year > 99) || (month > 12) || (day > 31) || 
		(hour > 23) || (min > 59) || (sec > 59)){
        cmos_write(RTC_YEAR , 8);
        cmos_write(RTC_MONTH, 8);
        cmos_write(RTC_DAY  , 8);
        cmos_write(RTC_HOUR , 8);
        cmos_write(RTC_MIN  , 8);
        cmos_write(RTC_SEC  , 8);
		cmos_write(RTC_WEEK , 5); // 2008-8-8 is Friday
		return 0;
    }

	return 1;
}
