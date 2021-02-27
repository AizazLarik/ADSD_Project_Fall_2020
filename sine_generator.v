`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2020 05:32:40 PM
// Design Name: 
// Module Name: sine_generator
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

module sine_generator ( input clk_in, input rst_in, //clock and reset
                        input step_in, //trigger a phase step (rate at which you run sine generator)
                        output wire [7:0] amp_out); //output phase   
   
//parameter PHASE_INCR = 32'b1000_0000_0000_0000_0000_0000_0000_0000>>5; //1/64th of 48 khz is 750 Hz
        parameter PHASE_INCR = 32'd39370534; //1MHz
//        parameter PHASE_INCR = 32'd2061585; //48KHz
//        parameter PHASE_INCR = 32'd858994; //20 KHz
//        parameter PHASE_INCR = 32'd644245; //15 KHz
//        parameter PHASE_INCR = 32'd429497; //10 KHz
//        parameter PHASE_INCR = 32'd42950; //1 KHz
//        parameter PHASE_INCR = 32'd32212; //750 Hz
//      parameter PHASE_INCR = 32'd18898; //440Hz
   
    reg [7:0] divider;
    reg [31:0] phase;
    wire [7:0] amp;
    
    assign amp_out = {~amp[7],amp[6:0]};
    
    sine_lut lut_1(.phase_in(phase[31:26]), .clk_in(clk_in), .amp_out(amp));
    
    always @(posedge clk_in)
    begin
        if (rst_in)
        begin
            divider <= 8'b0;
            phase <= 32'b0;
        end 
        
        else if (step_in)
        begin
            phase <= phase+PHASE_INCR;
        end
    end
endmodule

//module sine_gen_tb();
//reg clk_in, rst_in, step_in;
//wire [7:0] amp_out;

//sine_generator sin1(clk_in,rst_in,step_in,amp_out);

//initial
//begin
//   #00 clk_in = 0;  
//   forever  #5 clk_in = ~ clk_in;
//////   forever  #10.41 clk_in = ~ clk_in;
//end

//initial
//begin
//    #00 step_in = 1; 
//////    forever  #5 step_in = ~ step_in;
//end

//initial
//begin
//   #00 rst_in = 1; 
//    @(negedge clk_in) rst_in = 0;    
//end 
   
//initial #100000 $finish;
//endmodule