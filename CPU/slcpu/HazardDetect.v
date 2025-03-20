module HazardDetect(    
    input MemRead,
    input [4:0] EX_rd,
    input [4:0] rs1,
    input [4:0] rs2,
    output ID_EX_Reset,
    output IF_ID_Write,
    output NPC_Write
    );
    
    wire C;
    
    assign C = MemRead && ((EX_rd == rs1) || (EX_rd == rs2));
    
    assign ID_EX_Reset = C ? 1 : 0;
    assign IF_ID_Write = C ? 0 : 1;
    assign NPC_Write = C ? 0 : 1;
endmodule
