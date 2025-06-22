module rx_clk_gen
(
	input 			clk_50mhz,
	input 			rst_n,
	output reg 		clk_rx


);
	parameter FSYS_CLK =50_000_000;
	parameter BAND_SET =115200*9;

	reg [4:0] div_cnt;
	always @(posedge clk_50mhz or negedge rst_n)
		   if(~rst_n)
				div_cnt<=5'd0;
		 else if(div_cnt==(FSYS_CLK/BAND_SET)/2-1'b1)
				div_cnt<=5'd0;
		 else
				div_cnt<=div_cnt+1'b1;

	always @(posedge clk_50mhz or negedge rst_n)
		   if(~rst_n)
				clk_rx<=1'b0;
		 else if(div_cnt==(FSYS_CLK/BAND_SET)/2-1'b1)
				clk_rx<=~clk_rx;
		 else
				clk_rx<=clk_rx;


endmodule 