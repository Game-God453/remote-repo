module shift8to128 (
    input wire 			clk,            // 时钟信号
    input wire 			rst_n,       	// 低电平有效的复位信号
    input       		wr_en,
    input wire 	[7:0] 	data_in, 		// 8位输入数据
    output  	[127:0] data_out, 		// 128位输出数据
    output  reg        	done
);

    reg [127:0] data_out_reg;
    reg [4:0] counter; // 计数器，用于跟踪已经接收的8位数据的数量（0-15）
    reg [127:0] shift_reg; // 移位寄存器，用于暂存数据

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时，清零计数器和移位寄存器
            counter <= 5'b0;
            done <= 1'b0;
        end else begin if(wr_en == 1'b1)    begin
            // 将新数据移入移位寄存器
            shift_reg <= {shift_reg[119:0], data_in};
            
            // 计数器加1
            counter <= counter + 1;
           end
         else
             counter <= counter;

            // 当计数器达到16时（已经接收16个8位数据，共128位）
            if (counter == 5'd16) begin
                // 输出完整的128位数据
                data_out_reg <= shift_reg;
                done <= 1'b1;
                // 重置计数器
                counter <= 5'b0;
            end
            else    begin
                data_out_reg <= data_out_reg;
                done <= 1'b0;
             end
        end
    end
    
    assign  data_out = data_out_reg;

endmodule