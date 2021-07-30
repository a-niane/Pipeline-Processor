`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Astou Niane
// 
// Create Date: 02/18/2021 02:10:56 AM
// Design Name: 
// Module Name: mips_32
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

module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
    //Note, all individual wires are outputs of their respective modules
    
    // IF_pipe_stage (instruction fetch) wires 
    wire [9:0] pc_plus4;
    wire [31:0] instr;
    
    //Pipe_reg_en (IF-ID) wires
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
    
    //ID_pipe_stage (instruction decode) wires
    wire [31:0] reg1;
    wire [31:0] reg2;
    wire [31:0] imm_value;
    wire [9:0] branch_address;
    wire [9:0] jump_address;
    wire branch_taken;
    wire [4:0] destination_reg;
    wire mem_to_reg;
    wire [1:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    wire jump;
    
    //Pipe_reg (ID-EX) wires
    wire [31:0] id_ex_instr;
    wire [31:0] id_ex_reg1;
    wire [31:0] id_ex_reg2;
    wire [31:0] id_ex_imm_value;
    wire [4:0] id_ex_destination_reg;
    wire id_ex_mem_to_reg;
    wire [1:0] id_ex_alu_op;
    wire id_ex_mem_read;
    wire id_ex_mem_write;
    wire id_ex_alu_src;
    wire id_ex_reg_write;
    
    //Hazard Detection wires
    wire Data_Hazard;
    wire IF_Flush;
    
    //EX_pipe_stage (execution) wires
    wire [31:0] alu_in2_out;
    wire [31:0] alu_result;
    
    //Forwarding units
    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
    
    //Pipe_reg (EX-MEM) wires
    wire [31:0] ex_mem_instr;
    wire [4:0] ex_mem_destination_reg;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_alu_in2_out;
    wire ex_mem_mem_to_reg;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_reg_write;
    
    //Memory
    wire [31:0] mem_read_data;
    
    //Pipe_reg (MEM-WB) wires
    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_read_data;
    wire mem_wb_mem_to_reg;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_destination_reg;
    
    //Writeback
    wire [31:0] write_back_data;
    
// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here    
    IF_pipe_stage instruction_fetch 
    (   .clk(clk),
        .reset(reset),
        .en(Data_Hazard), //Hazard_Detection
        .branch_address(branch_address), //instruction_decode 
        .jump_address(jump_address), //instruction_decode 
        .branch_taken(branch_taken), //instruction_decode 
        .jump(jump), //instruction_decode 
        //outputs
        .pc_plus4(pc_plus4),
        .instr(instr)
    );
        
///////////////////////////// IF/ID registers
    // Complete your code here
    pipe_reg_en #(.WIDTH(10)) if_id_pipe_pc4
    (   .clk(clk),
        .reset(reset),
        .en(Data_Hazard), //Hazard_Detection
        .flush(IF_Flush), //Hazard_Detection
        .d(pc_plus4), //instruction_fetch
        //outputs
        .q(if_id_pc_plus4)
    );
    
    pipe_reg_en #(.WIDTH(32)) if_id_pipe_instr
    (   .clk(clk),
        .reset(reset),
        .en(Data_Hazard), //Hazard_Detection
        .flush(IF_Flush), //Hazard_Detection
        .d(instr), //instruction_fetch
        //outputs
        .q(if_id_instr)
    );

///////////////////////////// Instruction Decode 
	// Complete your code here 
    ID_pipe_stage instruction_decode 
    (   .clk(clk),
        .reset(reset),
        .pc_plus4(if_id_pc_plus4), //IF-ID pipe
        .instr(if_id_instr), //IF-ID pipe
        .mem_wb_reg_write(mem_wb_reg_write), //MEM-WB pipe
        .mem_wb_write_reg_addr(mem_wb_destination_reg), //MEM-WB pipe
        .mem_wb_write_back_data(write_back_data), //writeback
        .Data_Hazard(Data_Hazard), //Hazard_Detection
        .Control_Hazard(IF_Flush), //Hazard_Detection
        //outputs
        .reg1(reg1),
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump)
    );
    
///////////////////////////// ID/EX registers 
	// Complete your code here 
    pipe_reg #(.WIDTH(32)) id_ex_pipe_instr
    (   .clk(clk),
        .reset(reset),
        .d(if_id_instr), //IF-ID pipe
        //output
        .q(id_ex_instr)
    );
    
    pipe_reg #(.WIDTH(32)) id_ex_pipe_reg1
    (   .clk(clk),
        .reset(reset),
        .d(reg1), //instruction_decode 
        //output
        .q(id_ex_reg1)
    );
    
    pipe_reg #(.WIDTH(32)) id_ex_pipe_reg2
    (   .clk(clk),
        .reset(reset),
        .d(reg2), //instruction_decode 
        //output
        .q(id_ex_reg2)
    );
    
    pipe_reg #(.WIDTH(32)) id_ex_pipe_imm
    (   .clk(clk),
        .reset(reset),
        .d(imm_value), //instruction_decode 
        //output
        .q(id_ex_imm_value)
    );
    
    pipe_reg #(.WIDTH(5)) id_ex_pipe_destin
    (   .clk(clk),
        .reset(reset),
        .d(destination_reg), //instruction_decode 
        //output
        .q(id_ex_destination_reg)
    );
    
    pipe_reg #(.WIDTH(1)) id_ex_pipe_memreg
    (   .clk(clk),
        .reset(reset),
        .d(mem_to_reg), //instruction_decode 
        //output
        .q(id_ex_mem_to_reg)
    );
    
    pipe_reg #(.WIDTH(2)) id_ex_pipe_aluop
    (   .clk(clk),
        .reset(reset),
        .d(alu_op), //instruction_decode 
        //output
        .q(id_ex_alu_op)
    );
    
    pipe_reg #(.WIDTH(1)) id_ex_pipe_memread
    (   .clk(clk),
        .reset(reset),
        .d(mem_read), //instruction_decode 
        //output
        .q(id_ex_mem_read)
    );
    
    pipe_reg #(.WIDTH(1)) id_ex_pipe_memwrite
    (   .clk(clk),
        .reset(reset),
        .d(mem_write), //instruction_decode 
        //output
        .q(id_ex_mem_write)
    );
    
    pipe_reg #(.WIDTH(1)) id_ex_pipe_alusrc
    (   .clk(clk),
        .reset(reset),
        .d(alu_src), //instruction_decode 
        //output
        .q(id_ex_alu_src)
    );

    pipe_reg #(.WIDTH(1)) id_ex_pipe_regwrite
    (   .clk(clk),
        .reset(reset),
        .d(reg_write), //instruction_decode 
        //output
        .q(id_ex_reg_write)
    );
  
///////////////////////////// Hazard_detection unit
	// Complete your code here 
    Hazard_detection hazard_unit
    (   .id_ex_mem_read(id_ex_mem_read), //ID-EX pipe
        .id_ex_destination_reg(id_ex_destination_reg), //ID-EX pipe
        .if_id_rs(if_id_instr[25:21]), //IF-ID pipe
        .if_id_rt(if_id_instr[20:16]), //IF-ID pipe
        .branch_taken(branch_taken), //instruction_decode 
        .jump(jump), //instruction_decode 
        //outputs
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush)
    );
           
///////////////////////////// Execution    
	// Complete your code here
	EX_pipe_stage execution
	(
	   .id_ex_instr(id_ex_instr), //ID-EX pipe
	   .reg1(id_ex_reg1), //ID-EX pipe
	   .reg2(id_ex_reg2), //ID-EX pipe
	   .id_ex_imm_value(id_ex_imm_value), //ID-EX pipe
	   .ex_mem_alu_result(ex_mem_alu_result), //EX-MEM pipe
	   .mem_wb_write_back_result(write_back_data), //writeback
	   .id_ex_alu_src(id_ex_alu_src), //ID-EX pipe
	   .id_ex_alu_op(id_ex_alu_op), //ID-EX pipe
	   .Forward_A(Forward_A), //EX_Forwarding_unit
	   .Forward_B(Forward_B), //EX_Forwarding_unit
	   //outputs
	   .alu_in2_out(alu_in2_out),
	   .alu_result(alu_result)
	);
        
///////////////////////////// Forwarding unit
	// Complete your code here 
    EX_Forwarding_unit forwarding
    (   .ex_mem_reg_write(ex_mem_reg_write), //EX-MEM pipe
        .ex_mem_write_reg_addr(ex_mem_destination_reg), //EX-MEM pipe
        .id_ex_instr_rs(id_ex_instr[25:21]), //ID-EX pipe
        .id_ex_instr_rt(id_ex_instr[20:16]), //ID-EX pipe
        .mem_wb_reg_write(mem_wb_reg_write), //MEM-WB pipe
        .mem_wb_write_reg_addr(mem_wb_destination_reg), //MEM-WB pipe
        //outputs
        .Forward_A(Forward_A),
        .Forward_B(Forward_B)
    );
    
///////////////////////////// EX/MEM registers
	// Complete your code here
    pipe_reg #(.WIDTH(32)) ex_mem_pipe_instr
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_instr), //ID-EX pipe
        //output
        .q(ex_mem_instr) //This wire is not used after this
    );
    
    pipe_reg #(.WIDTH(5)) ex_mem_pipe_destin
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_destination_reg), //ID-EX pipe
        //output
        .q(ex_mem_destination_reg)
    );
    
    pipe_reg #(.WIDTH(32)) ex_mem_pipe_alu
    (   .clk(clk),
        .reset(reset),
        .d(alu_result), //execution
        //output
        .q(ex_mem_alu_result)
    );
    
    pipe_reg #(.WIDTH(32)) ex_mem_pipe_aluin2
    (   .clk(clk),
        .reset(reset),
        .d(alu_in2_out), //execution
        //output
        .q(ex_mem_alu_in2_out)
    );
 
    pipe_reg #(.WIDTH(1)) ex_mem_pipe_memreg
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_to_reg), //ID-EX pipe
        //output
        .q(ex_mem_mem_to_reg)
    );
    
    pipe_reg #(.WIDTH(1)) ex_mem_pipe_memread
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_read), //ID-EX pipe
        //output
        .q(ex_mem_mem_read)
    );
    
    pipe_reg #(.WIDTH(1)) ex_mem_pipe_memwrite
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_mem_write), //ID-EX pipe
        //output
        .q(ex_mem_mem_write)
    );
    
    pipe_reg #(.WIDTH(1)) ex_mem_pipe_regwrite
    (   .clk(clk),
        .reset(reset),
        .d(id_ex_reg_write), //ID-EX pipe
        //output
        .q(ex_mem_reg_write)
    );
    
///////////////////////////// memory    
	// Complete your code here 
    data_memory data_mem 
    (   .clk(clk),
        .mem_access_addr(ex_mem_alu_result), //EX-MEM pipe
        .mem_write_data(ex_mem_alu_in2_out), //EX-MEM pipe
        .mem_write_en(ex_mem_mem_write),//EX-MEM pipe
        .mem_read_en(ex_mem_mem_read), //EX-MEM pipe
        //output
        .mem_read_data(mem_read_data)
    );

    ///////////////////////////// MEM/WB registers  
	// Complete your code here
    pipe_reg #(.WIDTH(32)) mem_wb_pipe_result
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_alu_result), //EX-MEM pipe
        //output
        .q(mem_wb_alu_result)
    );
    
    pipe_reg #(.WIDTH(32)) mem_wb_pipe_memread
    (   .clk(clk),
        .reset(reset),
        .d(mem_read_data), //memory
        //output
        .q(mem_wb_mem_read_data)
    );
    
    pipe_reg #(.WIDTH(1)) mem_wb_pipe_memreg
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_mem_to_reg), //EX-MEM pipe
        //output
        .q(mem_wb_mem_to_reg)
    );
    
    pipe_reg #(.WIDTH(1)) mem_wb_pipe_regwrite
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_reg_write), //EX-MEM pipe
        //output
        .q(mem_wb_reg_write)
    );
    
    pipe_reg #(.WIDTH(5)) mem_wb_pipe_destin
    (   .clk(clk),
        .reset(reset),
        .d(ex_mem_destination_reg), //EX-MEM pipe
        //output
        .q(mem_wb_destination_reg)
    );

///////////////////////////// writeback    
	// Complete your code here 
    mux2 #(.mux_width(32)) writeback 
    (   .a(mem_wb_alu_result), //MEM-WB pipe
        .b(mem_wb_mem_read_data), //MEM-WB pipe
        .sel(mem_wb_mem_to_reg), //MEM-WB pipe
        //output
        .y(write_back_data)
    );  

    assign result = write_back_data;
endmodule
