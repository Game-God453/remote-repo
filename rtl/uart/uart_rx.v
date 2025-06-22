module uart_rx
(
	 input 			clk_50mhz,
	 input 			rst_n,
	 
	 input 			rx,
	 
	 output 		wr_en,
	 output 		wr_clk,
	 output [7:0]	dout,
	 input 			full
);

	wire clk_rx;

	rx_clk_gen rx_clk_gen_ins
	(
		.clk_50mhz(clk_50mhz),
		.rst_n(rst_n),
		.clk_rx(clk_rx)
	);

	rs232_rx rs232_rx_ins
	(
		.clk_rx(clk_rx),
		.rst_n(rst_n),
			
			
		.rx(rx),
		   
		.wr_en(wr_en),
		.wr_clk(wr_clk),
		.dout(dout),
		.full(full)
	);

endmodule 