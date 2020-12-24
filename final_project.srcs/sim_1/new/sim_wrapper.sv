`timescale 1ns / 1ps

module sim_wrapper(
    );
    logic CLK;
    logic BTNC;
    logic [15:0] SWITCHES;
    logic [15:0] LEDS;
    logic [7:0] CATHODES;
    logic [3:0] ANODES;
    
    Otter_Wrapper wrapper(.*);
    always begin
        CLK = 0;
        #1;
        CLK = 1;
        #1;
    end
    initial begin
        BTNC = 1; //reset
        SWITCHES = 0;
        #4;
        BTNC = 0;
        
    end
    
endmodule
