//---------------------------------------------------------------------------
//--	文件名		:	Counter_Module.v
//--	作者		:	ZIRCON
//--	描述		:	时钟计时模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module Counter_Module
( 
	//输入端口
	CLK_50M,RST_N,key_out,LED,
	//输出端口
	hours2_data,hours1_data,minutes2_data,minutes1_data,seconds2_data,
	seconds1_data
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_50M;							//时钟的端口,开发板用的50MHz晶振
input 				RST_N;							//复位的端口,低电平复位
input		[ 7:0]	key_out;							//按键端口
output	[ 7:0]	LED;								//LED端口
output 				hours2_data;					//时钟高4位数据
output 				hours1_data;					//时钟低4位数据
output 				minutes2_data;					//分钟高4位数据
output 				minutes1_data;					//分钟低4位数据
output 				seconds2_data;					//秒钟高4位数据
output 				seconds1_data;					//秒钟低4位数据

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[26:0] 	time_seconds;					//秒钟低位计数器
reg		[26:0] 	time_seconds_n;				//time_seconds的下一个状态
reg		[ 3:0] 	seconds1_data;					//秒钟低位数据寄存器1
reg		[ 3:0] 	seconds1_data_n;				//seconds1_data的下一个状态
reg		[ 3:0] 	seconds2_data;					//秒钟高位数据寄存器2
reg		[ 3:0] 	seconds2_data_n;				//seconds2_data的下一个状态
reg		[ 3:0] 	minutes1_data;					//分钟低位数据寄存器
reg		[ 3:0] 	minutes1_data_n;				//minutes1_data的下一个状态
reg		[ 3:0] 	minutes2_data;					//分钟高位数据寄存器
reg		[ 3:0] 	minutes2_data_n;				//minutes1_data的下一个状态
reg		[ 3:0] 	hours1_data;					//时钟低位数据寄存器
reg		[ 3:0] 	hours1_data_n;					//hours1_data一个状态
reg		[ 3:0] 	hours2_data;					//时钟高位数据寄存器
reg		[ 3:0] 	hours2_data_n;					//hours2_data一个状态
reg					stop_reg;						//控制时钟的开始和暂停
reg					stop_reg_n;						//stop_reg的下一个状态

//设置定时器的时间为1s,计算方法为  (1*10^9) / (1/50)  50MHZ为开发板晶振
parameter SEC_TIME_1S  = 27'd50_000_000;		

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给stop_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		stop_reg <= 1'b0;								//初始化stop_reg值
	else
		stop_reg <= stop_reg_n;						//用来给stop_reg赋值
end

//组合电路,用于控制数字时钟的暂停与开始
always @ (*)
begin
	if(key_out[7])										//判断KEY8有没有按下
		stop_reg_n = ~stop_reg;						//当按键按下时,改变stop_reg寄存器的状态
	else
		stop_reg_n = stop_reg;						//当按键没有按下时,stop_reg保持原状态不变
end
//---------------------------------------------------------------------------
//时序电路,用来给time_seconds寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		time_seconds <= 1'b0;						//初始化time_seconds值
	else
		time_seconds <= time_seconds_n;			//用来给time_seconds赋值
end

//组合电路，实现1s的定时计数器
always @ (*)
begin
	if(time_seconds == SEC_TIME_1S)				//判断1s时间
		time_seconds_n = 1'b0;						//如果到达1s,定时计数器将会被清零
	else if(stop_reg)									//判断有没有按下暂停
		time_seconds_n = time_seconds + 1'b1;	//如果没有暂停,定时计数器将会继续累加
	else
		time_seconds_n = time_seconds;			//否则,定时计数器将会保持不变
end	
//---------------------------------------------------------------------------
//时序电路,用来给seconds1_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		seconds1_data <= 1'b0;						//初始化seconds1_data值
	else
		seconds1_data <= seconds1_data_n;		//用来给seconds1_data赋值
end

//组合电路，用来控制秒数个位的进位和清零
always @ (*)
begin
	if(time_seconds == SEC_TIME_1S | key_out[6] == 1'b1)	//判断按键KEY7和判断1s时间
		seconds1_data_n = seconds1_data + 1'b1;//如果按键按下或者到达1s,seconds1_data将会加1
	else if(seconds1_data == 4'd10)				//判断seconds1_data有没有达到10s
		seconds1_data_n = 1'b0;						//如果seconds1_data到达10s,seconds1_data将会被清零
	else			
	seconds1_data_n = seconds1_data;				//否则seconds1_data将会保持不变
end
//---------------------------------------------------------------------------
//时序电路,用来给seconds2_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin	
	if(!RST_N)											//判断复位
		seconds2_data <= 4'd0;						//初始化seconds2_data值
	else
		seconds2_data <= seconds2_data_n;		//用来给seconds2_data赋值
end

//组合电路，用来控制秒数十位的进位和清零
always @ (*)
begin
	if(seconds1_data == 4'd10)						//判断seconds1_data有没有达到10s
		seconds2_data_n = seconds2_data + 1'b1;//如果seconds1_data到达10s,seconds2_data将会加1
	else if(seconds2_data == 4'd6)				//判断seconds2_data有没有达到60s
		seconds2_data_n = 1'b0;						//如果seconds2_data到达60s,seconds2_data将会被清零
	else
		seconds2_data_n = seconds2_data;			//否则seconds2_data将会保持不变
end
//---------------------------------------------------------------------------
//时序电路,用来给minutes1_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		minutes1_data <= 4'd0;						//初始化minutes1_data值
	else
		minutes1_data <= minutes1_data_n;		//用来给minutes1_data赋值
end

//组合电路，用来控制分数个位的进位和清零
always @ (*)
begin
	if(seconds2_data == 4'd6 | key_out[5] == 1'b1)	//判断按键KEY6和判断1m时间
		minutes1_data_n = minutes1_data + 1'b1;//如果按键按下或者到达1m,minutes1_data将会加1
	else if(minutes1_data == 4'd10)				//判断minutes1_data有没有达到10m
		minutes1_data_n = 1'b0;						//如果minutes1_data达到10m,minutes1_data将会被清零
	else
		minutes1_data_n = minutes1_data;			//否则minutes1_data将会保持不变
end
//---------------------------------------------------------------------------
//时序电路,用来给minutes2_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		minutes2_data <= 4'd0;						//初始化minutes2_data值
	else
		minutes2_data <= minutes2_data_n;		//用来给minutes2_data赋值
end

//组合电路，用来控制分数十位的进位和清零
always @ (*)
begin
	if(minutes1_data == 4'd10)						//判断minutes1_data有没有达到10m
		minutes2_data_n = minutes2_data + 1'b1;//如果minutes1_data达到10m,minutes2_data将会加1
	else if(minutes2_data == 4'd6)				//判断minutes2_data有没有达到60m
		minutes2_data_n = 1'b0;						//如果minutes2_data达到10m,minutes2_data将会被清零
	else
		minutes2_data_n = minutes2_data;			//否则minutes2_data将会保持不变
end
//---------------------------------------------------------------------------
//时序电路,用来给hours1_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin	
	if(!RST_N)											//判断复位
		hours1_data <= 4'd2;							//初始化hours1_data值
	else
		hours1_data <= hours1_data_n;				//用来给hours1_data赋值
end

//组合电路，用来控制时数个位的进位和清零
always @ (*)
begin
	if(minutes2_data == 4'd6 | key_out[4] == 1'b1)	//判断按键KEY5和判断1h时间
		hours1_data_n = hours1_data + 1'b1;		//如果按键按下或者到达1h,hours1_data将会加1	
	else if((hours2_data == 4'd0 || hours2_data == 4'd1) && hours1_data == 4'd10 || (hours2_data == 4'd2 && hours1_data == 4'd4))
		hours1_data_n = 1'b0;						//如果hours2_data等于0,且hours1_data等于10,hours1_data将会被清零
															//如果hours2_data等于1,且hours1_data等于10,hours1_data将会被清零
															//如果hours2_data等于2,且hours1_data等于 4,hours1_data将会被清零
	else
		hours1_data_n = hours1_data;				//否则hours1_data将会保持不变
end
//---------------------------------------------------------------------------
//时序电路,用来给hours2_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)											//判断复位
		hours2_data <= 1'b1;							//初始化hours2_data值
	else
		hours2_data <= hours2_data_n;				//用来给hours2_data赋值
end

//组合电路，用来控制时数十位的进位和清零
always @ (*)
begin
	if((hours2_data == 4'd0 || hours2_data == 4'd1) && hours1_data == 4'd10 || (hours2_data == 4'd2 && hours1_data == 4'd4))
		hours2_data_n = hours2_data + 1'b1;		//如果hours2_data等于0,且hours1_data等于10,hours1_data将会被清零
															//如果hours2_data等于1,且hours1_data等于10,hours1_data将会被清零
															//如果hours2_data等于2,且hours1_data等于 4,hours1_data将会被清零
	else if(hours2_data == 4'd3)							
		hours2_data_n = 1'b0;						//如果hours2_data等于3,hours2_data将会被清零
	else
		hours2_data_n = hours2_data;				//否则hours2_data将会保持不变
end
//---------------------------------------------------------------------------
assign LED = {seconds2_data,seconds1_data};	//将秒钟低4位数据和秒钟高4位数据赋值给LED端口

endmodule
