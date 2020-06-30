//---------------------------------------------------------------------------
//--	文件名		:	Segled_Module.v
//--	作者		:	ZIRCON
//--	描述		:	数码管显示模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module Segled_Module
(	
	//输入端口 
	CLK_50M,RST_N,seconds2_data,seconds1_data,minutes1_data,minutes2_data,
	hours1_data,hours2_data,
	//输出端口
	SEG_DATA,SEG_EN
);
	
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 						CLK_50M;					//时钟端口
input							RST_N;					//复位端口
input	 		[ 3:0]		hours2_data;			//时钟高4位数据
input	 		[ 3:0]		hours1_data;			//时钟低4位数据
input	 		[ 3:0]		minutes2_data;			//分钟高4位数据
input	 		[ 3:0]		minutes1_data;			//分钟低4位数据
input	 		[ 3:0]		seconds2_data;			//秒钟高4位数据
input	 		[ 3:0]		seconds1_data;			//秒钟低4位数据
output reg 	[ 5:0] 		SEG_EN;					//数码管使能端口
output reg 	[ 7:0] 		SEG_DATA;				//数码管端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg			[26:0]		time_cnt;				//用来控制数码管闪烁频率的定时计数器
reg			[26:0]		time_cnt_n;				//time_cnt的下一个状态
reg			[ 2:0]		led_cnt;					//用来控制数码管亮灭及显示数据的显示计数器
reg			[ 2:0]		led_cnt_n;				//led_cnt的下一个状态
reg 			[ 3:0]		led_data;				//数据转换寄存器

//设置定时器的时间为10ms,计算方法为  (1*10^6) / (1/50)  50MHz为开发板晶振
parameter SEC_TIME = 16'd50_000;	

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)											//判断复位
		time_cnt <= 27'h0;							//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;						//用来给time_cnt赋值
end

//组合电路,实现10ms的定时计数器
always @ (*)  
begin
	if(time_cnt == SEC_TIME )						//判断10ms时间
		time_cnt_n = 27'h0;							//如果到达10ms,定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 27'h1;			//如果未到10ms,定时计数器将会继续累加
end

//时序电路,用来给led_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)											//判断复位
		led_cnt <= 3'b000;							//初始化led_cnt值
	else
		led_cnt <= led_cnt_n;						//用来给led_cnt赋值
end

//组合电路,判断时间,实现控制显示计数器累加
always @ (*)  
begin
	if(time_cnt == SEC_TIME )						//判断10ms时间		
		led_cnt_n = led_cnt + 1'b1;				//如果到达10ms,计数器进行累加
	else
		led_cnt_n = led_cnt;							//如果未到10ms,计数器保持不变
end

//组合电路,实现数码管的数字显示,将时钟中的数据转换成显示数据
always @ (*)
begin
	case(led_cnt)
		0 : led_data = hours2_data;				//时钟高4位显示
		1 : led_data = hours1_data;				//时钟低4位显示
		2 : led_data = minutes2_data;				//分钟高4位显示
		3 : led_data = minutes1_data;				//分钟低4位显示
		4 : led_data = seconds2_data;				//秒钟高4位显示
		5 : led_data = seconds1_data;				//秒钟低4位显示
		default: led_data = 4'hF;					//给数码管赋值为F
	endcase
end

//组合电路,控制数码管的亮灭
always @ (*)
begin
	case (led_cnt)  
		0 : SEG_EN = 6'b111110; 					//当计数器为0时,数码管SEG1显示
		1 : SEG_EN = 6'b111101;  					//当计数器为1时,数码管SEG2显示
		2 : SEG_EN = 6'b111011; 					//当计数器为2时,数码管SEG3显示
		3 : SEG_EN = 6'b110111; 					//当计数器为3时,数码管SEG4显示
		4 : SEG_EN = 6'b101111;						//当计数器为4时,数码管SEG5显示
		5 : SEG_EN = 6'b011111;						//当计数器为5时,数码管SEG6显示
		default : SEG_EN = 6'b111111;				//熄灭所有数码管	
	endcase 	
end

//组合电路,控制数码管小数点的亮灭
always @ (*)
begin
	case (led_cnt)  
		0 : SEG_DATA[7] = 1'b0;  					//点亮数码管SEG1的小数点
		1 : SEG_DATA[7] = 1'b1;	  					//点亮数码管SEG2的小数点
		2 : SEG_DATA[7] = 1'b0; 					//点亮数码管SEG3的小数点
		3 : SEG_DATA[7] = 1'b1;  					//点亮数码管SEG4的小数点
		4 : SEG_DATA[7] = 1'b0; 					//点亮数码管SEG5的小数点
		5 : SEG_DATA[7] = 1'b0; 					//点亮数码管SEG6的小数点
		default : SEG_DATA[7] = 1'b0;				//熄灭所有数码管的小数点
	endcase 	
end

//组合电路,实现数码管的显示
always @ (*)
begin
  case(led_data)
		0  : SEG_DATA[6:0] = 7'b0111111;   		//显示数字 "0"
		1  : SEG_DATA[6:0] = 7'b0000110;  		//显示数字 "1"
		2  : SEG_DATA[6:0] = 7'b1011011;   		//显示数字 "2"
		3  : SEG_DATA[6:0] = 7'b1001111;   		//显示数字 "3"
		4  : SEG_DATA[6:0] = 7'b1100110;  		//显示数字 "4"
		5  : SEG_DATA[6:0] = 7'b1101101;   		//显示数字 "5"
		6  : SEG_DATA[6:0] = 7'b1111101;   		//显示数字 "6"
		7  : SEG_DATA[6:0] = 7'b0000111;   		//显示数字 "7"
		8  : SEG_DATA[6:0] = 7'b1111111;   		//显示数字 "8"
		9  : SEG_DATA[6:0] = 7'b1101111;  		//显示数字 "9"
		10 : SEG_DATA[6:0] = 7'b1110111;   		//显示数字 "A"
		11 : SEG_DATA[6:0] = 7'b1111100;   		//显示数字 "B"
		12 : SEG_DATA[6:0] = 7'b1011000;   		//显示数字 "C"
		13 : SEG_DATA[6:0] = 7'b1011110;   		//显示数字 "D"
		14 : SEG_DATA[6:0] = 7'b1111001;   		//显示数字 "E"
		15 : SEG_DATA[6:0] = 7'b1110001;   		//显示数字 "F"
		default :SEG_DATA[6:0] = 7'b0111111;	//显示数字 "0"
  endcase
end

endmodule

