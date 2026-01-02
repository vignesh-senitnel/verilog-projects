`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2025 15:25:07
// Design Name: 
// Module Name: tb_pwm
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


module tb_pwm;


    reg        mclk;
    wire       servo;
    wire [0:0] led;
    real       angle;

    pwm_2 dut (
        .mclk(mclk),
        .servo(servo),
        .led(led)
    );

    
    initial begin
        mclk = 0;
        forever #4 mclk = ~mclk;
    end

    always @(posedge mclk) begin
        if (dut.pwm_counter == 22'd0) begin
            if (dut.angle_cnt <= 8'd128)
                angle = (dut.angle_cnt * 180.0) / 128.0;
            else
                angle = ((255.0 - dut.angle_cnt) * 180.0) / 127.0;

            $display("Cnt=%3d  Dir=%b  Angle=%6.2f°  Control=%6d",
                     dut.angle_cnt, led[0], angle, dut.control);
        end
    end

    initial begin
        #900000000;      
        $finish;
    end

endmodule

