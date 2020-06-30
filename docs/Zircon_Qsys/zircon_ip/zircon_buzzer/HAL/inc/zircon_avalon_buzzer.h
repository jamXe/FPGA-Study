//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_buzzer.h
//-- Describe : buzzer IP core driver header file 
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#ifndef __ZIRCON_AVALON_BUZZER_H__
#define __ZIRCON_AVALON_BUZZER_H__

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#include "zircon_avalon_buzzer_regs.h"
#include "alt_types.h"
#include "system.h"

// rhythm: quarter note as a meter
#define RHYTHM   36
#define _1      RHYTHM*4     //note
#define _1d     RHYTHM*6     //dotted note
#define _2      RHYTHM*2     //halfnote
#define _2d     RHYTHM*3     //dotted halfnote
#define _4      RHYTHM*1     //quarter note
#define _4d     RHYTHM*3/2   //dotted quarter note
#define _8      RHYTHM*1/2   //eighth note
#define _8d     RHYTHM*3/4   //dotted eighth note
#define _16     RHYTHM*1/4   //sixteenth note
#define _16d    RHYTHM*3/8   //dotted sixteenth note
#define _32     RHYTHM*1/8   //thirty-second note
//bass
#define _1DO    (ALT_CPU_FREQ/131)
#define _1DOr   (ALT_CPU_FREQ/139)
#define _1RE    (ALT_CPU_FREQ/147)
#define _1REr   (ALT_CPU_FREQ/155)
#define _1MI    (ALT_CPU_FREQ/165)
#define _1FA    (ALT_CPU_FREQ/175)
#define _1FAr   (ALT_CPU_FREQ/185)
#define _1SOL   (ALT_CPU_FREQ/196)
#define _1SOLr  (ALT_CPU_FREQ/207)
#define _1LA    (ALT_CPU_FREQ/220)
#define _1LAr   (ALT_CPU_FREQ/233)
#define _1SI    (ALT_CPU_FREQ/247)
//Alto
#define _DO     (ALT_CPU_FREQ/262)
#define _DOr    (ALT_CPU_FREQ/277)
#define _RE     (ALT_CPU_FREQ/294)
#define _REr    (ALT_CPU_FREQ/311)
#define _MI     (ALT_CPU_FREQ/330)
#define _FA     (ALT_CPU_FREQ/349)
#define _FAr    (ALT_CPU_FREQ/370)
#define _SOL    (ALT_CPU_FREQ/392)
#define _SOLr   (ALT_CPU_FREQ/416)
#define _LA     (ALT_CPU_FREQ/440)
#define _LAr    (ALT_CPU_FREQ/466)
#define _SI     (ALT_CPU_FREQ/492)
//treble
#define _DO1    (ALT_CPU_FREQ/523)
#define _DO1r   (ALT_CPU_FREQ/554)
#define _RE1    (ALT_CPU_FREQ/579)
#define _RE1r   (ALT_CPU_FREQ/740)
#define _MI1    (ALT_CPU_FREQ/651)
#define _FA1    (ALT_CPU_FREQ/695)
#define _FA1r   (ALT_CPU_FREQ/740)
#define _SOL1   (ALT_CPU_FREQ/784)
#define _SOL1r  (ALT_CPU_FREQ/830)
#define _LA1    (ALT_CPU_FREQ/880)
#define _LAR1r  (ALT_CPU_FREQ/932)
#define _SI1    (ALT_CPU_FREQ/983)

#define SONG_SIZE 150
#define MUTE(TONE)      (TONE)>>2    //Bass to 25% duty cycle
#define LOUD(TONE)      (TONE)>>1    //treble to 50% duty cycle


//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_enable()
//-- Function 	        : buzzer open
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_enable();

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_disable()
//-- Function 	        : buzzer close
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_disable();

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_sound()
//-- Function 	        : buzzer Play sound
//-- Input parameters  : clock_divider: Cycle setting,duty_cycle: Duty cycle setting
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_sound(alt_u32 clock_divider, alt_u32 duty_cycle);

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_demo1()
//-- Function 	        : buzzer Play Da Chang Jin music
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_demo1();

/*
 * Macros used by alt_sys_init()
 */
#define ZIRCON_AVALON_BUZZER_INSTANCE(name, device) alt_u32 buzzer_controller_addr = name##_BASE
#define ZIRCON_AVALON_BUZZER_INIT(name, device) while (0) 

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ZIRCON_AVALON_BUZZER_H__ */
