//---------------------------------------------------------------------------
//--	文件名		:	A4_Ked2.v
//--	作者		:	ZIRCON
//--	描述		:	按键消抖
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module Key_Module
(
	//输入端口
	CLK_50M,RST_N,
	//输出端口
	KEY,key_out
);  
 
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;				//时钟的端口,开发板用的50MHz晶振
input					RST_N;				//复位的端口,低电平复位
input		[ 7:0]	KEY;					//对应开发板上的KEY
output	[ 7:0]	key_out;				//消抖完成输出按键

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[24:0]	time_cnt;			//用来计数按键延迟的定时计数器
reg		[24:0]	time_cnt_n;			//time_cnt的下一个状态
reg		[ 7:0]	key_in_r;			//用来接收按键信号的寄存器
reg		[ 7:0]	key_out;				//消抖完成输出按键
reg		[ 7:0] 	key_out_n;			//key_out的下一个状态
wire					key_press;			//检测按键有没有变化

//设置定时器的时间为20ms,计算方法为  (20*10^3)us / (1/50)us  50MHz为开发板晶振
parameter SET_TIME_20MS = 25'd10_000_000;	

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路，用来key_in_r寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		key_in_r <= 8'h00;				//初始化key_in_r值
	else
		key_in_r <= KEY;					//将按键的值赋值给key_in_r
end

assign key_press = key_in_r ^ KEY;	//检测按键有没有变化

//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		time_cnt <= 25'h0;				//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;			//用来给time_cnt赋值
end

//组合电路，实现20ms的定时计数器
always @ (*)
begin
	if(time_cnt == SET_TIME_20MS || key_press) //判断按键有没有变化、时间有没有到
		time_cnt_n = 25'h0;				//如果到达20ms或者按键有了变化,那么定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 1'b1;//如果未到20ms或者按键没有变化,那么定时计数器将会继续累加
end

//时序电路，用来key_out寄存器赋值
always @ (posedge CLK_50M, negedge RST_N)
begin
	if(!RST_N)								//判断复位
		key_out <= 8'h00;					//初始化key_out值
	else
		key_out <= key_out_n;			//用来给key_out赋值
end

//组合电路，每20ms接收一次按键的值
always @ (*)
begin
	if(time_cnt == SET_TIME_20MS)		//判断20ms时间
		key_out_n = key_in_r;			//如果到达20ms,接收一次按键的值
	else
		key_out_n = 8'h00;				//如果未到20ms,保持原状态不变
end

endmodule


