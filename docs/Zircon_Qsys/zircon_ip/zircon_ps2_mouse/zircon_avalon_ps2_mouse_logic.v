//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_mouse_logic.v
//-- 描述		:	PS/2鼠标IP核的硬件逻辑文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_mouse_logic
(
	//时钟复位
	clock,reset_n,
	//Avalon-MM从端口
	avs_read,ins_interrupt,	
	//外设管脚输出
	ps2_clk_in,ps2_data_in,ps2_clk_out,ps2_data_out,ps2_clk_dir,ps2_data_dir,  
	//用户逻辑输入与输出
	left_button,right_button,middle_button,x_increment,y_increment
	
);
  
input 					clock;									//系统时钟
input 					reset_n;									//系统复位
input 					avs_read;								//Avalon读请求信号
output reg				ins_interrupt;							//Avalon中断信号
reg						ins_interrupt_n;						//ins_interrupt的下一个状态
input 					ps2_clk_in;           				//PS/2时钟线,输入口
input 					ps2_data_in;          				//PS/2数据线,输入口
output reg				ps2_clk_out;  							//PS/2时钟线,输出口
reg						ps2_clk_out_n;  						//ps2_clk_out的下一个状态
output reg				ps2_data_out; 							//PS/2数据线,输出口
reg 						ps2_data_out_n; 						//ps2_data_out的下一个状态
output reg 				ps2_clk_dir;         				//PS/2时钟方向控制，高电平为输出，低电平为输入
reg 						ps2_clk_dir_n;         				//ps2_clk_dir的下一个状态
output reg				ps2_data_dir;        				//PS/2数据方向控制，高电平为输出，低电平为输入
reg						ps2_data_dir_n;        				//ps2_data_dir的下一个状态
output reg				left_button;							//鼠标左键标志位
reg 						left_button_n;							//left_button的下一个状态
output reg				right_button;							//鼠标右键标志位
reg 						right_button_n;						//right_button的下一个状态
output reg				middle_button;							//鼠标中键标志位
reg 						middle_button_n;						//middle_button的下一个状态
output reg	[ 8:0] 	x_increment;							//X轴增量
reg 			[ 8:0] 	x_increment_n;							//x_increment的下一个状态
output reg	[ 8:0] 	y_increment;							//Y轴增量
reg 			[ 8:0] 	y_increment_n;							//y_increment的下一个状态

reg 			[32:0] 	read_data;  							//移位寄存器
reg 			[32:0] 	read_data_n;  							//read_data的下一个状态
reg 			[ 2:0] 	fsm_cs1;									//状态机1的当前状态
reg 			[ 2:0] 	fsm_ns1;									//状态机1的下一个状态
reg 			[ 3:0] 	fsm_cs2;									//状态机2的当前状态
reg 			[ 3:0] 	fsm_ns2;									//状态机2的下一个状态
reg 			[ 5:0] 	bit_count;                			//发送接收数据是的位计数器
reg 			[ 5:0] 	bit_count_n;                		//bit_conut的下一个状态
reg 			[14:0] 	watchdog_time_cnt; 					//看门狗计时器
reg 			[14:0] 	watchdog_time_cnt_n; 				//watchdog_time_cnt的下一个状态
reg 			[ 7:0]   time_cnt_5us;        				//5us计时器
reg 			[ 7:0]   time_cnt_5us_n;         			//time_cnt_5us的下一个状态
reg 						sync_ps2_clk;     					//同步后的PS2时钟
reg 						sync_ps2_data;    					//同步后的PS2数据
reg 						sync_clk;         					//滤波后的PS2时钟
reg 						sync_clk_n;         					//sync_clk的下一个状态
reg 						rising_edge;      					//PS2时钟上升沿标志
reg 						rising_edge_n;      					//rising_edge的下一个状态
reg 						falling_edge;     					//PS2时钟下降沿标志
reg 						falling_edge_n;     					//falling_edge的下一个状态
reg						data_ready;								//数据已经正确收到 
reg 						data_ready_n;							//data_ready的下一个状态

wire 						watchdog_time_cnt_done; 			//看门狗状态指示
wire 						time_cnt_5us_done;      			//用于延时缓冲
wire 						packet_good;         				//数据包正确

//状态机1的参数表
parameter				FSM_CLK_HIGH     		= 3'b000,	//时钟高电平
							FSM_FALLING_EDGE		= 3'b001,	//时钟下降沿标志
							FSM_FALLING_WAIT		= 3'b011,	//时钟下降沿等待
							FSM_CLK_LOW  			= 3'b010,	//时钟低电平
							FSM_RISING_EDGE		= 3'b110,	//时钟上升沿标志
							FSM_RISING_WAIT		= 3'b100;	//时钟上升沿等待

//状态机2的参数表
parameter 				FSM_RESET				= 4'b0000,	//复位后,发送命令到PS2鼠标
							FSM_WAIT 				= 4'b0001,	//等待状态
							FSM_GATHER 		 		= 4'b0011,	//判断数据是否收完
							FSM_VERIFY 				= 4'b0010,	//检验数据包是否正确
							FSM_USE 			 		= 4'b0110,	//数据包正确
							FSM_HOLD_CLK_LOW 		= 4'b0111,	//拉低时钟线400US，准备发送命令
							FSM_DATA_LOW_1 		= 4'b0101,	//发送起始位"0",d[0],d[1]
							FSM_DATA_HIGH_1		= 4'b0100,	//发送位d[2]
							FSM_DATA_LOW_2 		= 4'b1100,	//发送位d[3]
							FSM_DATA_HIGH_2		= 4'b1101,	//发送位d[4],d[5],d[6],d[7]
							FSM_DATA_LOW_3 		= 4'b1001,	//发送奇偶校验位
							FSM_DATA_HIGH_3		= 4'b1011,	//停止位"1",应答处理
							FSM_AWAIT_RESPONSE	= 4'b1010;	//等待回复状态

//同步PS/2的输入时钟
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)							
		sync_ps2_clk <= 1'b0;					
	else
		sync_ps2_clk <= ps2_clk_in;			
end

//同步PS/2的数据信号
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)							
		sync_ps2_data <= 1'b0;					
	else
		sync_ps2_data <= ps2_data_in;			
end

//时序电路,用来给fsm_cs1赋值的
always @ (posedge clock or negedge reset_n)
begin 
	if(!reset_n == 1'b1) 
		fsm_cs1 <= FSM_CLK_HIGH;
	else 
		fsm_cs1 <= fsm_ns1;
end

//组合电路,同步PS2时钟，在PS2的时钟边沿产生边沿标志
always @ (*)
begin 
	case(fsm_cs1)
	
		FSM_CLK_HIGH:				//时钟高电平
		begin

			if(~sync_ps2_clk)
				fsm_ns1 <= FSM_FALLING_EDGE;
			else 
				fsm_ns1 <= FSM_CLK_HIGH;
		end

		FSM_FALLING_EDGE:			//时钟下降沿
		begin
			fsm_ns1 <= FSM_FALLING_WAIT;
		end

		FSM_FALLING_WAIT:			//等待5US延时防止毛刺干扰
		begin
			if(time_cnt_5us_done) 
				fsm_ns1 <= FSM_CLK_LOW;
			else 
				fsm_ns1 <= FSM_FALLING_WAIT;
		end

		FSM_CLK_LOW:       		//时钟低电平
		begin
			if(sync_ps2_clk)
				fsm_ns1 <= FSM_RISING_EDGE;
			else 
				fsm_ns1 <= FSM_CLK_LOW;
			end

		FSM_RISING_EDGE:    		//时钟上升沿
		begin
			fsm_ns1 <= FSM_RISING_WAIT;
		end

		FSM_RISING_WAIT:  		//等待5US延时防止毛刺干扰
		begin
			if(time_cnt_5us_done) 
				fsm_ns1 <= FSM_CLK_HIGH;
			else 
				fsm_ns1 <= FSM_RISING_WAIT;
			end

		default : fsm_ns1 <= FSM_CLK_HIGH;
	endcase
end

//时序电路,用来给falling_edge赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		falling_edge <= 1'b0;
	else
		falling_edge <= falling_edge_n;
end

//组合电路,产生下降沿
always @ (*)
begin
	if(fsm_cs1 == FSM_FALLING_EDGE)
		falling_edge_n = 1'b1;
	else
		falling_edge_n = 1'b0;
end

//时序电路,用来给rising_edge赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		rising_edge <= 1'b0;
	else
		rising_edge <= rising_edge_n;
end

//组合电路,产生上升沿
always @ (*)
begin
	if(fsm_cs1 == FSM_RISING_EDGE)
		rising_edge_n = 1'b1;
	else
		rising_edge_n = 1'b0;
end

//时序电路,用来给sync_clk赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		sync_clk <= 1'b0;
	else
		sync_clk <= sync_clk_n;
end

//组合电路,经过状态机同步后的时钟
always @ (*)
begin
	if((fsm_cs1 == FSM_CLK_HIGH) || (fsm_cs1 == FSM_RISING_WAIT))
		sync_clk_n = 1'b1;
	else
		sync_clk_n = 1'b0;
end

//时序电路,用来给fsm_cs2赋值的
always @ (posedge clock or negedge reset_n)
begin 
	if(!reset_n == 1'b1) 
		fsm_cs2 <= FSM_RESET;
	else 
		fsm_cs2 <= fsm_ns2;
end

//组合电路,初始化PS2鼠标，接收PS2鼠标数据包
always @ (*)
begin 
	case(fsm_cs2)
  
		FSM_RESET: 					//复位后,发送命令到PS2鼠标
		begin
			fsm_ns2 = FSM_HOLD_CLK_LOW;
		end

		FSM_WAIT:     
		begin
			if(falling_edge) 
				fsm_ns2 = FSM_GATHER;
			else
				fsm_ns2 = FSM_WAIT;
		end

		FSM_GATHER:        		//判断数据是否收完
		begin
			if(watchdog_time_cnt_done && (bit_count == 6'd33))
				fsm_ns2 = FSM_VERIFY;
			else if(watchdog_time_cnt_done && (bit_count < 6'd33))
				fsm_ns2 = FSM_HOLD_CLK_LOW;
			else
				fsm_ns2 = FSM_GATHER;
		end

		FSM_VERIFY:         		//检验数据包是否正确
		begin
			if(packet_good) 
				fsm_ns2 = FSM_USE;
			else 
				fsm_ns2 = FSM_WAIT;
		end

		FSM_USE:            		//数据包正确
		begin
			fsm_ns2 = FSM_WAIT;
		end

//复位或出错时进入以下状态,主机向PS2发送复位指令0xFF,PS2鼠标收到
//复位指令时应答0xFA,大约360mS后，鼠标完成自检,自检成功发送0xAA,
//不成功发送0xFC;然后发送ID号0x00.之后进入Stream 模式Stream 模式.
//此时PS2鼠标默认属性为:采样速率100 采样点/秒;分辨率4 个计数值/毫米;
//缩放比例1:1;数据报告被禁止,为简化程序,不修改默认属性。
//最后发送0xF4命令使能数据报告,等PS2鼠标应答0xFA.致此,初使化PS2鼠标完毕.
//为简化程序，发送复位指令部分省略(复位由鼠标上电复位完成)，只发送使能数据报告指令。
	   
		FSM_HOLD_CLK_LOW:  		//拉低时钟线400US，准备发送命令
		begin
			if(watchdog_time_cnt_done && ~sync_clk)
				fsm_ns2 = FSM_DATA_LOW_1;
			else 
				fsm_ns2 = FSM_HOLD_CLK_LOW;
		end

		FSM_DATA_LOW_1:     		//发送起始位"0",d[0],d[1]
		begin
			if(falling_edge && (bit_count == 6'd2))
				fsm_ns2 = FSM_DATA_HIGH_1;
			else 
				fsm_ns2 = FSM_DATA_LOW_1;
		end

		FSM_DATA_HIGH_1: 			//发送位d[2]
		begin
			if(falling_edge)
				fsm_ns2 = FSM_DATA_LOW_2;
			else
				fsm_ns2 = FSM_DATA_HIGH_1;
		end

		FSM_DATA_LOW_2:			//发送位d[3]
		begin							
			if(falling_edge)
				fsm_ns2 = FSM_DATA_HIGH_2;
			else 
				fsm_ns2 = FSM_DATA_LOW_2;
		end

		FSM_DATA_HIGH_2:    		//发送位d[4],d[5],d[6],d[7]
		begin
			if(falling_edge && (bit_count == 6'd8))
				fsm_ns2 = FSM_DATA_LOW_3;
			else 
				fsm_ns2 = FSM_DATA_HIGH_2;
		end

		FSM_DATA_LOW_3: 			//发送奇偶校验位
		begin
			if(falling_edge)
				fsm_ns2 = FSM_DATA_HIGH_3;
			else
				fsm_ns2 = FSM_DATA_LOW_3;
		end

		FSM_DATA_HIGH_3:			//停止位"1",应答处理
		begin
			if(falling_edge && sync_ps2_data)
				fsm_ns2 = FSM_HOLD_CLK_LOW; 	//有错误产生,重新复位
			else if(falling_edge && ~sync_ps2_data)
				fsm_ns2 = FSM_AWAIT_RESPONSE;
			else 
				fsm_ns2 = FSM_DATA_HIGH_3;
		end
		
//等待SP2鼠标回应：这里不对回应做处理,如果指令没有被鼠标正确收到，
//鼠标会回应(0xFC)要求重新发送指令，也可能回应(0xFE)表示收到的数
//据出错。如果正确收到会回应(0xFA)。
//注：如果鼠标的回应时间超过400us，bit_count将被复位，这时应收到
//的位数应该是11。但一般鼠标的回应时间较短，所以bit_count没被复，
//这时的位数值应该是22。

		FSM_AWAIT_RESPONSE :		//等待回复并完成操作
		begin
			if(bit_count == 6'd22)
				fsm_ns2 = FSM_VERIFY;
			else 
				fsm_ns2 = FSM_AWAIT_RESPONSE;
		end

		default: fsm_ns2 = FSM_WAIT;
  endcase
end

//时序电路,用来给data_ready赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		data_ready <= 1'b0;
	else
		data_ready <= data_ready_n;
end

//组合电路,判断数据是否已经正确收到  
always @ (*)
begin
	if(fsm_cs2 == FSM_USE)
		data_ready_n = 1'b1;
	else
		data_ready_n = 1'b0;
end

//时序电路,用来给ps2_data_dir赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_data_dir <= 1'b0;
	else
		ps2_data_dir <= ps2_data_dir_n;
end

//组合电路,PS/2数据方向控制，高电平为输出，低电平为输入
always @ (*)
begin
	if(fsm_cs2 == FSM_DATA_LOW_1 	|| fsm_cs2 == FSM_DATA_HIGH_1 || 
		fsm_cs2 == FSM_DATA_LOW_2 	||	fsm_cs2 == FSM_DATA_HIGH_2 || 
		fsm_cs2 == FSM_DATA_LOW_3	)
		ps2_data_dir_n = 1'b1;
	else
		ps2_data_dir_n = 1'b0;
end

//时序电路,用来给ps2_clk_dir赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_clk_dir <= 1'b0;
	else
		ps2_clk_dir <= ps2_clk_dir_n;
end

//组合电路,PS/2时钟方向控制，高电平为输出，低电平为输入
always @ (*)
begin
	if(fsm_cs2 == FSM_HOLD_CLK_LOW)
		ps2_clk_dir_n = 1'b1;
	else
		ps2_clk_dir_n = 1'b0;
end

//时序电路,用来给ps2_clk_out赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_clk_out <= 1'b1;
	else
		ps2_clk_out <= ps2_clk_out_n;
end

//组合电路,生成PS/2时钟信号,并输出
always @ (*)
begin
	if(fsm_cs2 == FSM_HOLD_CLK_LOW)
		ps2_clk_out_n = 1'b0;
	else
		ps2_clk_out_n = 1'b1;
end

//时序电路,用来给ps2_data_out赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_data_out <= 1'b1;
	else
		ps2_data_out <= ps2_data_out_n;
end

//组合电路,生成PS/2数据信号,并输出
always @ (*)
begin
	if(fsm_cs2 == FSM_DATA_LOW_1 || fsm_cs2 == FSM_DATA_LOW_2 || fsm_cs2 == FSM_DATA_LOW_3)
		ps2_data_out_n = 1'b0;
	else
		ps2_data_out_n = 1'b1;
end

//时序电路,用来给bit_count赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		bit_count <= 1'b0;
	else
		bit_count <= bit_count_n;
end

//组合电路,移位计数器,用在PS2时钟的下降沿加计数
always @ (*)
begin
	if(falling_edge) 
		bit_count_n = bit_count + 6'd1;
	else if(watchdog_time_cnt_done) 	
		bit_count_n = 6'd0;             
	else
		bit_count_n = bit_count;
end

//时序电路,用来给read_data赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		read_data <= 1'b0;
	else
		read_data <= read_data_n;
end


//组合电路,移位寄存器,接收PS2发送到来的数据,在时钟的下降沿锁存数据,
always @ (*)
begin
	if(falling_edge)
		read_data_n = {sync_ps2_data,read_data[32:1]};
	else
		read_data_n = read_data;
end

//时序电路,用来给watchdog_time_cnt赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		watchdog_time_cnt <= 1'b0;
	else
		watchdog_time_cnt <=  watchdog_time_cnt_n;
end

//组合电路,看门狗计时器,发送数据时抑制时钟线标志，接收数据包后状态指示。
always @ (*)
begin
	if(rising_edge || falling_edge) 
		watchdog_time_cnt_n = 1'b0;
	else if(!watchdog_time_cnt_done)
		watchdog_time_cnt_n = watchdog_time_cnt + 1;
	else
		watchdog_time_cnt_n = watchdog_time_cnt;
end

//组合电路,PS/2无时钟脉冲超过400us，watchdog_time_cnt_done置位
assign watchdog_time_cnt_done = (watchdog_time_cnt == 15'd19199);

//时序电路,用来给time_cnt_5us赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		time_cnt_5us <= 1'b0;
	else
		time_cnt_5us <=  time_cnt_5us_n;
end

//组合电路,缓冲时间5US计数器
always @ (*)
begin
	if(falling_edge || rising_edge ) 
		time_cnt_5us_n = 0;
	else 
		time_cnt_5us_n = time_cnt_5us + 1;
end

//组合电路,超过5us,time_cnt_5us_done置位
assign time_cnt_5us_done = (time_cnt_5us == 8'd239);

//验证收到的数据包数据是否有效、正确
assign packet_good = ((read_data[0]  == 1'b0) && (read_data[10] == 1'b1) && (read_data[11] == 1'b0) &&                                                  	
                      (read_data[21] == 1'b1) && (read_data[22] == 1'b0)	&& (read_data[32] == 1'b1) && 
                      (read_data[9] == ~^read_data[8:1]) && (read_data[20] == ~^read_data[19:12]) && 
							 (read_data[31] == ~^read_data[30:23]) );
							 
//时序电路,用来给left_button赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		left_button <= 1'b0;
	else
		left_button <= left_button_n;
end							 

//组合电路,读取鼠标左键标志位数据						 
always @ (*)
begin
	if(data_ready) 
		left_button_n = read_data[1];  
	else
		left_button_n = left_button;
end							 
		
//时序电路,用来给right_button赋值的		
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		right_button <= 1'b0;
	else
		right_button <= right_button_n;
end							 

//组合电路,读取鼠标右键标志位数据						 
always @ (*)
begin
	if(data_ready) 
		right_button_n = read_data[2];  
	else
		right_button_n = right_button;
end	

//时序电路,用来给middle_button赋值的	
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		middle_button <= 1'b0;
	else
		middle_button <= middle_button_n;
end							 

//组合电路,读取鼠标中键标志位数据							 
always @ (*)
begin
	if(data_ready) 
		middle_button_n = read_data[3];  
	else
		middle_button_n = middle_button;
end	
		
//时序电路,用来给x_increment赋值的		
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		x_increment <= 1'b0;
	else
		x_increment <= x_increment_n;
end	
						 
//组合电路,读取X轴增量数据				 
always @ (*)
begin
	if(data_ready) 
		x_increment_n = {read_data[5],read_data[19:12]}; 
	else
		x_increment_n = x_increment;
end		

//时序电路,用来给y_increment赋值的	
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		y_increment <= 1'b0;
	else
		y_increment <= y_increment_n;
end	
						 
//组合电路,读取Y轴增量数据			 
always @ (*)
begin
	if(data_ready) 
		y_increment_n = {read_data[6],read_data[30:23]};
	else
		y_increment_n = y_increment;
end	
		
 //时序电路,用来给ins_interrupt赋值的
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)								
		ins_interrupt <= 1'b0;						
	else
		ins_interrupt <= ins_interrupt_n;			
end

 //组合电路,生成中断信号
always @ (*)
begin
	if(avs_read)									
		ins_interrupt_n = 1'b0;					
	else if(data_ready)							
		ins_interrupt_n = 1'b1;						
	else
		ins_interrupt_n = ins_interrupt;			
end
	
endmodule


