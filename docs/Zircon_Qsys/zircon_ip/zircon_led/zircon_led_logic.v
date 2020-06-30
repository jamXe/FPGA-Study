module zircon_led_logic
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//用户逻辑输入与输出
	led_data,led_control,
	//外设管脚输出
	coe_led
);

input         		csi_clk;	//系统时钟
input         		rsi_reset_n;//系统复位
input 		[ 7:0]	led_data;	//led数据寄存器
input 				led_control;//led控制寄存器
output reg	[ 7:0]	coe_led;	//led接口管脚

reg			[ 7:0]	coe_led_r;	//led接口管脚的寄存器

//时序电路，用来给led接口管脚进行赋值
always @(posedge csi_clk or negedge rsi_reset_n )
begin
    if(!rsi_reset_n)			//判断复位
		coe_led <= 8'hff;		//初始化led接口管脚为0xff，LED全灭
	else
		coe_led <= coe_led_r;	//用来给led接口管脚赋值
end

//组合电路，用来实现led硬件逻辑功能
always @ (*)
begin
	if(led_control)				//判断led控制寄存器
		coe_led_r = led_data;	//如果led控制寄存器使能打开，允许接收led数据寄存器数据
	else
		coe_led_r = coe_led;	//否则，将保持不变
end

endmodule 