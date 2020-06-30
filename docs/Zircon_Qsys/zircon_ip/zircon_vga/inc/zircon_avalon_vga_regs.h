//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_vga_regs.h
//-- Describe : Vga IP core register header file 
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_VGA_REGS_H__
#define __ZIRCON_AVALON_VGA_REGS_H__

#include <io.h>

//Data register 0
#define IOWR_ZIRCON_AVALON_VGA_DATA(base,data)			IOWR(base, 0, data)
//Control register 1
#define IOWR_ZIRCON_AVALON_VGA_CONTROL(base,data)		IOWR(base, 1, data)


#endif /* __ZIRCON_AVALON_VGA_REGS_H__ */
