module Uart_Bps_Module
(
	//输入端口
	CLK_50M,RST_N,bps_start,
	//输出端口
	bps_flag
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50M晶振
input					RST_N;					//复位的端口,低电平复位
input 				bps_start;				//接收和发送端口的波特率时钟启动信号
output 				bps_flag;				//接收数据位的中间采样点,发送数据的数据改变点 

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[12:0] 	time_cnt;				//分频计数
reg		[12:0] 	time_cnt_n;				//time_cnt的下一个状态
reg					bps_flag;				//接收数据位的中间采样点,发送数据的数据改变点 
reg					bps_flag_n;				//bps_flag的下一个状态

//计算方式为,波特率为115200 ,1/115200每一位的周期是8.68us, 8.68 / (1 /50) = 434
parameter			BPS_PARA   = 9'd434;	//波特率为115200时的分频计数值
parameter 			BPS_PARA_2 = 8'd217;	//波特率为115200时的分频计数值的一半

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin	
	if(!RST_N)									//判断复位
		time_cnt <= 13'b0;					//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;				//用来给time_cnt赋值
end

//组合电路,1位数据需要8.68us,实现8.68us的定时器
always @ (*)
begin
	if((time_cnt == BPS_PARA) || (!bps_start)) 
		time_cnt_n = 1'b0;					//波特率计数清零
	else	
		time_cnt_n = time_cnt + 1'b1;		//波特率时钟计数启动
end

//时序电路,用来给bps_flag寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		bps_flag <= 1'b0;						//初始化bps_flag值
	else
		bps_flag <= bps_flag_n;				//用来给bps_flag赋值
end

//组合电路,判断接收数据位的中间采样点,发送数据的数据改变点 
always @ (*)
begin
	if(time_cnt == BPS_PARA_2)				//判断时间有没有到达4.43us
		bps_flag_n = 1'b1;					//如果达到,将采样标志位置1送出
	else
		bps_flag_n = 1'b0;					//如果没有达到,将采样完成标志位置0送出
end

endmodule

