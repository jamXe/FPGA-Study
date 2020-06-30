//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ir.v
//-- 描述		:	红外IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ir
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,ins_irq,
	//外设管脚输出
	coe_ir_data,coe_clk
);

input         			csi_clk;			//系统时钟
input         			rsi_reset_n;	//系统复位
input 					avs_address;	//Avalon地址总线
input						avs_read;		//Avalon读请求信号
output		[31:0]	avs_readdata;	//Avalon读数据总线
output					ins_irq;			//Avalon中断信号
input						coe_clk;			//红外硬件逻辑文件系统时钟
input						coe_ir_data;	//红外的数据管脚
	
wire			[ 7:0]	o_ir_data;		//从红外数据管脚中读出的数据

zircon_avalon_ir_logic	zircon_avalon_ir_logic_init
(
	.CLK_50M			(coe_clk			),	//红外硬件逻辑文件系统时钟
	.RST_N			(rsi_reset_n	),	//系统复位
	.IR_DATA			(coe_ir_data	),	//红外的数据管脚
	.o_ir_data		(o_ir_data		),	//从红外数据管脚中读出的数据
	.irq				(ins_irq			)	//Avalon中断信号
);

zircon_avalon_ir_register	zircon_avalon_ir_register_init
(
	.csi_clk			(csi_clk			),	//系统时钟
	.rsi_reset_n	(rsi_reset_n	),	//系统复位
	.avs_address	(avs_address	),	//Avalon地址总线
	.avs_read		(avs_read		),	//Avalon读请求信号
	.avs_readdata	(avs_readdata	),	//Avalon读数据总线
	.o_ir_data		(o_ir_data		)	//从红外数据管脚中读出的数据
);

endmodule
