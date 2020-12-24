`timescale 1ns / 1ps

module OTTER_MCU(
    input CLK, RST, INTR,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT, IOBUS_ADDR,
    output IOBUS_WR
    );
    
   
    logic [31:0] rs1, rs2, PC, BTYPE, JTYPE, ITYPE, UTYPE, STYPE, wd, A, B, alu_out,
                data, instr, PC_DIN, pc_out, branch, jal, jalr, mtvec, mepc, rd;
    logic [31:0] pc;
    logic br_eq, br_lt, br_ltu, regWrite, alu_a, memWE2, memRDEN1, memRDEN2, PCWrite, csr_WE, int_taken, mie;
    logic [4:0] adr1, adr2, wa;

    logic [3:0] alu_fun;
    logic [2:0] pcSource;
    logic [1:0] alu_b, rf_wr_sel;
    assign adr1 = {instr[19:15]};  
    assign adr2 = {instr[24:20]};
    assign wa = {instr[11:7]};  
    
    assign IOBUS_OUT = rs2;
    assign IOBUS_ADDR = alu_out;
    
    BranchConGen BranchCon(.IN1(rs1), .IN2(rs2), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu));
    BranchAddGen BranchAdd(.PC(pc), .BTYPE(BTYPE), .JTYPE(JTYPE), .ITYPE(ITYPE), .RS1(rs1),
                        .branch(branch), .jal(jal), .jalr(jalr));
    REG_FILE reg_file( .ADR1(adr1), .ADR2(adr2), .WA(wa), .WD(wd), 
                        .EN(regWrite), .CLK(CLK), .RS1(rs1), .RS2(rs2));
    ALU alu(.A(A), .B(B), .ALU_FUN(alu_fun), .RESULT(alu_out));
    IMMED_GEN IMMED(.INSTRUCT(instr), .UTYPE(UTYPE), .ITYPE(ITYPE),
                        .STYPE(STYPE), .JTYPE(JTYPE), .BTYPE(BTYPE));
    ProgramCounter ProgCounter(.PC_DIN (PC_DIN), .PC_WRITE (PCWrite), .PC_RST (RST),
                        .CLK(CLK), .PC_COUNT (pc));
    ControlUnit1 decoder(.ir1(instr[6:0]), .ir2(instr[14:12]), .ir3(instr[31:25]),.int_taken(int_taken),
                        .br_eq(br_eq),  .br_lt(br_lt), .br_ltu(br_ltu),
                        .alu_fun(alu_fun), .alu_srcA(alu_a), .alu_srcB(alu_b),
                        .pcSource(pcSource),  .rf_wr_sel(rf_wr_sel));
    ControlUnit2 fsm(.RST(RST), .INTR(INTR & mie), .clk(CLK) ,.ir1(instr[6:0]), .ir2(instr[14:12]),
                        .PCWrite(PCWrite), .regWrite(regWrite), .memWE2(memWE2),
                        .memRDEN1(memRDEN1), .memRDEN2(memRDEN2), .int_taken(int_taken), .csr_WE(csr_WE));                
    MEM mem(.MEM_CLK(CLK), .MEM_RDEN1(memRDEN1), .MEM_RDEN2(memRDEN2), .MEM_WE2(memWE2),
                        .MEM_ADDR1(pc[15:2]), .MEM_ADDR2(alu_out), .MEM_WD(rs2),
                        .MEM_SIZE(instr[13:12]), .MEM_SIGN(instr[14]), .IO_IN(IOBUS_IN),
                        .IO_WR(IOBUS_WR), .MEM_DOUT1(instr), .MEM_DOUT2(data));
    CSR CSR(.RST(RST), .int_taken(int_taken), .csr_WE(csr_WE), .CLK(CLK), .addr(instr[31:20]), .pc(pc), .wd(rs1), .mie(mie), .mepc(mepc), .mtvec(mtvec),.rd(rd));
    mux_4x1 reg_wd(.zero(pc_out), .one(rd), .two(data), .three(alu_out), 
                        .sel(rf_wr_sel), .mux_out(wd));
    mux_4x1 aluB(.zero(rs2), .one(ITYPE), .two(STYPE), .three(pc), .sel(alu_b), .mux_out(B));
    mux_2x1 aluA(.zero(rs1), .one(UTYPE), .sel(alu_a), .mux_out(A));
    mux_6x1 mux_pc(.zero(pc_out), .one (jalr), .two (branch), .three (jal), .four(mtvec), .five(mepc), .sel (pcSource), .mux_out (PC_DIN));
    pc_add4 add4(.pc(pc), .pc_plus4(pc_out));
    
endmodule
