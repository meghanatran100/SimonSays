`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2020 03:46:49 PM
// Design Name: 
// Module Name: CSR
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


module CSR(
    input RST, int_taken, csr_WE, CLK,
    input [11:0] addr,
    input [31:0] pc, wd,
    output logic mie,
    output logic [31:0] mepc, mtvec, rd
    );
    
    always_ff @(posedge CLK) begin
        if(RST ==1) begin
            mepc <= 0;
            mtvec <= 0;
            mie <= 0;
        end
        if(csr_WE == 1) begin
            case(addr)
                12'h304: mie <= wd[0];
                12'h305: mtvec <= wd;
                //12'h341: mepc <= wd;
            endcase
        end
        else if(int_taken == 1) begin
            mepc <= pc;
            mie <= 0;
        end
    end
    
    always_comb begin
        case(addr)
            12'h304: rd = {{31{1'b0}}, mie};
            12'h305: rd = mtvec;
            12'h341: rd = mepc;
            default: rd = 0;
        endcase
    end
endmodule
