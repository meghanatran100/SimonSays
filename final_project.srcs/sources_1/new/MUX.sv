`timescale 1ns / 1ps

module MUX(
    input [31:0] zero, one, two, three,
    input [1:0] sel,
    output logic [31:0] mux_out
    );
    
    always @ (*)
    begin
        case(sel)
            0: mux_out = zero;
            2'b01: mux_out = one;
            2: mux_out = two;
            3: mux_out = three;
            default: mux_out = zero;
        endcase
    end
    
endmodule
