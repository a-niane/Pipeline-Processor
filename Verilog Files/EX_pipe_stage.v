`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Astou Niane
// 
// Create Date: 02/18/2021 11:30:41 AM
// Design Name: 
// Module Name: EX_pipe_stage
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

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    
    //wire for ALU_Control
    wire [3:0] ALU_Control;
    
    //wires for muxes
    wire [31:0] forward_A_result;
    wire [31:0] forward_B_result;
    wire [31:0] alu_in2;
    
    wire zero; //not output, but kept to contain value
    
    ALUControl ALU_Control_unit
    (
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control)
    );

    mux4 #(.mux_width(32)) forward_A_mux 
    (   .a(reg1), //first register (00)
        .b(mem_wb_write_back_result), //WB result (01)
        .c(ex_mem_alu_result), //EX result (10)
        .d(32'b0), //this one will never be an option (11)
        .sel(Forward_A),
        .y(forward_A_result) 
    );
    
    mux4 #(.mux_width(32)) forward_B_mux 
    (   .a(reg2), //second register (00)
        .b(mem_wb_write_back_result), //WB result (01)
        .c(ex_mem_alu_result), //EX result (10)
        .d(32'b0), //this one will never be an option (11)
        .sel(Forward_B),
        .y(alu_in2_out) //overall output 
    );
    
    mux2 #(.mux_width(32)) alu_mux 
    (   .a(alu_in2_out),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(alu_in2)
    );
     
    ALU alu_inst 
    (   .a(forward_A_result),
        .b(alu_in2),
        .alu_control(ALU_Control),
        .zero(zero), 
        .alu_result(alu_result) 
     );
       
endmodule