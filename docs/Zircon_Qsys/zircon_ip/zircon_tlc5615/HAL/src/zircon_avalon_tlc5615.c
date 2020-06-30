//---------------------------------------------------------------------------
//-- Name     		: zircon_avalon_tlc5615.c
//-- Describe		: DA IP core driver C file
//-- Revision		: 2014-1-1
//-- Company		: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "alt_types.h"
#include "zircon_avalon_tlc5615.h"	

extern alt_u32 tlc5615_controller_addr;

//---------------------------------------------------------------------------
//-- Name             	: zircon_avalon_tlc5615_delay
//-- Function          	: software delays
//-- Input parameters 	: data: the delay parameters, the greater the value,
//--                      the longer the delay
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_tlc5615_delay(alt_u16 data)
{
	int i;
	for(i = 0; i < data; i++)
		;
}

//---------------------------------------------------------------------------
//-- Name             	: zircon_avalon_tlc5615_send
//-- Function          	: tlc5615 data transmission function
//-- Input parameters 	: length: the length of the data transmission,
//--                      wave_data: send data to the first address,
//--                      delay_data: delay time
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_tlc5615_send(alt_u16 length, alt_u16* wave_data, alt_u16 delay_data)
{
	alt_32 j,i = 0;

	for(j = 0; j < 200000; j++)
	{
		while(i < length)
		{
			IOWR_AVALON_ZIRCON_TLC5615_DATA(tlc5615_controller_addr,wave_data[i++]);
			zircon_avalon_tlc5615_delay(delay_data);
		}
		i = 0;
	}
	
}
