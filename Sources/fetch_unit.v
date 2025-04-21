`timescale 1ns / 1ps

module fetch_unit(
    input wire clk,
    input wire reset,
    input wire isBranchTaken,
    input wire [31:0] branchPC,
    output reg [31:0] inst,
    output reg [31:0] pc_out
);
    reg [31:0] pc;
    reg [7:0] instruction_memory [0:1048575]; // Byte-addressable memory (1MB)
    initial
    begin
    instruction_memory[0] = 8'h4C;
    instruction_memory[1] = 8'h00;
    instruction_memory[2] = 8'h00;
    instruction_memory[3] = 8'h46;
    instruction_memory[4] = 8'h4C;
    instruction_memory[5] = 8'h80;
    instruction_memory[6] = 8'hFF;
    instruction_memory[7] = 8'hBA;
    instruction_memory[8] = 8'h00;
    instruction_memory[9] = 8'h48;
    instruction_memory[10] = 8'h00;
    instruction_memory[11] = 8'h00;
    instruction_memory[12] = 8'h04;
    instruction_memory[13] = 8'h40;
    instruction_memory[14] = 8'h00;
    instruction_memory[15] = 8'h01;
    end
    wire [31:0] pc_plus;
    assign pc_plus = pc + 4;

    wire [31:0] next_pc;
    assign next_pc = isBranchTaken ? branchPC : pc_plus;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else
            pc <= next_pc;
    end
    

    always @(*) begin
        // Assemble 4 bytes into 1 word (Big Endian)
        inst = {instruction_memory[pc], instruction_memory[pc + 1], instruction_memory[pc + 2], instruction_memory[pc + 3]};
        pc_out = pc;
    end
endmodule