`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2020 04:26:25 PM
// Design Name: 
// Module Name: mux_6x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_6x1(
    input [31:0] zero, one, two, three,
    input [31:0] four, five,
    input [2:0] sel,
    output logic [31:0] mux_out
    );
    
    always_comb
    begin
        case(sel)
            3'b000: mux_out = zero;
            3'b001: mux_out = one;
            3'b010: mux_out = two;
            3'b011: mux_out = three;
            3'b100: mux_out = four;
            3'b101: mux_out = five;
            default: mux_out = zero;
        endcase
    end
    
endmodule