module shift8to128 (
    input wire 			clk,            // ʱ���ź�
    input wire 			rst_n,       	// �͵�ƽ��Ч�ĸ�λ�ź�
    input       		wr_en,
    input wire 	[7:0] 	data_in, 		// 8λ��������
    output  	[127:0] data_out, 		// 128λ�������
    output  reg        	done
);

    reg [127:0] data_out_reg;
    reg [4:0] counter; // �����������ڸ����Ѿ����յ�8λ���ݵ�������0-15��
    reg [127:0] shift_reg; // ��λ�Ĵ����������ݴ�����

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // ��λʱ���������������λ�Ĵ���
            counter <= 5'b0;
            done <= 1'b0;
        end else begin if(wr_en == 1'b1)    begin
            // ��������������λ�Ĵ���
            shift_reg <= {shift_reg[119:0], data_in};
            
            // ��������1
            counter <= counter + 1;
           end
         else
             counter <= counter;

            // ���������ﵽ16ʱ���Ѿ�����16��8λ���ݣ���128λ��
            if (counter == 5'd16) begin
                // ���������128λ����
                data_out_reg <= shift_reg;
                done <= 1'b1;
                // ���ü�����
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