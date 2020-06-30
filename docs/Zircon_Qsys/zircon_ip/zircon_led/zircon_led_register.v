module zircon_led_register
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//用户逻辑输入与输出
	led_data,led_control
);
 
input 				csi_clk;		//系统时钟
input				rsi_reset_n;	//系统复位
input		[ 1:0]	avs_address;	//Avalon地址总线
input				avs_write;		//Avalon写请求信
input		[31:0]	avs_writedata;	//Avalon写数据总线
output reg	[ 7:0]	led_data;		//led数据寄存器
output reg 			led_control;	//led控制寄存器

reg 				led_control_r;	//led_control下一个状态
reg			[ 7:0]	led_data_r;		//led_data下一个状态

//时序电路，用来给led控制寄存器进行赋值
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		led_control <= 1'b0;					//初始化led控制寄存器
	else
		led_control <= led_control_r;			//用来给led控制寄存器赋值
end

//组合电路，用来给地址偏移量0，也就是我们的led控制寄存器写数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b00))	//判断写使能和地址偏移量
		led_control_r = avs_writedata[0];		//如果条件成立，那么将写数据中的值赋值给led控制寄存器
	else
		led_control_r = led_control;			//否则，将保持不变
end
	
//时序电路，用来给led数据寄存器进行赋值
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		led_data <= 8'hff;						//初始化led数据寄存器
	else
		led_data <= led_data_r;					//用来给led数据寄存器赋值
end

//组合电路，用来给地址偏移量1，也就是我们的led数据寄存器写数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b01))	//判断写使能和地址偏移量
		led_data_r = avs_writedata[7:0];		//如果条件成立，那么将写数据中的值赋值给led数据寄存器
	else
		led_data_r = led_data;					//否则，将保持不变
end

endmodule
