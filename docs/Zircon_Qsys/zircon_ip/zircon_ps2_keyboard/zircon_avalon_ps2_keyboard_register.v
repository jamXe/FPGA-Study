//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_keyboard_register.v
//-- 描述		:	PS/2键盘IP核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_keyboard_register
(	
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,
	//用户逻辑输入与输出
	shift_key_on,continued_press,ascii_output,read_address
);

input 					csi_clk;			   		//系统时钟
input 					rsi_reset_n;				//系统复位
input		 				avs_address;	     		//Avalon地址总线
input 					avs_read;			    	//Avalon读请求信号
output reg 	[31:0] 	avs_readdata;	  			//Avalon读数据总线
input			[ 7:0]	ascii_output;				//从PS/2中读出的ASICC数据
input						shift_key_on;				//shift键状态标志位
input						continued_press;			//持续按下按键标志位
output					read_address;				//Avalon读请求和数据总线的使能标志位

reg 			[31:0] 	avs_readdata_n;			//avs_readdata的下一个状态

//时序电路,用来给数据寄存器赋值
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)									//判断复位
		avs_readdata <= 32'h00;						//初始化数据寄存器
	else
		avs_readdata <= avs_readdata_n;			//用来给数据寄存器赋值
end

 //组合电路,用来给地址偏移量0，也就是我们的数据寄存器读10位的数据
always @ (*)
begin           
	if((avs_read) && (avs_address == 1'b0))	//判断读请求和读地址
		avs_readdata_n = {22'b0,shift_key_on,continued_press,ascii_output}; 	//如果条件成立,将数据赋值给avs_readdata_n
	else		
		avs_readdata_n = 32'h0;						//否则，将保持不变
end

assign read_address = avs_read && (avs_address == 1'b0); 	//Avalon读请求和数据总线的使能标志位

endmodule
