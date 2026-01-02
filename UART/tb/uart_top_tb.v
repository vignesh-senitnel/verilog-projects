`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 18:34:18
// Design Name: 
// Module Name: uart_top_tb
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

`timescale 1ns/1ps

module uart_top_tb;

    parameter integer CLK_FREQ  = 125_000_000;
    parameter integer BAUD_RATE = 9600;

    localparam CLK_PERIOD_NS = 1_000_000_000 / CLK_FREQ;

    reg clk;
    reg rst;
    reg wr_enb;
    reg [7:0] tx_data;

    wire tx;
    wire [7:0] rx_data;
    wire rx_valid;

    uart_top #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .wr_enb  (wr_enb),
        .tx_data (tx_data),
        .tx      (tx),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );


    initial begin
        clk = 0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end


    initial begin
        rst = 1;
        wr_enb = 0;
        tx_data = 8'd0;
        repeat (5) @(posedge clk);
        rst = 0;
    end


    task send_and_wait;
        input [7:0] ch;
        begin
      
            @(posedge clk);
            tx_data = ch;
            wr_enb  = 1'b1;
            @(posedge clk);
            wr_enb  = 1'b0;

         
            @(posedge rx_valid);
        end
    endtask

 
    initial begin
        @(negedge rst);
        forever begin
            send_and_wait("a");
            send_and_wait("s");
            send_and_wait("t");
            send_and_wait("r");
            send_and_wait("o");
            send_and_wait("p");
            send_and_wait("h");
            send_and_wait("e");
            send_and_wait("l");
        end
    end

endmodule


