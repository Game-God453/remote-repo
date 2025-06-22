module rs232_tx
(
		input 		clk_50mhz,
		input 		rst_n,
		input 		tx_clk,
		//rs232总线发送
		output reg 	tx,
		
		
		//fifo接口
		output 		rd_en,
		output 		rd_clk,
		input [7:0] din,
		input 		empty
);

	parameter IDLE_T 	=4'd0,
			  START_T	=4'd1,
			  BIT0_T	=4'd2,
			  BIT1_T	=4'd3,
			  BIT2_T	=4'd4,
			  BIT3_T	=4'd5,
			  BIT4_T	=4'd6,
			  BIT5_T	=4'd7,
			  BIT6_T	=4'd8,
			  BIT7_T	=4'd9,
			  END_T		=4'd10;

	reg [3:0] state;
	always @(posedge clk_50mhz or negedge rst_n)
		   if(~rst_n)
				state<=IDLE_T;
		   else case(state)
				IDLE_T:if((~empty)&&(tx_clk))
							state<=START_T;
					   else
							state<=IDLE_T;
				
				START_T:if(tx_clk)
							state<=BIT0_T;
				BIT0_T:if(tx_clk)
							state<=BIT1_T;
				BIT1_T:if(tx_clk)
							state<=BIT2_T;
				BIT2_T:if(tx_clk)
							state<=BIT3_T;
				BIT3_T:if(tx_clk)
							state<=BIT4_T;
				BIT4_T:if(tx_clk)
							state<=BIT5_T;
				BIT5_T:if(tx_clk)
							state<=BIT6_T;
				BIT6_T:if(tx_clk)
							state<=BIT7_T;
				BIT7_T:if(tx_clk)
							state<=END_T;
				END_T:if(tx_clk)
							state<=IDLE_T;
				default:state<=IDLE_T;
			endcase
	reg [7:0]tx_buf;			
	always @(posedge clk_50mhz or negedge rst_n)
		   if(~rst_n)begin
				tx<=1'b1;
				tx_buf<=8'd0;
		   end else case(state)
				START_T:begin
						tx<=1'b0;
						if(tx_clk)
							tx_buf<=din;
						end	
				BIT0_T:tx<=tx_buf[0];
				BIT1_T:tx<=tx_buf[1];
				BIT2_T:tx<=tx_buf[2];
				BIT3_T:tx<=tx_buf[3];
				BIT4_T:tx<=tx_buf[4];
				BIT5_T:tx<=tx_buf[5];
				BIT6_T:tx<=tx_buf[6];
				BIT7_T:tx<=tx_buf[7];
				END_T:tx<=1'b1;
				default:begin tx<=1'b1;tx_buf<=tx_buf;end
			endcase

	//fifo读
	assign 	rd_clk=clk_50mhz;
	assign   rd_en=((state==IDLE_T)&&(~empty)	&& tx_clk )?1'b1:1'b0;

endmodule 