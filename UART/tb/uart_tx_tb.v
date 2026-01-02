`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 18:00:32
// Design Name: 
// Module Name: uart_tx_tb
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

module uart_tx_tb;

    parameter integer CLK_FREQ  = 125_000_000; // Hz
    parameter integer BAUD_RATE = 9600;         // bps

    localparam integer CLK_PERIOD_NS = 1_000_000_000 / CLK_FREQ;

    reg clk;
    reg rst;
    reg wr_enb;
    reg [7:0] data_in;
    wire tx;
    wire busy;

    // DUT
    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .wr_enb (wr_enb),
        .data_in(data_in),
        .tx     (tx),
        .busy   (busy)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    // Reset & initialization
    initial begin
        rst      = 1'b1;
        wr_enb  = 1'b0;
        data_in = 8'd0;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    // Send byte task
    task send_byte;
        input [7:0] ch;
        begin
            @(posedge clk);
            while (busy) @(posedge clk); // wait till TX idle
            data_in = ch;
            wr_enb  = 1'b1;
            @(posedge clk);
            wr_enb  = 1'b0;
        end
    endtask

    // Continuous transmission loop
    initial begin
        @(negedge rst);
        forever begin
            send_byte(8'h61); // a
            send_byte(8'h73); // s
            send_byte(8'h74); // t
            send_byte(8'h72); // r
            send_byte(8'h6F); // o
            send_byte(8'h70); // p
            send_byte(8'h68); // h
            send_byte(8'h65); // e
            send_byte(8'h6C); // l
        end
    end

    // Monitor
    initial begin
        $monitor("T=%0t ns | TX=%b | BUSY=%b | DATA=%h",
                 $time, tx, busy, data_in);
    end

endmodule




