`include "ctrl_encode_def.v"

module NPC(rst,PC, NPCOp, Target, NPC_Write, NPC);  // next pc module
   input        rst;
   input  [31:0] PC;        // pc
   input  [4:0]  NPCOp;     // next pc operation
   input  [31:0] Target;       // immediate
   input NPC_Write;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = rst ? 32'b0 : PC + 4; // pc + 4
  
   always @(*) begin
        if(NPC_Write)
            case (NPCOp)
                `NPC_PLUS4:  NPC = PCPLUS4;   // NPC computes addr for sequential execution
                `NPC_BRANCH: NPC = Target;  // B type, NPC computes addr for branches
                `NPC_JUMP:   NPC = Target;  // J type, NPC computes addr for jal
                `NPC_JALR:   NPC = Target;       // JALR type, NPC computes addr based on register value
                default:     NPC = PCPLUS4;
            endcase
    end // end always
   
endmodule
