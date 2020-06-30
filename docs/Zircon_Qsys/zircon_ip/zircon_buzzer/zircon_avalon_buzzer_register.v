//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_buzzer_register.v
//-- 描述		:	蜂鸣器IP核的寄存器文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_buzzer_register
(	
	//时钟和复位端口
	csi_clk,rsi_reset_n, 
	//Avalon从端口
	avs_address,avs_write,avs_writedata,
	//用户逻辑输入与输出
	pwm_clock_divide,pwm_duty_cycle,pwm_enable
);


input 					csi_clk;			    		//系统时钟
input 					rsi_reset_n;				//系统复位
input 	  	[ 1:0] 	avs_address;	     		//Avalon地址总线
input 					avs_write;					//Avalon写请求信号
input 	  	[31:0] 	avs_writedata;				//Avalon写数据总线
output reg 	[31:0] 	pwm_clock_divide; 		//周期设定寄存器
reg 			[31:0] 	pwm_clock_divide_n;		//pwm_clock_divide的下一个状态
output reg 	[31:0] 	pwm_duty_cycle;   		//占空比设定寄存器
reg 			[31:0] 	pwm_duty_cycle_n;  		//pwm_duty_cycle的下一个状态
output reg       		pwm_enable;       		//控制寄存器
reg        				pwm_enable_n;	 			//pwm_enalbe的下一个状态


//时序电路,用于给周期设定寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)									//判断复位
		pwm_clock_divide <= 1'b0;					//初始化周期设定寄存器
	else
		pwm_clock_divide <= pwm_clock_divide_n;//用来给周期设定寄存器赋值
end

//组合电路，用来给地址偏移量0，也就是我们的周期设定寄存器写32位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b00))	//判断写使能和地址偏移量
		pwm_clock_divide_n = avs_writedata;		//如果条件成立,那么将写数据中的值赋值给周期设定寄存器
	else
		pwm_clock_divide_n = pwm_clock_divide;	//否则，将保持不变
end

//时序电路,用于给占空比设定寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)									//判断复位
		pwm_duty_cycle <= 1'b0;						//初始化占空比设定寄存器
	else
		pwm_duty_cycle <= pwm_duty_cycle_n;		//用来给占空比设定寄存器赋值
end

//组合电路，用来给地址偏移量1，也就是我们的占空比设定寄存器写32位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b01))	//判断写使能和地址偏移量
		pwm_duty_cycle_n = avs_writedata;		//如果条件成立,那么将写数据中的值赋值给占空比设定寄存器
	else
		pwm_duty_cycle_n = pwm_duty_cycle;		//否则，将保持不变
end
				
//时序电路,用于给控制寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)									//判断复位
		pwm_enable <= 1'b0;							//初始化控制寄存器
	else
		pwm_enable <= pwm_enable_n;				//用来给控制寄存器赋值
end

//组合电路，用来给地址偏移量2，也就是我们的控制寄存器写1位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b10))	//判断写使能和地址偏移量
		pwm_enable_n = avs_writedata[0];			//如果条件成立,那么将写数据中的值赋值给控制寄存器
	else
		pwm_enable_n = pwm_enable;					//否则，将保持不变
end

endmodule
