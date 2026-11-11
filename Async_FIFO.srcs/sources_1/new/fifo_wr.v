`timescale 1ns / 1ps

module fifo_wr#(    
    parameter A_size =3)(
    input w_clk,
    input w_rst,
    input w_inc,
    input [A_size:0] r2w_ptr,
    output [A_size-1:0] w_addr,
    output reg [A_size:0] w_ptr_gray,
    output reg full
    );
    
    reg [A_size:0] w_ptr;
    wire [A_size:0] w_ptr_next;
    wire [A_size:0] gray_next;
    wire full_next;
     
    assign w_ptr_next = w_ptr + (!full && w_inc);// next pointer 
    assign gray_next = (w_ptr_next >>1)^w_ptr_next;// binary to gray in single line 
    assign full_next = (gray_next == {~r2w_ptr[A_size:A_size-1],r2w_ptr[A_size-2:0]}); // full pe top 2 bits inverted then compared with gray_next if true then full_next =1
    assign w_addr = w_ptr[A_size-1:0];// -1 bcz no wrap around bit included
    
    always@( posedge w_clk or negedge w_rst) begin
       if(!w_rst)
        begin
            w_ptr<=0;
            w_ptr_gray <=0;
            full <=0;
        end 
        else
            begin
                w_ptr <= w_ptr_next;
                w_ptr_gray <= gray_next;
                full <= full_next;
            end
    end
    
endmodule
