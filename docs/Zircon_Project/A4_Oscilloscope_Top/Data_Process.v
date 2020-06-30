module Data_Process
(
	//输入端口
	CLK_50M,CLK_40M,RST_N,AD_CS,in_ad_data,vga_x,
	//输出端口
	vga_freq,vga_fengzhi,ad_to_vga_data
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟端口,开发板用的50M晶振
input					CLK_40M;					//PLL生成的40M时钟
input					RST_N;					//复位端口,低电平复位
input					AD_CS;					//AD片选信号端口
input		[ 7:0]	in_ad_data;				//AD模数转换完成的数据输出
input		[15:0]	vga_x;					//VGA的x坐标
output	[31:0] 	vga_freq;				//VGA中显示的频率值
output	[31:0] 	vga_fengzhi;			//VGA中显示的峰峰值
output	[ 7:0]	ad_to_vga_data;		//VGA中显示的波形数据

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[ 1:0]	detect_edge;			//记录AD_CS的开始脉冲,即第一个上降沿
wire		[ 1:0]	detect_edge_n;			//detect_edge的下一个状态
reg					posedge_reg;			//上升沿标志
wire					posedge_reg_n;			//posedge_reg的下一个状态
reg 		[15:0] 	ad_to_vga_addr;		//读取AD到VGA的地址
reg 		[15:0] 	ad_to_vga_addr_n;		//ad_to_vga_addr的下一个状态
reg 		[15:0] 	ad_to_fft_addr;		//读取AD到FFT的地址
reg 		[15:0] 	ad_to_fft_addr_n;		//ad_to_fft_addr的下一个状态
reg		[26:0]	time_cnt;				//定时计数器
reg		[26:0]	time_cnt_n;				//time_cnt的下一个状态

reg 					fft_rst_flag;			//FFT模块复位标志位
reg 					fft_rst_flag_n;		//fft_rst_flag标志位
wire 		[ 9:0] 	fft_bit_cnt;			//FFT位计数器
wire		[ 9:0] 	fft_real_out_int;		//FFT实数的输出
wire 		[ 9:0] 	fft_imag_out_int;		//FFT虚数的输出
wire 		[ 9:0]	ad_to_fft_data;		//FFT中用到的AD数据
wire 		[31:0] 	vga_freq;				//VGA中显示的频率值
wire 		[31:0] 	vga_fengzhi;			//VGA中显示的峰峰值

//设置定时器的时间为1s,计算方法为  (1*10^6)ns / (1/50)ns  50MHz为开发板晶振
parameter SET_TIME_1S = 27'd50_000_000;	

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给detect_edge寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		detect_edge	<= 2'b11;				//初始化detect_edge值
	else
		detect_edge <= detect_edge_n;		//用来给detect_edge赋值
end

//组合电路,检测上升沿
assign detect_edge_n = {detect_edge[0] , AD_CS};	//接收AD_CS的时钟信号

//时序电路,用来给posedge_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		posedge_reg	<= 1'b0;					//初始化posedge_reg值
	else
		posedge_reg <= posedge_reg_n;		//用来给posedge_reg赋值
end

//组合电路,判断上升沿,如果detect_edge等于01,posedge_reg_n就置1
assign posedge_reg_n = (detect_edge == 2'b01) ? 1'b1 : 1'b0; 

//时序电路,用来给ad_to_vga_addr寄存器赋值
always @ (posedge posedge_reg or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		ad_to_vga_addr <= 1'b0;				//初始化ad_to_vga_addr
	else
		ad_to_vga_addr <= ad_to_vga_addr_n;//给ad_to_vga_addr赋值
end

//组合电路,用于生成RAM_AD_TO_VGA的地址
always @ (*)
begin
	if(ad_to_vga_addr < 16'd800)			//判断地址
		ad_to_vga_addr_n = ad_to_vga_addr + 1'b1;//地址累加
	else
		ad_to_vga_addr_n <= 0;				//地址清零
end

//例化双口RAM_AD_TO_VGA模块
RAM_AD_TO_VGA	AD_TO_VGA_Init
(
	.wrclock 	(CLK_50M 				),	//写时钟
	.wraddress 	(ad_to_vga_addr 		),	//写地址
	.wren 		(posedge_reg 			),	//写使能
	.data 		(10'd255 - in_ad_data),	//写数据
	
	.rdclock 	(CLK_40M 				),	//读时钟
	.rdaddress 	(vga_x - 16'd100		),	//读地址
	.q 			(ad_to_vga_data		)	//读数据
);

//时序电路,用来给ad_to_vga_addr寄存器赋值
always @ (posedge posedge_reg or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		ad_to_fft_addr <= 1'b0;				//初始化ad_to_fft_addr
	else
		ad_to_fft_addr <= ad_to_fft_addr_n;//给ad_to_fft_addr赋值
end

//组合电路,用于生成RAM_AD_TO_FFT的地址
always @ (*)
begin
	if(ad_to_fft_addr < 16'd256)			//判断地址
		ad_to_fft_addr_n = ad_to_fft_addr + 1'b1;//地址累加
	else
		ad_to_fft_addr_n <= 0;				//地址清零
end
//例化双口RAM_AD_TO_FFT模块
RAM_AD_TO_FFT	AD_TO_FFT_Init
(
	.wrclock 	(CLK_50M 			),		//写时钟
	.wraddress 	(ad_to_fft_addr 	),		//写地址
	.wren 		(posedge_reg 		),		//写使能
	.data 		(in_ad_data 		),		//写数据
	
	.rdclock 	(CLK_50M				),		//读时钟
	.rdaddress 	(fft_bit_cnt		),		//读地址
	.q 			(ad_to_fft_data	)		//读数据
);
	
//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)									//判断复位
		time_cnt  <=  27'h0;					//初始化time_cnt值
	else
		time_cnt  <=  time_cnt_n;			//用来给time_cnt赋值
end

//组合电路，实现1s的定时计数器
always @ (*)  
begin
	if(time_cnt == SET_TIME_1S)			//判断1s时间
		time_cnt_n = 27'h0;					//如果到达1s,定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 27'h1;	//如果未到1s,定时计数器将会继续累加
end

//时序电路，用来给fft_rst_flag寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)									//判断复位
		fft_rst_flag <= 1'b0;				//初始化fft_rst_flag值
	else
		fft_rst_flag <= fft_rst_flag_n;	//用来给fft_rst_flag赋值
end

//组合电路,用来生成FFT模块复位标志位
always @ (*)
begin
	if(time_cnt == SET_TIME_1S)			//判断时间
		fft_rst_flag_n = 1'b0;				//FFT模块复位标志位置0
	else
		fft_rst_flag_n = 1'b1;				//FFT模块复位标志位置1
end

//例化FFT控制模块
FFT_Control_Module	FFT_Control_Init
(
	.CLK_50M				(CLK_50M				), //时钟端口,开发板用的50M晶振
	.RST_N				(fft_rst_flag		),	//FFT模块复位标志位
	.data_real_in_int	(ad_to_fft_data	), //FFT中用到的AD数据
	.fft_real_out_int	(fft_real_out_int	),	//FFT实数的输出
	.fft_imag_out_int	(fft_imag_out_int	), //FFT虚数的输出
	.fft_bit_cnt		(fft_bit_cnt		), //FFT位计数器
	.vga_freq			(vga_freq			), //VGA中显示的频率值
	.vga_fengzhi		(vga_fengzhi		)  //VGA中显示的峰峰值
);

endmodule

