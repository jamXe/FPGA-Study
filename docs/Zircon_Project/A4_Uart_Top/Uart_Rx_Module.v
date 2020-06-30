module Uart_Rx_Module
(
	//输人端口
	CLK_50M,RST_N,UART_RX,rx_bps_flag,
	//输出端口
	out_rx_data,rx_bps_start
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50M晶振
input					RST_N;					//复位的端口,低电平复位
input					UART_RX;					//FPGA的接收端口,串口CP2102的发送端口
input 				rx_bps_flag;			//接收数据位的中间采样点
output 				rx_bps_start;			//接收端口的波特率时钟启动信号
output	[ 7:0] 	out_rx_data;			//从UART_RX数据线中解析完后的数据

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[ 1:0]	detect_edge;			//记录UART的开始脉冲,即第一个下降沿
wire		[ 1:0]	detect_edge_n;			//detect_edge的下一个状态
reg					negedge_reg;			//下降沿标志
wire					negedge_reg_n;			//negedge_reg的下一个状态
reg					rx_bps_start;			//接收端口的波特率时钟启动信号
reg					rx_bps_start_n;		//rx_bps_start的下一个状态
reg 		[ 3:0] 	bit_cnt;					//用来记录接收数据位
reg 		[ 3:0] 	bit_cnt_n;				//bit_cnt的下一个状态
reg 		[ 7:0] 	shift_data;				//接收串行数据流中用到的移位寄存器
reg 		[ 7:0] 	shift_data_n;			//shift_data的下一个状态
reg		[ 7:0] 	out_rx_data;			//从UART_RX数据线中解析完后的数据
reg		[ 7:0] 	out_rx_data_n;			//out_rx_data的下一个状态

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给detect_edge寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		detect_edge	<= 2'b11;				//初始化detect_edge值
	else
		detect_edge <= detect_edge_n;		//用来给detect_edge赋值
end

//组合电路,用来接收UART_RX信号
assign detect_edge_n = {detect_edge[0], UART_RX};	

//时序电路,用来给negedge_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		negedge_reg	<= 1'b0;					//初始化negedge_reg值
	else
		negedge_reg <= negedge_reg_n;		//用来给negedge_reg赋值
end

//组合电路,判断下降沿,如果下降沿到来,negedge_reg_n就为1
assign negedge_reg_n = (detect_edge == 2'b10) ? 1'b1 : 1'b0; 

//时序电路,用来给rx_bps_start寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		rx_bps_start <= 1'b0;				//初始化rx_bps_start值
	else
		rx_bps_start <= rx_bps_start_n;	//用来给rx_bps_start赋值
end

//组合电路,如果下降沿到来,那么将启动波特率计数器
always @ (*)
begin
	if(negedge_reg)							//判断下降沿
		rx_bps_start_n = 1'b1;				//如果下降沿到来,将rx_bps_start_n置1
	else if(bit_cnt == 4'd9)				//判断数据有没有接收完成
		rx_bps_start_n = 1'b0;				//如果数据接收完成,将rx_bps_start_n置0
	else
		rx_bps_start_n = rx_bps_start;	//否则,将保持不变
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		bit_cnt <= 4'b0;						//初始化bit_cnt值
	else
		bit_cnt <= bit_cnt_n;				//用来给bit_cnt赋值
end

//组合电路,如果到达数据位的中间采样点,那么接收数据位计数器加1,采样下一个数据位
always @ (*)
begin
	if(rx_bps_flag)							//判断有没有达到数据位的中间采样点
		bit_cnt_n = bit_cnt + 1'b1;		//如果到达,那么接收数据位计数器加1,
	else if(bit_cnt == 4'd9)				//判断数据有没有接收完成
		bit_cnt_n = 1'b0;						//如果数据接收完成,接收数据位计数器清零
	else
		bit_cnt_n = bit_cnt;					//否则,将保持不变
end

//时序电路,用来给shift_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		shift_data <= 8'b0;					//初始化shift_data值
	else
		shift_data <= shift_data_n;		//用来给shift_data赋值
end

//组合电路,采样每个数据位的中心时间点,每采样一个便开始启动移位寄存器记录数据
always @ (*)
begin
	if(rx_bps_flag)							//判断有没有达到数据位的中间采样点
		shift_data_n = {UART_RX,shift_data[7:1]};	//如果到达,那么接收UART_RX中的数据
	else
		shift_data_n = shift_data;			//否则,将保持不变
end

//时序电路,用来给out_rx_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		out_rx_data <= 8'b0;					//初始化out_rx_data值
	else
		out_rx_data <= out_rx_data_n;		//用来给out_rx_data赋值
end

//组合电路,如果数据接收完成,那么将移位寄存器中的数据输出
always @ (*)
begin
	if(bit_cnt == 4'd9)						//判断数据有没有接收完成
		out_rx_data_n = shift_data;		//如果接收完成,那么将移位寄存器中的数据输出
	else
		out_rx_data_n = out_rx_data;		//否则,将保持不变
end

endmodule
