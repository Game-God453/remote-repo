module rs232_rx
(
		input clk_rx,
		input rst_n,
		
		
	   input rx,
	   
	   output wr_en,
	   output wr_clk,
	   output  [7:0]dout,
	   input full

);
	//同步处理
	reg rx_r2,rx_r1;
	wire fall_rx;
	always @(posedge clk_rx)begin
			rx_r1<=rx;
			rx_r2<=rx_r1;
			
	end
	
	assign fall_rx=rx_r2 & (~rx_r1);

	parameter IDLE_R	=4'd0,
			  START_R	=4'd1,
			  BIT0_R	=4'd2,
			  BIT1_R	=4'd3,
			  BIT2_R	=4'd4,
			  BIT3_R	=4'd5,
			  BIT4_R	=4'd6,
			  BIT5_R	=4'd7,
			  BIT6_R	=4'd8,
			  BIT7_R	=4'd9,
			  END_R		=4'd10;
	reg [3:0]state;	
	reg [3:0] counter;
	
	always @(posedge clk_rx  or negedge rst_n)
		   if(~rst_n)
				state<=IDLE_R;
		   else case(state)
				IDLE_R:if(fall_rx)
							state<=START_R;
				START_R:if(counter==(4'd8-4'd2) )
							state<=BIT0_R;
				BIT0_R:if(counter==4'd8 )
							state<=BIT1_R;
				BIT1_R:if(counter==4'd8 )
							state<=BIT2_R;
				BIT2_R:if(counter==4'd8 )
							state<=BIT3_R;
				BIT3_R:if(counter==4'd8 )
							state<=BIT4_R;
				BIT4_R:if(counter==4'd8 )
							state<=BIT5_R;	
				BIT5_R:if(counter==4'd8 )
							state<=BIT6_R;	
				BIT6_R:if(counter==4'd8 )
							state<=BIT7_R;
				BIT7_R:if(counter==4'd8 )
							state<=END_R;
				END_R:if(counter==4'd6 )
							state<=IDLE_R;
				default:state<=IDLE_R;
			endcase
			
	always @(posedge clk_rx  or negedge rst_n)
		   if(~rst_n)
				counter<=4'd0;
		   else case(state)
				START_R:if(counter==(4'd8-4'd2) )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT0_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT1_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT2_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT3_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT4_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT5_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT6_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				BIT7_R:if(counter==4'd8 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;		
				END_R:if(counter==4'd6 )
							counter<=4'd0;
						else
							counter<=counter+1'b1;	
				default:counter<=4'd0;
			endcase
	reg [7:0]rx_buf;

	always @(posedge clk_rx  or negedge rst_n)
		   if(~rst_n)
				rx_buf<=8'd0;
		   else 	case(state)
				BIT0_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:1],rx};
				BIT1_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:2],rx,rx_buf[0]};
				BIT2_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:3],rx,rx_buf[1:0]};
				BIT3_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:4],rx,rx_buf[2:0]};
				BIT4_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:5],rx,rx_buf[3:0]};
				BIT5_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7:6],rx,rx_buf[4:0]};
				BIT6_R:if(counter==4'd4 )
							rx_buf<={rx_buf[7],rx,rx_buf[5:0]};
				BIT7_R:if(counter==4'd4 )
							rx_buf<={rx,rx_buf[6:0]};
				default:rx_buf<=rx_buf;
			endcase
				
	//fifo缓存
	assign wr_clk=clk_rx;
	assign wr_en=((state==END_R)&&(counter==4'd5 )&&(~full) )?1'b1:1'b0;
	assign dout=rx_buf;

endmodule 