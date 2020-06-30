#include "unistd.h"
#include "zircon_led.h"
#include "priv/alt_busy_sleep.h"
#include "alt_types.h"

extern alt_u32 led_controller_addr;

void zircon_led_allclose()
{
	IOWR_ZIRCON_LED_CONTROL(led_controller_addr,1);
	IOWR_ZIRCON_LED_DATA(led_controller_addr,0xff);
}

void zircon_led_allopen()
{
	IOWR_ZIRCON_LED_CONTROL(led_controller_addr,1);
	IOWR_ZIRCON_LED_DATA(led_controller_addr,0x00);
} 

void zircon_led_demo1()
{
	alt_u8 i;

	for(i = 0; i <= 254; i++)
	{
		IOWR_ZIRCON_LED_CONTROL(led_controller_addr,1);
		IOWR_ZIRCON_LED_DATA(led_controller_addr,~i);
		usleep(50000);
	}

}

void zircon_led_demo2(alt_u32 length ,alt_u32* led_data)
{
	alt_u8 i;

	for(i = 0; i < length;i++)
	{
		IOWR_ZIRCON_LED_CONTROL(led_controller_addr,1);
		IOWR_ZIRCON_LED_DATA(led_controller_addr, ~led_data[i]);
		usleep(100000);
	}

}


