//---------------------------------------------------------------------------
//--	文件名		:	A4_Segled1.v
//--	作者		:	ZIRCON
//--	描述		:	静态数码管显示,所有数码管全部数字8
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module A4_Segled1   //模块的开始
(
	//数码管数据引脚
	SEG_DATAa,SEG_DATAb,SEG_DATAc,SEG_DATAd,SEG_DATAe,SEG_DATAf,SEG_DATAg,SEG_DATADP,
	//数码管使能引脚
	SEG_EN1,SEG_EN2,SEG_EN3,SEG_EN4,SEG_EN5,SEG_EN6   
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
//将数码管数据位和数码管使能位声明为输出默认类型wire
output  SEG_DATAa,SEG_DATAb,SEG_DATAc,SEG_DATAd,SEG_DATAe,SEG_DATAf,SEG_DATAg,SEG_DATADP;
output  SEG_EN1,SEG_EN2,SEG_EN3,SEG_EN4,SEG_EN5,SEG_EN6;
//ouput [6:0] SEG_DATA; SEG_DATA[0]等价于SEG_DATAa …… SEG_DATA[7]等价于SEG_DATAg
//ouput [5:0] SEG;      SEG[0]等价于SEG1 …… SEG[5]等价于SEG6

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
//数码管显示0~F对应段选输出
parameter	SEG_NUM0 = 8'hbf,   //数字0
				SEG_NUM1 = 8'h86,   //数字1
				SEG_NUM2 = 8'hdb,   //数字2
				SEG_NUM3 = 8'hcf,   //数字3
				SEG_NUM4 = 8'he6,   //数字4
				SEG_NUM5 = 8'hed,   //数字5
				SEG_NUM6 = 8'hfd,   //数字6
				SEG_NUM7 = 8'h87,   //数字7
				SEG_NUM8 = 8'hff,   //数字8
				SEG_NUM9 = 8'hef,   //数字9
				SEG_NUMA = 8'hf7,   //数字A
				SEG_NUMB = 8'hfc,   //数字B
				SEG_NUMC = 8'hb9,   //数字C
				SEG_NUMD = 8'hde,   //数字D
				SEG_NUME = 8'hf9,   //数字E
				SEG_NUMF = 8'hf1;   //数字F
				
//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//给数码管数据位赋值，也可以这样写 SEG_DATA[7:0] = SEG_NUM8; 这样写是有前提的，要这样声明output [7:0] SEG_DATA;
assign {SEG_DATADP,SEG_DATAg,SEG_DATAf,SEG_DATAe,SEG_DATAd,SEG_DATAc,SEG_DATAb,SEG_DATAa} = SEG_NUM1;
//给数码管使能位赋值也可以这样写 SEG[5:0] = 6'b000000; 同上
assign {SEG_EN6,SEG_EN5,SEG_EN4,SEG_EN3,SEG_EN2,SEG_EN1} = 6'b000000;
    
endmodule				//模块的结束
