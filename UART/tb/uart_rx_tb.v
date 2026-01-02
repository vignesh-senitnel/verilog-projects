`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 18:26:53
// Design Name: 
// Module Name: uart_rx_tb
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
`timescale 1ns / 1ps

module uart_rx_tb;

   
    parameter integer CLK_FREQ  = 125_000_000; // Hz
    parameter integer BAUD_RATE = 9600;         // bps

    localparam integer CLK_PERIOD_NS = 1_000_000_000 / CLK_FREQ;
    localparam integer BIT_TIME_NS   = 1_000_000_000 / BAUD_RATE;


    reg        clk;
    reg        rst;
    reg        rx;
    wire [7:0] data_out;
    wire       data_valid;


    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .rx        (rx),
        .data_out  (data_out),
        .data_valid(data_valid)
    );


    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end


    initial begin
        rst = 1'b1;
        rx  = 1'b1;   // idle line
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end


    task send_uart_byte;
        input [7:0] ch;
        integer i;
        begin
        
            rx = 1'b0;
            #(BIT_TIME_NS);

       
            for (i = 0; i < 8; i = i + 1) begin
                rx = ch[i];
                #(BIT_TIME_NS);
            end

            
            rx = 1'b1;
            #(BIT_TIME_NS);
        end
    endtask

    initial begin
        @(negedge rst);

        forever begin
            send_uart_byte(8'h61); // a
            send_uart_byte(8'h73); // s
            send_uart_byte(8'h74); // t
            send_uart_byte(8'h72); // r
            send_uart_byte(8'h6F); // o
            send_uart_byte(8'h70); // p
            send_uart_byte(8'h68); // h
            send_uart_byte(8'h65); // e
            send_uart_byte(8'h6C); // l

            #(10 * BIT_TIME_NS);   
        end
    end

    /
    initial begin
        $monitor("T=%0t ns | RX=%b | DATA_OUT=%h | VALID=%b",
                 $time, rx, data_out, data_valid);
    end

endmodule

