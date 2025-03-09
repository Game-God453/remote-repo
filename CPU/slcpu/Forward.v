
module Forward(
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,
    input [4:0] MEM_rs2,
    input MEM_RegWrite,
    input [4:0] MEM_rd,
    input MEM_MemWrite,
    input [4:0] WB_rd,
    input WB_RegWrite,
    output DiSrc,
    output [1:0] BusBFW,
    output [1:0] BusAFW
    );
    
    assign BusAFW[1]=MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rs1);
    assign BusBFW[1]=MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rs2);
    assign BusAFW[0]=WB_RegWrite && (WB_rd != 0) && (MEM_rd != EX_rs1) && (WB_rd == EX_rs1);
    assign BusBFW[0]=WB_RegWrite && (WB_rd != 0) && (MEM_rd != EX_rs2) && (WB_rd == EX_rs2);
    assign DiSrc=WB_RegWrite && (WB_rd != 0) && (WB_rd == MEM_rs2) && MEM_MemWrite;
    
endmodule
