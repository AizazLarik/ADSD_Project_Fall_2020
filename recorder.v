`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2020 05:40:01 PM
// Design Name: 
// Module Name: recorder
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
///////////////////////////////////////////////////////////////////////////////
//
// Record/playback
//
///////////////////////////////////////////////////////////////////////////////

  module recorder(
  input wire clk_in,              // 100MHz system clock
  input wire rst_in,               // 1 to reset to initial state
  input wire record_in,            // 0 for playback, 1 for record
  input wire ready_in,             // 1 when data is available
  input wire filter_in,            // 1 when using low-pass filter
  input wire signed [7:0] mic_in,         // 8-bit PCM data from mic
  output reg signed [7:0] data_out       // 8-bit PCM data to headphone
); 
    wire [7:0] tone_750;
    wire [7:0] tone_440;
    integer i=0;
    integer full=0;
    //generate a 750 Hz tone
    sine_generator  tone750hz (   .clk_in(clk_in), .rst_in(rst_in), 
                                 .step_in(ready_in), .amp_out(tone_750));
    //generate a 440 Hz tone
    sine_generator  #(.PHASE_INCR(32'd39370534)) tone440hz(.clk_in(clk_in), .rst_in(rst_in), 
                               .step_in(ready_in), .amp_out(tone_440));                          
    reg [7:0] data_to_bram;
    wire [7:0] data_from_bram;
    reg [15:0] addr=16'd0;
    reg [7: 0] array_mem [(2**16)-1 :0];
   // wire wea=1;
    integer ready=0;
    blk_mem_gen_0 mybram(.addra(addr), .clka(clk_in), .dina(data_to_bram), .douta(data_from_bram), 
                    .ena(1), .wea(record_in));                                  
            
//    always @(posedge clk_in)begin
//            data_out = filter_in?tone_440:tone_750; //send tone immediately to output
//            data_out = mic_in; //send tone immediately to output
//    end  

            
        always @(posedge clk_in)begin   
            if(record_in) begin
                if (addr <65535 && full==0)
                begin
                    if (ready_in==1 && ready==0) begin
                        data_to_bram [addr] = mic_in;
                        //data_out = mic_in;
                        data_out = data_from_bram [addr];
                        ready = ready + 1;
                        addr = addr + 1; 
                    end
                    
                    else if(ready_in == 1 && ready!=0 && ready !=7)begin
                        ready = ready + 1;
                    end
                    
                    else if(ready_in == 1 && ready == 7)
                    ready = 0;
                end
                
                else if(addr == 65535) begin
                     full = 1;
                     addr = 0;
                     ready = 0;
                end
             end
        
             else begin
             //data_out = mic_in;
                    if(ready_in==1 && full==1 && ready==0 )begin
                        data_out = mic_in;
                       // array_mem[addr] = data_from_bram[addr];
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        addr = addr+1;
                        data_out = data_from_bram[addr];
                        ready = ready + 1;
                        addr = addr +1;
                    end
                    
                    else if(ready_in == 1 && ready!=0 && ready !=7 && full==1)
                        ready = ready + 1;
                    
                    else if(ready_in == 1 && ready == 7 && full==1)
                        ready = 0;
             end 
        end                          
endmodule