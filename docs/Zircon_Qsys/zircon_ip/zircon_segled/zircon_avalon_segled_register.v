module zircon_segled_register
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//用户逻辑输入与输出
	seg_data1,seg_data2,seg_data3,seg_data4,seg_data5,seg_data6
);
 
input 				csi_clk;		//系统时钟
input				rsi_reset_n;	//系统复位
input		[ 2:0]	avs_address;	//Avalon地址总线
input				avs_write;		//Avalon写请求信
input		[31:0]	avs_writedata;	//Avalon写数据总线

output reg	[ 3:0]	seg_data1;		//数码管数据寄存器0
reg			[ 3:0]	seg_data1_n;	//seg_data1的下一个状态
output reg	[ 3:0]	seg_data2;		//数码管数据寄存器1
reg			[ 3:0]	seg_data2_n;	//seg_data2的下一个状态
output reg	[ 3:0]	seg_data3;		//数码管数据寄存器2
reg			[ 3:0]	seg_data3_n;	//seg_data3的下一个状态
output reg	[ 3:0]	seg_data4;		//数码管数据寄存器3
reg			[ 3:0]	seg_data4_n;	//seg_data4的下一个状态
output reg	[ 3:0]	seg_data5;		//数码管数据寄存器4
reg			[ 3:0]	seg_data5_n;	//seg_data5的下一个状态
output reg	[ 3:0]	seg_data6;		//数码管数据寄存器5
reg			[ 3:0]	seg_data6_n;	//seg_data6的下一个状态

//时序电路，用于给数码管数据寄存器0进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data1 <= 4'hf;						//初始化数码管数据寄存器0
	else
		seg_data1 <= seg_data1_n;				//用来给数码管数据寄存器0赋值
end
	
//组合电路，用来给地址偏移量0，也就是我们的数码管数据寄存器0写4位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 3'b000))	//判断写使能和地址偏移量
		seg_data1_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器0
	else
		seg_data1_n = seg_data1;				//否则，将保持不变
end

//时序电路，用于给数码管数据寄存器1进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data2 <= 4'hf;						//初始化数码管数据寄存器1
	else
		seg_data2 <= seg_data2_n;				//用来给数码管数据寄存器1赋值
end
	
//组合电路，用来给地址偏移量1，也就是我们的数码管数据寄存器1写4位的数据
always @ (*)
begin	
	if((avs_write) && (avs_address == 3'b001))	//判断写使能和地址偏移量
		seg_data2_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器1
	else
		seg_data2_n = seg_data2;				//否则，将保持不变
end

//时序电路，用于给数码管数据寄存器2进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data3 <= 4'hf;						//初始化数码管数据寄存器2
	else
		seg_data3 <= seg_data3_n;				//用来给数码管数据寄存器2赋值
end
	
//组合电路，用来给地址偏移量2，也就是我们的数码管数据寄存器2写4位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 3'b010))	//判断写使能和地址偏移量
		seg_data3_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器2
	else
		seg_data3_n = seg_data3;				//否则，将保持不变
end

//时序电路，用于给数码管数据寄存器3进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data4 <= 4'hf;						//初始化数码管数据寄存器3
	else
		seg_data4 <= seg_data4_n;				//用来给数码管数据寄存器3赋值
end
	
//组合电路，用来给地址偏移量3，也就是我们的数码管数据寄存器3写4位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 3'b011))	//判断写使能和地址偏移量
		seg_data4_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器3
	else
		seg_data4_n = seg_data4;				//否则，将保持不变
end

//时序电路，用于给数码管数据寄存器4进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data5 <= 4'hf;						//初始化数码管数据寄存器4
	else
		seg_data5 <= seg_data5_n;				//用来给数码管数据寄存器4赋值
end
	
//组合电路，用来给地址偏移量4，也就是我们的数码管数据寄存器4写4位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 3'b100))	//判断写使能和地址偏移量
		seg_data5_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器4
	else
		seg_data5_n = seg_data5;				//否则，将保持不变
end

//时序电路，用于给数码管数据寄存器5进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)							//判断复位
		seg_data6 <= 4'hf;						//初始化数码管数据寄存器5
	else
		seg_data6 <= seg_data6_n;				//用来给数码管数据寄存器5赋值
end
	
//组合电路，用来给地址偏移量5，也就是我们的数码管数据寄存器5写4位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 3'b101))	//判断写使能和地址偏移量
		seg_data6_n = avs_writedata[3:0];		//如果条件成立，那么将写数据中的值赋值给数码管数据寄存器5
	else
		seg_data6_n = seg_data6;				//否则，将保持不变
end

endmodule
