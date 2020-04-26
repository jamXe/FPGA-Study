`timescale 1ns/1ps
`define time_period 20

module jsq4_2_tb();

	reg 	clk	;
	reg	rst_n	;
	reg	en		;
	wire	dout	;
	
	jsq4_2 U0(
		.clk(		clk	),
		.rst_n(	rst_n	),
		.en(		en		),
		.dout(	dout	)
	);
	
	initial clk = 1;
	always #( `time_period / 2 ) clk = ~clk;
	
	initial begin
		rst_n = 0;
		en = 0;
		#( `time_period * 5 );
		rst_n = 1;
		#( `time_period * 5 );
		
		en = 1;
		#( `time_period * 1 );
		en = 0;
		#( `time_period * 15 );
		
		en = 1;
		#( `time_period * 1 );
		en = 0;
		#( `time_period * 15 );
		
		$stop;
	end
endmodule

