`timescale 1ns / 1ps

module BranchConGen(
    input [31:0] IN1, IN2,
    output logic br_eq, br_lt, br_ltu
    );
    
    assign br_eq = (IN1 == IN2);
    assign br_ltu = (IN1 < IN2);
    assign br_lt = ($signed(IN1) < $signed(IN2));
    
endmodule
