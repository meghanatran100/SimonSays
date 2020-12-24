`timescale 1ns / 1ps

module pc_add4(
    input [31:0] pc,
    output logic [31:0] pc_plus4
    );
    assign pc_plus4 = pc + 4;
endmodule
