`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 18:33:42
// Design Name: 
// Module Name: uart_top
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

module uart_top #(
    parameter integer CLK_FREQ  = 125_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       wr_enb,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire [7:0] rx_data,
    output wire       rx_valid
);

   
    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk    (clk),
        .rst    (rst),
        .wr_enb (wr_enb),
        .data_in(tx_data),
        .tx     (tx),
        .busy   ()
    );

    
    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk       (clk),
        .rst       (rst),
        .rx        (tx),        
        .data_out  (rx_data),
        .data_valid(rx_valid)
    );

endmodule

