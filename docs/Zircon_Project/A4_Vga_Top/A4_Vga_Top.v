module A4_Vga_Top
(
	//输入端口
	CLK_50M,RST_N,
	//输出端口
	VGA_VSYNC,VGA_HSYNC,VGA_DATA
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_50M;				//时钟的端口,开发板用的50M晶振
input 				RST_N;				//复位的端口,低电平复位
output 				VGA_VSYNC;			//VGA垂直同步端口
output 				VGA_HSYNC;			//VGA水平同步端口
output  	[ 7:0]	VGA_DATA;			//VGA数据端口

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//例化PLL模块，生成VGA需要的40M时钟
PLL_Module			PLL_Inst 
(
	.inclk0 			(CLK_50M 	),		//50M时钟输入
	.c0 				(CLK_40M 	)		//40M时钟输出
);

Vga_Module			Vga_Init
(
	.CLK_50M			(CLK_40M		),		//40M时钟输入
	.RST_N			(RST_N		),		//复位的端口,低电平复位
	.VSYNC			(VGA_VSYNC	),		//VGA垂直同步端口
	.HSYNC			(VGA_HSYNC	),		//VGA水平同步端口
	.VGA_DATA		(VGA_DATA	)		//VGA数据端口
);

endmodule
