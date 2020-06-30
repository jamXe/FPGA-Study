//---------------------------------------------------------------------------
//--	文件名		:	Ad_Module.v
//--	作者		:	ZIRCON
//--	描述		:	AD模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------

`define AD_CLK_TIME			10'd45	//1.1M, 909ns,909 / (1 / 50M) = 45 =0x2D
`define AD_CLK_TIME_HALF	10'd22	//909ns / 2 = 454.5ns 45 / 2 = 22	

module Ad_Module
(	
	//Input
	CLK_50M,RST_N,
	//Output
	AD_CS,AD_CLK,AD_DATA,data_out
);
	
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;				//时钟的端口,开发板用的50M晶振
input					RST_N;				//复位的端口,低电平复位
input					AD_DATA;				//AD数据端口
output				AD_CS;				//AD片选端口
output				AD_CLK;				//AD时钟端口，最大不超过1.1MHz
output	[ 7:0]	data_out;			//AD模数转换完成的数据输出


//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg					AD_CS;				//AD片选信号端口
reg					AD_CS_N;				//AD_CS的下一个状态
reg					AD_CLK;				//AD时钟，最大不超过1.1MHz
reg					AD_CLK_N;			//AD_CLK的下一个状态

reg		[ 2:0]	ad_fsm_cs;			//状态机的当前状态
reg		[ 2:0]	ad_fsm_ns;			//状态机的下一个状态

reg		[ 5:0]	time_cnt;			//用于记录一个时钟所用时间的定时器
reg		[ 5:0]	time_cnt_n;			//time_cnt的下一个状态
reg		[ 5:0]	bit_cnt;				//用来记录时钟周期个数的计数器
reg		[ 5:0]	bit_cnt_n;			//bit_cnt的下一个状态

reg		[ 7:0]	data_out;			//用来保存稳定的AD数据
reg		[ 7:0]	data_out_n;			//data_out的下一个状态
reg		[ 7:0]	ad_data_reg;		//用于保存数据的移位寄存器
reg		[ 7:0]	ad_data_reg_n;		//ad_data_reg_n的下一个状态

parameter	FSM_IDLE			= 3'h0;	//状态机的初始状态；
parameter	FSM_READY		= 3'h1;	//满足CS有效时的第一个1.4us的延时状态
parameter	FSM_DATA			= 3'h2;	//读取8个数据状态
parameter	FSM_WAIT_CONV	= 3'h3;	//等待转换状态,等待17us;
parameter	FSM_END			= 3'h4;	//结束的状态

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给ad_fsm_cs寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		ad_fsm_cs <= 1'b0;				//初始化ad_fsm_cs值
	else
		ad_fsm_cs <= ad_fsm_ns;			//用来给ad_fsm_ns赋值
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(ad_fsm_cs)						//判断状态机的当前状态
		FSM_IDLE:
												//3 x 0.909us = 2.727us用于初始化延时 
			if((bit_cnt == 6'd2 ) && (time_cnt == `AD_CLK_TIME))
				ad_fsm_ns = FSM_READY;	//如果空闲状态完成就进入延时状态
			else
				ad_fsm_ns = ad_fsm_cs;	//否则保持原状态不变
		FSM_READY:
												//2 x 0.909us = 1.818us用于延迟1.4us
			if((bit_cnt == 6'd1 ) && (time_cnt == `AD_CLK_TIME))
				ad_fsm_ns = FSM_DATA;	//如果延时状态完成就进入读取数据状态
			else
				ad_fsm_ns = ad_fsm_cs;  //否则保持原状态不变 
		FSM_DATA:
												//读取数据8位，1~8个时钟脉冲
			if((bit_cnt == 6'd8 ) && (time_cnt == `AD_CLK_TIME))
				ad_fsm_ns = FSM_WAIT_CONV;//如果读取数据状态完成就进入等待状态
			else
				ad_fsm_ns = ad_fsm_cs;	//否则保持原状态不变		
		FSM_WAIT_CONV:
												//19 x 0.909us = 17.271us用于延迟17us
			if((bit_cnt == 6'd18) && (time_cnt == `AD_CLK_TIME))
				ad_fsm_ns = FSM_END;		//如果等待状态完成就进入读取状态
			else
				ad_fsm_ns = ad_fsm_cs;	//否则保持原状态不变  
		FSM_END:								
			ad_fsm_ns = FSM_READY;		//完成一次数据转换,进入下一次转换
		default:ad_fsm_ns = FSM_IDLE;				
	endcase
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		time_cnt <= 6'h0;					//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;			//用来给time_cnt赋值
end

//组合电路,实现0.909us的定时计数器
always @ (*)
begin
	if(time_cnt == `AD_CLK_TIME)		//判断0.909us时间
		time_cnt_n = 6'h0;				//如果到达0.909us,定时器清零
	else
		time_cnt_n = time_cnt + 6'h1;	//如果未到0.909us,定时器继续加1
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		bit_cnt <= 6'h0;					//初始化bit_cnt值
	else
		bit_cnt <= bit_cnt_n;			//用来给bit_cnt赋值
end

//组合电路,用来记录时钟周期个数的计数器
always @ (*)
begin
	if(ad_fsm_cs != ad_fsm_ns)			//判断状态机的当前状态
		bit_cnt_n = 6'h0;					//如果当前的状态不等于下一个状态,计时器就清零
	else if(time_cnt == `AD_CLK_TIME_HALF)//判断0.4545us时间
		bit_cnt_n = bit_cnt + 6'h1;	//如果到达0.4545us,计数器就加1
	else
		bit_cnt_n = bit_cnt;				//否则计数器保持不变
end

//时序电路,用来给AD_CLK寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		AD_CLK <= 1'h0;					//初始化AD_CLK值
	else
		AD_CLK <= AD_CLK_N;				//用来给AD_CLK赋值
end

//组合电路,用来生成AD的时钟波形
always @ (*)
begin
	if(ad_fsm_cs != FSM_DATA)			//判断状态机的当前状态
		AD_CLK_N = 1'h0;					//如果当前的状态不等于读取数据状态,AD_CLK_N就置0
	else if(time_cnt == `AD_CLK_TIME_HALF)//判断0.4545us时间
		AD_CLK_N = 1'h1;					//如果到达0.4545us,ADC_CLK_N就置1
	else if(time_cnt == `AD_CLK_TIME)//判断0.909us时间
		AD_CLK_N = 1'h0;					//如果到达0.909us,AD_CLK_N就置0
	else
		AD_CLK_N = AD_CLK;				//否则保持不变
end

//时序电路,用来给AD_CS寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		AD_CS <= 1'h0;						//初始化AD_CS值
	else
		AD_CS <= AD_CS_N;					//用来给AD_CS赋值
end

//组合电路,用来生成AD的片选波形
always @ (*)
begin
	if((ad_fsm_cs == FSM_DATA) || (ad_fsm_cs == FSM_READY))//判断状态机的当前状态
		AD_CS_N = 1'h0;//如果当前的状态等于读取数据状态或等于延时1.4us状态,AD_CS_N就置0
	else
		AD_CS_N = 1'h1;//如果当前的状态不等于读取数据状态或不等于延时1.4us状态,AD_CS_N就置1
end

//时序电路,用来给ad_data_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		ad_data_reg <= 8'h0;				//初始化ad_data_reg值
	else
		ad_data_reg <= ad_data_reg_n;	//用来给ad_data_reg赋值
end

//组合电路,将AD线上的数据保存到移位寄存器中
always @(*)
begin
	if((ad_fsm_cs == FSM_DATA) && (!AD_CLK) && (AD_CLK_N))//判断每一个时钟的上升沿
		ad_data_reg_n = {ad_data_reg[6:0],AD_DATA};//将数据存入移位寄存器中,高位优先
	else
		ad_data_reg_n = ad_data_reg;	//否则保持不变
end

//时序电路,用来给data_out寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		data_out <= 8'h0;					//初始化data_out值
	else
		data_out <= data_out_n;			//用来给data_out赋值
end

//组合电路,将移位寄存器中的数据存入data_out中,可用于输出
always @ (*)
begin
	if(ad_fsm_cs == FSM_END)			//判断复位
		data_out_n = ad_data_reg;		//初始化data_out值
	else
		data_out_n = data_out;			//用来给data_out赋值
end

endmodule


