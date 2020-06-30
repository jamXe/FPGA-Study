//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_vga_register.v
//-- 描述		:	Vga Ip核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_vga_register 
(
	//时钟和复位端口
	csi_clk,rsi_reset_n,
	//Avalon从端口
	avs_address,avs_write,avs_writedata,
	//Avalon主端口
	avm_address,avm_byteenable,avm_read,avm_readdata,
	avm_waitrequest,avm_readdatavalid,
	//外设管脚输出端口
	coe_vga_clk,coe_vga_rgb,vga_data_en,vga_frame_start
);


input					csi_clk;						//系统时钟
input					rsi_reset_n;				//系统复位

input		[ 1:0]	avs_address;				//Avalon从端口地址总线
input          	avs_write;					//Avalon从端口写请求信号
input		[31:0]	avs_writedata;				//Avalon从端口写数据总线

output	[31:0]	avm_address;				//Avalon主端口地址总线
output				avm_byteenable;			//Avalon主端口字节使能信号
output				avm_read;					//Avalon主端口读请求信号
input		[ 7:0]	avm_readdata;				//Avalon主端口读数据总线
input					avm_waitrequest;			//Avalon主端口等待信号
input					avm_readdatavalid;		//Avalon主端口读数据有效信号

input					coe_vga_clk;				//vga的系统时钟
input					vga_data_en;				//vga的数据使能信号
output	[ 7:0]	coe_vga_rgb;				//vga的数据信号
input					vga_frame_start;			//vga的每一帧的开始位

reg        			vga_start;					//vga的开始位
reg        			vga_start_n;				//vga_start的下一个状态
reg 		[31:0]	vga_buffer_address;		//vga的缓冲区首地址
reg 		[31:0]	vga_buffer_address_n;	//vga_buffer_address的下一个状态

reg		[18:0]	buffer_address_count;	//数据地址计数器
reg		[18:0]	buffer_address_count_n;	//buffer_address_count的下一个状态
reg					vga_read;					//读数据信号
reg					vga_read_n;					//vga_read的下一个状态

wire		[ 7:0]	fifo_data;					//从FIFO中读取出来的数据
wire		[16:0]	fifo_count;					//显示当前FIFO中数据存量
wire					fifo_clear;					//FIFO的清除位

//----------------Avalon Slave Start-------------------------------

//时序电路,用于给数据寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)								//判断复位
		vga_buffer_address <= 1'b0;			//初始化数据寄存器
	else
		vga_buffer_address <= vga_buffer_address_n;	//用来给数据寄存器赋值
end

//组合电路，用来给地址偏移量0，也就是我们的数据寄存器写32位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b00))	//判断写使能和地址偏移量
		vga_buffer_address_n = avs_writedata;	//如果条件成立,那么将写数据中的值赋值给数据寄存器
	else
		vga_buffer_address_n = vga_buffer_address;	//否则，将保持不变
end

//时序电路,用于给控制寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)								//判断复位
		vga_start <= 1'b0;						//初始化控制寄存器
	else
		vga_start <= vga_start_n;				//用来给控制寄存器赋值
end

//组合电路，用来给地址偏移量1，也就是我们的控制寄存器写1位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b01))	//判断写使能和地址偏移量
		vga_start_n = avs_writedata[0];		//如果条件成立,那么将写数据中的值赋值给控制寄存器
	else
		vga_start_n = vga_start;				//否则，将保持不变
end

//----------------Avalon Master Start-----------------------------

//时序电路,用于给数据地址计数器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n) 
begin
	if (!rsi_reset_n)
		buffer_address_count <= 19'h0;
	else
		buffer_address_count <= buffer_address_count_n;
end

//组合电路,根据Avalon主端口时序,用来给Avalon交换结构发送地址信号总线的
always @ (*) 
begin
	if(!vga_start)
		buffer_address_count_n = 19'h0;
	else if((vga_start) && (!avm_waitrequest) && (fifo_clear)) 
		buffer_address_count_n = 19'h0;
	else if((vga_start) && (!avm_waitrequest) && (!fifo_clear) && (buffer_address_count < 19'd480000) && (vga_read)) 
		buffer_address_count_n = buffer_address_count + 1'b1;
	else
		buffer_address_count_n = buffer_address_count;
end

//时序电路,用于给读数据信号进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)
		vga_read <= 1'b0;
	else
		vga_read <= vga_read_n;
end

//组合电路,根据Avalon主端口时序,用来给Avalon交换结构发送读请求信号的
always @ (*) 
begin
	if(!vga_start)
		vga_read_n = 1'b0;
	else if((vga_start) && (!avm_waitrequest) && (fifo_clear))
		vga_read_n = 1'b0;
	else if((vga_start) && (!avm_waitrequest) && (!fifo_clear) && (fifo_count < 500) && (buffer_address_count < 19'd480000))
		vga_read_n = 1'b1;
	else if((vga_start) && (!avm_waitrequest) && (!fifo_clear) && (fifo_count >= 1500))
		vga_read_n = 1'b0;
	else
		vga_read_n = vga_read;

end

//FIFO缓冲模块
zircon_avalon_vga_fifo zircon_avalon_vga_fifo_init
(
	.aclr			(fifo_clear			),	//FIFO的清除位
	.data			(avm_readdata		),	//FIFO写数据
	.rdclk		(~coe_vga_clk		),	//FIFO读时钟
	.rdreq		(vga_data_en		),	//FIFO读请求
	.wrclk		(csi_clk				),	//FIFO写时钟
	.wrreq		(avm_readdatavalid),	//FIFO写请求
	.q				(fifo_data			),	//FIFO读数据
	.wrusedw		(fifo_count			)	//显示当前FIFO中数据存量
);

assign avm_byteenable = 1'b1;	//Avalon主端口字节使能信号
assign avm_address = vga_buffer_address + buffer_address_count;	//Avalon主端口地址总线
assign avm_read = vga_read;	//Avalon主端口读请求信号
assign fifo_clear = vga_frame_start;	//vga的每一帧的开始位
assign coe_vga_rgb = vga_data_en ? fifo_data[7:0] : 8'b0;	//从FIFO中读取出来的数据传输给vga

endmodule
