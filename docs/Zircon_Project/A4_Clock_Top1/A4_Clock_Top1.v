//---------------------------------------------------------------------------
//--	文件名		:	A4_Clock_Top1.v
//--	作者		:	ZIRCON
//--	描述		:	用外设实现数字电子时钟顶层文件
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module A4_Clock_Top1
(
	//输入端口
	CLK_50M,RST_N,KEY,
	//输出端口
	SEG_EN,SEG_DATA,BEEP,LED
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_50M;						//时钟端口
input 				RST_N;						//复位端口
input	 	[ 7:0]	KEY;							//按键端口
output 				BEEP;							//蜂鸣器端口
output 	[ 5:0]	SEG_EN;						//数码管使能端口
output 	[ 7:0]	SEG_DATA;					//数码管数据端口
output 	[ 7:0]	LED;							//LED端口
		
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
wire		[ 3:0] 	hours2_data;				//时钟高4位数据
wire		[ 3:0] 	hours1_data;				//时钟低4位数据
wire		[ 3:0] 	minutes2_data;				//分钟高4位数据
wire		[ 3:0] 	minutes1_data;				//分钟低4位数据
wire		[ 3:0] 	seconds2_data;				//秒钟高4位数据
wire		[ 3:0] 	seconds1_data;				//秒钟低4位数据
wire 		[ 7:0] 	key_out;						//消抖完毕输出

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//例化时钟计时模块
Counter_Module			Counter_Init
(
		.CLK_50M			(CLK_50M			),		//时钟端口
		.RST_N			(RST_N			),		//复位端口
		.key_out			(key_out			),		//消抖完毕输入
		.hours2_data	(hours2_data	),		//时钟高4位数据
		.hours1_data	(hours1_data	),		//时钟低4位数据
		.minutes2_data	(minutes2_data	),		//分钟高4位数据
		.minutes1_data	(minutes1_data	),		//分钟低4位数据
		.seconds2_data	(seconds2_data	),		//秒钟高4位数据
		.seconds1_data	(seconds1_data	),		//秒钟低4位数据
		.LED				(LED				)
);
//---------------------------------------------------------------------------
//例化数码管模块
Segled_Module			Segled_Init
(
		.CLK_50M			(CLK_50M			),		//时钟端口
		.RST_N			(RST_N			),		//复位端口
		.hours2_data	(hours2_data	),		//时钟高4位数据
		.hours1_data	(hours1_data	),		//时钟低4位数据
		.minutes2_data	(minutes2_data	),		//分钟高4位数据
		.minutes1_data	(minutes1_data	),		//分钟低4位数据
		.seconds2_data	(seconds2_data	),		//秒钟高4位数据
		.seconds1_data	(seconds1_data	),		//秒钟低4位数据
		.SEG_EN			(SEG_EN			),		//数码管使能端口
		.SEG_DATA		(SEG_DATA		)		//数码管数据端口
);
//---------------------------------------------------------------------------
//例化蜂鸣器模块
Beep_Module				Beep_Init
(
		.CLK_50M			(CLK_50M			),		//时钟端口
		.RST_N			(RST_N			),		//复位端口
		.BEEP				(BEEP				),		//蜂鸣器端口
		.KEY				(KEY				)		//没有消抖输入
);
//---------------------------------------------------------------------------
//例化按键消抖模块
Key_Module				Key_Init
(
		.CLK_50M			(CLK_50M			),		//时钟端口
		.RST_N			(RST_N			),		//复位端口
		.KEY				(KEY				),		//没有消抖输入
		.key_out			(key_out			)		//消抖完毕输出
);
	
endmodule

