module zircon_segled
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//外设管脚输出
	coe_seg_cs,coe_seg_data
);

input         			csi_clk;		//系统时钟
input         			rsi_reset_n;	//系统复位
input 			[ 2:0]	avs_address;	//Avalon地址总线
input					avs_write;		//Avalon写请求信
input			[31:0]	avs_writedata;	//Avalon写数据总线
	
output 			[ 7:0]	coe_seg_data;  	//数码管数据管脚
output			[ 5:0]	coe_seg_cs;		//数码管数据使能管脚

wire			[ 3:0]	seg_data1;		//数码管数据寄存器0
wire			[ 3:0]	seg_data2;		//数码管数据寄存器1
wire			[ 3:0]	seg_data3;		//数码管数据寄存器2
wire			[ 3:0]	seg_data4;		//数码管数据寄存器3
wire			[ 3:0]	seg_data5;		//数码管数据寄存器4
wire			[ 3:0]	seg_data6;		//数码管数据寄存器5

//硬件逻辑文件
zircon_segled_logic	zircon_segled_logic_init
(
	.CLK_50M		(csi_clk		),	//系统时钟
	.RST_N			(rsi_reset_n	),	//系统复位
	.seg_data1		(seg_data1		),	//数码管数据寄存器0
	.seg_data2		(seg_data2		),	//数码管数据寄存器1
	.seg_data3		(seg_data3		),	//数码管数据寄存器2
	.seg_data4		(seg_data4		),	//数码管数据寄存器3
	.seg_data5		(seg_data5		),	//数码管数据寄存器4
	.seg_data6		(seg_data6		),	//数码管数据寄存器5
	.coe_seg_data	(coe_seg_data	),	//数码管数据管脚
	.coe_seg_cs		(coe_seg_cs		)	//数码管数据使能管脚
);

//寄存器文件
zircon_segled_register	zircon_segled_register_init
(
	.csi_clk		(csi_clk		),	//系统时钟
	.rsi_reset_n	(rsi_reset_n	),	//系统复位
	.avs_address	(avs_address	),	//Avalon地址总线
	.avs_write		(avs_write		),	//Avalon写请求信
	.avs_writedata	(avs_writedata	),	//Avalon写数据总线
	.seg_data1		(seg_data1		),	//数码管数据寄存器0
	.seg_data2		(seg_data2		),	//数码管数据寄存器1
	.seg_data3		(seg_data3		),	//数码管数据寄存器2
	.seg_data4		(seg_data4		),	//数码管数据寄存器3
	.seg_data5		(seg_data5		),	//数码管数据寄存器4
	.seg_data6		(seg_data6		)	//数码管数据寄存器5
);


endmodule
