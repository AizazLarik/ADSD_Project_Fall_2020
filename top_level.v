`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2021 04:12:00 PM
// Design Name: 
// Module Name: top_level
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

//Top level module (should not need to change except to uncomment ADC module)

module top_level(   input clk_100mhz,
                    input [15:0] sw,
                    input btnc, btnu, btnd, btnr, btnl,
                    input vauxp3,
                    input vauxn3,
                    input vn_in,
                    input vp_in,
                    output wire [15:0] led,
                    output wire aud_pwm,
                    output wire aud_sd
    );  
    parameter SAMPLE_COUNT = 2082;//gets approximately (will generate audio at approx 48 kHz sample rate.
    
    reg [15:0] sample_counter;
    wire [11:0] adc_data;
    reg [11:0] sampled_adc_data;
    wire sample_trigger;
    wire adc_ready;
    wire enable;
    wire [7:0] recorder_data;             
    wire [7:0] vol_out;
    wire pwm_val; //pwm signal (HI/LO)
    
    assign aud_sd = 1;
    assign led = sw; //just to look pretty 
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);

//    always @(posedge clk_100mhz)begin
//        if (sample_counter == SAMPLE_COUNT)begin
//            sample_counter <= 16'b0;
//        end else begin
//            sample_counter <= sample_counter + 16'b1;
//        end
//        if (sample_trigger) begin
//            sampled_adc_data <= {~adc_data[11],adc_data[10:0]}; //convert to signed. incoming data is offset binary
//            //https://en.wikipedia.org/wiki/Offset_binary
//        end
//    end

    always @(posedge clk_100mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 32'b0;
        end else begin
            sample_counter <= sample_counter + 32'b1;
        end
        if (sample_trigger)
            sampled_adc_data <= {~adc_data[11],adc_data[10:0]}; //convert from offset binary to 2's comp.
    end


    //ADC uncomment when activating!
    xadc_wiz_0 my_adc ( .dclk_in(clk_100mhz), .daddr_in(8'h13), //read from 0x13 for a
                        .vauxn3(vauxn3),.vauxp3(vauxp3),
                        .vp_in(1),.vn_in(1),
                        .di_in(16'b0),
                        .do_out(adc_data),.drdy_out(adc_ready),
                        .den_in(1), .dwe_in(0));
 
    recorder myrec( .clk_in(clk_100mhz),.rst_in(btnd),
                    .record_in(btnc),.ready_in(sample_trigger),
                    .filter_in(sw[0]),.mic_in(sampled_adc_data[11:4]),
                    .data_out(recorder_data));   
                                                                                            
                                                                                            
    volume_control vc (.vol_in(sw[15:13]),
                       .signal_in(recorder_data), .signal_out(vol_out));
    pwm pwm_1 (.clk_in(clk_100mhz), .rst_in(btnd), .level_in({~vol_out[7],vol_out[6:0]}), .pwm_out(pwm_val));
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
endmodule