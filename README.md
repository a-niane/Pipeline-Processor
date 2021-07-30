# Pipeline-Processor
Implemented Verilog on Vivado 2019.

The objective of this lab is to pipeline the single-cycle processor previously created. The purpose of doing so is to optimize and improve the performance of the processor. This is done by increasing instruction throughput (the amount of instruction performed within one clock cycle) and keeping multiple stages of the processor busy at all times.

Additionally, we implement a form of hazard detection and forwarding meant to avoid structural,
data, and control hazards that can prevent a proper instruction from being executed. In addition
to the ten modules from the original single-cycle processor, here are the following new modules
created to be used in pipelining:
1. IF_pipe_stage: Reads and increments program counter, keeping track of jump and branch statements to initiate instructions in instruction_memory.
2. Pipe_reg_en: Stores data needed in the next stage of pipeline and consists of a flip-flop determining whether an instruction is sent out immediately or not at all.
3. ID_pipe_stage: Determines control signals, jump and branch addresses, and other values necessary to perform the instruction’s different processes.
4. Pipe_reg: Sends signals from previous pipe stages into the next stages.
5. Hazard_detection: Detects potential instruction hazards caused by branch/jump statements and stalls pipeline by inserting NOP instructions.
6. Mux4: Uses a 2-bit selector to choose between four inputs to pass as a signal.
7. EX_pipe_stage: Executes or addresses calculation in its ALU passing previous signals.
8. EX_Forwarding_unit: Forwards data from registers and memory back to the execution stage.
