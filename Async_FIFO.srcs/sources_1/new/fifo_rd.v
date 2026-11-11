`timescale 1ns / 1ps


module fifo_rd#(parameter A_size=3)(
    input r_clk,
    input r_rst,
    input r_inc,
    input [A_size:0] w2r_ptr,
    output [A_size-1:0] r_addr,
    output reg [A_size:0] r_ptr_gray,
    output reg empty
    );
    reg [A_size:0] r_ptr;
    wire [A_size:0] r_ptr_next;
    wire [A_size:0] gray_next;
    wire empty_next;
    
    assign r_ptr_next = r_ptr + (r_inc && !empty);
    assign gray_next  = (r_ptr_next >>1) ^ r_ptr_next;
    assign empty_next = (gray_next == w2r_ptr);
    assign r_addr = r_ptr[A_size-1:0];
    
    always@(posedge r_clk or negedge r_rst)begin
        if(!r_rst)begin
            r_ptr <=0;
            r_ptr_gray <=0;
            empty <= 1'b1;
        end
        else begin
            r_ptr <= r_ptr_next;
            r_ptr_gray <= gray_next;
            empty <= empty_next;
        end
    end
endmodule
