`timescale 1ns/1ps
`define time_period 20
module jsq3_tb();

	reg 		clk	;
	reg		rst_n	;
	reg 		en1	;
	reg 		en2	;
	wire		dout	;
	
	jsq3 U0(
		.clk(		clk	),
		.rst_n(	rst_n	),
		.en1(		en1	),
		.en2(		en2	),
		.dout(	dout	)
	);

	initial clk = 1;
	always #( `time_period / 2 ) clk = ~clk;
	
	initial begin
		rst_n = 0;
		en1 = 0;
		en2 = 0;
		#( `time_period * 5 );
		rst_n = 1;
		#( `time_period * 1 );
		
		en1 = 1;
		#( `time_period * 1 );
		en1 = 0;
		#( `time_period * 10 );
		
		en2 = 1;
		#( `time_period * 1 );
		en2 = 0;
		#( `time_period * 10 );
		
		$stop;
	end
	
endmodule
