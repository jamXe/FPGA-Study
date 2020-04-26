module led_flash(
	clk		,
	rst_n		,
	led		
);

	input 	clk	;
	input		rst_n	;
	output	led	;
	
	reg	[28:0]	cnt0		;
	wire 				add_cnt0	;
	wire				end_cnt0	;
	
	reg	[3:0]		cnt1		;
	wire				add_cnt1	;
	wire				end_cnt1	;
	
	reg	[28:0]	x			;
	
	reg				led		;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt0 <= 0;
		end
		else if( add_cnt0 )begin
			if( end_cnt0 )
				cnt0 <= 0;
			else
				cnt0 <= cnt0 + 1;
		end
	end
	
	assign add_cnt0 = 1;
	assign end_cnt0 = add_cnt0 && cnt0==x-1;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt1 <= 0;
		end
		else if( add_cnt1 )begin
			if( end_cnt1 )
				cnt1 <= 0;
			else
				cnt1 <= cnt1 + 1;
		end
		
	end
	
	assign add_cnt1 = end_cnt0==1;
	assign end_cnt1 = add_cnt1 && cnt1==9-1;
	
	always@(*)begin
		if( cnt1==0 )
			x = 100_000_000;
		else if( cnt1==1 )
			x = 150_000_000;
		else if( cnt1==2 )
			x = 200_000_000;
		else if( cnt1==3 )
			x = 250_000_000;
		else if( cnt1==4 )
			x = 300_000_000;
		else if( cnt1==5 )
			x = 350_000_000;
		else if( cnt1==6 )
			x = 400_000_000;
		else if( cnt1==7 )
			x = 450_000_000;
		else if( cnt1==8 )
			x = 500_000_000;
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led <= 1;	// led off
		end
		else if( add_cnt0 && cnt0==50_000_000-1 )begin
			led <= 0;	// led on
		end
		else if( end_cnt0 )begin
			led <= 1;	// led off
		end
	end

endmodule
