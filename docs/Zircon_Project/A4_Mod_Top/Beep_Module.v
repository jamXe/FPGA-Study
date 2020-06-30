//---------------------------------------------------------------------------
//--	文件名		:	Beep_Module.v
//--	作者		:	ZIRCON
//--	描述		:	蜂鸣器发声模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module Beep_Module
(
	//输入端口
	CLK_50M,RST_N,in_rx_data,in_ir_data,in_ps2_data,
	uart_finish,ir_finish,ps2_finish,
	//输出端口
	BEEP
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50MHz晶振
input					RST_N;					//复位的端口,低电平复位
input 	[ 7:0] 	in_rx_data;				//接收数据寄存器，保存直至下一个数据来到
input 	[ 7:0]	in_ir_data;				//接收到红外的完整数据
input	 	[15:0]	in_ps2_data;			//接收到PS2的完整数据
input					uart_finish;			//串口数据接收完成标志位	
input					ir_finish;				//红外数据接收完成标志位
input					ps2_finish;				//PS/2数据接收完成标志位
output				BEEP;						//蜂鸣器端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[15:0]	time_cnt;				//用来控制蜂鸣器发声频率的定时计数器
reg		[15:0]	time_cnt_n;				//time_cnt的下一个状态
reg		[15:0]	freq;						//各种音调的分频值
reg		[15:0]	freq_n;					//各种音调的分频值
reg					beep_reg;				//用来控制蜂鸣器发声的寄存器
reg					beep_reg_n;				//beep_reg的下一个状态
reg		[ 7:0]	temp_data;				//用来接收串口、红外和PS/2数据的临时寄存器
reg		[ 7:0]	temp_data_n;			//temp_data的下一个状态
	
//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		time_cnt <= 16'b0;						//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;				//用来给time_cnt赋值
end

//组合电路,判断频率,让定时器累加 
always @ (*)
begin
	if(time_cnt == freq)						//判断分频值
		time_cnt_n = 16'b0;					//定时器清零操作
	else
		time_cnt_n = time_cnt + 1'b1;		//定时器累加操作

end

//时序电路，用来给beep_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		beep_reg <= 1'b0;						//初始化beep_reg值
	else
		beep_reg <= beep_reg_n;				//用来给beep_reg赋值
end

//组合电路,判断频率,使蜂鸣器发声
always @ (*)
begin
	if(time_cnt == freq)						//判断分频值
		beep_reg_n = ~beep_reg;				//改变蜂鸣器的状态
	else
		beep_reg_n = beep_reg;				//蜂鸣器的状态保持不变
end

//时序电路，用来给temp_data寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		temp_data <= 8'b0;					//初始化temp_data值
	else
		temp_data <= temp_data_n;			//用来给temp_data赋值
end

//时序电路，用来接收串口、红外和PS/2数据
always @ (*)
begin
	if(uart_finish)							//判断串口数据有没有接收完毕
		temp_data_n = in_rx_data;			//如果接收完毕，那么将串口的数据赋值给temp_data
	else if(ir_finish)						//判断红外数据有没有接收完毕
		temp_data_n = in_ir_data;			//如果接收完毕，那么将红外的数据赋值给temp_data
	else if(ps2_finish)						//判断PS2数据有没有接收完毕
		temp_data_n = in_ps2_data;			//如果接收完毕，那么将PS2的数据赋值给temp_data
	else
		temp_data_n = temp_data;			//否则,将保持不变
end

//时序电路，用来给beep_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		freq <= 16'b0;							//初始化beep_reg值
	else
		freq <= freq_n;						//用来给beep_reg赋值
end

//组合电路，按键选择分频值来实现蜂鸣器发出不同声音
//中音do的频率为523.3hz，freq = 50 * 10^6 / (523 * 2) = 47774
always @ (*)
begin
	case(temp_data)
		8'h16: freq_n = 16'd0;				//判断红外的值,没有声音
		8'h0C: freq_n = 16'd47774; 		//中音1的频率值262Hz
		8'h18: freq_n = 16'd42568; 		//中音2的频率值587.3Hz
		8'h5E: freq_n = 16'd37919; 		//中音3的频率值659.3Hz
		8'h08: freq_n = 16'd35791; 		//中音4的频率值698.5Hz
		8'h1C: freq_n = 16'd31888; 		//中音5的频率值784Hz
		8'h5A: freq_n = 16'd28409; 		//中音6的频率值880Hz
		8'h42: freq_n = 16'd25309; 		//中音7的频率值987.8Hz
		8'h52: freq_n = 16'd23889; 		//高音1的频率值1046.5Hz
		8'h4A: freq_n = 16'd21276; 		//高音2的频率值1175Hz
		8'h70: freq_n = 16'd0;				//判断PS的值,没有声音
		8'h69: freq_n = 16'd47774; 		//中音1的频率值262Hz
		8'h72: freq_n = 16'd42568; 		//中音2的频率值587.3Hz
		8'h7A: freq_n = 16'd37919; 		//中音3的频率值659.3Hz
		8'h6B: freq_n = 16'd35791; 		//中音4的频率值698.5Hz
		8'h73: freq_n = 16'd31888; 		//中音5的频率值784Hz
		8'h74: freq_n = 16'd28409; 		//中音6的频率值880Hz
		8'h6C: freq_n = 16'd25309; 		//中音7的频率值987.8Hz
		8'h75: freq_n = 16'd23889; 		//高音1的频率值1046.5Hz
		8'h7D: freq_n = 16'd21276; 		//高音2的频率值1175Hz
		8'h30: freq_n = 16'd0;				//判断串口的值,没有声音
		8'h31: freq_n = 16'd47774; 		//中音1的频率值262Hz
		8'h32: freq_n = 16'd42568; 		//中音2的频率值587.3Hz
		8'h33: freq_n = 16'd37919; 		//中音3的频率值659.3Hz
		8'h34: freq_n = 16'd35791; 		//中音4的频率值698.5Hz
		8'h35: freq_n = 16'd31888; 		//中音5的频率值784Hz
		8'h36: freq_n = 16'd28409; 		//中音6的频率值880Hz
		8'h37: freq_n = 16'd25309; 		//中音7的频率值987.8Hz
		8'h38: freq_n = 16'd23889; 		//高音1的频率值1046.5Hz
		8'h39: freq_n = 16'd21276; 		//高音2的频率值1175Hz
		default: freq_n = freq;
	endcase
end

assign BEEP = beep_reg;		//最后,将寄存器的值赋值给端口BEEP

endmodule



