module jsq3(
	clk	,
	rst_n	,
	en1	,
	en2	,
	dout	
);

	input 	clk	;
	input		rst_n	;
	input		en1	;
	input 	en2	;
	
	output	dout	;
	
	reg 	[2:0]		cnt		;
	wire				add_flag	;
	wire				end_cnt	;
//	reg				sel_falg	;
	reg	[2:0]		x			;
	reg 				dout		;
	
	always@( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt <= 0;
		end
		else if( add_flag )begin
			if( end_cnt )
				cnt <= 0;
			else
				cnt <= cnt + 1;
		end
	end
	
	assign add_flag = dout==1;
	assign end_cnt = add_flag && cnt == x-1;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
//			sel_falg <= 0;
			x <= 2;
		end
		else if( en1 )begin
//			sel_falg <= 1;
			x <= 3;
		end
		else if( en2 )begin
//			sel_falg <= 0;
			x <= 2;
		end
	end
	
//	always @(*)begin
//		if(sel_falg==1)
//			x = 3;
//		else
//			x = 2;
//	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			dout <= 0;
		end
		else if( en1 || en2 )begin
			dout <= 1;
		end
		else if( end_cnt )begin
			dout <= 0;
		end
	end

endmodule

