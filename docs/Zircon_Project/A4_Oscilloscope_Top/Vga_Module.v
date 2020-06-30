//---------------------------------------------------------------------------
//--	文件名		:	A4_Vga.v
//--	作者		:	ZIRCON
//--	描述		:	VGA显示彩条
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- VGA 800*600@60 
//-- VGA_DATA[7:0] red2,red1,red0,green2,green1,green0,blue1,blue0
//-- VGA CLOCK 40MHz.
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- Horizonal timing information
//-- Sync pluse   128  a
//-- back porch   88   b
//-- active       800  c
//-- front porch  40   d
//-- All line     1056 e
//-- Vertical timing information
//-- sync pluse   4    o
//-- back porch   23   p
//-- active time  600  q
//-- front porch  1    r
//-- All lines    628  s
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- Horizonal timing information
`define HSYNC_A   16'd128  // 128
`define HSYNC_B   16'd216  // 128 + 88
`define HSYNC_C   16'd1016 // 128 + 88 + 800
`define HSYNC_D   16'd1056 // 128 + 88 + 800 + 40
//-- Vertical  timing information
`define VSYNC_O   16'd4    // 4 
`define VSYNC_P   16'd27   // 4 + 23
`define VSYNC_Q   16'd627  // 4 + 23 + 600
`define VSYNC_R   16'd628  // 4 + 23 + 600 + 1
//---------------------------------------------------------------------------

module Vga_Module
(
	//输入端口
	CLK_40M,RST_N,vga_freq,vga_fengzhi,
	//输出端口
	VSYNC,HSYNC,VGA_DATA,vga_x,vga_y,ad_to_vga_data
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_40M;					//时钟的端口
input 				RST_N;					//复位的端口,低电平复位
input		[7:0]		ad_to_vga_data;		//VGA中显示的波形数据
input 	[31:0]	vga_freq;				//VGA中显示的频率值
input 	[31:0] 	vga_fengzhi;			//VGA中显示的峰峰值
output 				VSYNC;					//VGA垂直同步端口
output 				HSYNC;					//VGA水平同步端口
output  	[ 7:0]	VGA_DATA;				//VGA数据端口
output	[15:0] 	vga_x;					//VGA的x坐标
output 	[15:0] 	vga_y;					//VGA的y坐标
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg 		[15:0] 	hsync_cnt;				//水平扫描计数器
reg 		[15:0]	hsync_cnt_n;			//hsync_cnt的下一个状态
reg 		[15:0] 	vsync_cnt;				//垂直扫描计数器
reg 		[15:0] 	vsync_cnt_n;			//vsync_cnt的下一个状态
reg 		[ 7:0] 	VGA_DATA;				//RGB端口总线
reg 		[ 7:0] 	VGA_DATA_N;				//VGA_DATA的下一个状态
reg 					VSYNC;					//垂直同步端口	
reg					VSYNC_N;					//VSYNC的下一个状态
reg 					HSYNC;					//水平同步端口
reg					HSYNC_N;					//HSYNC的下一个状态
reg 					vga_data_en;			//RGB传输使能信号		
reg 					vga_data_en_n;			//vga_data_en的下一个状态
wire 		[15:0] 	rom_font_data;			//字库的数据位
reg  		[15:0] 	rom_font_addr;			//字库的地址位
reg  		[15:0] 	rom_font_addr_n;		//rom_font_addr的下一个状态

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路,用来给hsync_cnt寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		hsync_cnt <= 16'b0;					//初始化hsync_cnt值
	else
		hsync_cnt <= hsync_cnt_n;			//用来给hsync_cnt赋值
end

//组合电路,水平扫描
always @ (*)
begin
	if(hsync_cnt == `HSYNC_D)				//判断水平扫描时序
		hsync_cnt_n = 16'b0;					//如果水平扫描完毕,计数器将会被清零
	else
		hsync_cnt_n = hsync_cnt + 1'b1;	//如果水平没有扫描完毕,计数器继续累加
end

//时序电路,用来给vsync_cnt寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		vsync_cnt <= 16'b0;					//给行扫描赋值
	else
		vsync_cnt <= vsync_cnt_n;			//给行扫描赋值
end

//组合电路,垂直扫描
always @ (*)
begin
	if((vsync_cnt == `VSYNC_R) && (hsync_cnt == `HSYNC_D))//判断垂直扫描时序
		vsync_cnt_n = 16'b0;					//如果垂直扫描完毕,计数器将会被清零
	else if(hsync_cnt == `HSYNC_D)		//判断水平扫描时序
		vsync_cnt_n = vsync_cnt + 1'b1;	//如果水平扫描完毕,计数器继续累加
	else
		vsync_cnt_n = vsync_cnt;			//否则,计数器将保持不变
end

//时序电路,用来给HSYNC寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		HSYNC <= 1'b0;							//初始化HSYNC值
	else
		HSYNC <= HSYNC_N;						//用来给HSYNC赋值
end

//组合电路，将HSYNC_A区域置0,HSYNC_B+HSYNC_C+HSYNC_D置1
always @ (*)
begin	
	if(hsync_cnt < `HSYNC_A)				//判断水平扫描时序
		HSYNC_N = 1'b0;						//如果在HSYNC_A区域,那么置0
	else
		HSYNC_N = 1'b1;						//如果不在HSYNC_A区域,那么置1
end

//时序电路,用来给VSYNC寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		VSYNC <= 1'b0;							//初始化VSYNC值
	else
		VSYNC <= VSYNC_N;						//用来给VSYNC赋值
end

//组合电路，将VSYNC_A区域置0,VSYNC_P+VSYNC_Q+VSYNC_R置1
always @ (*)
begin	
	if(vsync_cnt < `VSYNC_O)				//判断水平扫描时序
		VSYNC_N = 1'b0;						//如果在VSYNC_O区域,那么置0
	else
		VSYNC_N = 1'b1;						//如果不在VSYNC_O区域,那么置1
end

//时序电路,用来给vga_data_en寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		vga_data_en <= 1'b0;					//初始化vga_data_en值
	else
		vga_data_en <= vga_data_en_n;		//用来给vga_data_en赋值
end

//组合电路，判断显示有效区（列像素>216&&列像素<1017&&行像素>27&&行像素<627）
always @ (*)
begin
	if((hsync_cnt > `HSYNC_B && hsync_cnt <`HSYNC_C) && 
		(vsync_cnt > `VSYNC_P && vsync_cnt < `VSYNC_Q))
		vga_data_en_n = 1'b1;				//如果在显示区域就给使能数据信号置1
	else
		vga_data_en_n = 1'b0;				//如果不在显示区域就给使能数据信号置0
end


//时序电路,用来给VGA_DATA寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		VGA_DATA <= 8'h0;						//初始化VGA_DATA值
	else
		VGA_DATA <= VGA_DATA_N;				//用来给VGA_DATA赋值
end

//例化ROM字库模块
ROM_Font_Module	ROM_Font_Init
(
	.address 		(rom_font_addr ),		//字库的地址位
	.clock 			(CLK_40M 		),		//字库的时钟
	.q 				(rom_font_data )		//字库的数据位
);

//判断数字显示的位置
assign rom_5v_en = (vga_y >= 10'd90) && (vga_y <= 10'd106) && (vga_x >= 10'd98) && (vga_x <= 10'd116);
assign rom_4_375v_en = (vga_y >= 10'd122) && (vga_y <= 10'd138) && (vga_x >= 10'd66) && (vga_x <= 10'd116);
assign rom_3_75v_en = (vga_y >= 10'd154) && (vga_y <= 10'd170) && (vga_x >= 10'd74) && (vga_x <= 10'd116);
assign rom_3_125v_en = (vga_y >= 10'd186) && (vga_y <= 10'd203) && (vga_x >= 10'd66) && (vga_x <= 10'd116);
assign rom_2_5v_en = (vga_y >= 10'd218) && (vga_y <= 10'd234) && (vga_x >= 10'd82) && (vga_x <= 10'd116);

assign rom_1_875v_en = (vga_y >= 10'd250) && (vga_y <= 10'd266) && (vga_x >= 10'd66) && (vga_x <= 10'd116);
assign rom_1_25v_en = (vga_y >= 10'd282) && (vga_y <= 10'd298) && (vga_x >= 10'd74) && (vga_x <= 10'd116);
assign rom_0_625v_en = (vga_y >= 10'd314) && (vga_y <= 10'd330) && (vga_x >= 10'd66) && (vga_x <= 10'd116);
assign rom_0v_en = (vga_y >= 10'd346) && (vga_y <= 10'd362) && (vga_x >= 10'd98) && (vga_x <= 10'd116);

assign rom_pinlv_en = (vga_y > 10'd490) && (vga_y < 10'd507) && (vga_x >= 10'd130) && (vga_x <= 10'd176);
assign rom_500hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd220);
assign rom_333hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd220);
assign rom_833hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd220);
assign rom_166hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd220);
assign rom_666hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd220);
assign rom_1khz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd212);

assign rom_2000hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd214);
assign rom_1833hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd230);
assign rom_1666hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd230);
assign rom_1500hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd230);
assign rom_1333hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd230);
assign rom_1166hz_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd180) && (vga_x <= 10'd230);

assign rom_26v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_25v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_24v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_23v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_22v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_21v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_20v_en = (vga_y >= 10'd490) && (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd516);
assign rom_fengzhi_0v_en = (vga_y >= 10'd490) & (vga_y <= 10'd506) && (vga_x >= 10'd482) & (vga_x <= 10'd500);
assign rom_fengzhi_en = (vga_y >= 10'd490) & (vga_y <= 10'd506) & (vga_x >= 10'd416) & (vga_x <= 10'd482);


//时序电路,用来给rom_font_addr寄存器赋值
always @ (posedge CLK_40M or negedge RST_N)
begin
	if(!RST_N) 
		rom_font_addr <= 8'd0;
	else
		rom_font_addr <= rom_font_addr_n;
end

//组合电路,用于生成字库的地址位
always @ (*)
begin
	if(rom_5v_en)
	begin
		if(vga_x == 10'd98) 
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_4_375v_en)
	begin
		if(vga_x == 10'd66) 
			rom_font_addr_n = 8'h20;
		else if(vga_x == 10'd74)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h38;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_3_75v_en)
	begin
		if(vga_x == 10'd74) 
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h38;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_3_125v_en)
	begin
		if(vga_x == 10'd66) 
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd74)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_2_5v_en)
	begin
		if(vga_x == 10'd82)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1_875v_en)
	begin
		if(vga_x == 10'd66) 
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd74)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h40;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h38;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1_25v_en)
	begin
		if(vga_x == 10'd74) 
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_0_625v_en)
	begin
		if(vga_x == 10'd66) 
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd74)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd82)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd90)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd98)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_0v_en)
	begin
		if(vga_x == 10'd98) 
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd106)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	
	else if(rom_166hz_en && (vga_freq == 10'd166))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_333hz_en && (vga_freq == 10'd333))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_500hz_en && (vga_freq == 10'd500))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_666hz_en && (vga_freq == 10'd666))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_833hz_en && (vga_freq == 10'd833))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h40;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1khz_en && (vga_freq == 10'd1000))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 12'h0a0;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1166hz_en && (vga_freq == 32'd1166))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 10'h8;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd220)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1333hz_en && (vga_freq == 32'd1333))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 10'h18;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd220)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1500hz_en && (vga_freq == 32'd1500))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 10'h28;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd220)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1666hz_en && (vga_freq == 32'd1666))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 10'h30;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd220)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_1833hz_en && (vga_freq == 32'd1833))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 10'h40;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd212)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd220)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_2000hz_en && (vga_freq == 32'd2000))
	begin
		if(vga_x == 10'd180)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd188)
			rom_font_addr_n = 12'h0a0;
		else if(vga_x == 10'd196)
			rom_font_addr_n = 8'h90;
		else if(vga_x == 10'd204)
			rom_font_addr_n = 8'h98;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_26v_en) && (vga_fengzhi == 10'd26))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h30;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_25v_en) && (vga_fengzhi == 10'd25))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h28;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_24v_en) && (vga_fengzhi == 10'd24))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h20;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_23v_en) && (vga_fengzhi == 10'd23))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h18;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_22v_en) && (vga_fengzhi == 10'd22))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_21v_en) && (vga_fengzhi == 10'd21))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h8;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_20v_en) && (vga_fengzhi == 10'd20))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h10;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h50;
		else if(vga_x == 10'd498)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd506)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if((rom_fengzhi_0v_en) && (vga_fengzhi == 10'd0))
	begin
		if(vga_x == 10'd482)
			rom_font_addr_n = 8'h0;
		else if(vga_x == 10'd490)
			rom_font_addr_n = 8'h58;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_pinlv_en)
	begin
		if(vga_x == 10'd130)
			rom_font_addr_n = 8'h60;
		else if(vga_x == 10'd146)
			rom_font_addr_n = 8'h70;
		else if(vga_x == 10'd162)
			rom_font_addr_n = 8'h80;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else if(rom_fengzhi_en)
	begin
		if(vga_x == 10'd416)
			rom_font_addr_n = 8'ha8;
		else if(vga_x == 10'd432)
			rom_font_addr_n = 8'hb8;
		else if(vga_x == 10'd448)
			rom_font_addr_n = 8'hc8;
		else if(vga_x == 10'd464)
			rom_font_addr_n = 8'hd8;
		else 
			rom_font_addr_n = rom_font_addr + 1'b1;
	end
	else
		rom_font_addr_n <= 15'b0;;
end

//组合电路，判断字符显示的位置并进行显示
always @ (*)
begin
	if(vga_data_en)
	begin
		if( (vga_x >= 10'd128 && vga_x <= 10'd704) && (vga_y >= 10'd96 && vga_y <= 10'd480) )
			begin
				if(vga_y - 10'd97 == (ad_to_vga_data ))	//显示波形
						VGA_DATA_N = 10'd253;
				else if((10'd0 == (vga_y % 10'd5)) && (10'd0 == (vga_x % 10'd32)))	//画虚线
						VGA_DATA_N = 10'd208;
				else if((10'd0 == (vga_y % 10'd32)) && (10'd0 == (vga_x % 10'd5)))	//画虚线
						VGA_DATA_N = 10'd208;
				else if((vga_y == 10'd96 || vga_y == 10'd480) && (vga_x >= 10'd96 && vga_x <= 10'd704)) //上下线
						VGA_DATA_N = 10'd208;
				else if((vga_x == 10'd128 || vga_x == 704) && (vga_y >= 96 && vga_y <= 480)) //左右线
						VGA_DATA_N = 10'd208;
				else if(vga_y == 10'd352 && vga_x >= 10'd96 && vga_x <= 10'd704)  //X轴
						VGA_DATA_N = 10'he0;
				else if(vga_x == 416 && vga_y >= 10'd96 && vga_y <= 10'd480)     //Y轴
						VGA_DATA_N = 10'he0;	
				else	
						VGA_DATA_N = 8'h08;			
			end
		else if(rom_5v_en)	//在屏幕上显示5V
			begin
				if(rom_font_data[10'd106 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_4_375v_en)	//在屏幕上显示4.375V
			begin
				if(rom_font_data[10'd138 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_3_75v_en)	//在屏幕上显示3.75V
			begin
				if(rom_font_data[10'd170 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_3_125v_en)	//在屏幕上显示3.125V
			begin
				if(rom_font_data[10'd202 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_2_5v_en) //在屏幕上显示2.5V
			begin
				if(rom_font_data[10'd234 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_1_875v_en) //在屏幕上显示1.875V
			begin
				if(rom_font_data[10'd266 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_1_25v_en) //在屏幕上显示1.25V
			begin
				if(rom_font_data[10'd298 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_0_625v_en) //在屏幕上显示0.625V
			begin
				if(rom_font_data[10'd330 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_0v_en) //在屏幕上显示0V
			begin
				if(rom_font_data[10'd362 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if(rom_pinlv_en) //在屏幕上显示频率两个字
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_500hz_en) && (vga_freq == 10'd500)) //在屏幕上显示500hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end 
		else if((rom_333hz_en) && (vga_freq == 10'd333)) //在屏幕上显示333hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_166hz_en) && (vga_freq == 10'd166)) //在屏幕上显示166hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_666hz_en) && (vga_freq == 10'd666)) //在屏幕上显示666hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_833hz_en) && (vga_freq == 10'd833)) //在屏幕上显示833hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1khz_en) && (vga_freq == 32'd1000)) //在屏幕上显示1khz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1166hz_en) && (vga_freq == 32'd1166)) //在屏幕上显示1166hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1333hz_en) && (vga_freq == 32'd1333)) //在屏幕上显示1333hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1500hz_en) && (vga_freq == 32'd1500)) //在屏幕上显示1500hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1666hz_en) && (vga_freq == 32'd1666)) //在屏幕上显示1666hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_1833hz_en) && (vga_freq == 32'd1833)) //在屏幕上显示1833hz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_2000hz_en) && (vga_freq == 32'd2000)) //在屏幕上显示2khz
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
				
		else if((rom_fengzhi_en)) //在屏幕上显示峰峰值3个字
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_26v_en) && (vga_fengzhi == 10'd26)) //在屏幕上显示2.6V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_25v_en) && (vga_fengzhi == 10'd25)) //在屏幕上显示2.5V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_24v_en) && (vga_fengzhi == 10'd24)) //在屏幕上显示2.4V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_23v_en) && (vga_fengzhi == 10'd23)) //在屏幕上显示2.3V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_22v_en) && (vga_fengzhi == 10'd22)) //在屏幕上显示2.2V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_21v_en) && (vga_fengzhi == 10'd21)) //在屏幕上显示2.1V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_20v_en) && (vga_fengzhi == 10'd20)) //在屏幕上显示2.0V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else if((rom_fengzhi_0v_en) && (vga_fengzhi == 10'd0)) //在屏幕上显示0V
			begin
				if(rom_font_data[10'd506 - vga_y])
					VGA_DATA_N = 10'd253;
				else
					VGA_DATA_N = 8'h03;
			end
		else
			VGA_DATA_N = 8'h03;								
	end
	else
		VGA_DATA_N = 8'h0;	
end

assign vga_x = hsync_cnt - `HSYNC_B;
assign vga_y = vsync_cnt - `VSYNC_P;


endmodule



