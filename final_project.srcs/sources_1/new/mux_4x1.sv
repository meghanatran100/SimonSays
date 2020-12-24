`timescale 1ns / 1ps

module mux_4x1(
    input [31:0] zero, one, two, three,
    input [1:0] sel,
    output logic [31:0] mux_out
    );
    
    always_comb
    begin
        case(sel)
            2'b00: mux_out = zero;
            2'b01: mux_out = one;
            2'b10: mux_out = two;
            2'b11: mux_out = three;
            default: mux_out = zero;
        endcase
    end
    
endmodule
