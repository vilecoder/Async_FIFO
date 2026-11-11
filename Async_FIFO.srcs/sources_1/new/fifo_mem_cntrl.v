`timescale 1ns / 1ps


module fifo_mem_cntrl#(
    parameter data_width = 8,
    parameter A_size = 3)(
    input w_clk,
    input [data_width-1:0] w_data,
    input w_inc,
    input w_full,
    input [A_size-1:0] w_addr,
    output [data_width-1:0] r_data,
    input [A_size-1:0] r_addr
    );
    localparam depth = 1<<A_size;
    reg [data_width-1:0] mem [depth-1:0];
    always@(posedge w_clk)begin
        if(w_inc && !w_full)
        begin   
            mem[w_addr] <= w_data;
        end  
    end
    
    assign r_data = mem[r_addr];
endmodule
