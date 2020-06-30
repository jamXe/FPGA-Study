//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_tlc5615.v
//-- 描述		:	TLC5615 DA IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_tlc5615
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//外设管脚输出
	coe_tlc5615_cs,coe_tlc5615_data,coe_tlc5615_clk
);

input         			csi_clk;				//系统时钟
input         			rsi_reset_n;		//系统复位
input 					avs_address;		//Avalon地址总线
input						avs_write;			//Avalon写请求信号
input			[31:0]	avs_writedata;		//Avalon写数据总线

output 					coe_tlc5615_cs;  	//tlc5615的片选信号
output					coe_tlc5615_data;	//tlc5615的数据信号
output					coe_tlc5615_clk;	//tlc5615的时钟信号

wire 						da_start;			//tlc5615发送开始位
wire 			[ 7:0]	da_in;				//tlc5615发送的8位数据

zircon_avalon_tlc5615_logic	zircon_avalon_tlc5615_logic_init
(
	.CLK_50M			(csi_clk				),	//系统时钟
	.RST_N			(rsi_reset_n		),	//系统复位
	.DA_CLK			(coe_tlc5615_clk	),	//tlc5615的时钟信号
	.DA_DIN			(coe_tlc5615_data	),	//tlc5615的数据信号
	.DA_CS			(coe_tlc5615_cs	),	//tlc5615的片选信号
	.DA_DATA			({da_in,2'b00}		),	//tlc5615发送的8位数据
	.send_start		(da_start			)	//tlc5615发送开始位
);

zircon_avalon_tlc5615_register	zircon_avalon_tlc5615_register_init
(
	.csi_clk			(csi_clk				),	//系统时钟
	.rsi_reset_n	(rsi_reset_n		),	//系统复位
	.avs_address	(avs_address		),	//Avalon地址总线
	.avs_write		(avs_write			),	//Avalon写请求信号
	.avs_writedata	(avs_writedata		),	//Avalon写数据总线
	.da_in			(da_in				),	//tlc5615发送的8位数据
	.da_start		(da_start			)	//tlc5615发送开始位
);

endmodule
