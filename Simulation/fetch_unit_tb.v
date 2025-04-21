`timescale 1ns / 1ps

module fetch_unit_tb;

    reg clk;
    reg reset;
    reg isBranchTaken;
    reg [31:0] branchPC;
    wire [31:0] inst;
    wire [31:0] pc_out;

    // Instantiate the fetch unit
    fetch_unit uut (
        .clk(clk),
        .reset(reset),
        .isBranchTaken(isBranchTaken),
        .branchPC(branchPC),
        .inst(inst),
        .pc_out(pc_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Init signals
        clk = 0;
        reset = 1;
        isBranchTaken = 0;
        branchPC = 0;

        // Wait a bit, then release reset
        #10;
        reset = 0;

        // Load instructions manually into byte-addressable memory
        // Instruction 0: 0xDEADBEEF
        uut.instruction_memory[0] = 8'hDE;
        uut.instruction_memory[1] = 8'hAD;
        uut.instruction_memory[2] = 8'hBE;
        uut.instruction_memory[3] = 8'hEF;

        // Instruction 1: 0xCAFEBABE
        uut.instruction_memory[4] = 8'hCA;
        uut.instruction_memory[5] = 8'hFE;
        uut.instruction_memory[6] = 8'hBA;
        uut.instruction_memory[7] = 8'hBE;

        // Instruction 2: 0x12345678
        uut.instruction_memory[8]  = 8'h12;
        uut.instruction_memory[9]  = 8'h34;
        uut.instruction_memory[10] = 8'h56;
        uut.instruction_memory[11] = 8'h78;

        // Instruction 3: 0xAABBCCDD
        uut.instruction_memory[12] = 8'hAA;
        uut.instruction_memory[13] = 8'hBB;
        uut.instruction_memory[14] = 8'hCC;
        uut.instruction_memory[15] = 8'hDD;

        // Run a few cycles
        #40;

        // Branch to 3rd instruction (pc = 8)
        isBranchTaken = 1;
        branchPC = 32'd8;
        #10;

        // Disable branch and keep going
        isBranchTaken = 0;
        #20;

        $finish;
    end
endmodule