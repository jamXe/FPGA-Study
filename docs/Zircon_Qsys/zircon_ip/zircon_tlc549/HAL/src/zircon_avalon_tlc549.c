//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_tlc549.c
//-- Describe : tlc549 IP core driver C file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "unistd.h"	
#include <stdio.h>	
#include "alt_types.h"	
#include "zircon_avalon_tlc549_regs.h"

extern alt_u32 tlc549_controller_addr;

//---------------------------------------------------------------------------
//-- Name             	: zircon_avalon_tlc549_read()
//-- Function          	: Read the value of AD
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_tlc549_read()
{
	int 	ad_data;
	float 	ad_value;
	
	ad_data = IORD_ZIRCON_AVALON_TLC549_DATA(tlc549_controller_addr);

	printf("data = %d ,",ad_data);

	ad_value = ad_data;
	ad_value = ad_value / 255 * 5;

	printf("Value = %2.1fV .",ad_value);

	usleep(1000000);

}
