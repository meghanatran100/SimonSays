`timescale 1ns / 1ps

module ControlUnit2(
    input RST, INTR, clk,
    input [6:0] ir1,
    input [2:0] ir2,
    output logic PCWrite, regWrite, memWE2, memRDEN1, memRDEN2, int_taken, csr_WE
    );
    
    typedef enum {ST_FETCH, ST_EXEC, ST_BACK, ST_INTR} STATES;
    STATES NS, PS;
    
    
    always_ff@(posedge clk) begin
        if(RST ==1) begin
            PS <= ST_FETCH;
        end
        else begin
        PS <= NS;
        end
    end
    
    always_comb begin
        PCWrite = 0;
        regWrite = 0;
        memWE2 = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        int_taken  = 0;
        csr_WE = 0;
        case(PS)
            ST_FETCH: begin
                memRDEN1 = 1;
                NS = ST_EXEC;
            end
            ST_EXEC: begin
                if(INTR == 0 &&  ir1 == 7'b0000011) begin
                    memRDEN2 = 1;
                    regWrite = 0;
                    memRDEN1 = 0;
                    PCWrite = 0;
                    NS = ST_BACK;
                end
                else if(INTR == 1 && ir1 != 7'b0000011) begin
                    NS = ST_INTR;
                end
                else begin
                    if (ir1 == 7'b0100011) begin   //saves
                        PCWrite = 1;
                        memWE2 = 1;
                        regWrite = 0;
                        memRDEN1 = 0;
                        memRDEN2 = 1;
                        NS = ST_FETCH;
                    end
                    else if(ir1 == 7'b1100011) begin   //branches
                        PCWrite = 1;
                        NS = ST_FETCH;
                    end
                    else if(ir1 == 7'b1110011) begin    //csrrw & mret
                        if(ir2 == 3'b001) begin //csrrw
                            csr_WE = 1;
                            regWrite = 1;
                            PCWrite  = 1;
                            NS = ST_FETCH;
                        end
                        else if (ir2 == 3'b000) begin  //mret
                            csr_WE = 0;
                            regWrite = 0;
                            PCWrite = 1;
                            NS = ST_FETCH;
                        end
                    end
                    else begin
                        PCWrite = 1;
                        regWrite = 1;
                        memRDEN1 = 0;
                        NS = ST_FETCH;
                    end
                end
               
            end
            ST_BACK: begin
                if(INTR == 0) begin
                    regWrite = 1;
                    PCWrite = 1;
                    memRDEN1 = 0;
                    memRDEN2 = 0;
                    NS = ST_FETCH;
                end
                else begin
                    NS = ST_INTR;
                end
            end
            ST_INTR: begin
                int_taken = 1;
                PCWrite = 1;
                NS = ST_FETCH;
            end
            default: NS = ST_FETCH;
        endcase
    end
endmodule
