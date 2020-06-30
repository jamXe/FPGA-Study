//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_tlc5615_register.v
//-- 描述		:	TLC5615 DA IP核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_tlc5615_register
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//用户逻辑输入与输出
	da_in,da_start
);
 
input 					csi_clk;			//系统时钟
input						rsi_reset_n;	//系统复位
input						avs_address;	//Avalon地址总线
input						avs_write;		//Avalon写请求信
input			[31:0]	avs_writedata;	//Avalon写数据总线

output reg 	[ 7:0]	da_in;			//tlc5615发送的8位数据
reg			[ 7:0]	da_in_n;			//da_in的下一个状态
output reg				da_start;		//tlc5615发送开始位
reg						da_start_n;		//da_start的下一个状态

//时序电路,用于给数据寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)						//判断复位
		da_in <= 8'h00;					//初始化数据寄存器
	else
		da_in <= da_in_n;					//用来给数据寄存器赋值
end
	
//组合电路，用来给地址偏移量0，也就是我们的数据寄存器写8位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 1'b0))	//判断写使能和地址偏移量
		da_in_n = avs_writedata[7:0];	//如果条件成立,那么将写数据中的值赋值给数据寄存器
	else
		da_in_n = da_in;					//否则，将保持不变
end

//时序电路,用于给tlc5615发送开始位进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)						//判断复位
		da_start <= 1'b0;					//初始化tlc5615发送开始位
	else
		da_start <= da_start_n;			//用来给tlc5615发送开始位赋值
end

//组合电路，用来判断tlc5615发送开始位
always @ (*)
begin
	if((avs_write) && (avs_address == 1'b0))	//判断写使能和地址偏移量
		da_start_n = 1'b1;				//如果条件成立，那么将tlc5615发送开始位置1
	else
		da_start_n = 1'b0;				//否则，将置0
end


endmodule
