`timescale 1us/1ns

module target_tracking_unit(
    input rst,
    input track_target_command,
    input clk,
    input echo,
    output reg trigger_radar_transmitter,
    output reg [13:0] distance_to_target,
    output reg target_locked,
    output [1:0] TTU_state
);

    // Your code goes here.  DO NOT change anything that is already given! Otherwise, you will not be able to pass the tests!
    // You should implement the target_tracking_unit module HERE using behavioral design approach. 
    // You should read the instructions first and make sure you understand the problem completely.
    // Please inspect the provided waveforms very carefully and try to produce the same results.

    reg [1:0] TTU_state;
    parameter S0 = 00, S1 = 01, S2 = 10, S3 = 11;
    reg [1:0] nextstate;
    integer listen_for_echo_timer = 0;
    integer target_update_timer = 0;
    integer echo_start_time = 0;
    integer echo_end_time = 0;
    
    always @(posedge clk or posedge rst)
    if(rst)
        begin
        TTU_state = S0;
        trigger_radar_transmitter = 0;
        distance_to_target = 0;
        target_locked = 0;
        listen_for_echo_timer = 0;
        target_update_timer = 0;
        echo_start_time = 0;
        echo_end_time = 0;
        nextstate = S0;
        end
    else
        begin
        if(TTU_state == 0 && distance_to_target != 0)
        begin
            target_update_timer <= target_update_timer + 2;
        end
        if(TTU_state == 0 && target_update_timer == 62)
        begin
            trigger_radar_transmitter = 0;
            distance_to_target = 0;
            target_locked = 0;
            listen_for_echo_timer = 0;
            target_update_timer = 0;
            echo_start_time = 0;
            echo_end_time = 0;
            nextstate = S0;
            TTU_state = S0;
        end
        if(TTU_state == 1 && distance_to_target != 0)
        begin
            target_update_timer <= target_update_timer + 2;
        end
        if(TTU_state == 2)
        begin
            if(distance_to_target != 0)
            begin
                target_update_timer <= target_update_timer + 2;
            end
            listen_for_echo_timer <= listen_for_echo_timer + 2;
        end
        if(TTU_state == 3)
        begin
            if(nextstate == 1)
            begin
                target_locked <= 0;
            end
            target_update_timer = target_update_timer + 2;
        end
        if(TTU_state == 3 && target_update_timer == 62)
        begin
            trigger_radar_transmitter = 0;
            distance_to_target = 0;
            target_locked = 0;
            listen_for_echo_timer = 0;
            target_update_timer = 0;
            echo_start_time = 0;
            echo_end_time = 0;
            nextstate = S0;
            TTU_state = S0;
        end
        TTU_state <= nextstate;
        end

    always @(TTU_state or track_target_command or echo or listen_for_echo_timer or target_update_timer)
    begin
        case(TTU_state)
            0: if(track_target_command)
                nextstate = S1;
                else
                nextstate <= S0;
            1:
                begin
                #50;
                if(TTU_state != S0)
                begin
                    nextstate = S2;
                end
                end
            2: if(echo)
                begin
                    if($time % 5 == 0 && $time % 10 != 0)
                    begin
                        TTU_state <= S3;
                        target_update_timer = 0;
                    end
                    nextstate = S3;
                end
                else
                    if(listen_for_echo_timer == 20)
                    begin
                        TTU_state = S0;
                        listen_for_echo_timer <= 0;
                        nextstate = S0;
                        echo_start_time = 0;
                        echo_end_time = 0;
                    end
            3: if(track_target_command)
                nextstate = S1;
        endcase
    end
    
    always @(TTU_state or track_target_command or echo or listen_for_echo_timer or target_update_timer)
    begin
        case(TTU_state)
            0: if(track_target_command)
                begin
                trigger_radar_transmitter = 1;
                #50;
                trigger_radar_transmitter = 0;
                if(TTU_state != S0)
                begin
                    echo_start_time = $time;
                end
                end
            2: if(echo)
                begin
                    echo_end_time <= $time;
                    distance_to_target = (150*(echo_end_time - echo_start_time));
                    target_locked = 1;
                    listen_for_echo_timer <= -2;
                    target_update_timer = 0;
                end
            3: if(track_target_command)
                begin
                trigger_radar_transmitter = 1;
                #50;
                trigger_radar_transmitter = 0;
                if(TTU_state != S0)
                begin
                    echo_start_time = $time;
                end
                end
                else
                    if(target_update_timer == 62)
                    begin
                        trigger_radar_transmitter = 0;
                        distance_to_target = 0;
                        target_locked = 0;
                        listen_for_echo_timer = 0;
                        target_update_timer = 0;
                        echo_start_time = 0;
                        echo_end_time = 0;
                        nextstate = S0;
                        TTU_state = S0;
                    end
        endcase
    end

endmodule