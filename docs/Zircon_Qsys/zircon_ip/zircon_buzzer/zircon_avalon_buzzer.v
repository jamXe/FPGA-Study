//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_buzzer.v
//-- 描述		:	蜂鸣器IP核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_buzzer
(
	//时钟和复位端口
	csi_clk,rsi_reset_n,
	//Avalon从端口
	avs_address,avs_write,avs_writedata,
	//外设管脚输出端口
	coe_buzzer
 );

//Avalon_Slave_PWM Avalon I/O
input 				csi_clk;		 				//系统时钟
input 				rsi_reset_n;				//系统复位
input 	[ 1:0]	avs_address;	    		//Avalon地址总线
input 				avs_write;					//Avalon写请求信号
input 	[31:0]	avs_writedata;				//Avalon写数据总线

output 				coe_buzzer;					//蜂鸣器输出信号
	
wire 		[31:0] 	pwm_clock_divide;  		//周期设定寄存器
wire 		[31:0] 	pwm_duty_cycle;    		//占空比设定寄存器
wire 	      		pwm_enable;       		//控制寄存器
	

//PWM Instance
zircon_avalon_buzzer_logic zircon_avalon_buzzer_logic
(
	.csi_clk				(csi_clk 			),	//系统时钟
	.rsi_reset_n		(rsi_reset_n		),	//系统复位
	.pwm_enable			(pwm_enable			),	//控制寄存器
	.pwm_clock_divide	(pwm_clock_divide	),	//周期设定寄存器
	.pwm_duty_cycle	(pwm_duty_cycle	),	//占空比设定寄存器
	.coe_buzzer			(coe_buzzer			)	//蜂鸣器输出信号
);

zircon_avalon_buzzer_register zircon_avalon_buzzer_register
(	
	.csi_clk				(csi_clk				),	//系统时钟
	.rsi_reset_n		(rsi_reset_n		),	//系统复位
	.avs_address		(avs_address		),	//Avalon地址总线
	.avs_write			(avs_write			),	//Avalon写请求信号
	.avs_writedata		(avs_writedata		),	//Avalon写数据总线
	.pwm_clock_divide	(pwm_clock_divide	),	//周期设定寄存器
	.pwm_duty_cycle	(pwm_duty_cycle	),	//占空比设定寄存器
	.pwm_enable			(pwm_enable			)	//控制寄存器
);

endmodule
