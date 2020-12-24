`timescale 1ns / 1ps


module IMMED_GEN(
    input logic [31:0] INSTRUCT,
    output logic [31:0] UTYPE, ITYPE, STYPE, JTYPE, BTYPE
    );
    
    assign UTYPE = {INSTRUCT[31:12], 12'b000000000000};
    assign ITYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:20]};
    assign STYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:25], INSTRUCT[11:7]};
    assign BTYPE = {{20{INSTRUCT[31]}}, INSTRUCT[7], INSTRUCT[30:25], INSTRUCT[11:8], 1'b0};
    assign JTYPE = {{12{INSTRUCT[31]}}, INSTRUCT[19:12], INSTRUCT[20], INSTRUCT[30:21], 1'b0};
    
endmodule
