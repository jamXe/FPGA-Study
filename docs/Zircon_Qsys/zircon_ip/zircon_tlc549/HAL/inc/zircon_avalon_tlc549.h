//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_tlc549.h
//-- Describe : tlc549 IP core driver header file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_TLC549_H__
#define __ZIRCON_AVALON_TLC549_H__

#include "system.h"
#include "alt_types.h"
#include "zircon_avalon_tlc549_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

//---------------------------------------------------------------------------
//-- Name             	: zircon_avalon_tlc549_read()
//-- Function          	: Read the value of AD
//-- Input parameters 	: no
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_tlc549_read();


/* Macros used by alt_sys_init */
#define ZIRCON_AVALON_TLC549_INSTANCE(name, dev) alt_u32 tlc549_controller_addr = name##_BASE
#define ZIRCON_AVALON_TLC549_INIT(name, dev) while(0)   


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_TLC549_H__ */
