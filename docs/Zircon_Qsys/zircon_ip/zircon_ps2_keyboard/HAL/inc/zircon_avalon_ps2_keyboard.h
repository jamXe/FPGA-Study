//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_ps2_keyboard.h
//-- Describe : ps2_keyboard IP core driver header file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_PS2_KEYBOARD_H__
#define __ZIRCON_AVALON_PS2_KEYBOARD_H__

#include "zircon_avalon_ps2_keyboard_regs.h"
#include "alt_types.h"
#include "system.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

//---------------------------------------------------------------------------
//-- Name             	: ReadKeyboardData()
//-- Function          	: Read Keyboard Data
//-- Input parameters 	: no
//-- Output parameters	: Keyboard Data
//---------------------------------------------------------------------------
alt_u32 ReadKeyboardData(void);

//---------------------------------------------------------------------------
//-- Name             	: KeyboardIRQ()
//-- Function          	: Interrupt service routine
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardIRQ(void* context, alt_u32 id);

//---------------------------------------------------------------------------
//-- Name             	: KeyboardInit()
//-- Function          	: Keyboard Interrupt Init
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardInit(void);

//---------------------------------------------------------------------------
//-- Name             	: KeyboarDemo()
//-- Function          	: Keyboard program demo
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void KeyboardDemo(void);

/*
 * Macros used by alt_sys_init()
 */
#define ZIRCON_AVALON_PS2_KEYBOARD_INSTANCE(name, dev) alt_u32 ps2keyboard_addr = name##_BASE
#define ZIRCON_AVALON_PS2_KEYBOARD_INIT(name, dev) while (0)

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_PS2_KEYBOARD_H__ */



