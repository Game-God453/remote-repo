module tx_clk_gen
(
	input 		clk_50mhz,
	input 		rst_n,
	
	output 		tx_clk
);

	parameter FSYS_CLK  =50_000_000;
	parameter BAND_SET	=115200;

	reg [8:0]div_cnt;

	always @(posedge clk_50mhz  or negedge rst_n)
		   if(~rst_n)
				div_cnt<=9'd0;
		   else if(div_cnt==((FSYS_CLK/BAND_SET)-1'b1) )
				div_cnt<=9'd0;
		   else 
				div_cnt<=div_cnt+1'b1;
				
				
	assign 	tx_clk=	(div_cnt==(FSYS_CLK/BAND_SET)-1'b1 )?1'b1:1'b0;

endmodule 