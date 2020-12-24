`timescale 1ns / 1ps

module mux_2x1(
    input [31:0] zero, one,
    input sel,
    output logic [31:0] mux_out
    );
    
    always_comb
    begin
        case(sel)
            0: mux_out = zero;
            1: mux_out = one;
            default: mux_out = zero;
        endcase
    end
    
endmodule