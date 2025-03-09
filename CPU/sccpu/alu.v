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
        `ALUOp_bne:        C = (A != B) ? 32'b0 : 32'b1;  //bne：不相等分支指令，如果两个寄存器的值不相等，则跳转到指定的地址。
        `ALUOp_blt:        C = (A < B) ? 32'b0 : 32'b1;  //blt：小于分支指令，如果第一个寄存器的值小于第二个寄存器的值，则跳转到指定的地址。
        `ALUOp_bltu:       C = ($unsigned(A) < $unsigned(B)) ? 32'b0 : 32'b1;  //无符号小于分支指令
        `ALUOp_bge:        C = (A >= B) ? 32'b0 : 32'b1;  //大于等于分支指令，如果第一个寄存器的值大于或等于第二个寄存器的值，则跳转到指定的地址。
        `ALUOp_bgeu:       C = ($unsigned(A) >= $unsigned(B)) ? 32'b0 : 32'b1; //无符号大于等于分支指令
        default:           C = A;  // Default to no operation
      endcase
   end // end always
   
   assign Zero = (C == 32'b0);  

endmodule
    
