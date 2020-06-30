//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_keyboard.v
//-- 描述		:	PS/2键盘IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_keyboard
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,ins_interrupt,
	//外设管脚输出
	coe_ps2_clk,coe_ps2_data
);

input 				csi_clk;		 						//系统时钟
input 				rsi_reset_n;						//系统复位
input  				avs_address;	 					//Avalon地址总线
input 				avs_read;							//Avalon读请求信号
output 	[31:0]	avs_readdata;						//Avalon读数据总线
output 				ins_interrupt;						//Avalon中断信号
input					coe_ps2_clk;						//ps/2的时钟信号
input 				coe_ps2_data;						//ps/2的数据信号
	
wire					continued_press;					//持续按下按键标志位
wire					shift_key_on;						//shift键状态标志位
wire		[ 7:0]	ascii_output;						//从PS/2中读出的ASICC数据
wire					read_address;						//Avalon读请求和数据总线的使能标志位
		
//硬件逻辑文件
zircon_avalon_ps2_keyboard_logic zircon_avalon_ps2_keyboard_logic_init
(
	.clock					(csi_clk 			),		//系统时钟
	.reset					(rsi_reset_n		),		//系统复位
	.rx_read					(read_address		),		//Avalon读请求和数据总线的使能标志位
	.continued_press		(continued_press	),		//持续按下按键标志位
	.shift_key_on			(shift_key_on		),		//shift键状态标志位
	.ascii_output			(ascii_output		),		//从PS/2中读出的ASICC数据
	.interrupt				(ins_interrupt		),		//Avalon中断信号
	.ps2_clk_in				(coe_ps2_clk		),		//ps/2的时钟信号
	.ps2_data_in			(coe_ps2_data		)		//ps/2的数据信号

);

//寄存器文件
zircon_avalon_ps2_keyboard_register 	zircon_avalon_ps2_keyboard_register_init
(	
	.csi_clk					(csi_clk				),		//系统时钟
	.rsi_reset_n			(rsi_reset_n		),		//系统复位
	.avs_address			(avs_address		),		//Avalon地址总线
	.avs_read				(avs_read			),		//Avalon读请求信号
	.avs_readdata			(avs_readdata		),		//Avalon读数据总线
	.read_address			(read_address		),		//Avalon读请求和数据总线的使能标志位
	.continued_press		(continued_press	),		//持续按下按键标志位
	.ascii_output			(ascii_output		),		//从PS/2中读出的ASICC数据
	.shift_key_on			(shift_key_on		)		//shift键状态标志位
);

endmodule







