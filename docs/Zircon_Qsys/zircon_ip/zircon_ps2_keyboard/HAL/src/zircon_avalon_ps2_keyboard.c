
//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_ps2_keyboard.c
//-- Describe : ps2_keyboard IP core driver C file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "zircon_avalon_ps2_keyboard.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "system.h"
#include  <stdio.h>

extern alt_u32 ps2keyboard_addr;

alt_u32  KeyboardData = 0;		//Read from the PS2 key
alt_u32  keydone = 0; //Signal quantity: notify the external interrupt event occurs


//---------------------------------------------------------------------------
//-- Name             	: ReadKeyboardData()
//-- Function          	: Read Keyboard Data
//-- Input parameters 	: no
//-- Output parameters	: Keyboard Data
//---------------------------------------------------------------------------
alt_u32 ReadKeyboardData(void)
{
	return(IORD_ZIRCON_AVALON_PS2_KEYBOARD_DATA(ps2keyboard_addr));
}

//---------------------------------------------------------------------------
//-- Name             	: KeyboardIRQ()
//-- Function          	: Interrupt service routine
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardIRQ(void* context, alt_u32 id)
{  

   KeyboardData = ReadKeyboardData();
   keydone++; 
}

//---------------------------------------------------------------------------
//-- Name             	: KeyboardInit()
//-- Function          	: Keyboard Interrupt Init
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardInit(void)
{
 
    alt_irq_register(ZIRCON_AVALON_PS2_KEYBOARD_IRQ, NULL, KeyboardIRQ);
}   

//---------------------------------------------------------------------------
//-- Name             	: KeyboarDemo()
//-- Function          	: Keyboard program demo
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardDemo(void)
{
	alt_u8 keydata;

	while(1)
	{
		if(keydone != 0)
		{
			keydone--;
			keydata = KeyboardData & 0x000000ff;

			if((KeyboardData & 0x100)!=0x100)
			{
				if( ((keydata >= 0x20) && (keydata < 0x7f)) && (((KeyboardData & 0x200)!=0x200) || (keydata != 0x2e)) )
				{
					printf("%c," ,keydata);
				}

			}
		}
	}
}
