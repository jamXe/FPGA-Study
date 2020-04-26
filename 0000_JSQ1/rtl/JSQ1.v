module JSQ1(
	clk,
	rst_n,
	
	en,
	dout
);

	input		clk	;
	input		rst_n	;
	input		en		;
	output	dout	;
	
	reg	[3:0]	cnt		;
	wire			add_cnt	;
	wire			end_cnt	;
	reg			dout		;
	
always @( posedge clk or negedge rst_n ) begin
	if( rst_n == 0 ) begin
		cnt <= 0;
	end
	else if(add_cnt) begin
		if(end_cnt)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end
end

assign add_cnt = dout==1;
assign end_cnt = add_cnt && cnt== 10-1;

always @( posedge clk or negedge rst_n ) begin
	if(rst_n == 1'b0) begin
		dout <= 0;
	end
	else if(en==1) begin
		dout <= 1;
	end
	else if( end_cnt ) begin
		dout <= 0;
	end
end

endmodule
