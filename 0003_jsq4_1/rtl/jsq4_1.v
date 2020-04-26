module jsq4_1( 
	clk	,
	rst_n	,
	en		,
	dout
);

	input 	clk	;
	input		rst_n	;
	input 	en		;
	
	output	dout	;
	
	reg	[3:0]	cnt		;
	wire			add_cnt	;
	wire			end_cnt	;
	reg			add_flag	;
	reg			dout		;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			cnt <= 0;
		end
		else if( add_cnt )begin
			if( end_cnt )
				cnt <= 0;
			else
				cnt <= cnt + 1;
		end
	end
	
	assign add_cnt = add_flag==1;
	assign end_cnt = add_cnt && cnt==9-1;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			add_flag <= 0;
		end
		else if( en )begin
			add_flag <= 1;
		end
		else if( end_cnt )begin
			add_flag <= 0;
		end
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			dout <= 0;
		end
		else if(add_cnt && (cnt==1-1 || cnt==4-1 || cnt==7-1) )begin
			dout <= 1;
		end
		else if( cnt==3-1 || cnt==6-1 || end_cnt )begin
			dout <= 0;
		end
	end
	
endmodule
