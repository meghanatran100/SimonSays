
`timescale 1ns / 1ps

module REG_FILE(
    input [4:0] ADR1, ADR2, 
    input logic [4:0] WA,
    input logic [31:0] WD,
    input logic EN,
    input CLK,
    output logic [31:0] RS1,
    output logic [31:0] RS2 
    );
    
    logic [31:0] ram [0:31];
    
    initial begin
        int i;
        for(i = 0; i < 32; i++) begin
            ram[i] = 0;
        end
    end
    
    
    always_comb begin
        RS1 = ram[ADR1];
        RS2 = ram[ADR2];
    end

    always_ff @(posedge CLK) begin
        if((EN == 1) & (WA != 0))
            ram[WA] <= WD;
    end
endmodule
