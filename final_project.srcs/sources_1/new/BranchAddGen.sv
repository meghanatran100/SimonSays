`timescale 1ns / 1ps

module BranchAddGen(
    input [31:0] PC, BTYPE, JTYPE, ITYPE, RS1,
    output logic [31:0] branch, jal, jalr

    );
    
    assign branch = (PC + BTYPE);
    assign jal = (PC + JTYPE);
    assign jalr = (RS1 + ITYPE);
   
endmodule
