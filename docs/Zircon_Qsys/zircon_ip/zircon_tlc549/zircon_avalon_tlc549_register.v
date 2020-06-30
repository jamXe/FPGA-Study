//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_tlc549_register.v
//-- 描述		:	TLC549 AD IP核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_tlc549_register
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,
	//用户逻辑输入与输出
	data_out,
);
 
input 					csi_clk;					//系统时钟
input						rsi_reset_n;			//系统复位
input						avs_address;			//Avalon地址总线
input						avs_read;				//Avalon读请求信号
output		[31:0]	avs_readdata;			//Avalon读数据总线

input			[ 7:0]	data_out;				//从AD中读出的数据
reg			[ 7:0]	data_reg;				//用来将AD数据赋值给Avalon读数据总线
reg			[ 7:0]	data_reg_n;				//data_reg的下一个状态

//时序电路,用来给数据寄存器赋值
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)								//判断复位
		data_reg <= 8'h00;						//初始化数据寄存器
	else
		data_reg <= data_reg_n;					//用来给数据寄存器赋值
end

//组合电路,用来给地址偏移量0，也就是我们的数据寄存器读8位的数据
always @ (*)
begin
	if((avs_read) && (avs_address == 1'b0))//判断读请求和读地址
		data_reg_n = data_out;					//如果条件成立,将AD数据赋值给data_reg_n
	else
		data_reg_n = data_reg;					//否则，将保持不变
end

assign avs_readdata = {24'h0,data_reg};	//将AD数据赋值给Avalon读数据总线

endmodule
