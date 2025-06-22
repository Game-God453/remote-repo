module shift128to8(
    input 				clk,
    input 				rst,
    input 		[127:0] data_in,
    input 				data_valid,
    input 				fifo_full,
    output reg 	[7:0]	fifo_data,
    output reg 			fifo_wr_en
);

	reg [3:0] count;  // 0-15计数器（128/8=16）
	reg splitting;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			count <= 4'd15;
			fifo_wr_en <= 1'b0;
			splitting <= 1'b0;
		end
		else begin
			fifo_wr_en <= 1'b0;  // 默认不写入
			
			if (splitting) begin
				if (!fifo_full) begin
					fifo_data <= data_in[count*8 +: 8];  // 选择当前字节
					fifo_wr_en <= 1'b1;
					
					if (count == 4'd0) begin
						splitting <= 1'b0;  // 完成16字节发送
					end
					else    count <= count - 4'd1;
				end
			end
			else if (data_valid && !fifo_full) begin
				splitting <= 1'b1;
				count <= 4'd15;
			end
		end
	end

endmodule
