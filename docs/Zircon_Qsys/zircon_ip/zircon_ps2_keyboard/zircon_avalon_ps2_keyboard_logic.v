//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_keyboard_logic.v
//-- 描述		:	PS/2键盘IP核的硬件逻辑文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_keyboard_logic
(
	//时钟复位
	clock,reset,
	//外设管脚输出
	ps2_clk_in,ps2_data_in,  
	//用户逻辑输入与输出
	continued_press,shift_key_on,ascii_output,interrupt,rx_read
);  
  
input 				clock;          					//系统时钟
input 				reset;          					//系统复位
input 				ps2_clk_in;        				//PS/2时钟线,输入口
input 				ps2_data_in;          			//PS/2数据线,输入口
output 				continued_press;         		//持续按下按键标志位
output 				shift_key_on;	    				//shift键状态标志
output 	[7:0] 	ascii_output;						//从PS/2中读出的ASICC数据
output				interrupt;      					//avalon中断信号
input 				rx_read;       					//Avalon读请求和数据总线的使能标志位

reg 					continued_press;					//持续按下按键标志位
reg 					continued_press_n;				//continued_press的下一个状态
reg 		[7:0] 	ascii_output;						//从PS/2中读出的ASICC数据
reg 		[7:0] 	ascii_output_n;					//ascii_out的下一个状态
reg					interrupt;							//avalon中断信号
reg 					interrupt_n;						//interrupt的下一个状态
reg 					sync_ps2_clk;     				//同步PS/2时钟信号
reg 					sync_ps2_data;    				//同步PS/2数据信号
reg 		[ 1:0] 	fsm_cs;        					//状态机的当前状态
reg 		[ 1:0] 	fsm_ns;								//状态机的下一个状态
reg 		[ 3:0] 	bit_count;       					//移位计数器
reg 		[ 3:0] 	bit_count_n;       				//bit_count的下一个状态
reg 		[14:0] 	time_cnt_400us; 					//400us计数器
reg 		[14:0] 	time_cnt_400us_n; 				//time_cnt_400us的下一个状态
reg 					time_cnt_400us_done;				//400us计数器完成标识位
reg 					time_cnt_400us_done_n;			//time_cnt_400us_done的下一个状态
reg 		[10:0] 	read_data;   						//移位寄存器，用于接收ps2数据     
reg 		[10:0] 	read_data_n;   					//read_data的下一个状态
reg 					hold_released; 					//保持原先的值
reg 					hold_released_n; 					//hold_released的下一个状态
reg 					left_shift_key;      			//左SHIFT键标志
reg 					left_shift_key_n;      			//left_shift_key的下一个状态
reg 					right_shift_key;     			//右SHIFT键标志
reg 					right_shift_key_n;     			//right_shift_key的下一个状态
reg 		[ 6:0] 	ascii;           					//ASCII码

wire 					read_data_done; 					//接收一帧数据完成标识位
wire 					output_strobe; 					//收到键盘发送过来的一帧数据置位,且0xF0和SHIFT键值 
wire 					released;          				//断码标志    
wire 		[ 8:0] 	shift_key_plus_code; 			//包含shift键状态的扫描码

//状态机的状态参数表
parameter   		FSM_CLK_LOW  		= 2'd0,		//读时钟低电平
						FSM_CLK_HIGH  		= 2'd1,		//读时钟高电平
						FSM_FALLING_EDGE	= 2'd2,		//读时钟下降沿标志
						FSM_RISING_EDGE 	= 2'd3;		//读时钟上升沿标志


//同步PS/2的输入时钟
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		sync_ps2_clk <= 1'b0;					
	else
		sync_ps2_clk <= ps2_clk_in;			
end

//同步PS/2的数据信号
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		sync_ps2_data <= 1'b0;					
	else
		sync_ps2_data <= ps2_data_in;			
end
				
//时序电路,用来给fsm_cs赋值的
always @ (posedge clock or negedge reset)
begin 
	if(!reset) 
		fsm_cs <= FSM_CLK_HIGH;
	else 
		fsm_cs <= fsm_ns;
end

//组合电路,从PS/2键盘读数据到主机的状态机
always @ (*)
begin 
	case (fsm_cs)
		FSM_CLK_LOW:			//读状态时钟低电平
		begin
			if(sync_ps2_clk) 
				fsm_ns = FSM_RISING_EDGE;
			else 
				fsm_ns = FSM_CLK_LOW;
		end
 
		FSM_CLK_HIGH:			//读状态时钟高电平
		begin
			if(!sync_ps2_clk)                      
				fsm_ns = FSM_FALLING_EDGE;  
			else
				fsm_ns = FSM_CLK_HIGH;
		end

		FSM_FALLING_EDGE:		//读状态时钟下降沿标志
		begin
			fsm_ns = FSM_CLK_LOW;
		end

		FSM_RISING_EDGE:		//读状态时钟上升沿标志
		begin
			fsm_ns = FSM_CLK_HIGH;
		end

		default: fsm_ns = FSM_CLK_HIGH; 
	endcase
end

//时序电路,用来给time_cnt_400us赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		time_cnt_400us <= 1'b0;
	else
		time_cnt_400us <= time_cnt_400us_n;
end

//组合电路,400us定时器计数器
always @ (*)
begin
	if(!((fsm_cs == FSM_CLK_HIGH) || (fsm_cs == FSM_CLK_LOW))) 
		time_cnt_400us_n = 1'b0;
	else if(!time_cnt_400us_done) 
		time_cnt_400us_n = time_cnt_400us + 1;
	else 
		time_cnt_400us_n = time_cnt_400us;
end

//时序电路,用来给time_cnt_400us_done赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		time_cnt_400us_done <= 1'b0;
	else
		time_cnt_400us_done <= time_cnt_400us_done_n;
end

//组合电路,400us计时完成标识位
always @ (*)
begin
	if(time_cnt_400us == 15'd19199) 
		time_cnt_400us_done_n = 1'b1;
	else
    	time_cnt_400us_done_n = 1'b0;
end

//时序电路,给bit_count赋值
always @ (posedge clock or negedge reset)
begin
	if(!reset)
		bit_count <= 4'd0;
	else
		bit_count <= bit_count_n;
end

//组合电路,移位计数器
always @ (*)
begin
	if(read_data_done)
		bit_count_n = 4'd0;  
	else if(time_cnt_400us_done && (fsm_cs == FSM_CLK_HIGH) && (sync_ps2_clk)) 
		bit_count_n = 4'd0; 
	else if(fsm_cs == FSM_FALLING_EDGE)
    	bit_count_n = bit_count + 4'd1;
	else
		bit_count_n = bit_count;
end

//时序电路,用来给read_data赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		read_data <= 11'd0;
	else
    	read_data <= read_data_n;
end

//组合电路,串行数据移位寄存器,用于接收ps2的值
always @ (*)
begin
	if(fsm_cs == FSM_FALLING_EDGE) 
		read_data_n = {sync_ps2_data,read_data[10:1]};
	else
		read_data_n = read_data;
end

//接收一帧数据完成标识位
assign read_data_done = (bit_count == 4'd11);

//输出断码标志
assign released = (read_data[8:1] == 16'hF0) && read_data_done;

//时序电路,用来给hold_released赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset)     
		hold_released <= 1'b0;
	else
		hold_released <= hold_released_n;
end

//组合电路,输出键码为断码时置相应标志位
always @(*)
begin
	if(read_data_done && (!released))     
		hold_released_n = 1'b0;
	else if(read_data_done && released)
		hold_released_n = 1'b1;
end

//时序电路,用来给left_shift_key赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		left_shift_key <= 1'b0;
	else
		left_shift_key <= left_shift_key_n;
end

//组合电路,shift按键检测,左shift键
always @ (*)
begin
	if((read_data[8:1] == 16'h12) && read_data_done && ~hold_released)  //shift键通码
		left_shift_key_n = 1'b1;	
	else if ((read_data[8:1] == 16'h12) && read_data_done && hold_released)   //shift键断码
    	left_shift_key_n = 1'b0;
	else
		left_shift_key_n = left_shift_key;
end

//时序电路,用来给right_shift_key赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		right_shift_key <= 1'b0;
	else
		right_shift_key <= right_shift_key_n;
end

//组合电路,shift按键检测,右shift键
always @ (*)
begin
	if((read_data[8:1] == 16'h59) && read_data_done && ~hold_released)  //shift键通码
		right_shift_key_n = 1'b1;
	else if((read_data[8:1] == 16'h59) && read_data_done && hold_released)   //shift键断码
    	right_shift_key_n = 1'b0;
	else
		right_shift_key_n = right_shift_key;
end

//输出shift状态标志,输出1：shift键有按住,输出0：shift键无按住
assign shift_key_on = left_shift_key || right_shift_key;

//收到键盘发送过来的键码，不是0xF0（断码前都有0xF0）不是shift的键值
assign output_strobe = (read_data_done && !(released) 
														&& ( ( (read_data[8:1] != 16'h59)
														&& (read_data[8:1] != 16'h12 ) ) ));
													
//时序电路,用来给interrupt赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		interrupt <= 1'b0;					
	else
		interrupt <= interrupt_n;			
end

//产生中断信号 interrupt = 1 时有数据输出，interrupt_n = 0 时无数据输出
//组合电路,读取数据时(rx_read = 1) interrupt = 0.
always @ (*)
begin
	if(rx_read)							
		interrupt_n = 1'b0;					
	else if(output_strobe)	
		interrupt_n = 1'b1;
	else	
		interrupt_n = interrupt;			
end

//时序电路,用来给continued_press赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		continued_press <= 1'b0;					
	else
		continued_press <= continued_press_n;			
end

//组合电路,输出持续按下按键标志位
always @ (*)
begin
	if(output_strobe)
    	continued_press_n = hold_released;  
	else
		continued_press_n = continued_press;
end

//时序电路,用来给ascii_output赋值的
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		ascii_output <= 1'b0;					
	else
		ascii_output <= ascii_output_n;			
end

//组合电路,输出ASICC数据
always @ (*)
begin
	if(output_strobe)
    	ascii_output_n = {1'b0,ascii};    //载入之前保存的状态值
	else
		ascii_output_n = ascii_output;
end

//这部分将键盘的扫描码转找成ASCII码，这里只列了一部分，如果还要
//增加更多的键码，可以找到相关的扫描键码增加到下面CASE语句中。
assign shift_key_plus_code = {shift_key_on,read_data[8:1]};

//表中9'hXXX最高位为1表示有SHIFT键按下
always @(shift_key_plus_code)
begin
	casez (shift_key_plus_code)
		9'h?66 : ascii <= 7'h08;  // 删除键 "backspace"key
		9'h?0d : ascii <= 7'h09;  // Tab键
		9'h?5a : ascii <= 7'h0d;  // 回车键 "enter"key
		9'h?76 : ascii <= 7'h1b;  // Escape "esc"key
		9'h?29 : ascii <= 7'h20;  // 空格键"Space"key
		9'h116 : ascii <= 7'h21;  // !
		9'h152 : ascii <= 7'h22;  // "
		9'h126 : ascii <= 7'h23;  // #
		9'h125 : ascii <= 7'h24;  // $
		9'h12e : ascii <= 7'h25;  // %
		9'h13d : ascii <= 7'h26;  // &
		9'h052 : ascii <= 7'h27;  // '
		9'h146 : ascii <= 7'h28;  // (
		9'h145 : ascii <= 7'h29;  // )
		9'h13e : ascii <= 7'h2a;  // *
		9'h155 : ascii <= 7'h2b;  // +
		9'h041 : ascii <= 7'h2c;  // ,
		9'h04e : ascii <= 7'h2d;  // -
		9'h049 : ascii <= 7'h2e;  // .
		9'h04a : ascii <= 7'h2f;  // /
		9'h045 : ascii <= 7'h30;  // 0
		9'h016 : ascii <= 7'h31;  // 1
		9'h01e : ascii <= 7'h32;  // 2
		9'h026 : ascii <= 7'h33;  // 3
		9'h025 : ascii <= 7'h34;  // 4
		9'h02e : ascii <= 7'h35;  // 5
		9'h036 : ascii <= 7'h36;  // 6
		9'h03d : ascii <= 7'h37;  // 7
		9'h03e : ascii <= 7'h38;  // 8
		9'h046 : ascii <= 7'h39;  // 9
		9'h14c : ascii <= 7'h3a;  // :
		9'h04c : ascii <= 7'h3b;  // ;
		9'h141 : ascii <= 7'h3c;  // <
		9'h055 : ascii <= 7'h3d;  // =
		9'h149 : ascii <= 7'h3e;  // >
		9'h14a : ascii <= 7'h3f;  // ?
		9'h11e : ascii <= 7'h40;  // @
		9'h11c : ascii <= 7'h41;  // A
		9'h132 : ascii <= 7'h42;  // B
		9'h121 : ascii <= 7'h43;  // C
		9'h123 : ascii <= 7'h44;  // D
		9'h124 : ascii <= 7'h45;  // E
		9'h12b : ascii <= 7'h46;  // F
		9'h134 : ascii <= 7'h47;  // G
		9'h133 : ascii <= 7'h48;  // H
		9'h143 : ascii <= 7'h49;  // I
		9'h13b : ascii <= 7'h4a;  // J
		9'h142 : ascii <= 7'h4b;  // K
		9'h14b : ascii <= 7'h4c;  // L
		9'h13a : ascii <= 7'h4d;  // M
		9'h131 : ascii <= 7'h4e;  // N
		9'h144 : ascii <= 7'h4f;  // O
		9'h14d : ascii <= 7'h50;  // P
		9'h115 : ascii <= 7'h51;  // Q
		9'h12d : ascii <= 7'h52;  // R
		9'h11b : ascii <= 7'h53;  // S
		9'h12c : ascii <= 7'h54;  // T
		9'h13c : ascii <= 7'h55;  // U
		9'h12a : ascii <= 7'h56;  // V
		9'h11d : ascii <= 7'h57;  // W
		9'h122 : ascii <= 7'h58;  // X
		9'h135 : ascii <= 7'h59;  // Y
		9'h11a : ascii <= 7'h5a;  // Z
		9'h054 : ascii <= 7'h5b;  // [
		9'h05d : ascii <= 7'h5c;  // '\'
		9'h05b : ascii <= 7'h5d;  // ]
		9'h136 : ascii <= 7'h5e;  // ^
		9'h14e : ascii <= 7'h5f;  // _    
		9'h00e : ascii <= 7'h60;  // `
		9'h01c : ascii <= 7'h61;  // a
		9'h032 : ascii <= 7'h62;  // b
		9'h021 : ascii <= 7'h63;  // c
		9'h023 : ascii <= 7'h64;  // d
		9'h024 : ascii <= 7'h65;  // e
		9'h02b : ascii <= 7'h66;  // f
		9'h034 : ascii <= 7'h67;  // g
		9'h033 : ascii <= 7'h68;  // h
		9'h043 : ascii <= 7'h69;  // i
		9'h03b : ascii <= 7'h6a;  // j
		9'h042 : ascii <= 7'h6b;  // k
		9'h04b : ascii <= 7'h6c;  // l
		9'h03a : ascii <= 7'h6d;  // m
		9'h031 : ascii <= 7'h6e;  // n
		9'h044 : ascii <= 7'h6f;  // o
		9'h04d : ascii <= 7'h70;  // p
		9'h015 : ascii <= 7'h71;  // q
		9'h02d : ascii <= 7'h72;  // r
		9'h01b : ascii <= 7'h73;  // s
		9'h02c : ascii <= 7'h74;  // t
		9'h03c : ascii <= 7'h75;  // u
		9'h02a : ascii <= 7'h76;  // v
		9'h01d : ascii <= 7'h77;  // w
		9'h022 : ascii <= 7'h78;  // x
		9'h035 : ascii <= 7'h79;  // y
		9'h01a : ascii <= 7'h7a;  // z
		9'h154 : ascii <= 7'h7b;  // {
		9'h15d : ascii <= 7'h7c;  // |
		9'h15b : ascii <= 7'h7d;  // }
		9'h10e : ascii <= 7'h7e;  // ~
		9'h?71 : ascii <= 7'h7f;  //  Delete键或小键盘的DEL键
		default: ascii <= 7'h2e;  // '.' 代表其它没列出的字符
	endcase
end

endmodule
