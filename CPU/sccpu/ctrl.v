`include "ctrl_encode_def.v"

module ctrl(
    input [6:0] Op,       // opcode
    input [6:0] Funct7,   // funct7
    input [2:0] Funct3,   // funct3
    input Zero,           // zero flag for branch instructions
    output RegWrite,      // control signal for register write
    output MemWrite,      // control signal for memory write
    output [5:0] EXTOp,   // control signal to signed extension
    output [4:0] ALUOp,   // ALU operation
    output [2:0] NPCOp,   // next pc operation
    output ALUSrc,        // ALU source for B
    output [1:0] WDSel    // (register) write data selection
);

    // Define control signals for each instruction
    wire LUI = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; // 0110111
//    wire AUIPC = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & ~Op[0]; // 0010111
    wire JAL = Op[6] & Op[5] & ~Op[4] & Op[3] & Op[2] & Op[1] & Op[0]; // 1101111
    wire JALR = Op[6] & Op[5] & ~Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; // 1100111
    wire BRANCH = Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 1100011
    wire LOAD = ~Op[6] & ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0000011
    wire STORE = ~Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0100011
    wire IMMEDIATE = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0010011 
    wire RTYPE = ~Op[6] & Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0110011

    // R-Type instructions
    wire i_add = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // add
    wire i_sub = RTYPE & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sub
    wire i_xor = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xor
    wire i_or = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & ~Funct3[0]; // or
    wire i_and = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & Funct3[0]; // and
    wire i_sll = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sll
    wire i_srl = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // srl
    wire i_sra = RTYPE & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // sra
    wire i_slt = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slt
    wire i_sltu = RTYPE & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltu
   
    // I-Type instructions
    wire i_addi = IMMEDIATE & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // addi
    wire i_xori = IMMEDIATE & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xori
    wire i_ori = IMMEDIATE & Funct3[2] & Funct3[1] & ~Funct3[0]; // ori
    wire i_andi = IMMEDIATE & Funct3[2] & Funct3[1] & Funct3[0]; // andi
    wire i_slli = IMMEDIATE & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // slli
    wire i_srli = IMMEDIATE & Funct3[2] & ~Funct3[1] & Funct3[0] & ~Funct7[5]; // srli 101 
    wire i_srai = IMMEDIATE & Funct3[2] & ~Funct3[1] & Funct3[0] & Funct7[5]; // srai 101
    wire i_lw = LOAD & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // lw
    wire i_slti = IMMEDIATE & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slti 010
    wire i_sltui = IMMEDIATE & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltiu 011 

    // S-Type instructions
    wire i_sw = STORE & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // sw

    // B-Type instructions
    wire i_beq = BRANCH & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // beq
    wire i_bne = BRANCH & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // bne
    wire i_blt = BRANCH & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // blt 100
    wire i_bge = BRANCH & Funct3[2] & ~Funct3[1] & Funct3[0]; // bge 101
    wire i_bltu = BRANCH & Funct3[2] & Funct3[1] & ~Funct3[0]; // bltu 110
    wire i_bgeu = BRANCH & Funct3[2] & Funct3[1] & Funct3[0]; // bgeu 111

    // J-Type instructions
    wire i_jalr = JALR; // jalr
    wire i_jal = JAL; // jal

    // Control Signals
    assign RegWrite = RTYPE | IMMEDIATE | LOAD | LUI | JAL | JALR;
    assign MemWrite = STORE;
    assign ALUSrc = IMMEDIATE | LUI | LOAD | STORE | JALR;

    // ALUOp
    assign ALUOp[4] = i_srl | i_srli | i_sra | i_srai;                                                                      
    assign ALUOp[3] = i_or | i_ori | i_sll | i_slli | i_xor | i_xori | i_bltu | i_bgeu | i_slt | i_slti | i_sltu | i_sltui | i_and | i_andi;
    assign ALUOp[2] = i_or | i_ori | i_sub | i_beq | i_sll | i_slli | i_xor | i_xori | i_bne | i_blt | i_bge | i_and | i_andi;
    assign ALUOp[1] = i_addi | i_add | i_jalr | i_and | i_andi | i_sll | i_slli | i_lw | i_sw | i_blt | i_bge | i_slt | i_slti | i_sltu | i_sltui;
    assign ALUOp[0] = i_addi | i_add | i_jalr | i_or | i_ori | LUI | i_sll | i_slli | i_sra | i_srai | i_lw | i_sw | i_bne | i_bge | i_bgeu | i_sltu | i_sltui;

    // EXTOp
    assign EXTOp[5] = 0;
    assign EXTOp[4] = IMMEDIATE | i_lw | i_jalr;      //I
    assign EXTOp[3] = i_sw;      //S
    assign EXTOp[2] = BRANCH;       //B
    assign EXTOp[1] = LUI;         //U
    assign EXTOp[0] = i_jal;       //J

    // WDSel
    assign WDSel[1] = i_jal | i_jalr;
    assign WDSel[0] = LOAD;

   // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	   3'b100
    assign NPCOp[2] = i_jalr;
    assign NPCOp[1] = i_jal;
    assign NPCOp[0] = BRANCH & Zero;

endmodule