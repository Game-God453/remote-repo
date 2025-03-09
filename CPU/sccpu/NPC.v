`include "ctrl_encode_def.v"

module NPC( PC, NPCOp, IMM, RD, NPC );  // next pc module
   input  [31:0] PC;        // current pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate value
   input [31:0] RD;   //jalr π”√
   output reg [31:0] NPC;   // next pc

   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4

   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;   // NPC computes addr for sequential execution
          `NPC_BRANCH: NPC = PC + IMM;  // B type, NPC computes addr for branches
          `NPC_JUMP:   NPC = PC + IMM;  // J type, NPC computes addr for jal
          `NPC_JALR:   NPC = IMM + RD;       // JALR type, NPC computes addr based on register value
          default:     NPC = PCPLUS4;   // Default to sequential execution
      endcase
   end 
endmodule
