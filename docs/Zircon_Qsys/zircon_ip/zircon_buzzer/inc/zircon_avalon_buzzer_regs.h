//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_buzzer_regs.h
//-- Describe : buzzer IP core register header file 
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_BUZZER_REGS_H__
#define __ZIRCON_AVALON_BUZZER_REGS_H__

#include <io.h>
//Cycle setting register
#define IOWR_ZIRCON_BUZZER_CLOCK_DIVIDER(base, data) 	IOWR(base, 0, data)
//Duty Cycle Value Register
#define IOWR_ZIRCON_BUZZER_DUTY_CYCLE(base, data)   	IOWR(base, 1, data)
//Control Register 
#define IOWR_ZIRCON_BUZZER_ENABLE(base, data)       	IOWR(base, 2, data)


#endif /* __ZIRCON_AVALON_BUZZER_REGS_H__ */
