module uart_tx
(
	input 			clk_50mhz,
	input 			rst_n,
	
	output 			rd_clk,
	output 			rd_en,
	input 			empty,
	input [7:0] 	din,
	
	output 			tx
);
	wire tx_clk;

	tx_clk_gen tx_clk_gen_ins
	(
		.clk_50mhz(clk_50mhz),
		.rst_n(rst_n),
		
		.tx_clk(tx_clk)
	);

	rs232_tx rs232_tx_ins
	(
		.clk_50mhz(clk_50mhz),
		.rst_n(rst_n),
		.tx_clk(tx_clk),
		//rs232总线发送
		.tx(tx),
		
		
		//fifo接口
		.rd_en(rd_en),
		.rd_clk(rd_clk),
		.din(din),
		.empty(empty)
	);

endmodule 