//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_tlc5615_logic.v
//-- 描述		:	TLC5615 DA IP核的硬件逻辑文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_tlc5615_logic
(
	//输入端口
	CLK_50M,RST_N,
	//TLC5615输出管脚
	DA_CLK,DA_DIN,DA_CS,
	//用户逻辑输入与输出
	DA_DATA,send_start,send_finish
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------

input						CLK_50M;				//系统时钟
input						RST_N;				//系统复位
output reg				DA_CLK;				//DA时钟端口
output					DA_DIN;				//DA数据输出端口
output reg				DA_CS;				//DA片选端口
input			[ 9:0]	DA_DATA;				//DA数据的输入
input						send_start;			//DA工作开始标识
output					send_finish;		//DA工作完成标识

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg			[ 3:0]	FSM_CS;				//状态机的当前状态
reg			[ 3:0]	FSM_NS;				//状态机的下一个状态
reg			[ 3:0]	bit_cnt;				//用来记录数据发送个数的计数器
reg			[ 3:0]	bit_cnt_n;			//bit_cnt的下一个状态
reg			[11:0]	shift_reg;			//移位寄存器,将最高位数据移给DA_DIN
reg			[11:0]	shift_reg_n;		//shift_reg的下一个状态
reg			[ 3:0]	time_cnt;			//用于记录时钟个数的计数器
reg			[ 3:0]	time_cnt_n;			//time_cnt的下一个状态
reg						DA_CLK_N;			//DA_CLK的下一个状态
reg						DA_CS_N;				//DA_CS的下一个状态

parameter		FSM_IDLE  = 4'h0;			//状态机的空闲状态
parameter		FSM_READY = 4'h1;			//状态机的准备状态,将CS拉低
parameter		FSM_SEND  = 4'h2;			//状态机的发送状态,发送12个数据
parameter		FSM_FINISH= 4'h4;			//状态的完成状态,将CS拉高

//---------------------------------------------------------------------------
//--	逻辑功能
//---------------------------------------------------------------------------
//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)							//判断复位
		time_cnt <= 4'h0;				//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;		//用来给time_cnt赋值
end

//组合电路,用于记录时钟个数的计数器
always @ (*)
begin
	if(FSM_CS != FSM_NS)				//判断状态机的当前状态
		time_cnt_n = 4'h0;			//如果当前的状态不等于下一个状态,计数器就清零
	else if(DA_CLK != DA_CLK_N)	//判断时钟的当前状态
		time_cnt_n = 4'h0;			//如果当前的时钟不等于下一个时钟状态,计数器清零
	else
		time_cnt_n = time_cnt + 4'h1;//否则计数器就加1
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)							//判断复位
		bit_cnt	<= 4'h0;				//初始化bit_cnt值
	else
		bit_cnt	<= bit_cnt_n;		//用来给bit_cnt赋值
end

//组合电路,用来记录数据发送个数的计数器
always @ (*)
begin
	if(FSM_CS == FSM_FINISH)		//判断状态机的当前状态
		bit_cnt_n = 4'h0;				//如果当前的状态不等于完成状态,bit_cnt_n就置0
	else if(DA_CLK && (!DA_CLK_N))//判断时钟的当前状态
		bit_cnt_n = bit_cnt + 4'h1;//如果当前的时钟等于下一个时钟取非的状态,bit_cnt_n就加1
	else
		bit_cnt_n = bit_cnt;			//否则保持不变
end

//时序电路,用来给shift_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)							//判断复位
		shift_reg <= 12'h0;			//初始化shift_reg值
	else
		shift_reg <= shift_reg_n;	//用来给shift_reg赋值
end

//组合电路,移位寄存器,将DA_DATA的数据依次移给DA_DIN
always @ (*)
begin
	if(send_start)						//判断开始标识
		shift_reg_n = {DA_DATA,2'h0};//如果标志为1,则将DA_DATA的数据赋值给移位寄存器
	else if(DA_CLK && (time_cnt == 4'h0))//判断DA_CLK的状态
		shift_reg_n = {shift_reg[10:0] , 1'h0};//如果DA_CLK为高,移位寄存器开始移位
	else
		shift_reg_n = shift_reg;	//否则保持不变
end

//---------------------------------------------------------------------------
//--	状态机
//---------------------------------------------------------------------------

//时序电路,用来给FSM_CS寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin	
	if(!RST_N)							//判断复位
		FSM_CS <= FSM_IDLE;			//初始化FSM_CS值
	else
		FSM_CS <= FSM_NS;				//用来给FSM_CS赋值
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(FSM_CS)						//判断状态机的当前状态
		FSM_IDLE: 							
			if(send_start)				//判断开始标识
				FSM_NS = FSM_READY;	//如果标识符为1,则进入准备状态
			else
				FSM_NS = FSM_CS;		//否则保持原状态不变

		FSM_READY: 
			if(time_cnt == 4'h1)		//等待两个时钟
				FSM_NS = FSM_SEND;		//两个时钟到了便进入发送状态
			else
				FSM_NS = FSM_CS;		//否则保持原状态不变

		FSM_SEND: 
			if((bit_cnt == 4'hC)&&(!DA_CLK))//发送数据12个
				FSM_NS = FSM_FINISH;	//发送完成进入完成状态
			else
				FSM_NS = FSM_CS;		//否则保持原状态不变

		FSM_FINISH: 
			if(time_cnt == 4'h2)		//等待三个时钟
				FSM_NS = FSM_IDLE;		//完成一次数据转换,进入下一次转换
			else
				FSM_NS = FSM_CS;		//否则保持原状态不变
		
		default:FSM_NS = FSM_IDLE;
	endcase
end

//时序电路,用来给DA_CS寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)							//判断复位
		DA_CS <= 1'h1;					//初始化DA_CS值
	else
		DA_CS <= DA_CS_N;				//用来给DA_CS赋值
end

//组合电路,用来生成DA的片选波形
always @ (*)
begin
	if(FSM_CS == FSM_READY)			//判断状态机的当前状态
		DA_CS_N = 1'h0;				//如果当前的状态等于准备状态,DA_CS_N就置0
	else if((FSM_CS == FSM_FINISH) && (time_cnt == 4'h1))//判断状态机的当前状态
		DA_CS_N = 1'h1;				//如果当前的状态等于完成状态并且时钟计数器等于1,DA_CS_N就置1
	else
		DA_CS_N = DA_CS;				//否则保持不变
end

//时序电路,用来给DA_CLK寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)							//判断复位
		DA_CLK <= 1'h0;				//初始化DA_CLK值
	else
		DA_CLK <= DA_CLK_N;			//用来给DA_CLK赋值
end

//组合电路,用来生成DA的时钟波形
always @ (*)
begin
	if((FSM_CS == FSM_SEND) && (!DA_CLK) && (time_cnt == 4'h1))//判断状态机的当前状态
		DA_CLK_N = 1'h1;				//如果符合上述条件,每两个时钟就会生成一个高电平的DA_CLK
	else if((FSM_CS == FSM_SEND) && (DA_CLK) && (time_cnt == 4'h1))//判断状态机的当前状态
		DA_CLK_N = 1'h0;				//如果符合上述条件,每两个时钟就会生成一个低电平的DA_CLK
	else
		DA_CLK_N = DA_CLK;			//否则保持不变
end

assign DA_DIN = shift_reg[11];	//将移位寄存器的最高位赋值给DA_DIN
assign send_finish = (FSM_CS == FSM_IDLE);	//标识发送完成

endmodule