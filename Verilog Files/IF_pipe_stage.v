`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Astou Niane
// 
// Create Date: 02/18/2021 10:16:28 AM
// Design Name: 
// Module Name: IF_pipe_stage
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

module IF_pipe_stage(
    input clk, reset,
    input en, // from Hazard_Detection
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
    reg[9:0] pc; //holds current PC
    wire[9:0] branch_pc; //branch PC
    wire[9:0] jump_pc;//jump PC
    
// write your code here  
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            pc <= 10'b0000000000;
        else if (en)
            pc <= jump_pc; //after going through muxes and addition
    end
    
    mux2 #(.mux_width(10)) branch_mux //branch mux
    (   .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken), 
        .y(branch_pc)
    );
    
    mux2 #(.mux_width(10)) jump_mux //jump mux
    (   .a(branch_pc),
        .b(jump_address),
        .sel(jump), 
        .y(jump_pc) 
    );
    
    instruction_mem inst_mem 
    (
        .read_addr(pc), //after passing en
        .data(instr)
    ); 
    
    //outputs
    assign pc_plus4 = pc + 10'b0000000100; //value returns to first mux
           
endmodule
