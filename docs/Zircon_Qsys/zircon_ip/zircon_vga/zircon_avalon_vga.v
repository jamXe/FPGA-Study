//---------------------------------------------------------------------------
//-- 文件名		:	zircon_avalon_vga.v
//-- 描述		:	Vga Ip核的顶层文件
//-- 修订历史	:	2014-1-1
//-- 作者		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_vga 
(
	//时钟和复位端口
	csi_clk,rsi_reset_n,
	//Avalon从端口
	avs_address,avs_write,avs_writedata,
	//Avalon主端口
	avm_address,avm_byteenable,avm_read,avm_readdata,
	avm_waitrequest,avm_readdatavalid,
	//外设管脚输出端口
	coe_vga_clk,coe_vga_hsync,coe_vga_vsync,coe_vga_rgb
);

input					csi_clk;							//系统时钟
input					rsi_reset_n;					//系统复位

input		[ 1:0]	avs_address;					//Avalon从端口地址总线
input					avs_write;						//Avalon从端口写请求信号
input		[31:0]	avs_writedata;					//Avalon从端口写数据总线

output	[31:0]	avm_address;					//Avalon主端口地址总线
output				avm_byteenable;				//Avalon主端口字节使能信号
output				avm_read;						//Avalon主端口读请求信号
input		[ 7:0]	avm_readdata;					//Avalon主端口读数据总线
input					avm_waitrequest;				//Avalon主端口等待信号
input					avm_readdatavalid;			//Avalon主端口读数据有效信号

input					coe_vga_clk;					//vga的系统时钟
output				coe_vga_hsync;					//vga的行同步信号
output				coe_vga_vsync;					//vga的帧同步信号
output	[ 7:0]	coe_vga_rgb;					//vga的数据信号

wire					vga_data_en;					//vga的数据使能信号
wire					vga_frame_start;				//vga的每一帧的开始位

zircon_avalon_vga_logic		zircon_avalon_vga_logic_init
(
	.CLK_40M					(coe_vga_clk		),	//vga的系统时钟
	.RST_N					(rsi_reset_n		),	//系统复位
	.vga_data_en			(vga_data_en		),	//vga的数据使能信号
	.HSYNC					(coe_vga_hsync		),	//vga的行同步信号
	.VSYNC					(coe_vga_vsync		),	//vga的帧同步信号
	.vga_frame_start		(vga_frame_start	)	//vga的每一帧的开始位
);

zircon_avalon_vga_register	zircon_avalon_vga_register_init
(
	.csi_clk					(csi_clk				),	//系统时钟
	.rsi_reset_n			(rsi_reset_n		),	//系统复位
	.avs_address			(avs_address		),	//Avalon从端口地址总线
	.avs_write				(avs_write			),	//Avalon从端口写请求信号
	.avs_writedata			(avs_writedata		),	//Avalon从端口写数据总线
	
	.avm_address			(avm_address		),	//Avalon主端口地址总线
	.avm_byteenable		(avm_byteenable	),	//Avalon主端口字节使能信号
	.avm_read				(avm_read			),	//Avalon主端口读请求信号
	.avm_readdata			(avm_readdata		),	//Avalon主端口读数据总线
	.avm_waitrequest		(avm_waitrequest	),	//Avalon主端口等待信号
	.avm_readdatavalid	(avm_readdatavalid),	//Avalon主端口读数据有效信号
	
	.coe_vga_clk			(coe_vga_clk		),	//vga的系统时钟
	.coe_vga_rgb			(coe_vga_rgb		),	//vga的数据信号
	.vga_data_en			(vga_data_en		),	//vga的数据使能信号
	.vga_frame_start		(vga_frame_start	)	//vga的每一帧的开始位
);

endmodule
