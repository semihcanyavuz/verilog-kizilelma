`timescale 1us/1ns

module weapons_control_unit_tb;
    reg target_locked;
    reg clk;
    reg rst;
    reg fire_command;
    wire launch_missile;

    wire [1:0] WCU_state;
    wire [3:0] remaining_missiles;

    weapons_control_unit uut(target_locked, clk, rst, fire_command, launch_missile, remaining_missiles, WCU_state);

    initial begin
        // Your code goes here.  DO NOT change anything that is already given! Otherwise, you will not be able to pass the tests!
        // Please inspect the provided waveforms very carefully and try to produce the same results.
        // Make sure to use $finish statement to avoid infinite loops.

        rst = 1;
        target_locked = 0;
        fire_command = 0;
        #17;
        rst = 0;
        #3;
        target_locked = 1;
        #20;
        target_locked = 0;
        #20;
        target_locked = 1;
        #20;
        fire_command = 1;
        #10;
        target_locked = 0;
        #20;
        target_locked = 1;
        #110;
        
        $finish;
    end

    
    initial begin
        clk = 0;
        forever begin
            #5;
            clk = ~clk;
        end
    end

endmodule