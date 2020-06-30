//---------------------------------------------------------------------------
//-- Name		: zircon_avalon_segled.h
//-- Describe  : segled IP core driver header file 
//-- Revision	: 2014-1-1
//-- Company	: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_SEGLED_H__
#define __ZIRCON_AVALON_SEGLED_H__

#include "system.h"
#include "alt_types.h"
#include "zircon_avalon_segled_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_allclose
//-- Function 	        : Close all segled
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_allclose();

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_allopen
//-- Function 	        : Open all segled and 8 digital display
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_allopen();

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo1
//-- Function 	        : From left to right,in order to open and display 0,
//-- 			1,2,3,4,5 In the next, from right to left, turn off the segled
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo1();

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo2
//-- Function 	        : every segled display random 0-E 
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo2();

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo3
//-- Function 	        : segled to achieve a stopwatch function
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo3();

/* Macros used by alt_sys_init */
#define ZIRCON_AVALON_SEGLED_INSTANCE(name, dev) alt_u32 segled_controller_addr = name##_BASE
#define ZIRCON_AVALON_SEGLED_INIT(name, dev) while(0)   


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_SEGLED_H__ */
