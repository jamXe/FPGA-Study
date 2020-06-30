//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_ps2_mouse.c
//-- Describe : ps2_mouse IP core driver C file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "zircon_avalon_ps2_mouse.h"
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "system.h"
#include  <stdio.h>

extern alt_u32 ps2mouse_addr;

alt_u32  MouseDone;	//Signal quantity: notify the external interrupt event occurs
alt_u32  MouseData;	//Read from the PS2 key

alt_16 x = 0;
alt_16 y = 0;

struct {
	signed	x:9,
			y:9;
}inc={0,0};

//---------------------------------------------------------------------------
//-- Name             	: ReadMouseData()
//-- Function          	: Read Mouse Data
//-- Input parameters 	: no
//-- Output parameters	: Mouse Data
//---------------------------------------------------------------------------
alt_u32 ReadMouseData(void)
{
	return(IORD_ZIRCON_AVALON_PS2_MOUSE_DATA(ps2mouse_addr));
}

//---------------------------------------------------------------------------
//-- Name             	: MouseInit()
//-- Function          	: Interrupt service routine
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseIRQ(void* context, alt_u32 id)
{  
   MouseData = ReadMouseData();
   MouseDone++; 
}

//---------------------------------------------------------------------------
//-- Name             	: MouseInit()
//-- Function          	: Mouse Interrupt Init
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseInit(void)
{
	alt_irq_register(ZIRCON_AVALON_PS2_MOUSE_IRQ, NULL, MouseIRQ);
}    

//---------------------------------------------------------------------------
//-- Name             	: MouseDemo()
//-- Function          	: Mouse program demo
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseDemo(void)
{
	while(1)
	{
		if(MouseDone != 0)
		{
			MouseDone--;
			if((MouseData & 0x00100000) == 0x00100000)	//Mouse left
			{
				printf("left press\n");
			}
			if((MouseData & 0x00080000) == 0x00080000)	//Mouse right
			{
				printf("right press\n");
			}
			if((MouseData & 0x00040000) == 0x00040000)	//Mouse middle
			{
				printf("middle press\n");
			}

			inc.x = (MouseData & 0x1ff);			//Gets the mouse x value
			x += inc.x;								
			inc.y = ((MouseData>>9) & 0x1ff);	//Gets the mouse y value
			y -= inc.y;                            
			if(x < -320) x = -320;                 
			else if(x > 319) x = 319;             
			if(y < -240) y = -240;					 
			else if(y > 239) y = 239;   				

			printf("X:%d,Y:%d,\n",x,y);

		}
	}
}


