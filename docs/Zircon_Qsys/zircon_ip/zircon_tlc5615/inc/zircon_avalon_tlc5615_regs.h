//---------------------------------------------------------------------------
//-- Name     		: zircon_avalon_tlc5615_regs.h
//-- Describe		: DA IP core register header file 
//-- Revision		: 2014-1-1
//-- Company		: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_TLC5615_REGS_H__
#define __ZIRCON_AVALON_TLC5615_REGS_H__

#include <io.h>

//Data register
#define IOWR_AVALON_ZIRCON_TLC5615_DATA(base,data)			IOWR(base, 0, data)

#endif /* __ZIRCON_AVALON_TLC5615_REGS_H__ */
