//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_vga.c
//-- Describe : vga IP core driver C file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "unistd.h"		
#include "alt_types.h"	
#include "zircon_avalon_vga.h"	
#include "Andy_Warhol.h"	

extern alt_u32 vga_controller_addr;

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_init
//-- Function         	: vga init
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_init()
{
	IOWR_ZIRCON_AVALON_VGA_CONTROL(vga_controller_addr, 0);
	IOWR_ZIRCON_AVALON_VGA_DATA(vga_controller_addr,(alt_u32)vga_buffer);
	IOWR_ZIRCON_AVALON_VGA_CONTROL(vga_controller_addr, 1);
}

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_DrawPoint
//-- Function         	: Draw point at the specified location
//-- Input parameters	: x:horizontal direction;y:vertical direction
//--                      color:specified color
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_DrawPoint(alt_u16 x, alt_u16 y, alt_u16 color)
{
	IOWR_8DIRECT((alt_u32 )vga_buffer, (y * VGA_WIDTH) + x, color);
}

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_ClearScreen
//-- Function         	: Clear Screen
//-- Input parameters	: color:specified color
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_ClearScreen(alt_u16 color)
{
	int x, y;
	for (y = 0;y < VGA_HEIGHT;y ++)
	{
		for (x = 0;x < VGA_WIDTH;x ++)
		{
			zircon_avalon_vga_DrawPoint(x, y, color);
		}
	}
}

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_ColorBar
//-- Function         	: display Four color ColorBar
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_ColorBar()
{
    int x, y;
    for (y = 0;y < VGA_HEIGHT;y ++)
    {
        for (x = 0;x < VGA_WIDTH;x ++)
        {
            if (x < 200) zircon_avalon_vga_DrawPoint(x, y, COLOR_RED);
            else if (x < 400) zircon_avalon_vga_DrawPoint(x, y, COLOR_BLUE);
            else if (x < 600) zircon_avalon_vga_DrawPoint(x, y, COLOR_GREEN);
            else zircon_avalon_vga_DrawPoint(x, y, COLOR_FUCHSINE);
        }
    }
}

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_DisplayPic
//-- Function         	: Display Andy_Warhol picture
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_DisplayPic()
{
	int x, y;
	for (y = 0;y < VGA_HEIGHT;y ++)
	{
		for (x = 0;x < VGA_WIDTH;x ++)
		{
			zircon_avalon_vga_DrawPoint(x, y, Andy_Warhol[(y * VGA_WIDTH) + x]);
		}
	}
}
