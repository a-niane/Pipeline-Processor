`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Astou Niane
// 
// Create Date: 02/18/2021 10:37:51 AM
// Design Name: 
// Module Name: ID_pipe_stage
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

module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard, //IF_flush from Hazard_Detection
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    //wires for control output (note that out_reg_dst is not an ultimate output)
    wire out_reg_dst , out_reg_write, out_alu_src, out_mem_read, out_mem_write, out_mem_to_reg;
    wire [1:0] out_alu_op;
    wire out_branch;
    
    //non-module outputs
    wire error; //data_hazard and control_hazard
    wire[27:0] imm_value_shifted; //jump address
    wire equality_test; //compares registers for branch
    wire [31:0] out_jump_addr; //after shift_left2 for jump address
    
    control control_unit 
    (
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(out_reg_dst), 
        .mem_to_reg(out_mem_to_reg),
        .alu_op(out_alu_op),
        .mem_read(out_mem_read),  
        .mem_write(out_mem_write),
        .alu_src(out_alu_src),
        .reg_write(out_reg_write),
        .branch(out_branch),
        .jump(jump) 
    ); 
    
    assign error = ~Data_Hazard | Control_Hazard; //for muxes
    
    mux2 #(.mux_width(1)) mem_to_reg_mux 
    (   .a(out_mem_to_reg),
        .b(1'b0), 
        .sel(error),
        .y(mem_to_reg) 
    );
    
    mux2 #(.mux_width(2)) alu_op_mux 
    (   .a(out_alu_op),
        .b(2'b00), 
        .sel(error),
        .y(alu_op) 
    );
    
    mux2 #(.mux_width(1)) mem_read_mux 
    (   .a(out_mem_read),
        .b(1'b0), 
        .sel(error),
        .y(mem_read) 
    );
    
    mux2 #(.mux_width(1)) mem_write_mux 
    (   .a(out_mem_write),
        .b(1'b0), 
        .sel(error),
        .y(mem_write) 
    );
    
    mux2 #(.mux_width(1)) alu_src_mux 
    (   .a(out_alu_src),
        .b(1'b0), 
        .sel(error),
        .y(alu_src) 
    );
    
    mux2 #(.mux_width(1)) reg_write_mux 
    (   .a(out_reg_write),
        .b(1'b0), 
        .sel(error),
        .y(reg_write) 
    );
    
    assign out_jump_addr = {pc_plus4[31:28], instr[25:0] << 2}; 
    assign jump_address = out_jump_addr[9:0];
    
    register_file reg_file 
    (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2)
    ); 

    assign equality_test = (( reg1 ^ reg2 )== 32'd0) ? 1'b1: 1'b0; //using xor to test
    assign branch_taken = out_branch & equality_test; 
    
    sign_extend sign_ex_inst 
    (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value) 
    ); 
    
    assign imm_value_shifted = imm_value << 2;
    assign branch_address = imm_value_shifted[9:0] + pc_plus4;
    
    mux2 #(.mux_width(5)) reg_mux 
    (   .a(instr[20:16]),
        .b(instr[15:11]), 
        .sel(out_reg_dst),
        .y(destination_reg) 
    );

endmodule
