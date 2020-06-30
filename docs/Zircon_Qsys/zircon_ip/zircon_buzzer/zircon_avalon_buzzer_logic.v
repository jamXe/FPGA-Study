//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_buzzer_logic.v
//-- 描述		:	蜂鸣器IP核的硬件逻辑文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_buzzer_logic
(
	//时钟和复位端口
	csi_clk,rsi_reset_n,
	//用户逻辑输入与输出
	pwm_enable,pwm_clock_divide,pwm_duty_cycle,
	//外设管脚输出端口
	coe_buzzer
);

//Inputs
input		 				csi_clk;					//系统时钟
input 					rsi_reset_n;			//系统复位
input 		[31:0] 	pwm_clock_divide;		//周期设定寄存器
input 		[31:0] 	pwm_duty_cycle;		//占空比设定寄存器
input 					pwm_enable;				//控制寄存器
output reg 				coe_buzzer;				//蜂鸣器输出信号
reg 						coe_buzzer_n;			//coe_buzzer的下一个状态
reg 			[31:0] 	counter;					//计数器
reg			[31:0] 	counter_n;				//counter的下一个状态

//时序电路,用于给计数器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)								//判断复位
		counter <= 1'b0;							//初始化计数器
	else
		counter <= counter_n;					//用来给计数器赋值
end

//组合电路，计数器根据周期设定寄存器进行计数
always @ (*)
begin
	if((pwm_enable) && (counter >= pwm_clock_divide))
		counter_n = 1'b0;							//如果条件成立,那么将计数器清零
	else
		counter_n = counter + 1;				//否则，计数器加1
end	

//时序电路,用于给蜂鸣器输出信号进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)								//判断复位
		coe_buzzer <= 1'b0;						//初始化蜂鸣器输出信号
	else
		coe_buzzer <= coe_buzzer_n;			//用来给蜂鸣器输出信号赋值
end

//组合电路，蜂鸣器根据占空比设定寄存器来输出高低电平
always @ (*)
begin
	if((pwm_enable) && (counter <= pwm_duty_cycle))	
		coe_buzzer_n = 1'b1;						//如果条件成立,那么将写蜂鸣器输出信号置1
	else
		coe_buzzer_n = 1'b0;						//否则，将蜂鸣器输出信号置0
end	

endmodule
