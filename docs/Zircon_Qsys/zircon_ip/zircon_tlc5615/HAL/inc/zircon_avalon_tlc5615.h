//---------------------------------------------------------------------------
//-- Name     		: zircon_avalon_tlc5615.h
//-- Describe		: DA IP core driver header file
//-- Revision		: 2014-1-1
//-- Company		: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_TLC5615_H__
#define __ZIRCON_AVALON_TLC5615_H__

#include "system.h"
#include "alt_types.h"
#include "zircon_avalon_tlc5615_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

//---------------------------------------------------------------------------
//-- Name             	: zircon_avalon_tlc5615_send
//-- Function          	: tlc5615 data transmission function
//-- Input parameters 	: length: the length of the data transmission,
//--                      wave_data: send data to the first address,
//--                      delay_data: delay time
//-- Output parameters	: no
//---------------------------------------------------------------------------
void zircon_avalon_tlc5615_send(alt_u16 length, alt_u16* wave_data, alt_u16 delay_data);

/* Macros used by alt_sys_init */
#define ZIRCON_AVALON_TLC5615_INSTANCE(name, dev) alt_u32 tlc5615_controller_addr = name##_BASE
#define ZIRCON_AVALON_TLC5615_INIT(name, dev) while(0)   

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_TLC5615_H__ */
