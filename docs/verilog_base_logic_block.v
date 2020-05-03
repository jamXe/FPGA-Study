always@(*)begin
	B=A;
end

assign B=A;



计数器:
reg 	[]	cnt_A		;
wire		add_cnt_A	;
wire		end_cnt_A	;


always@(posedge clk or negedge rst_n)begin
	if( !rst_n )begin
		cnt_A <= 0;
	end
	else if( add_cnt_A )begin
		if( end_cnt_A )
			cnt_A <= 0;
		else 
			cnt_A <= cnt_A + 1;
	end
end

assign add_cnt_A = ;
assign end_cnt_A = add_cnt_A && cnt_A == - 1;


//四段式状态机
//第一段：同步时序always模块，格式化描述次态寄存器迁移到现态寄存器(不需更改）
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		state_c <= IDLE;
	end
	else begin
		state_c <= state_n;
	end
end
//第二段：组合逻辑always模块，描述状态转移条件判断
always@(*)begin
	case(state_c)
	IDLE:begin
		if(idl2s1_start)begin
			state_n = S1;
		end
		else begin
			state_n = state_c;
		end
	end
	S1:begin
		if(s12s2_start)begin
			state_n = S2;
		end
		else begin
			state_n = state_c;
		end
	end
	S2:begin
		if(s22s3_start)begin
			state_n = S3;
		end
		else begin
			state_n = state_c;
		end
	end
	default:begin
		state_n = IDLE;
	end
	endcase
end
//第三段：设计转移条件
assign idl2s1_start  = state_c==IDLE && ;
assign s12s2_start = state_c==S1    && ;
assign s22s3_start  = state_c==S2    && ;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out1 <=1'b0
	end
	else if(state_c==S1)begin
		out1 <= 1'b1;
	end
	else begin
		out1 <= 1'b0;
	end
end



:ab Shixu 
always  @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)begin
	end
	else begin
	end
end

:ab Zuhe 
always  @(*)begin
end

:ab Module 
module module_name(
	clk    ,
	rst_n  ,
	//其他信号,举例dout
	dout
);
	//参数定义
	parameter      DATA_W =         8;
	
	//输入信号定义
	input               clk    ;
	input               rst_n  ;
	
	//输出信号定义
	output[DATA_W-1:0]  dout   ;
	
	//输出信号reg定义
	reg   [DATA_W-1:0]  dout   ;
	
	//中间信号定义
	reg                 signal1;
	
	//组合逻辑写法
	always@(*)begin
	end
	
	//时序逻辑写法
	always@(posedge clk or negedge rst_n)begin
		if(rst_n==1'b0)begin
		end
		else begin
		end
	end
endmodule


:ab Test 
`timescale 1 ns/1 ns

module testbench_name();
	//时钟和复位
	reg clk  ;
	reg rst_n;
	
	//uut的输入信号
	reg[3:0]  din0  ;
	reg       din1  ;
	//uut的输出信号
	wire      dout0;
	wire[4:0] dout1;
	
	//时钟周期，单位为ns，可在此修改时钟周期。
	parameter CYCLE    = 20;

	//复位时间，此时表示复位3个时钟周期的时间。
	parameter RST_TIME = 3 ;
	
	//待测试的模块例化
	module_name uut(
		.clk          (clk     ), 
		.rst_n        (rst_n   ),
		.din0         (din0    ),
		.din1         (din1    ),
		.dout0        (dout0   ),
		.dout1        (dout1   )
	);
	//生成本地时钟50M
	initial begin
		clk = 0;
		forever	#(CYCLE/2)	clk=~clk;
	end
	//产生复位信号
	initial begin
		rst_n = 1;
		#2;
		rst_n = 0;
		#(CYCLE*RST_TIME);
		rst_n = 1;
	end
	//输入信号din0赋值方式
	initial begin
		#1;
		//赋初值
		din0 = 0;
		#(10*CYCLE);
		//开始赋值
	end
	//输入信号din1赋值方式
	initial begin
		#1;
		//赋初值
		din1 = 0;
		#(10*CYCLE);
		//开始赋值
	end
endmodule

:ab Jsq    
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt <= 0;
	end
	else if(add_cnt)begin
		if(end_cnt)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end
end
assign add_cnt = ;       
assign end_cnt = add_cnt && cnt== ;   

:ab Jsq2 
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt0 <= 0;
	end
	else if(add_cnt0)begin
		if(end_cnt0)
			cnt0 <= 0;
		else
			cnt0 <= cnt0 + 1;
	end
end
assign add_cnt0 = ;
assign end_cnt0 = add_cnt0 && cnt0== ;

always @(posedge clk or negedge rst_n)begin 
	if(!rst_n)begin
		cnt1 <= 0;
	end
	else if(add_cnt1)begin
		if(end_cnt1)
			cnt1 <= 0;
		else
			cnt1 <= cnt1 + 1;
	end
end
assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1== ;

:ab Jsq3 
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt0 <= 0;
	end
	else if(add_cnt0)begin
		if(end_cnt0)
			cnt0 <= 0;
		else
			cnt0 <= cnt0 + 1;
	end
end
assign add_cnt0 = ;
assign end_cnt0 = add_cnt0 && cnt0== ;

always @(posedge clk or negedge rst_n)begin 
	if(!rst_n)begin
		cnt1 <= 0;
	end
	else if(add_cnt1)begin
		if(end_cnt1)
			cnt1 <= 0;
		else
			cnt1 <= cnt1 + 1;
	end
end

assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1== ;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt2 <= 0;
	end
	else if(add_cnt2)begin
		if(end_cnt2)
			cnt2 <= 0;
		else
			cnt2 <= cnt2 + 1;
	end
end
assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2== ; 

:ab Shixu2 
always  @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)begin
	end
	else if()begin
	end
	else if()begin
	end
end

:ab Shixu1 
always  @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)begin
	end
	else if()begin
	end
end

:ab Shixu3 
always  @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)begin
	end
	else if()begin
	end
	else if()begin
	end
	else if()begin
	end
end

:ab Zuhe2 
always  @(*)begin
	if()begin
	end
	else begin
	end
end

:ab Zuhe3 
always  @(*)begin
	if()begin
	end
	else if()begin
	end
	else begin
	end
end

:ab Zuhe4 
always  @(*)begin
	if()begin
	end
	else if()begin
	end
	else if()begin
	end
	else begin
	end
end

:ab Output32 
output[   31: 0]         ;
:ab Output16 
output[   15: 0]         ;
:ab Output8  
output[    7: 0]         ;
:ab Output4  
output[    3: 0]         ;
:ab Output3  
output[    2: 0]         ;
:ab Output2  
output[    1: 0]         ;
:ab Output1  
output                   ;

:ab Input32 
input [   31: 0]         ;
:ab Input16 
input [   15: 0]         ;
:ab Input8  
input [    7: 0]         ;
:ab Input4  
input [    3: 0]         ;
:ab Input3  
input [    2: 0]         ;
:ab Input2  
input [    1: 0]         ;
:ab Input1  
input                    ;

:ab Wire32 
wire  [   31: 0]         ;
:ab Wire16 
wire  [   15: 0]         ;
:ab Wire8  
wire  [    7: 0]         ;
:ab Wire4  
wire  [    3: 0]         ;
:ab Wire3  
wire  [    2: 0]         ;
:ab Wire2  
wire  [    1: 0]         ;
:ab Wire1  
wire                     ;

:ab Wire32 
wire  [   31: 0]         ;
:ab Wire16 
wire  [   15: 0]         ;
:ab Wire8  
wire  [    7: 0]         ;
:ab Wire4  
wire  [    3: 0]         ;
:ab Wire3  
wire  [    2: 0]         ;
:ab Wire2  
wire  [    1: 0]         ;
:ab Wire1  
wire                     ;

:ab Reg32 
reg   [   31: 0]         ;
:ab Reg16 
reg   [   15: 0]         ;
:ab Reg8  
reg   [    7: 0]         ;
:ab Reg4  
reg   [    3: 0]         ;
:ab Reg3  
reg   [    2: 0]         ;
:ab Reg2  
reg   [    1: 0]         ;
:ab Reg1  
reg                      ;



