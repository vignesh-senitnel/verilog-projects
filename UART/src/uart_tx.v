`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 17:59:32
// Design Name: 
// Module Name: uart_tx
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
module uart_tx #(
    parameter integer CLK_FREQ = 125_000_000, // Hz
    parameter integer BAUD_RATE = 9600         // bits per second
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       wr_enb,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy
);


    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    localparam integer BAUD_CNT_WIDTH = $clog2(BAUD_DIV);

    reg [BAUD_CNT_WIDTH-1:0] baud_cnt;
    reg                      baud_tick;

    always @(posedge clk) begin
        if (rst) begin
            baud_cnt  <= 0;
            baud_tick <= 1'b0;
        end
        else if (baud_cnt == BAUD_DIV - 1) begin
            baud_cnt  <= 0;
            baud_tick <= 1'b1;   
        end
        else begin
            baud_cnt  <= baud_cnt + 1'b1;
            baud_tick <= 1'b0;
        end
    end

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] tx_shift;


    initial begin
        tx   = 1'b1;  
        busy = 1'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            tx       <= 1'b1;
            busy     <= 1'b0;
            bit_cnt  <= 3'd0;
            tx_shift <= 8'd0;
        end
        else begin
            case (state)

            IDLE: begin
                tx   <= 1'b1;
                busy <= 1'b0;
                if (wr_enb) begin
                    tx_shift <= data_in;
                    bit_cnt  <= 3'd0;
                    busy     <= 1'b1;
                    state    <= START;
                end
            end

            START: begin
                busy <= 1'b1;
                if (baud_tick) begin
                    tx    <= 1'b0;  
                    state <= DATA;
                end
            end

            DATA: begin
                busy <= 1'b1;
                if (baud_tick) begin
                    tx       <= tx_shift[0];     
                    tx_shift <= tx_shift >> 1;
                    if (bit_cnt == 3'd7)
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1'b1;
                end
            end

            STOP: begin
                busy <= 1'b1;
                if (baud_tick) begin
                    tx    <= 1'b1;  
                    busy  <= 1'b0;
                    state <= IDLE;
                end
            end

            default: begin
                state <= IDLE;
                tx    <= 1'b1;
                busy  <= 1'b0;
            end

            endcase
        end
    end

endmodule

