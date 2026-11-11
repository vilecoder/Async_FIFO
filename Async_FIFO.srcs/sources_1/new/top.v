`timescale 1ns / 1ps


module top#(
    parameter data_width = 8,
    parameter A_size =3 )(
    
    input w_clk,
    input w_rst,
    input w_inc,
    input [data_width-1:0] w_data,
    input r_clk,
    input r_rst,
    input r_inc,
    output[data_width-1:0] r_data,
    output full,
    output empty
    );
    
    wire[A_size-1:0] w_addr,r_addr;
    wire [A_size:0] w_ptr_gray,r_ptr_gray;//gray ptr leaving domains
    wire [A_size:0] w2r_ptr,r2w_ptr;//gray ptr after synchronization
    
    fifo_mem_cntrl #(
        .data_width(data_width),
        .A_size(A_size)
        )u_mem (
        .w_clk  (w_clk),
        .w_data (w_data),
        .w_inc  (w_inc),
        .w_full (full),
        .w_addr (w_addr),
        .r_addr (r_addr),
        .r_data (r_data)
    );

    fifo_wr #(.A_size(A_size)) u_wr (
        .w_clk      (w_clk),
        .w_rst     (w_rst),
        .w_inc      (w_inc),
        .r2w_ptr    (r2w_ptr),
        .w_addr     (w_addr),
        .w_ptr_gray (w_ptr_gray),
        .full       (full)
    );

    fifo_rd #(.A_size(A_size)) u_rd (
        .r_clk      (r_clk),
        .r_rst     (r_rst),
        .r_inc      (r_inc),
        .w2r_ptr    (w2r_ptr),
        .r_addr     (r_addr),
        .r_ptr_gray (r_ptr_gray),
        .empty      (empty)
    );

    // write pointer -> read domain (read clock/reset)
    DF_sync #(.data_size(A_size + 1)) u_sync_w2r (
        .sync_clk  (r_clk),
        .sync_rst  (r_rst),
        .unsync_ip (w_ptr_gray),
        .sync_op   (w2r_ptr)
    );

    // read pointer -> write domain (write clock/reset)
    DF_sync #(.data_size(A_size + 1)) u_sync_r2w (
        .sync_clk  (w_clk),
        .sync_rst  (w_rst),
        .unsync_ip (r_ptr_gray),
        .sync_op   (r2w_ptr)
    );

endmodule
