module Da_Data_Module
(
	//输入端口
	CLK_50M,RST_N,
	//输出端口
	da_data,da_start
);


//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_50M;				//时钟端口,开发板用的50M晶振	
input 				RST_N;				//复位端口,低电平复位
output	[9:0]		da_data;				//从ROM中读出的DA数据
output				da_start;			//DA模块的开始标志位

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[7:0]		time_cnt;			//计数器
reg		[7:0]		time_cnt_n;			//time_cnt的下一个状态
reg		[9:0]		rom_addr;			//rom的地址端口
reg		[9:0]		rom_addr_n;			//rom_addr的下一个状态
reg					da_start;			//DA模块的开始标志位
reg					da_start_n;			//da_start的下一个状态

//---------------------------------------------------------------------------
//--	逻辑功能实现
//---------------------------------------------------------------------------
//例化ROM模块
ROM 					ROM_Init
(
	.address			(rom_addr		),	//rom的地址端口
	.clock			(CLK_50M			),	//rom的时钟端口
	.q					(da_data[9:2]	)	//rom的数据端口
);

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		time_cnt	<= 8'h0;					//初始化time_cnt值
	else
		time_cnt	<= time_cnt_n;			//用来给time_cnt赋值
end

//1KHz的正弦波,周期为1ms,即1ms送出一个完整的512个点的波形
//每个点的时间是1 / 512 * 1000000(ns) 我们采用开发板上的50Mhz晶振系统周期为20ns
//FPGA内部的计数器值为 1 / 512 * 1000000(ns) / 20 = 97
always @ (*)
begin
	if(time_cnt == 8'd96)				//判断计数器是否到97,从0开始即96
		time_cnt_n = 8'h0;				//如果到97就将time_cnt_n置0
	else
		time_cnt_n = time_cnt + 8'h1;	//否则,time_cnt_n加1
end

//时序电路,用来给rom_addr寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		rom_addr <= 10'h0;				//初始化time_cnt值
	else
		rom_addr <= rom_addr_n;			//用来给time_cnt赋值
end

//组合电路,发送一个完整的512个点的波形,我们的mif文件中有1024个点
always @ (*)
begin
	if(time_cnt == 8'd96)				//判断计数器是否到97,从0开始即96
		rom_addr_n = rom_addr + 10'h2;//如果到97,rom_addr_n加2,1024 / 2 = 512
	else 
		rom_addr_n = rom_addr;			//否则保持不变
end

//时序电路,用来给da_start寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)								//判断复位
		da_start <= 1'h0;					//初始化da_start值	
	else
		da_start <= da_start_n;			//用来给da_start赋值
end

//组合电路,生成DA工作开始标识
always @ (*)
begin
	if(time_cnt == 8'h0)					//判断计数器的值
		da_start_n = 1'h1;				//如果计数器为0,标识为1
	else
		da_start_n = 1'h0;				//否则计数器则为0
end

assign da_data[1:0] = 2'h0;			//给da_data低两位赋值

endmodule
