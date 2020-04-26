
`timescale 1ns/1ps
`define time_period 20

module breath_led_tb();

	reg	clk	;
	reg	rst_n	;
	
	wire		led0	;
	wire		led1	;
	wire		led2	;
	wire		led3	;

	breath_led #( .COUNTER_1S(5) ) U0(
		.clk(		clk	),
		.rst_n(	rst_n	),
		.led0(	led0	),
		.led1(	led1	),
		.led2(	led2	),
		.led3(	led3	)
	);
	
	initial begin
		clk = 1;
		rst_n = 0;
	end
	always #( `time_period / 2 ) clk = ~clk;
	
	initial begin
		rst_n = 0;
		#( `time_period * 5 );
		rst_n = 1;
		#( `time_period * 5 );
		
		#( `time_period * 500 );
		
		$stop;
	end
	
endmodule
