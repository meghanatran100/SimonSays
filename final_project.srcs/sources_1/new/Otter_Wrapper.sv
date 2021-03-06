`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Calllenes
//           P. Hummel
// 
// Create Date: 01/20/2019 10:36:50 AM
// Design Name: 
// Module Name: OTTER_Wrapper 
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

module Otter_Wrapper(
   input CLK,
   input BTNL,
   input BTNC, BTNU,
   input [15:0] SWITCHES,
   output logic [15:0] LEDS,
   output [7:0] CATHODES,
   output [3:0] ANODES,
   output [7:0] VGA_RGB,
   output VGA_HS,
   output VGA_VS
   );
        
    // INPUT PORT IDS ////////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more MMIO, and you'll have
    // to add constants here for the mux below
    localparam SWITCHES_AD = 32'h11000000;
    localparam VGA_READ_AD = 32'h11040000;
    localparam BTNU_AD = 32'h11000020;
    localparam RAND_AD = 32'h11008000;
    
           
    // OUTPUT PORT IDS ///////////////////////////////////////////////////////
    // In future labs you can add more MMIO
    localparam LEDS_AD      = 32'h11080000;
    localparam SSEG_AD     = 32'h110C0000;
    localparam VGA_ADDR_AD = 32'h11100000;
    localparam VGA_COLOR_AD = 32'h11140000; 
    
   // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////////
   logic s_reset, s_interrupt, btn_int;
   logic sclk = 1'b0;
   logic [31:0] IOBUS_out,IOBUS_in,IOBUS_addr;
   logic IOBUS_wr;
   
   // Signals for connecting VGA Framebuffer Driver
   logic r_vga_we;             // write enable
   logic [12:0] r_vga_wa;      // address of framebuffer to read and write
   logic [7:0] r_vga_wd;       // pixel color data to write to framebuffer
   logic [7:0] r_vga_rd;       // pixel color data read from framebuffer
   
   logic [15:0]  r_SSEG;
   
   // Connect Signals ////////////////////////////////////////////////////////////
   assign s_interrupt = btn_int;
   assign s_reset = BTNC;
   
   // signals for random
   logic [3:0] random; 
   
   // Declare OTTER_CPU ///////////////////////////////////////////////////////
   OTTER_MCU MCU (.RST(s_reset),.INTR(s_interrupt), .CLK(sclk),  
                   .IOBUS_OUT(IOBUS_out),.IOBUS_IN(IOBUS_in),
                   .IOBUS_ADDR(IOBUS_addr),.IOBUS_WR(IOBUS_wr));

   // Declare Seven Segment Display /////////////////////////////////////////
   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
   
  
   // Declare Debouncer One Shot  ///////////////////////////////////////////
   debounce_one_shot DB(.CLK(sclk), .BTN(BTNL), .DB_BTN(btn_int));
   
   // Declare VGA Frame Buffer //////////////////////////////////////////////
   vga_fb_driver_80x60 VGA(.CLK_50MHz(sclk), .WA(r_vga_wa), .WD(r_vga_wd),
                               .WE(r_vga_we), .RD(r_vga_rd), .ROUT(VGA_RGB[7:5]),
                               .GOUT(VGA_RGB[4:2]), .BOUT(VGA_RGB[1:0]),
                               .HS(VGA_HS), .VS(VGA_VS));   
                               
   // Declare Random Number Generator ///////////////////////////////////////
   RandGen RandGen(.CLK(CLK), .RST(s_reset), .RANDOM(random));
   //DecoderRandom DR(.RANDOM(random), .LED(LEDS));
 
 
   // Clock Divider to create 50 MHz Clock /////////////////////////////////
   always_ff @(posedge CLK) begin
       sclk <= ~sclk;
   end

   // Connect Board peripherals (Memory Mapped IO devices) to IOBUS /////////////////////////////////////////
   always_ff @ (posedge sclk) begin
        r_vga_we<=0;       
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS <= IOBUS_out[15:0];    
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                VGA_ADDR_AD: r_vga_wa <= IOBUS_out[12:0];
                VGA_COLOR_AD: begin  
                        r_vga_wd <= IOBUS_out[7:0];
                        r_vga_we <= 1;  
                    end     
            endcase
    end
    
    always_comb begin
        case(IOBUS_addr)
            SWITCHES_AD: IOBUS_in = {16'b0, SWITCHES};
            VGA_READ_AD: IOBUS_in = {24'b0, r_vga_rd};
            BTNU_AD: IOBUS_in = {31'b0, BTNU};
            RAND_AD: IOBUS_in = {28'b0,random};
            default: IOBUS_in = 32'b0;
        endcase
    end
   endmodule

