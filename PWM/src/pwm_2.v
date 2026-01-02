`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.12.2025 15:22:07
// Design Name: 
// Module Name: pwm_2
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


module pwm_2(
    input  wire       mclk,     
    output wire [0:0] led,      
    output wire       servo
);

   
    reg [21:0] pwm_counter = 22'd0;
    reg [7:0]  angle_cnt   = 8'd0;
    reg [16:0] control     = 17'd0;
    reg        servo_reg   = 1'b0;
    reg        toggle      = 1'b1;   
    always @(posedge mclk) begin
        pwm_counter <= (pwm_counter == 22'd2_499_999) ? 22'd0
                                                     : pwm_counter + 1'b1;
    end

    always @(posedge mclk) begin
        if (pwm_counter == 22'd0)
            angle_cnt <= angle_cnt + 1'b1;
    end

    always @(posedge mclk) begin
        if (pwm_counter == 22'd0) begin
            case (angle_cnt)

                
                8'd0   : begin toggle<=1; control<=17'd0;      end
                8'd32  : begin toggle<=1; control<=17'd31250;  end
                8'd64  : begin toggle<=1; control<=17'd62500;  end
                8'd96  : begin toggle<=1; control<=17'd93750;  end
                8'd128 : begin toggle<=1; control<=17'd125000; end

                
                8'd160 : begin toggle<=0; control<=17'd93750;  end
                8'd192 : begin toggle<=0; control<=17'd62500;  end
                8'd224 : begin toggle<=0; control<=17'd31250;  end
                8'd255 : begin toggle<=0; control<=17'd0;      end

                
                default: begin
                    case (angle_cnt[7])     
                        1'b0: begin          
                            toggle  <= 1;
                            control <= (angle_cnt * 17'd125000) >> 7;
                        end
                        1'b1: begin          
                            toggle  <= 0;
                            control <= ((8'd255-angle_cnt) * 17'd125000) >> 7;
                        end
                    endcase
                end

            endcase
        end
    end

    always @(posedge mclk) begin
        servo_reg <= (pwm_counter < (22'd125000 + control));
    end

    assign servo  = servo_reg;
    assign led[0] = toggle;

endmodule

