`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2020 04:31:52 PM
// Design Name: 
// Module Name: DecoderRandom
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


module DecoderRandom(
    input [3:0] RANDOM,
    output logic [15:0] LED
    );
    
    always_comb begin
       case(RANDOM)
           4'b0000: LED = 16'b0000000000000001; 
           4'b0001: LED = 16'b0000000000000010;
           4'b0010: LED = 16'b0000000000000100;
           4'b0011: LED = 16'b0000000000001000;
           4'b0100: LED = 16'b0000000000010000;
           4'b0101: LED = 16'b0000000000100000;
           4'b0110: LED = 16'b0000000001000000;
           4'b0111: LED = 16'b0000000010000000;
           4'b1000: LED = 16'b0000000100000000;
           4'b1001: LED = 16'b0000001000000000;
           4'b1010: LED = 16'b0000010000000000;
           4'b1011: LED = 16'b0000100000000000;
           4'b1100: LED = 16'b0001000000000000;
           4'b1101: LED = 16'b0010000000000000;
           4'b1110: LED = 16'b0100000000000000;
           4'b1111: LED = 16'b1000000000000000;
           default: LED = 16'b0000000000000000;
           
       endcase
        
    end
    
endmodule
