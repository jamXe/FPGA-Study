//---------------------------------------------------------------------------
//--	文件名		:	Ir_Module.v
//--	作者		:	ZIRCON
//--	描述		:	红外模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------

/*Timing control.
`define HEAD_HIGH 	 24'h6_DDD0 // 9.000ms @ 50MHz, standard is 24'h6_DDD0.
`define HEAD_LOW		 24'h3_6EE8 // 4.500ms @ 50MHz, standard is 24'h3_6EE8
`define BIT_1_HIGH	 24'h6D60   // 0.560ms @ 50MHz, standard is 24'h6D60
`define BIT_1_LOW		 24'h6E5A   // 0.565ms @ 50MHz, standard is 24'h6E5A
`define BIT_0_HIGH	 24'h6D60   // 0.560ms @ 50MHz, standard is 24'h6D60
`define BIT_0_LOW		 24'h1_4A14 // 1.690ms @ 50MHz, standard is 24'h1_4A14
`define REP_HEAD_HIGH 24'h6_DDD0 // 9.000ms @ 50MHz, standard is 24'h6_DDD0.
`define REP_HEAD_LOW	 24'h1_B774 // 2.250ms @ 50MHz, standard is 24'h1_B774
`define REP_BIT_HIGH	 24'h6D60   // 0.560ms @ 50MHz, standard is 24'h6D60
`define REP_BIT_LOW	 24'hF4240  // 20.00ms @ 50MHz, standard is 24'hF4240*/

//Timing control.
`define HEAD_HIGH 	 10'h1B		//[23:14] 24'h6_DDD0 = (0110_11)01_1101_1101_0000
`define HEAD_LOW		 10'hD		//12'h37  24'h3_6EE8 = (0011_01)10_1110_1110_1000
`define BIT_1_HIGH	 10'h1		//12'h7   24'h6D60   = (0000_01)10_1101_0110_0000
`define BIT_1_LOW		 10'h1		//12'h7	 24'h6E5A   = (0000_01)10_1110_0101_1010
`define BIT_1_LOW2	 10'h2		//12'h7   
`define BIT_0_HIGH	 10'h1		//12'h7   24'h6D60   = (0000_01)10_1101_0110_0000
`define BIT_0_LOW		 10'h5		//12'h14  24'h1_4A14 = (0001_01)00_1010_0001_0100
`define BIT_0_LOW2	 10'h4		//12'h14                                         
`define REP_HEAD_HIGH 10'h1B		//12'h6F  24'h6_DDD0 = (0110_11)01_1101_1101_0000
`define REP_HEAD_LOW	 10'h7		//12'h1C  24'h1_B774 = (0001_10)11_0111_0111_0100
`define REP_BIT_HIGH	 10'h1		//12'h7   24'h6D60   = (0000_01)10_1101_0110_0000
`define REP_BIT_LOW	 10'h37		//12'hF4  24'hF4240  = (1111_01)00_0010_0100_0000

module Ir_Module
(
	//输入端口
	CLK_50M,RST_N,IR_DATA,
	//输出端口
	o_ir_data,ir_finish
);
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input						CLK_50M;				//系统时钟
input						RST_N;				//系统复位
input						IR_DATA;				//红外输入管脚
output  	[ 7:0]		o_ir_data;			//从红外读出的数据
output					ir_finish;			//红外数据接收完成标志位
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[ 3:0]		ir_fsm_cs;			//状态机的当前状态
reg		[ 3:0]		ir_fsm_ns;			//状态机的下一个状态
reg		[23:0]		time_cnt;			//计时器
reg		[23:0]		time_cnt_n;			//time_cnt的下一个状态
reg		[23:0]		low_time;			//低电平计时器（实际是高电平）
reg		[23:0]		low_time_n;			//low_time的下一个状态
reg		[23:0]		high_time;			//高电平计时器（实际是低电平）
reg		[23:0]		high_time_n;   	//high_time的下一个状态
reg		[ 7:0]		bit_cnt;				//用来记录8位串行红外数据组成一个字节
reg		[ 7:0]		bit_cnt_n;			//bit_cnt的下一个状态
reg		[ 1:0]		detect_edge;		//检测边沿寄存器
wire		[ 1:0]		detect_edge_n;		//detect_edge的下一个状态
reg		[31:0]		ir_data;				//从红外读出的数据
reg		[31:0]		ir_data_n;			//ir_data的下一个状态
reg		[31:0]		ir_data_reg;		//红外数据的缓存寄存器
reg		[31:0]		ir_data_reg_n;		//ir_data_reg的下一个状态
reg						posedge_reg;		//检测上升沿
wire						posedge_reg_n;		//posedge_reg的下一个状态
wire						head_code;			//红外引导码
wire						bit_0_code;			//逻辑0（实际逻辑1）
wire						bit_1_code;			//逻辑1（实际逻辑0）
wire						rep_head_code;		//重复引导码
wire						rep_bit_code; 		//重复码
reg						ir_finish;			//红外数据接收完成标志位
reg						ir_finish_n;		//ir_finish的下一个状态

parameter				FSM_IDLE     		= 4'h0;	//空闲状态
parameter				FSM_DATA 			= 4'h1;	//串行数据接收状态
parameter				FSM_DATA_END	 	= 4'h2;	//数据接收完成状态
parameter				FSM_REP_BIT 	 	= 4'h3;	//处理重复码状态
parameter				FSM_REP_BIT_END	= 4'h4;	//重复码处理完成状态

//时序电路,用来给detect_edge寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
  if(!RST_N)									//判断复位
    detect_edge <= 2'h0;					//初始化detect_edge值
  else
    detect_edge <= detect_edge_n;		//用来给detect_edge赋值
end

//组合电路,检测上升沿
assign detect_edge_n = {detect_edge[0] , {~IR_DATA}};//将红外信号取反并接收

//时序电路,用来给posedge_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		posedge_reg <= 1'h0;					//初始化posedge_reg值
	else
		posedge_reg	<= posedge_reg_n;		//用来给posedge_reg赋值
end

//组合电路,判断上升沿,如果detect_edge等于01,posedge_reg_n就置1
assign posedge_reg_n = (detect_edge == 2'b01) ? 1'b1 : 1'b0; 

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		time_cnt	<= 24'h0;					//初始化time_cnt值
	else
		time_cnt	<= time_cnt_n;				//用来给time_cnt赋值
end

//组合电路,计数器用于记录高电平或者低电平的脉冲宽度
always @ (*)
begin
	if(detect_edge[0] != detect_edge[1])//判断电平变化
		time_cnt_n = 24'h0;					//如果红外信号发生变化,time_cnt_n就从0开始计数
	else
		time_cnt_n = time_cnt + 24'h1;	//否则,time_cnt就加1
end

//时序电路,用来给high_time寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin	
  if(!RST_N)									
    high_time <= 24'h0;						//初始化high_time值
  else
    high_time <= high_time_n;				//用来给high_time赋值
end

//组合电路,实际记录的是IR_DATA上的低电平宽度，因为上面对IR_DATA做了一次取反操作
always @ (*)
begin
  if(detect_edge == 2'b10)					//判断下降沿			
    high_time_n = time_cnt;				//如果判断为下降沿，则开始计数
  else
    high_time_n = high_time;				//否则保持不变
end

//时序电路,用来给low_time寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
  if(!RST_N)									//判断复位
    low_time <= 24'h0;						//初始化low_time值
  else
    low_time <= low_time_n;				//用来给low_time赋值
end

//组合电路,实际记录的是IR_DATA上的高电平宽度，因为上面对IR_DATA做了一次取反操作
always @ (*)
begin
  if(IR_DATA)									//判断高电平
    low_time_n	 = time_cnt;				//如果判断为高电平，则开始计数
  else
    low_time_n	 = low_time;				//当IR_DATA变成0时就保持不变
end

//high_time 为红外引导码9ms低电平，(high_time[23:14] == `HEAD_HIGH) 即是 [23:14] 24'h6_DDD0 = (0110_11)01_1101_1101_0000 的14位到23位是(01_1011)10'h1B
//1B+14个0=6C000 X 20ns = 8.8ms ,低电平这里同样是设置的4.25ms
assign head_code     = (high_time[23:14] == `HEAD_HIGH)     && (low_time[23:14] == `HEAD_LOW) && posedge_reg;
//同理，低电平至少0.3ms,高电平1.6ms或者1.4ms,被认为是逻辑"1"
assign bit_0_code    = (high_time[23:14] == `BIT_0_HIGH)     && ((low_time[23:14] == `BIT_0_LOW)||(low_time[23:14] == `BIT_0_LOW2)) && posedge_reg;
//同理，低电平至少0.3ms,高电平0.3ms或者1.4ms,被认为是逻辑"0"
assign bit_1_code    = (high_time[23:14] == `BIT_1_HIGH)     && ((low_time[23:14] == `BIT_1_LOW)||(low_time[23:14] == `BIT_1_LOW2))&& posedge_reg;
//重复引导码
assign rep_head_code = (high_time[23:14] == `REP_HEAD_HIGH) && (low_time[23:14] == `REP_HEAD_LOW) && posedge_reg;
//重复码
assign rep_bit_code  = (high_time[23:14] == `REP_BIT_HIGH)  && (low_time[23:14] == `REP_BIT_LOW) && posedge_reg; 


//时序电路,用来给bit_cnt赋值的
always @ (posedge CLK_50M or negedge RST_N)
begin
  if(!RST_N)									//判断复位
    bit_cnt	<=  8'h0;						//初始化bit_cnt
  else
    bit_cnt	<=  bit_cnt_n;					//用来给bit_cnt赋值
end

//组合电路,用来记录8位串行红外数据组成一个字节
always @ (*)
begin
  if(ir_fsm_cs != FSM_DATA)				//判断状态机当前状态是否在接收数据状态
    bit_cnt_n	 = 8'h0;						//如果不等于,bit_cnt_n则清零
  else if((ir_fsm_cs == FSM_DATA) && (detect_edge == 2'b01))//判断状态机当前状态是否在接收数据状态以及是否在上升沿
    bit_cnt_n	 = bit_cnt + 8'h1;		//如果条件成立,则记录8位串行红外数据
  else
    bit_cnt_n	 = bit_cnt;					//否则保持不变
end

//时序电路,用来给ir_fsm_cs赋值的
always @ (posedge CLK_50M or negedge RST_N)
begin
  if(!RST_N)									//判断复位
    ir_fsm_cs	<=  FSM_IDLE;				//初始化ir_fsm_cs的值
  else
    ir_fsm_cs	<=  ir_fsm_ns;				//用来给ir_fsm_cs赋值
end

//组合电路,状态机的控制核心
always @ (*)
begin
	case(ir_fsm_cs)							//判断当前的状态
	
	FSM_IDLE: 
		if(head_code)							//收到引导码后
			ir_fsm_ns = FSM_DATA;			//进入串行接收状态
    	else if(rep_head_code)				//收到重复码后
			ir_fsm_ns = FSM_REP_BIT;		//进入处理重复码状态
		else 
			ir_fsm_ns = ir_fsm_cs;   		//否则保持不变
			
	FSM_DATA: 
		if(bit_cnt == 8'h20)					//接收4个字节(地址码，地址反码，命令码，命令反码)
			ir_fsm_ns = FSM_DATA_END;		//接收完毕后，进入数据完成状态
		else if(rep_head_code || head_code || rep_bit_code)	//判断重复码
			ir_fsm_ns = FSM_IDLE;			//进入空闲状态
		else 
			ir_fsm_ns = ir_fsm_cs;			//否则保持不变
			
	FSM_DATA_END:
			ir_fsm_ns = FSM_IDLE;			//进入空闲状态
			
	FSM_REP_BIT: 	
		if(rep_bit_code)						//判断重复码
			ir_fsm_ns = FSM_REP_BIT_END;	//进入重复码处理完成状态
		else if(rep_head_code || head_code || bit_0_code || bit_1_code)	//判断重复码
			ir_fsm_ns = FSM_IDLE;			//进入空闲状态
		else 
			ir_fsm_ns = ir_fsm_cs;  		//否则保持不变
			
	FSM_REP_BIT_END: 
			ir_fsm_ns = FSM_IDLE;			//进入空闲状态
			
	default:ir_fsm_ns = FSM_IDLE; 		//进入空闲状态
	endcase
end

//时序电路,用来给ir_data_reg赋值的
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		ir_data_reg	<=  32'h0;				//初始化ir_data_reg
	else
		ir_data_reg	<=  ir_data_reg_n;	//用来给ir_data_reg赋值的
end

//组合电路,记录接收到的串行码32BIT,每接收一位，判断是0还是1后移位保存。实质是高电平时间大于0.65ms就是0,否则是1
always @ (*)
begin
	if(ir_fsm_cs == FSM_IDLE)				//判断状态机的状态
		ir_data_reg_n = 32'hFFFF;
	else if((ir_fsm_cs == FSM_DATA) && ((low_time[23:14] > 10'h2 )&& (detect_edge == 2'b01)))
		ir_data_reg_n	 = {ir_data_reg[30:0] , 1'h1};	
	else if(((ir_fsm_cs == FSM_DATA)||(ir_fsm_cs == FSM_IDLE)) && (detect_edge == 2'b01))
		ir_data_reg_n = {ir_data_reg[30:0] , 1'h0};		
	else
		ir_data_reg_n = ir_data_reg;		//否则保持不变
end

//时序电路,用来给ir_data赋值的
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		ir_data <= 32'h0;					//初始化ir_data
	else
		ir_data <= ir_data_n;				//用来给ir_data赋值
end

//组合电路,解码完成的状态就可以读取值了
always @ (*)
begin
	if(ir_fsm_ns == FSM_DATA_END)			//判断状态机的状态
		ir_data_n = ir_data_reg;			//解码完成的状态就可以读取值了
	else
		ir_data_n = ir_data;					//否则保持不变
end

//时序电路,用来给ir_finish寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		ir_finish <= 1'h0;					//初始化ir_finish值
	else
		ir_finish <= ir_finish_n;			//用来给ir_finish赋值
end

//组合电路,如果数据接收完成,那么将ir_finish标志位置1
always @ (*)
begin
	if(ir_fsm_ns == FSM_DATA_END)			//判断数据有没有接收完成
		ir_finish_n = 1'b1;					//如果接收完成,那么将ir_finish标志位置1
	else
		ir_finish_n = 1'b0;					//否则,将ir_finish标志位置0
end

assign o_ir_data =  {ir_data[8],ir_data[9],ir_data[10],ir_data[11],ir_data[12],ir_data[13],ir_data[14],ir_data[15]};

endmodule

 