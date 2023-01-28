`timescale 1us/1ns

module weapons_control_unit(
    input target_locked,
    input clk,
    input rst,
    input fire_command,
    output reg launch_missile,
    output [3:0] remaining_missiles,
    output [1:0] WCU_state
);

    // Your code goes here.  DO NOT change anything that is already given! Otherwise, you will not be able to pass the tests!
    // You should implement the weapons_control_unit module HERE using behavioral design approach. 
    // You should read the instructions first and make sure you understand the problem completely.
    // Please inspect the provided waveforms very carefully and try to produce the same results.

    reg [3:0] remaining_missiles;
    reg [1:0] WCU_state;
    parameter S0 = 00, S1 = 01, S2 = 10, S3 = 11;
    reg [1:0] nextstate;

    always @(posedge clk or posedge rst)
    if(rst)
    begin
        WCU_state = S0;
        launch_missile = 0;
        remaining_missiles = 4;
        nextstate = S0;
    end
    else
    begin
        if(WCU_state == S1 && fire_command)
        begin
            nextstate = S2;
        end
        if(WCU_state == S0 && target_locked)
        begin
            nextstate = S1;
        end
        if(WCU_state == S0 && !target_locked)
        begin
            nextstate = S0;
        end
        WCU_state = nextstate;
    end

    always @(WCU_state or target_locked or fire_command)
    begin
        case(WCU_state)
            1: if(!target_locked)
                begin
                if($time % 5 == 0 && $time % 10 != 0)
                begin
                    WCU_state <= S0;
                end
                nextstate = S0;
                end
            2: if(remaining_missiles != 0)
                begin
                launch_missile <= 1;
                remaining_missiles <= remaining_missiles - 1;
                #10;
                launch_missile = 0;
                if(remaining_missiles != 0)
                begin
                    if(!target_locked)
                        nextstate = S0;
                    else
                        nextstate = S1;
                end
                else if(remaining_missiles == 0)
                begin
                    nextstate = S3;
                end
                end
        endcase
    end

endmodule