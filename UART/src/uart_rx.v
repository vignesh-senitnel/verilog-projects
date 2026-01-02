`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 18:24:27
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter integer CLK_FREQ  = 125_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg        data_valid
);

    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_DIV = BAUD_DIV / 2;
    localparam integer BAUD_CNT_WIDTH = $clog2(BAUD_DIV);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift;
    reg [BAUD_CNT_WIDTH-1:0] baud_cnt;

    // Reset / init
    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            baud_cnt   <= 0;
            bit_cnt    <= 0;
            shift      <= 0;
            data_out   <= 0;
            data_valid <= 1'b0;
        end else begin
            data_valid <= 1'b0; // 1-cycle pulse

            case (state)

            // ---------- IDLE ----------
            IDLE: begin
                if (rx == 1'b0) begin
                    baud_cnt <= HALF_DIV;   // sample mid start bit
                    state    <= START;
                end
            end

            START: begin
                if (baud_cnt == 0) begin
                    if (rx == 1'b0) begin   
                        baud_cnt <= BAUD_DIV - 1;
                        bit_cnt  <= 0;
                        state    <= DATA;
                    end else begin
                        state <= IDLE;      
                    end
                end else
                    baud_cnt <= baud_cnt - 1;
            end

           
            DATA: begin
                if (baud_cnt == 0) begin
                    shift <= {rx, shift[7:1]};  
                    baud_cnt <= BAUD_DIV - 1;

                    if (bit_cnt == 3'd7)
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                end else
                    baud_cnt <= baud_cnt - 1;
            end

           
            STOP: begin
                if (baud_cnt == 0) begin
                    if (rx == 1'b1) begin       
                        data_out   <= shift;
                        data_valid <= 1'b1;
                    end
                    baud_cnt <= 0;
                    bit_cnt  <= 0;
                    state    <= IDLE;
                end else
                    baud_cnt <= baud_cnt - 1;
            end

            endcase
        end
    end

endmodule
