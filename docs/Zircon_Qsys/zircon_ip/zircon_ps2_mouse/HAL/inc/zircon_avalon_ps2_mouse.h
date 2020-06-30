//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_ps2_mouse.h
//-- Describe : ps2_mouse IP core driver header file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_PS2_MOUSE_H__
#define __ZIRCON_AVALON_PS2_MOUSE_H__

#include "zircon_avalon_ps2_mouse_regs.h"
#include "alt_types.h"
#include "system.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


//---------------------------------------------------------------------------
//-- Name             	: ReadMouseData()
//-- Function          	: Read Mouse Data
//-- Input parameters 	: no
//-- Output parameters	: Mouse Data
//---------------------------------------------------------------------------
alt_u32 ReadMouseData(void);

//---------------------------------------------------------------------------
//-- Name             	: MouseInit()
//-- Function          	: Interrupt service routine
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseIRQ(void* context, alt_u32 id);

//---------------------------------------------------------------------------
//-- Name             	: MouseInit()
//-- Function          	: Mouse Interrupt Init
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseInit(void);

//---------------------------------------------------------------------------
//-- Name             	: MouseDemo()
//-- Function          	: Mouse program demo
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void MouseDemo(void);

/*
 * Macros used by alt_sys_init()
 */


#define ZIRCON_AVALON_PS2_MOUSE_INSTANCE(name, dev) \
alt_u32 ps2mouse_addr = name##_BASE

#define ZIRCON_AVALON_PS2_MOUSE_INIT(name, dev) while(0)
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_PS2_MOUSE_H__ */



