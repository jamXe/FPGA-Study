
module breath_led(
	clk		,
	rst_n		,
	led0		,
	led1		,
	led2		,
	led3
);
	input		clk	;
	input		rst_n	;
	output	led0	;
	output	led1	;
	output	led2	;
	output	led3	;
	
	reg		led0	;
	reg		led1	;
	reg		led2	;
	reg		led3	;
	
	reg	[25:0]	cnt_1s		;
	wire				add_cnt_1s	;
	wire				end_cnt_1s	;
	
	reg	[2:0]		cnt_breath_led			;
	wire				end_cnt_breath_led	;
	wire				add_cnt_breath_led	;
	
	reg	[2:0]		cnt_breath_led_number		;
	wire				add_cnt_breath_led_number	;
	wire				end_cnt_breath_led_number	;
	
	reg 	[3:0]		x_breath_led_number	;
	
	// 1 second counter 
	parameter COUNTER_1S = 50_000_000;		// 50Mhz is 50_000_000 tick times
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_1s <= 0;
		end
		else if( add_cnt_1s )begin
			if( end_cnt_1s )
				cnt_1s <= 0;
			else
				cnt_1s <= cnt_1s + 1;
		end
	end
	assign add_cnt_1s = 1;
	assign end_cnt_1s = add_cnt_1s && cnt_1s==COUNTER_1S-1;
	
	// breath_led time counter
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_breath_led <= 0;
		end
		else if( add_cnt_breath_led )begin
			if( end_cnt_breath_led )
				cnt_breath_led <= 0;
			else
				cnt_breath_led <= cnt_breath_led + 1;
		end
	end
	
	assign add_cnt_breath_led = end_cnt_1s==1;
	assign end_cnt_breath_led = add_cnt_breath_led && cnt_breath_led==x_breath_led_number-1;
	
	// breath led number counter
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_breath_led_number <= 0;
		end
		else if( add_cnt_breath_led_number )begin
			if( end_cnt_breath_led_number )
				cnt_breath_led_number <= 0;
			else
				cnt_breath_led_number <= cnt_breath_led_number + 1;
		end
	end
	assign add_cnt_breath_led_number = end_cnt_breath_led==1;
	assign end_cnt_breath_led_number = add_cnt_breath_led_number && cnt_breath_led_number==4-1;
	
	always @( * )begin
		if( cnt_breath_led_number==0 )begin
			x_breath_led_number = 2;
		end
		else if( cnt_breath_led_number==1 )begin
			x_breath_led_number = 3;
		end 
		else if( cnt_breath_led_number==2 )begin
			x_breath_led_number = 4;
		end 
		else if( cnt_breath_led_number==3 )begin
			x_breath_led_number = 5;
		end 
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led0 <= 1;	// led off
		end
		else if( add_cnt_breath_led && cnt_breath_led==1-1 && cnt_breath_led_number==0 )begin
			led0 <= 0; // led on
		end
		else if( end_cnt_breath_led && cnt_breath_led_number==0 )begin
			led0 <= 1; // led off
		end
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led1 <= 1;	// led off
		end
		else if( add_cnt_breath_led && cnt_breath_led==1-1 && cnt_breath_led_number==1 )begin
			led1 <= 0; // led on
		end
		else if( end_cnt_breath_led && cnt_breath_led_number==1 )begin
			led1 <= 1; // led off
		end
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led2 <= 1;	// led off
		end
		else if( add_cnt_breath_led && cnt_breath_led==1-1 && cnt_breath_led_number==2 )begin
			led2 <= 0; // led on
		end
		else if( end_cnt_breath_led && cnt_breath_led_number==2 )begin
			led2 <= 1; // led off
		end
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led3 <= 1;	// led off
		end
		else if( add_cnt_breath_led && cnt_breath_led==1-1 && cnt_breath_led_number==3 )begin
			led3 <= 0; // led on
		end
		else if( end_cnt_breath_led && cnt_breath_led_number==3 )begin
			led3 <= 1; // led off
		end
	end

endmodule
