//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_tlc549.v
//-- 描述		:	TLC549 AD IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_tlc549
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,
	//外设管脚输出
	coe_ad_data,coe_ad_cs,coe_ad_clk,coe_ad_sysclk
);

input         		csi_clk;				//系统时钟
input         		rsi_reset_n;		//系统复位
input 				avs_address;		//Avalon地址总线
input					avs_read;			//Avalon读请求信号
output	[31:0]	avs_readdata;		//Avalon读数据总线
input					coe_ad_sysclk;		//AD模块的系统时钟
input					coe_ad_data;		//AD数据端口
output				coe_ad_cs;			//AD片选端口
output				coe_ad_clk;			//AD时钟端口

wire 		[ 7:0]	data_out;			//从AD中读出的数据

//硬件逻辑文件
zircon_avalon_tlc549_logic	zircon_avalon_tlc549_logic_init
(
	.CLK_50M			(coe_ad_sysclk	),	//AD模块的系统时钟
	.RST_N			(rsi_reset_n	),	//系统复位
	.data_out		(data_out		),	//从AD中读出的数据
	.coe_ad_cs		(coe_ad_cs		),	//AD片选端口
	.coe_ad_clk		(coe_ad_clk		),	//AD时钟端口
	.coe_ad_data	(coe_ad_data	)	//AD数据端口
);

//寄存器文件
zircon_avalon_tlc549_register	zircon_avalon_tlc549_register_init
(
	.csi_clk			(csi_clk			),	//系统时钟
	.rsi_reset_n	(rsi_reset_n	),	//系统复位
	.avs_address	(avs_address	),	//Avalon地址总线
	.avs_read		(avs_read		),	//Avalon读请求信号
	.avs_readdata	(avs_readdata	),	//Avalon读数据总线
	.data_out		(data_out		)	//从AD中读出的数据
);

endmodule
