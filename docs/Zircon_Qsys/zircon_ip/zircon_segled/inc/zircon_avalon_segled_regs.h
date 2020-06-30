//---------------------------------------------------------------------------
//-- Name		: zircon_avalon_segled_regs.h
//-- Describe  : segled IP core register header file 
//-- Revision	: 2014-1-1
//-- Company	: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_SEGLED_REGS_H__
#define __ZIRCON_AVALON_SEGLED_REGS_H__

#include <io.h>

//Data register 0
#define IOWR_ZIRCON_AVALON_SEGLED_DATA0(base,data)			IOWR(base, 0, data)
//Data register 1
#define IOWR_ZIRCON_AVALON_SEGLED_DATA1(base,data)			IOWR(base, 1, data)	
//Data register 2
#define IOWR_ZIRCON_AVALON_SEGLED_DATA2(base,data)			IOWR(base, 2, data)	
//Data register 3
#define IOWR_ZIRCON_AVALON_SEGLED_DATA3(base,data)			IOWR(base, 3, data)	
//Data register 4
#define IOWR_ZIRCON_AVALON_SEGLED_DATA4(base,data)			IOWR(base, 4, data)	
//Data register 5
#define IOWR_ZIRCON_AVALON_SEGLED_DATA5(base,data)			IOWR(base, 5, data)	

#endif /* __ZIRCON_AVALON_SEGLED_REGS_H__ */
