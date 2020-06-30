module zircon_led
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//外设管脚输出
	coe_led
);

input         		csi_clk;			//系统时钟
input         		rsi_reset_n;		//系统复位
input 		[ 1:0]	avs_address;		//Avalon地址总线
input				avs_write;			//Avalon写请求信
input		[31:0]	avs_writedata;		//Avalon写数据总线
output 		[ 7:0]	coe_led;  			//led接口管脚

wire 		[ 7:0]	led_data;			//led数据寄存器
wire				led_control;		//led控制寄存器

//硬件逻辑文件
zircon_led_logic	zircon_led_logic_init
(
	.csi_clk		(csi_clk		),	//系统时钟
	.rsi_reset_n	(rsi_reset_n	),	//系统复位
	.led_data		(led_data		),	//led数据寄存器
	.led_control	(led_control	),	//led控制寄存器
	.coe_led		(coe_led		)	//led接口管脚
);

//寄存器文件
zircon_led_register	zircon_led_register_init
(
	.csi_clk		(csi_clk		),	//系统时钟
	.rsi_reset_n	(rsi_reset_n	),	//系统复位
	.avs_address	(avs_address	),	//Avalon地址总线
	.avs_write		(avs_write		),	//Avalon写请求信
	.avs_writedata	(avs_writedata	),	//Avalon写数据总线
	.led_data		(led_data		),	//led数据寄存器
	.led_control	(led_control	)	//led控制寄存器
);

endmodule
