//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_mouse.v
//-- 描述		:	PS/2鼠标IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_mouse
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,ins_interrupt,
	//外设管脚输出
	coe_ps2_clk,coe_ps2_data
);

input 				csi_clk;		 					//系统时钟
input 				rsi_reset_n;					//系统复位
input  				avs_address;	  				//Avalon地址总线
input 				avs_read;		   			//Avalon读请求信号
output 	[31:0]	avs_readdata;					//Avalon读数据总线
output 				ins_interrupt;					//Avalon中断信号
inout					coe_ps2_clk;					//PS/2的时钟信号
inout					coe_ps2_data;					//PS/2的数据信号
		
wire					left_button;					//鼠标左键标志位
wire					right_button;					//鼠标右键标志位
wire					middle_button;					//鼠标中键标志位
wire		[ 8:0]	x_increment;					//X轴增量
wire		[ 8:0]	y_increment;					//Y轴增量

wire					ps2_clk_in;						//PS/2时钟线,输入口
wire					ps2_clk_out;					//PS/2时钟线,输出口
wire					ps2_clk_dir;					//PS/2时钟方向控制，高电平为输出，低电平为输入
wire					ps2_data_in;					//PS/2数据线,输入口
wire					ps2_data_out;					//PS/2数据线,输出口
wire					ps2_data_dir;					//PS/2数据方向控制，高电平为输出，低电平为输入


zircon_avalon_ps2_mouse_logic zircon_avalon_ps2_mouse_logic_init
(
	.clock					(csi_clk 			),	//系统时钟
	.reset_n					(rsi_reset_n		),	//系统复位
	.avs_read				(avs_read			),	//Avalon读请求信号
	.ins_interrupt			(ins_interrupt		),	//Avalon中断信号
	.x_increment			(x_increment		),	//X轴增量
	.y_increment			(y_increment		),	//Y轴增量
	.left_button			(left_button		),	//鼠标左键标志位
	.right_button			(right_button		),	//鼠标右键标志位
	.middle_button			(middle_button		),	//鼠标中键标志位
	.ps2_clk_in				(ps2_clk_in			),	//PS/2时钟线,输入口
	.ps2_clk_out			(ps2_clk_out		),	//PS/2时钟线,输出口
	.ps2_clk_dir			(ps2_clk_dir		),	//PS/2时钟方向控制，高电平为输出，低电平为输入
	.ps2_data_in			(ps2_data_in		),	//PS/2数据线,输入口
	.ps2_data_out			(ps2_data_out		),	//PS/2数据线,输出口
	.ps2_data_dir			(ps2_data_dir		)	//PS/2数据方向控制，高电平为输出，低电平为输入
);


zircon_avalon_ps2_mouse_register zircon_avalon_ps2_mouse_register_init
(	
	.csi_clk					(csi_clk				),	//系统时钟
	.rsi_reset_n			(rsi_reset_n		),	//系统复位
	.avs_address			(avs_address		),	//Avalon地址总线
	.avs_read				(avs_read			),	//Avalon读请求信号
	.avs_readdata			(avs_readdata		),	//Avalon读数据总线
	.x_increment			(x_increment		),	//X轴增量
	.y_increment			(y_increment		),	//Y轴增量
	.left_button			(left_button		),	//鼠标左键标志位
	.right_button			(right_button		),	//鼠标右键标志位
	.middle_button			(middle_button		)	//鼠标中键标志位
);

assign coe_ps2_clk 	= (ps2_clk_dir) ? ps2_clk_out : 1'bz;	
assign coe_ps2_data 	= (ps2_data_dir) ? ps2_data_out : 1'bz;
assign ps2_clk_in		= coe_ps2_clk;
assign ps2_data_in 	= coe_ps2_data;

endmodule







