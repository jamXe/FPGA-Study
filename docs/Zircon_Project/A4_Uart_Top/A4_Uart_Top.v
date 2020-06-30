module A4_Uart_Top
(
	//输入端口
	CLK_50M,RST_N,UART_RX,
	//输出端口
	UART_TX,BEEP
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50M晶振
input					RST_N;					//复位的端口,低电平复位
input					UART_RX;					//FPGA的接收端口,串口CP2102的发送端口
output 				UART_TX;					//FPGA的发送端口,串口CP2102的接收端口
output				BEEP;						//蜂鸣器端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
wire 					rx_bps_start;			//接收端口的波特率时钟启动信号
wire 					tx_bps_start;			//发送端口的波特率时钟启动信号
wire 					rx_bps_flag;			//接收数据位的中间采样点
wire 					tx_bps_flag;			//发送数据的数据改变点 
wire 		[7:0] 	out_rx_data;			//接收数据寄存器，保存直至下一个数据来到

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
	.out_rx_data		(out_rx_data	)	//将接收的数据输出
);

/*
//例化波特率模块			
Uart_Bps_Module		Uart_Tx_Bps_Init
(	
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.bps_start			(tx_bps_start	),	//发送端口的波特率时钟启动信号
	.bps_flag			(tx_bps_flag	)	//发送数据的数据改变点 
);

//例化发送模块
Uart_Tx_Module			Uart_Tx_Init
(		
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			), //复位端口
	.UART_TX				(UART_TX			),	//FPGA的发送端口,串口CP2102的接收端口
	.tx_bps_start		(tx_bps_start	),	//发送端口的波特率时钟启动信号
	.tx_bps_flag		(tx_bps_flag	),	//发送数据的数据改变点 
	.tx_start_flag		(rx_bps_start	),	//接收模块完成数据采集标志位
	.in_rx_data			(out_rx_data	)	//将接收的数据输出给发送模块进行发送
);
*/

//例化蜂鸣器模块
Beep_Module				Beep_Init
(
	.CLK_50M				(CLK_50M			),	//时钟端口
	.RST_N				(RST_N			),	//复位端口
	.BEEP					(BEEP				),	//蜂鸣器端口
	.KEY					(out_rx_data	)	//将接收的数据输出给蜂鸣器模块
);


endmodule
