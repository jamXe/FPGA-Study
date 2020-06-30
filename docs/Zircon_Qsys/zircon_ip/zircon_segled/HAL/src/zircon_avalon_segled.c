//---------------------------------------------------------------------------
//-- Name		: zircon_avalon_segled.c
//-- Describe  : segled IP core driver C file 
//-- Revision	: 2014-1-1
//-- Company	: Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
#include "unistd.h"		
#include "alt_types.h"
#include "stdlib.h"		
#include "zircon_avalon_segled.h"	

extern alt_u32 segled_controller_addr;

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_allclose
//-- Function 	        : Close all segled
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_allclose()
{
	
	IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,15);
	IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,15);
	IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,15);
	IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,15);
	IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,15);
	IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,15);
	
}

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_allopen
//-- Function 	        : Open all segled and 8 digital display
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_allopen()
{
	
	IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,8);
	IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,8);
	IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,8);
	IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,8);
	IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,8);
	IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,8);
	
} 

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo1
//-- Function 	        : From left to right,in order to open and display 0,
//-- 			1,2,3,4,5 In the next, from right to left, turn off the segled
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo1()
{

	IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,0);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,1);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,2);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,3);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,4);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,5);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,15);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,15);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,15);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,15);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,15);
	usleep(200000);
	IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,15);
	usleep(200000);

}

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo2
//-- Function 	        : every segled display random 0-E 
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo2()
{
	int i,k1=0,k2=0,k3=0,k4=0,k5=0,k6=0;

	for(i = 0 ; i < 50; i++)
	{
		k1 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,k1);
		usleep(10000);
		k2 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,k2);
		usleep(10000);
		k3 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,k3);
		usleep(10000);
		k4 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,k4);
		usleep(10000);
		k5 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,k5);
		usleep(10000);
		k6 = rand()%15;
		IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,k6);
		usleep(10000);
	}
	
	zircon_avalon_segled_allclose();
}

//---------------------------------------------------------------------------
//-- Name              : zircon_avalon_segled_demo3
//-- Function 	        : segled to achieve a stopwatch function
//-- Input parameters  : no
//-- Output parameters : no
//---------------------------------------------------------------------------
void zircon_avalon_segled_demo3()
{
	int i,k1=0,k2=0,k3=0,k4=0,k5=0,k6=0;

	while(1)
	{
		k1++;
		if(k1 == 10) {k2++; k1 = 0;}
		if(k2 == 10) {k3++; k2 = 0;}
		if(k3 == 10) {k4++; k3 = 0;}
		if(k4 == 10) 
		{
			k4 = 0; 
			zircon_avalon_segled_allclose(); 
			break;
		}

		IOWR_ZIRCON_AVALON_SEGLED_DATA5(segled_controller_addr,k1);
		IOWR_ZIRCON_AVALON_SEGLED_DATA4(segled_controller_addr,k2);
		IOWR_ZIRCON_AVALON_SEGLED_DATA3(segled_controller_addr,k3);
		IOWR_ZIRCON_AVALON_SEGLED_DATA2(segled_controller_addr,k4);
		IOWR_ZIRCON_AVALON_SEGLED_DATA1(segled_controller_addr,15);
		IOWR_ZIRCON_AVALON_SEGLED_DATA0(segled_controller_addr,15);
		usleep(1000);

	}

}
