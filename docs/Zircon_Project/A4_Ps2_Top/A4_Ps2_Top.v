//---------------------------------------------------------------------------
//--	文件名		:	A4_Ps2_Top.v
//--	作者		:	ZIRCON
//--	描述		:	接收到的键盘值显示到数码管上
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module A4_Ps2_Top
(
	//输入端口
	CLK_50M,RST_N,PS2_CLK,PS2_DATA,
	//输出端口
	BEEP
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input				CLK_50M;				//时钟的端口,开发板用的50M晶振
input				RST_N;				//复位的端口,低电平复位
input				PS2_CLK;				//PS2的时钟端口
input				PS2_DATA;			//PS2的数据端口
output 			BEEP;					//蜂鸣器端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
wire	 [15:0]	o_ps2_data;			//接收到PS2的完整数据

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//例化PS2
Ps2_Module			Ps2_Init
(
	.CLK_50M			(CLK_50M		),	//时钟端口
	.RST_N			(RST_N		),	//复位端口
	.PS2_CLK			(PS2_CLK		),	//PS2的时钟端口
	.PS2_DATA		(PS2_DATA	),	//PS2的数据端口
	.o_ps2_data		(o_ps2_data	)	//接收的PS2的完整数据
);

//例化蜂鸣器模块
Beep_Module			Beep_Init
(
	.CLK_50M			(CLK_50M		),	//时钟端口
	.RST_N			(RST_N		),	//复位端口
	.BEEP				(BEEP			),	//蜂鸣器端口
	.KEY				(o_ps2_data	)	//将接收的数据输出给蜂鸣器模块
);

endmodule