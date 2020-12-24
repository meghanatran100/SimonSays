`timescale 1ns / 1ps

module ControlUnit1(
    input [6:0] ir1, //opcode
    input [2:0] ir2, //funct3
    input [6:0] ir3, //tunct7
    input int_taken,
    input br_eq, br_lt, br_ltu,
    output logic [3:0] alu_fun,
    output logic alu_srcA,
    output logic [2:0] pcSource,
    output logic [1:0] alu_srcB,  rf_wr_sel
    );
    //decoder
    //need to initialize everything to zero
    
    always_comb begin
        alu_srcA = 0;
        alu_srcB = 0;
        pcSource = 0;
        rf_wr_sel = 0;
        alu_fun = 0;
        if(int_taken == 1)
            pcSource = 4;
        else begin
            case(ir1)
                7'b1110011: begin
                    case(ir2)
                        3'b001: begin   //csrrw
                            rf_wr_sel = 1;
                        end
                        3'b000: begin   //mret
                            pcSource = 5;
                        end
                    endcase
                end
                7'b0110011: begin       //RType
                    alu_srcA = 0;
                    alu_srcB = 0;
                    pcSource = 0;
                    rf_wr_sel = 3;
                    alu_fun = {ir3[5], ir2};        
                end
                7'b0010011: begin           //IType
                    alu_srcA = 0;
                    alu_srcB = 2'b01;
                    pcSource = 0;
                    rf_wr_sel = 3;
                    case(ir2)
                        3'b000: alu_fun = 4'b0000;  //addi
                        3'b111: alu_fun = 4'b0111;  //andi
                        3'b110: alu_fun = 4'b0110;  //ori
                        3'b001: alu_fun = 4'b0001;  //slli
                        3'b010: alu_fun = 4'b0010;  //slti
                        3'b011: alu_fun = 4'b0011;  //sltiu
                        3'b101: begin
                            case(ir3)
                                7'b0000000: alu_fun = 4'b0101;  //srli
                                7'b0100000: alu_fun = 4'b1101;  //srai
                            endcase
                        end
                        3'b100: alu_fun = 4'b0100;  //xori
                    endcase
                end
                7'b1100111: begin
                    //jalr
                    pcSource = 1;
                end
                7'b0000011: begin
                    alu_srcA = 0;
                    alu_srcB = 2'b01;
                    pcSource = 0;
                    rf_wr_sel = 2;
                    alu_fun = 4'b0000; //loads
                end
                7'b0100011: begin  //SType
                    alu_srcB = 2;
                    rf_wr_sel = 2;
                end
                7'b1100011: begin //BType
                    case(ir2)
                        3'b000: begin
                            if(br_eq == 1)
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                        3'b101: begin
                            if((br_eq == 0 && br_lt == 0) | (br_eq == 1 && br_lt == 0))
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                        3'b111: begin
                            if((br_eq == 0 && br_ltu == 0) | (br_eq == 1 && br_ltu == 0))
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                        3'b100: begin
                            if(br_lt == 1)
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                        3'b110: begin
                            if(br_ltu == 1)
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                        3'b001: begin
                            if(br_eq == 0)
                                pcSource = 2;
                            else
                                pcSource = 0;
                        end
                    endcase
                    
                end
                7'b0110111: begin //lui
                    pcSource = 0;
                    alu_srcA = 1;
                    alu_srcB = 0;
                    alu_fun = 4'b1001;
                    rf_wr_sel = 3;
                end
                7'b0010111: begin //aui_pc
                    pcSource = 0;
                    alu_srcA = 1;
                    alu_srcB = 2'b11;
                    rf_wr_sel = 3;
                    alu_fun = 4'b0000;
                end
                7'b1101111: begin
                    pcSource = 3;   //jal
                end
            default:;                
            endcase
            
        end
    end
            
    
    
    
    
    
endmodule
