module A4_Mod_Top
(
	//输入端口
	CLK_50M,RST_N,UART_RX,IR_DATA,PS2_CLK,PS2_DATA,
	//输出端口
	BEEP
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50M晶振
input					RST_N;					//复位的端口,低电平复位
input					UART_RX;					//FPGA的接收端口,串口CP2102的发送端口
input					IR_DATA;					//红外端口
input					PS2_CLK;					//PS2的时钟端口
input					PS2_DATA;				//PS2的数据端口
output				BEEP;						//蜂鸣器端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
wire 					rx_bps_start;			//接收端口的波特率时钟启动信号
wire 					rx_bps_flag;			//接收数据位的中间采样点
wire 		[ 7:0] 	out_rx_data;			//接收数据寄存器，保存直至下一个数据来到
wire 		[ 7:0]	o_ir_data;				//接收到红外的完整数据
wire	 	[15:0]	o_ps2_data;				//接收到PS2的完整数据
wire					ps2_finish;				//PS/2数据接收完成标志位
wire					uart_finish;			//串口数据接收完成标志位
wire 					ir_finish;				//红外数据接收完成标志位

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//例化波特率模块
Uart_Bps_Module		Uart_Rx_Bps_Init
(	
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.bps_start			(rx_bps_start	),	//接收端口的波特率时钟启动信号
	.bps_flag			(rx_bps_flag	)	//接收数据位的中间采样点
);

//例化接收模块
Uart_Rx_Module			Uart_Rx_Init
(		
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.UART_RX				(UART_RX			),	//FPGA的接收端口,串口CP2102的发送端口
	.rx_bps_start		(rx_bps_start	),	//接收端口的波特率时钟启动信号
	.rx_bps_flag		(rx_bps_flag	),	//接收数据位的中间采样点
	.out_rx_data		(out_rx_data	),	//将接收的数据输出
	.uart_finish		(uart_finish	)	//串口数据接收完成标志位
);

//例化红外模块
Ir_Module				Ir_Module_Init
(
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.IR_DATA				(IR_DATA			),	//红外端口
	.o_ir_data			(o_ir_data		),	//接收的红外的完整数据
	.ir_finish			(ir_finish		)	//红外数据接收完成标志位
);	

//例化PS2
Ps2_Module				Ps2_Init
(
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.PS2_CLK				(PS2_CLK			),	//PS2的时钟端口
	.PS2_DATA			(PS2_DATA		),	//PS2的数据端口
	.o_ps2_data			(o_ps2_data		),	//接收的PS2的完整数据
	.ps2_finish			(ps2_finish		)	//PS/2数据接收完成标志位
);

//例化蜂鸣器模块
Beep_Module				Beep_Init
(
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.BEEP					(BEEP				),	//蜂鸣器端口
	.uart_finish		(uart_finish	),	//串口数据接收完成标志位	
	.ir_finish			(ir_finish		),	//红外数据接收完成标志位
	.ps2_finish			(ps2_finish		),	//PS/2数据接收完成标志位
	.in_rx_data			(out_rx_data	),	//将接收的串口数据输出给蜂鸣器模块
	.in_ir_data			(o_ir_data		),	//将接收的红外数据输出给蜂鸣器模块
	.in_ps2_data		(o_ps2_data		)	//将接收的PS/2数据输出给蜂鸣器模块
);


endmodule
