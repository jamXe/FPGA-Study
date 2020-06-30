//---------------------------------------------------------------------------
//-- Name     : zircon_avalon_buzzer.c
//-- Describe : buzzer IP core driver C file
//-- Revision : 2014-1-1
//-- Company  : Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "zircon_avalon_buzzer.h"
#include "alt_types.h"
#include "unistd.h"
#include  "priv/alt_busy_sleep.h"

extern alt_u32 buzzer_controller_addr;


//First column tone,
//Second columns rhythm
//Third column pitch (high and low)
int dachangjin[SONG_SIZE][3] = {
  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4d,LOUD(_SI)}, //3.
  {_LA, _8, MUTE(_LA)}, //2_
  {_SOL,_4, MUTE(_SOL)},//1
  {_MI, _4, LOUD(_MI)}, //.6
  {_SOL,_4, MUTE(_SOL)},//1
  {_SOL,_8d, MUTE(_SOL)},//1
  {_LA, _32,MUTE(_LA)}, //2__
  {_SOL,_2d,MUTE(_SOL)},//1--

  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4d,LOUD(_SI)}, //3.
  {_RE1,_8, MUTE(_RE1)},//5
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4, MUTE(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _2d,MUTE(_SI)}, //3--

  {_RE1,_4, LOUD(_RE1)},//5
  {_MI1,_4, MUTE(_MI1)},//6
  {_MI1,_4, MUTE(_MI1)},//6
  {_MI1,_4d,LOUD(_MI1)},//6
  {_RE1,_8, MUTE(_RE1)},//5
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, LOUD(_SI)}, //3
  {_RE1,_4, MUTE(_RE1)},//5
  {_MI1,_8, MUTE(_MI1)},//6
  {_RE1,_32,MUTE(_RE1)},//5
  {_MI1,_32,MUTE(_MI1)},//6
  {_RE1,_2d,MUTE(_RE1)},//5

  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4d,LOUD(_LA)}, //3.
  {_SI, _8, MUTE(_SI)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_MI, _4, LOUD(_MI)}, //.6
  {_SOL,_16,MUTE(_SOL)},//1
  {_MI, _2d,MUTE(_MI)}, //.6
  {_MI, _4,0},          //stop
  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4d,LOUD(_SI)}, //3.
  {_LA, _8, MUTE(_LA)}, //2_
  {_SOL,_4, MUTE(_SOL)},//1
  {_MI, _4, LOUD(_MI)}, //.6
  {_SOL,_4, MUTE(_SOL)},//1
  {_SOL,_8d,MUTE(_SOL)},//1
  {_LA, _32,MUTE(_LA)}, //2__
  {_SOL,_2d,MUTE(_SOL)},//1--

  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4d,LOUD(_SI)}, //3.
  {_RE1,_8, MUTE(_RE1)},//5
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4, MUTE(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _2d,MUTE(_SI)}, //3--

  {_RE1,_4, LOUD(_RE1)},//5
  {_MI1,_4, MUTE(_MI1)},//6
  {_MI1,_4, MUTE(_MI1)},//6
  {_MI1,_4d,LOUD(_MI1)},//6
  {_RE1,_8, MUTE(_RE1)},//5
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, LOUD(_SI)}, //3
  {_RE1,_4, MUTE(_RE1)},//5
  {_MI1,_4, MUTE(_MI1)},//6
  {_RE1,_2d,MUTE(_RE1)},//5

  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4d,LOUD(_LA)}, //3.
  {_SI, _8, MUTE(_SI)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_MI, _4, LOUD(_MI)}, //.6
  {_SOL,_16,MUTE(_SOL)},//1
  {_MI, _2d,MUTE(_MI)}, //.6--

  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16d,LOUD(_LA)}, //2
  {_SOL,_8, MUTE(_SOL)},//1
  {_MI, _4, MUTE(_MI)}, //.6
  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16d,LOUD(_LA)}, //2
  {_SOL,_8, MUTE(_SOL)},//1
  {_MI, _4, MUTE(_MI)}, //.6
  {_LA, _4, LOUD(_LA)}, //2
  {_SI, _4, MUTE(_SI)}, //3
  {_SOL,_4, MUTE(_SOL)},//1
  {_LA, _4d,LOUD(_LA)}, //2
  {_SI, _8, MUTE(_SI)}, //3
  {_RE1,_4, MUTE(_RE1)},//5
  {_MI1,_16,LOUD(_MI1)},//6
  {_MI1,_16,LOUD(_MI1)},//6
  {_MI1,_16d,LOUD(_MI1)},//6
  {_RE1,_8, MUTE(_RE1)},//5
  {_SI, _4, MUTE(_SI)}, //3
  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16,LOUD(_LA)}, //2
  {_LA, _16d, LOUD(_LA)}, //2
  {_SOL,_8, MUTE(_SOL)},//1
  {_MI, _4, MUTE(_MI)}, //.6
  {_MI, _4, LOUD(_MI)}, //.6
  {_RE, _4, MUTE(_RE)}, //.5
  {_MI, _4, MUTE(_MI)}, //.6
  {_MI, _2d,MUTE(_MI)}, //.6
  {_MI, _4,0},          //stop
  {_MI, _4,0},          //stop
   };

/*{_1SOL, _4d, MUTE(_1SOL)}, //.1
{_1LA, _4d, MUTE(_1LA)}, //.2
{_1SI, _4d, MUTE(_1SI)}, //.3
{_DO, _4d, MUTE(_DO)}, //.4
{_RE, _4d, MUTE(_RE)}, //.5
{_MI, _4d, MUTE(_MI)}, //.6
{_FA, _4d, MUTE(_FA)}, //.7
{_SOL, _4d, MUTE(_SOL)}, //1
{_LA, _4d, MUTE(_LA)}, //2
{_SI, _4d, MUTE(_SI)}, //3
{_DO1, _4d, MUTE(_DO1)}, //4
{_RE1, _4d, MUTE(_RE1)}, //5
{_MI1, _4d, MUTE(_MI1)}, //6
{_FA1, _4d, MUTE(_FA1)}, //7
{_SOL1, _4d, MUTE(_SOL1)}, //1.
{_LA1, _4d, MUTE(_LA1)}, //2.
{_SI1, _4d, MUTE(_SI1)}, //3.
*/


//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_sound()
//-- Function 	        : buzzer Play sound
//-- Input parameters  : clock_divider: Cycle setting,duty_cycle: Duty cycle setting
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_sound(alt_u32 clock_divider, alt_u32 duty_cycle)
{
	IOWR_ZIRCON_BUZZER_CLOCK_DIVIDER(buzzer_controller_addr, clock_divider - 1);
	IOWR_ZIRCON_BUZZER_DUTY_CYCLE(buzzer_controller_addr, duty_cycle);
}

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_enable()
//-- Function 	        : buzzer open
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_enable()
{
	IOWR_ZIRCON_BUZZER_ENABLE(buzzer_controller_addr, 1);
}

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_disable()
//-- Function 	        : buzzer close
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_disable()
{
	IOWR_ZIRCON_BUZZER_ENABLE(buzzer_controller_addr, 0);
}

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_delay()
//-- Function 	        : Software delay
//-- Input parameters  : delaydata：Delay time
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_delay(alt_32 delaydata)
{
    while(delaydata--)
    {
    	usleep(1000);
    }
}

//---------------------------------------------------------------------------
//-- Name              : zircon_buzzer_demo1()
//-- Function 	        : buzzer Play Da Chang Jin music
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_buzzer_demo1()
{
	int i;

	for(i=0; i<SONG_SIZE; i++)
	{
		zircon_buzzer_disable();
		zircon_buzzer_delay(150);
		if(dachangjin[i][1]!=0)
		{
			zircon_buzzer_sound(dachangjin[i][0],dachangjin[i][2]);
			zircon_buzzer_enable();
			zircon_buzzer_delay(10*dachangjin[i][1]);
		}
	}
}

