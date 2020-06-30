
module Uart_Tx_Module
(
	//输入端口
	CLK_50M,RST_N,in_rx_data,tx_start_flag,tx_bps_flag,
	//输出端口
	UART_TX,tx_bps_start
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50M晶振
input					RST_N;					//复位的端口,低电平复位
input 				tx_start_flag;			//接收模块完成数据采集标志位
input 				tx_bps_flag;			//发送数据的数据改变点 
input		[ 7:0] 	in_rx_data;				//将接收的数据输出给发送模块进行发送
output 				tx_bps_start;			//发送端口的波特率时钟启动信号
output 				UART_TX;					//FPGA的发送端口,串口CP2102的接收端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[ 1:0]	detect_edge;			//记录tx_start_flag的脉冲
wire		[ 1:0]	detect_edge_n;			//detect_edge的下一个状态
reg					negedge_reg;			//下降沿标志
wire					negedge_reg_n;			//negedge_reg的下一个状态
reg					tx_bps_start;			//发送端口的波特率时钟启动信号
reg					tx_bps_start_n;		//tx_bps_start的下一个状态
reg		[ 7:0] 	tx_temp_data;			//待发送数据的寄存器
reg		[ 7:0] 	tx_temp_data_n;		//tx_temp_data的下一个状态
reg		[ 3:0] 	bit_cnt;					//用来记录发送数据位
reg		[ 3:0] 	bit_cnt_n;				//bit_cnt的下一个状态
reg					UART_TX;					//FPGA的发送端口,串口CP2102的接收端口
reg					UART_TX_N;				//UART_TX的下一个状态

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

//组合电路,用来接收tx_start_flag信号
assign detect_edge_n = {detect_edge[0], tx_start_flag};	

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

//时序电路,用来给tx_bps_start寄存器赋值
always @ (posedge CLK_50M or negedge RST_N) 
begin
	if(!RST_N)									//判断复位
		tx_bps_start <= 1'b0;				//初始化tx_bps_start值
	else
		tx_bps_start <= tx_bps_start_n;	//用来给tx_bps_start赋值
end

//组合电路,如果接收模块完成数据采集,那么就启动发送模块开始发送数据
always @ (*)
begin
	if(negedge_reg)							//判断接收模块是否完成数据采集
		tx_bps_start_n = 1'b1;				//如果完成数据采集,那么将tx_bps_start_n置1
	else if(bit_cnt == 4'd10)				//判断数据有没有发送完成
		tx_bps_start_n = 1'b0;				//如果数据发送完成,将tx_bps_start_n置0
	else
		tx_bps_start_n = tx_bps_start;	//否则,将保持不变
end

//时序电路,用来给tx_temp_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N) 
begin
	if(!RST_N)									//判断复位
		tx_temp_data <= 1'b0;				//初始化tx_temp_data值
	else
		tx_temp_data <= tx_temp_data_n;	//用来给tx_temp_data赋值
end

//组合电路,如果接收模块完成数据采集,那么将接收模块中接收到的数据读取到tx_temp_data中
always @ (*)
begin
	if(negedge_reg)							//判断接收模块是否完成数据采集
		tx_temp_data_n = in_rx_data;		//如果完成,那么将数据赋值给tx_temp_data_n
	else
		tx_temp_data_n = tx_temp_data;	//否则,将保持不变
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		bit_cnt <= 4'b0;						//初始化bit_cnt值
	else
		bit_cnt <= bit_cnt_n;				//用来给bit_cnt赋值
end

//组合电路,如果发送数据的数据改变点到来,那么发送数据位计数器加1,发送下一个数据位
always @ (*)
begin
	if(tx_bps_flag)							//判断发送数据的数据改变点
		bit_cnt_n = bit_cnt + 1'b1;		//如果到达,那么发送数据位计数器加1,
	else if(bit_cnt == 4'd10)				//判断数据有没有发送完成
		bit_cnt_n = 1'b0;						//如果数据接收完成,接收数据位计数器清零
	else
		bit_cnt_n = bit_cnt;					//否则,将保持不变
end

//时序电路,用来给UART_TX寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N) 									//判断复位
		UART_TX <= 1'b1;						//初始化UART_TX值
	else
		UART_TX <= UART_TX_N;				//用来给UART_TX赋值
end

//组合电路,用来将tx_temp_data中的数据赋值给UART_TX进行发送
always @ (*)
begin
	if(tx_bps_flag)							//判断发送数据的数据改变点
		case (bit_cnt)					
			4'd0: UART_TX_N = 1'b0; 				//发送起始位
			4'd1: UART_TX_N = tx_temp_data[0];	//发送bit0
			4'd2: UART_TX_N = tx_temp_data[1];	//发送bit1
			4'd3: UART_TX_N = tx_temp_data[2];	//发送bit2
			4'd4: UART_TX_N = tx_temp_data[3];	//发送bit3
			4'd5: UART_TX_N = tx_temp_data[4];	//发送bit4
			4'd6: UART_TX_N = tx_temp_data[5];	//发送bit5
			4'd7: UART_TX_N = tx_temp_data[6];	//发送bit6
			4'd8: UART_TX_N = tx_temp_data[7];	//发送bit7
			4'd9: UART_TX_N = 1'b1;					//发送结束位
			default: UART_TX_N = 1'b1;
		endcase
	else
		UART_TX_N = UART_TX;					//否则,将保持不变
end

endmodule


