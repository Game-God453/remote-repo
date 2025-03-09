`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero);
   input  signed [31:0] A, B;
   input         [4:0]  ALUOp;
   output signed [31:0] C;
   output Zero;  //condition flag: set if condition is true for B-type instruction
   
   reg [31:0] C;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
        `ALUOp_nop:        C = A;  // No operation
        `ALUOp_lui:        C = B;  // Load upper immediate
       // `ALUOp_auipc:      C = A + B;  // Add upper immediate to PC
        `ALUOp_add:        C = A + B;  // Addition
        `ALUOp_sub:        C = A - B;  // Subtraction
        `ALUOp_xor:        C = A ^ B;  // Bitwise XOR
        `ALUOp_or:         C = A | B;  // Bitwise OR
        `ALUOp_and:        C = A & B;  // Bitwise AND
        `ALUOp_sll:        C = A << B[4:0];  // Logical left shift
        `ALUOp_srl:        C = A >> B[4:0];  // Logical right shift
        `ALUOp_sra:        C = A >>> B[4:0];  // Arithmetic right shift
        `ALUOp_slt:        C = (A < B) ? 32'b1 : 32'b0;  // Set less than (signed)
        `ALUOp_sltu:       C = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0;  // Set less than unsigned
        `ALUOp_bne:        C = (A != B) ? 32'b0 : 32'b1;  //bne������ȷ�ָ֧���������Ĵ�����ֵ����ȣ�����ת��ָ���ĵ�ַ��
        `ALUOp_blt:        C = (A < B) ? 32'b0 : 32'b1;  //blt��С�ڷ�ָ֧������һ���Ĵ�����ֵС�ڵڶ����Ĵ�����ֵ������ת��ָ���ĵ�ַ��
        `ALUOp_bltu:       C = ($unsigned(A) < $unsigned(B)) ? 32'b0 : 32'b1;  //�޷���С�ڷ�ָ֧��
        `ALUOp_bge:        C = (A >= B) ? 32'b0 : 32'b1;  //���ڵ��ڷ�ָ֧������һ���Ĵ�����ֵ���ڻ���ڵڶ����Ĵ�����ֵ������ת��ָ���ĵ�ַ��
        `ALUOp_bgeu:       C = ($unsigned(A) >= $unsigned(B)) ? 32'b0 : 32'b1; //�޷��Ŵ��ڵ��ڷ�ָ֧��
        default:           C = A;  // Default to no operation
      endcase
   end // end always
   
   assign Zero = (C == 32'b0);  

endmodule
    
