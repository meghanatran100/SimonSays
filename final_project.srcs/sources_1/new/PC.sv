`timescale 1ns / 1ps

module ProgramCounter(
    input [31:0] PC_DIN,
    input PC_WRITE,
    input PC_RST,
    input CLK,
    output logic [31:0] PC_COUNT
);
    always_ff @(posedge CLK) begin
        if(PC_RST == 1)
            PC_COUNT <= 0;            
        else if (PC_WRITE == 1)
            PC_COUNT <= PC_DIN; 
    end
endmodule
