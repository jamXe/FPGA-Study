module jsq4_2(
	clk	,
	rst_n	,
	en		,
	dout	
);
	input 	clk	;
	input		rst_n	;
	input		en		;
	
	output	dout	;
	
	reg	[1:0]		cnt0		;
	wire				add_cnt0	;
	wire				end_cnt0	;
	reg				add_flag	;
	
	reg	[1:0]		cnt1		;
	wire				add_cnt1	;
	wire				end_cnt1	;
	
	reg				dout		;
	
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
	
	assign add_cnt0 = add_flag==1;
	assign end_cnt0 = add_cnt0 && cnt0==3-1;
	
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
	assign end_cnt1 = add_cnt1 && cnt1==3-1;
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			add_flag <= 0;
		end
		else if(en)begin
			add_flag <= 1;
		end
		else if(end_cnt1)begin
			add_flag <= 0;
		end
	end
	
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )begin
			dout <= 0;
		end
		else if(add_cnt0 && cnt0==1-1)begin
			dout <= 1;
		end
		else if(end_cnt0)begin
			dout <= 0;
		end
	end

endmodule
