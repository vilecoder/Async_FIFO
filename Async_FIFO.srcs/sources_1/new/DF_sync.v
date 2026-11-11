`timescale 1ns / 1ps

module DF_sync#( parameter data_size = 4)(  
    input sync_clk,
    input sync_rst,
    input [data_size-1:0] unsync_ip,
    
    output reg [data_size-1:0] sync_op
    );
    reg [data_size-1:0] meta_flop;
    
    always@(posedge sync_clk or negedge sync_rst )begin
        if(!sync_rst)
            begin
                meta_flop <=0;
                sync_op <= 0;
            end
        else begin
            meta_flop <= unsync_ip;
            sync_op <= meta_flop;
        end
    end
endmodule
