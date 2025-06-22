module 		uart
(
			input 			clk_50mhz,
			input 			rst_n,
			output 			tx,
			input 			rx,
			
			output          done,
			output          done_v1,
			
			output			no,
			input 			wr_clk,
			input [127:0]	     wrdata,
			output 			full,
			
			input 			rd_clk,
			input 			rd_en,
			output 			empty,
			output [127:0]  rddata
);
	wire wr_en_in;
	wire wr_clk_in;
	wire [7:0]dout_in; 
	wire full_in;
	 
	wire rd_clk_in;
	wire rd_en_in;
	wire empty_in;
	assign no= empty_in & empty;
	wire [7:0] din_in;
	wire [7:0] din_in_v1;
	wire wr_en;

	wire   [7:0]   data_v1; 

	shift128to8 shift128to8_dut(
		.clk        (wr_clk),
		.rst        (~rst_n),
		.data_in    (wrdata),
		.data_valid (done),
		.fifo_full  (full),
		.fifo_data  (din_in),
		.fifo_wr_en (wr_en)
	);

	shift8to128 shift8to128_dut(
		.clk        (rd_clk),
		.rst_n      (rst_n),
		.wr_en      (rd_en),       
		.data_in    (data_v1),
		.data_out   (rddata),
		.done       (done_v1)
	);

	fifo_generator_0 rvfifo_ins(
	  .wr_clk   	(wr_clk_in),
	  .rd_clk   	(rd_clk),
	  .din      	(dout_in),
	  .wr_en    	(wr_en_in),
	  .rd_en    	(rd_en),
	  .dout     	(data_v1),
	  .full     	(full_in),
	  .empty    	(empty)
	);
		
	fifo_generator_1 txfifo_ins(
	  .wr_clk   	(wr_clk),
	  .rd_clk   	(rd_clk_in),
	  .din      	(din_in),
	  .wr_en    	(wr_en),
	  .rd_en    	(rd_en_in),
	  .dout     	(din_in_v1),
	  .full     	(full),
	  .empty    	(empty_in)
	);

	uart_rx uart_rx_ins
	(
	  .clk_50mhz	(clk_50mhz),
	  .rst_n		(rst_n),
	  
	  .rx			(rx),
	  
	  .wr_en		(wr_en_in),
	  .wr_clk		(wr_clk_in),
	  .dout			(dout_in),
	  .full			(full_in)

	);

	uart_tx uart_tx_ins
	(
	  .clk_50mhz	(clk_50mhz),
	  .rst_n		(rst_n),
	  
	  .rd_clk		(rd_clk_in),
	  .rd_en		(rd_en_in),
	  .empty		(empty_in),
	  .din			(din_in_v1),
	  
	  .tx			(tx)
	);
	
endmodule 