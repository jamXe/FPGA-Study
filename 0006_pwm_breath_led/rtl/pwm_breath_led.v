
module pwm_breath_led(
	clk		,
	rst_n		,
	led		
);
	input		clk	;
	input		rst_n	;
	output	led	;
	
	reg		led	;
	reg	[18:0]	cnt_pwm		;
	wire				add_cnt_pwm	;
	wire				end_cnt_pwm	;
	
	// 10ms counter for pwm cycles
	parameter PWM_CYCLE = 500_000;
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_pwm <= 0;
		end
		else if( add_cnt_pwm )begin
			if( end_cnt_pwm )
				cnt_pwm <= 0;
			else
				cnt_pwm <= cnt_pwm + 1;
		end
	end
	assign add_cnt_pwm = 1;
	assign end_cnt_pwm = add_cnt_pwm && cnt_pwm==PWM_CYCLE-1;

	reg	[7:0]		cnt_second		;
	wire				add_cnt_second	;
	wire				end_cnt_second	;
	// how many 10ms cycles in 2s counter
	parameter PWM_SECOND_IN_CYCLE = 15;	// 50=0.5s 100=1s 200=2s
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_second <= 0;
		end
		else if( add_cnt_second )begin
			if( end_cnt_second )
				cnt_second <= 0;
			else
				cnt_second <= cnt_second + 1;
		end
	end
	assign add_cnt_second = end_cnt_pwm==1;
	assign end_cnt_second = add_cnt_second && cnt_second==PWM_SECOND_IN_CYCLE-1;

	reg	[7:0]		cnt_breath		;
	wire				add_cnt_breath	;
	wire				end_cnt_breath	;
		
	// counter 10 time to change pwm 
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt_breath <= 0;
		end
		else if( add_cnt_breath )begin
			if( end_cnt_breath )
				cnt_breath <= 0;
			else
				cnt_breath <= cnt_breath + 1;
		end
	end
	assign add_cnt_breath = end_cnt_second==1;
	assign end_cnt_breath = add_cnt_breath && cnt_breath==10-1;
	
	// breath led control
	reg	[18:0]	x_pwm		;
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			led <= 1;	// led off
		end
		else if( add_cnt_pwm && cnt_pwm==x_pwm-1 )begin
			led <= 0;	// led on
		end
		else if( end_cnt_pwm )begin
			led <= 1;	// led off
		end
	end
	
	// 占空比数值计算
	always @(*)begin
		if(cnt_breath==0)
			x_pwm = 450_000;	// 90%
		else if(cnt_breath==1)
			x_pwm = 375_000;	// 75%
		else if(cnt_breath==2)
			x_pwm = 275_000;	// 55%
		else if(cnt_breath==3)
			x_pwm = 175_000;	//	35%
		else if(cnt_breath==4)
			x_pwm = 75_000;	// 15%
		else if(cnt_breath==5)
			x_pwm = 125_000;	// 25%
		else if(cnt_breath==6)
			x_pwm = 225_000;	// 45%
		else if(cnt_breath==7)
			x_pwm = 325_000;	// 65%
		else if(cnt_breath==8)
			x_pwm = 425_000;	// 85%
		else if(cnt_breath==9)
			x_pwm = 475_000;	//95%
	end
	
	
endmodule
