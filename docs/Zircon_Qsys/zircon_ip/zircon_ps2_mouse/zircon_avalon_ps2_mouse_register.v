//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_ps2_mouse_register.v
//-- 描述		:	PS/2鼠标IP核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_mouse_register
(	
	//时钟复位
	csi_clk,rsi_reset_n, 
	//Avalon-MM从端口
	avs_address,avs_read,avs_readdata,
	//用户逻辑输入与输出
	left_button,right_button,middle_button,x_increment,y_increment
);

input 					csi_clk;			   		//系统时钟
input 					rsi_reset_n;				//系统复位
input 		 			avs_address;	     		//Avalon地址总线
input 					avs_read;			   	//Avalon读请求信号
output reg	[31:0] 	avs_readdata;	  			//Avalon读数据总线
input						left_button;				//鼠标左键标志位
input						right_button;				//鼠标右键标志位
input						middle_button;				//鼠标中键标志位
input			[ 8:0]	x_increment;				//X轴增量
input			[ 8:0]	y_increment;				//Y轴增量

reg			[31:0] 	avs_readdata_n;	  		//avs_address的下一个状态

//时序电路,用来给数据寄存器赋值
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)									//判断复位
		avs_readdata <= 32'h00;						//初始化数据寄存器
	else
		avs_readdata <= avs_readdata_n;			//用来给数据寄存器赋值
end

 //组合电路,用来给地址偏移量0，也就是我们的数据寄存器读21位的数据
always @ (*)
begin           
	if((avs_read) && (avs_address == 1'b0))	//判断读请求和读地址
		avs_readdata_n = {11'b0,left_button,right_button,middle_button,y_increment,x_increment}; 	//如果条件成立,将数据赋值给avs_readdata_n
	else		
		avs_readdata_n = 32'h0;						//否则，将保持不变
end

endmodule
