module jsq2(
	clk		,
	rst_n		,
	
	en			,
	dout		
);

	input		clk	;
	input		rst_n	;
	input		en		;
	
	output	dout	;
	
	reg		dout	;
	
	reg	[2:0]	cnt	;
	reg			add_flag	;
	wire			add_cnt	;
	wire			end_cnt	;
	
	// counter

	always @( posedge clk or negedge rst_n )begin
		if(!rst_n)	begin
			cnt <= 0;
		end
		else if( add_cnt ) begin
			if( end_cnt )
				cnt <= 0;
			else
				cnt <= cnt + 1;
		end
	end

	assign add_cnt = add_flag==1;
	assign end_cnt	= add_cnt && cnt==5-1;

	// signal add_flag
	always @( posedge clk or negedge rst_n )begin
		if( !rst_n )	begin
			add_flag	<=	1'b0;
		end
		else if(	en==1	)begin
			add_flag	<=	1;
		end
		else if( end_cnt==1 )begin
			add_flag	<= 0;
		end
	end

	// signal dout
	always @( posedge clk or negedge rst_n )begin
		if(!rst_n)begin
			dout <= 0;
		end
		else if( cnt==3-1 )begin
			dout <= 1;
		end
		else if(end_cnt)begin
			dout <= 0;
		end
	end

endmodule

