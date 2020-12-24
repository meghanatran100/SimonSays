`timescale 1ns / 1ps

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_FUN,
    output logic [31:0] RESULT
);

always_comb
begin
    case(ALU_FUN)
        4'b0000: RESULT = A + B;	//add
        4'b1000: RESULT = A - B; //sub
        4'b0110: RESULT = A | B; //or
        4'b0111: RESULT = A & B; //and
        4'b0100: RESULT = A ^ B; //xor
        4'b0101: RESULT = A >> B[4:0]; //srl
        4'b0001: RESULT = A << B[4:0]; //sll
        4'b1101: RESULT = $signed (A) >>> ($signed (B[4:0])); //sra
        4'b0010: RESULT = ($signed(A) < $signed(B)); //slt
        4'b0011: RESULT = A < B;  //sltu
        4'b1001: RESULT = A; //lui-copy
        default: RESULT = 0;
    endcase
end
endmodule
