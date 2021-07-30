`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Astou Niane
// 
// Create Date: 02/18/2021 07:21:42 AM
// Design Name: 
// Module Name: Data_Hazard
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

module Hazard_detection(
    input id_ex_mem_read,
    input [4:0] id_ex_destination_reg,
    input [4:0] if_id_rs, if_id_rt,
    input branch_taken, jump,
    output reg Data_Hazard,
    output reg IF_Flush
    );
    
	// Copy the code of this module from the lab manual.  
	always @(*)
    begin
        if (( id_ex_mem_read == 1'b1) & (( id_ex_destination_reg == if_id_rs ) | ( id_ex_destination_reg == if_id_rt )) )
            Data_Hazard = 1'b0;
        else
            Data_Hazard = 1'b1;
        
        IF_Flush = branch_taken | jump ;
    end
	
endmodule

