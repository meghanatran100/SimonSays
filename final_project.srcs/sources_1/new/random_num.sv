/*`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2020 02:08:37 PM
// Design Name: 
// Module Name: random_num
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


module random_num(
    input logic [3:0]random,
    input logic [15:0]switches,
    input logic clk, RST,
    output logic [15:0]led
    );
    //logic num_led = $urandom_range(0,15);
    //level 1
    logic [15:0]array[6:0];
    typedef enum {ST_USER, ST_LED, ST_BEGINGAME} STATES;
    STATES NS, PS;
    
    always_ff@(posedge clk) begin
        if(RST == 1) begin
            PS <= ST_LED;
        end
        else begin
        PS <= NS;
        end
    end
    
    always_comb begin
        case(PS)
            ST_LED: begin
                led = $urandom_range(0,15);
                NS = ST_USER;
            end
            ST_USER: begin
                if (switches == led)
                    NS = ST_LED;
                else
                    RST = 1;   
            end
    
    
endmodule*/
