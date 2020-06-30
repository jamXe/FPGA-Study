//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_vga.h
//-- Describe : Vga IP core driver header file 
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_VGA_H__
#define __ZIRCON_AVALON_VGA_H__

#include "system.h"
#include "alt_types.h"
#include "zircon_avalon_vga_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


#define COLOR_BLACK		0X00
#define COLOR_BLUE		0X03
#define COLOR_GREEN		0X1D
#define COLOR_CYAN		0X1F
#define COLOR_RED		0XE0
#define COLOR_FUCHSINE	0XE3
#define COLOR_YELLOW	0xFD
#define COLOR_WHITE		0XFF

#define VGA_WIDTH       800
#define VGA_HEIGHT      600
#define VGA_BUFFER_SIZE (VGA_WIDTH * VGA_HEIGHT)
alt_u8 vga_buffer[VGA_BUFFER_SIZE];

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_DrawPoint
//-- Function         	: Draw point at the specified location
//-- Input parameters	: x:horizontal direction;y:vertical direction
//--                      color:specified color
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_DrawPoint(alt_u16 x, alt_u16 y, alt_u16 color);

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_init
//-- Function         	: vga init
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_init();

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_ColorBar
//-- Function         	: display Four color ColorBar
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_ColorBar();

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_ClearScreen
//-- Function         	: Clear Screen
//-- Input parameters	: color:specified color
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_ClearScreen(alt_u16 color);

//---------------------------------------------------------------------------
//-- Name              	: zircon_avalon_vga_DisplayPic
//-- Function         	: Display Andy_Warhol picture
//-- Input parameters	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_vga_DisplayPic();

/* Macros used by alt_sys_init */
#define ZIRCON_AVALON_VGA_INSTANCE(name, dev) alt_u32 vga_controller_addr = name##_BASE
#define ZIRCON_AVALON_VGA_INIT(name, dev) while(0)   


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_VGA_H__ */
