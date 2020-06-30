//---------------------------------------------------------------------------
//--	文件名		:	A4_Oscilloscope_Top.v
//--	作者		:	ZIRCON
//--	描述		:	数字示波器
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module A4_Oscilloscope_Top
(
	//时钟和复位端口
	CLK_50M,RST_N,
	//拨码开关端口
	SWITCH,	
	//AD外设端口
	AD_CS,AD_CLK,AD_DATA,
	//DA外设端口
	DA_CLK,DA_DIN,DA_CS,
	//VGA外设端口
	VGA_HSYNC,VGA_VSYNC,VGA_DATA
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;				//时钟端口,开发板用的50M晶振
input					RST_N;				//复位端口,低电平复位
input	  [1:0]		SWITCH;				//拨码开关输入端口
input					AD_DATA;				//模拟数据输入端口
output				AD_CS;				//AD片选信号端口
output				AD_CLK;				//AD时钟，最大不超过1.1MHz
output				DA_CS;				//DA片选端口
output				DA_DIN;				//DA数据输出端口
output				DA_CLK;				//DA时钟端口

output				VGA_VSYNC;			//VGA垂直同步端口
output				VGA_HSYNC;			//VGA水平同步端口
output	[ 7:0]	VGA_DATA;			//VGA数据端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
wire 					clk_40m;				//PLL生成的40M时钟
wire		[ 9:0]	da_data;				//从ROM中读出的DA数据
wire					da_start;			//DA模块的开始标志位
wire 		[ 7:0] 	in_ad_data;			//AD模数转换完成的数据输出
wire 		[15:0] 	vga_x;				//VGA的x坐标
wire 		[31:0] 	vga_freq;			//VGA中显示的频率值
wire 		[31:0] 	vga_fengzhi;		//VGA中显示的峰峰值
wire 		[ 7:0] 	ad_to_vga_data;	//VGA中显示的波形数据

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//例化DA模块
Da_Module	 		Da_Init
(
	.CLK_50M			(CLK_50M			),	//时钟端口,开发板用的50M晶振	
	.RST_N			(RST_N			),	//复位端口,低电平复位
	.DA_CLK			(DA_CLK			),	//DA时钟端口
	.DA_DIN			(DA_DIN			),	//DA数据输出端口
	.DA_CS			(DA_CS			),	//DA片选端口
	.da_data			(da_data			),	//从ROM中读出的DA数据输入给DA模块
	.send_start		(da_start		)	//DA模块的开始标志位
);

//例化DA数据生成模块
Da_Data_Module		Da_Data_Init
(
	.CLK_50M			(CLK_50M			),	//时钟端口,开发板用的50M晶振	
	.RST_N			(RST_N			),	//复位端口,低电平复位
	.da_data			(da_data			),	//从ROM中读出的DA数据
	.da_start		(da_start		),	//DA模块的开始标志位
	.SWITCH			(SWITCH			)	//拨码开关输入端口
);

//例化AD模块
Ad_Module			Ad_Init
(
   .CLK_50M			(CLK_50M			),	//时钟端口
   .RST_N			(RST_N			),	//复位端口
	.AD_CS			(AD_CS			),	//AD片选端口
	.AD_CLK			(AD_CLK			),	//AD时钟，最大不超过1.1MHz
	.AD_DATA			(AD_DATA			),	//AD数据端口
	.data_out		(in_ad_data		)	//AD模数转换完成的数据输出
);	

Data_Process		Data_Process_Init
(
	.CLK_50M			(CLK_50M			),	//系统时钟50MHz
	.CLK_40M			(clk_40m			),	//PLL生成的40MHz时钟
   .RST_N			(RST_N			),	//复位端口
	.AD_CS			(AD_CS			),	//AD片选端口
	.in_ad_data		(in_ad_data		), //AD模数转换完成的数据输出
	.vga_x			(vga_x			),	//VGA的x坐标
	.vga_freq		(vga_freq		),	//VGA中显示的频率值
	.vga_fengzhi	(vga_fengzhi	), //VGA中显示的峰峰值
	.ad_to_vga_data(ad_to_vga_data)	//VGA中显示的波形数据
	
);

//例化PLL模块
PLL_Module			PLL_Module_Init 
(
	.inclk0 			(CLK_50M 		),	//系统时钟50MHz
	.c0 				(clk_40m 		)	//PLL生成的40MHz时钟
);

//例化VGA模块
Vga_Module			VGA_Init
(
	.RST_N			(RST_N			),	//复位端口
	.CLK_40M			(clk_40m			),	//PLL生成的40MHz时钟
	.VSYNC			(VGA_VSYNC		),	//VGA垂直同步端口
	.HSYNC			(VGA_HSYNC		),	//VGA水平同步端口
	.VGA_DATA		(VGA_DATA		),	//VGA数据端口
	.vga_x			(vga_x			), //VGA的x坐标
	.ad_to_vga_data(ad_to_vga_data), //VGA中显示的波形数据
	.vga_freq		(vga_freq		), //VGA中显示的频率值
	.vga_fengzhi	(vga_fengzhi	)  //VGA中显示的峰峰值
	
);

	
endmodule



