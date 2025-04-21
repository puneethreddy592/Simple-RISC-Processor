`timescale 1ns / 1ps

module reg_writeback_tb;

    // Inputs
    reg         isWb;
    reg         isLd;
    reg         isCall;
    reg  [3:0]  rd;
    reg  [31:0] aluResult;
    reg  [31:0] ldResult;
    reg  [31:0] pc;

    // Outputs
    wire        isWa;
    wire [3:0]  wa;
    wire [31:0] wd;

    // Instantiate the Unit Under Test (UUT)
    reg_writeback_unit uut (
        .isWb(isWb),
        .isLd(isLd),
        .isCall(isCall),
        .rd(rd),
        .aluResult(aluResult),
        .ldResult(ldResult),
        .pc(pc),
        .isWa(isWa),
        .wa(wa),
        .wd(wd)
    );

    initial begin
        $display("Time\tisCall\tisLd\tisWb\trd\twa\tisWa\twd");
        $monitor("%4dns\t%b\t%b\t%b\t%2d\t%2d\t%b\t%h", 
                 $time, isCall, isLd, isWb, rd, wa, isWa, wd);

        // Test 1: isCall = 1 -> wd = pc+4, wa = 15
        isCall = 1; isLd = 0; isWb = 1; rd = 4'd2;
        pc = 32'h00000010;
        aluResult = 32'hAAAAAAAA;
        ldResult = 32'hBBBBBBBB;
        #10;

        // Test 2: isLd = 1 -> wd = ldResult, wa = rd
        isCall = 0; isLd = 1; isWb = 1; rd = 4'd3;
        pc = 32'h00000020;
        aluResult = 32'hCCCCCCCC;
        ldResult = 32'hDDDDDDDD;
        #10;

        // Test 3: Normal ALU write -> wd = aluResult, wa = rd
        isCall = 0; isLd = 0; isWb = 1; rd = 4'd4;
        pc = 32'h00000030;
        aluResult = 32'hEEEEEEEE;
        ldResult = 32'hFFFFFFFF;
        #10;

        // Test 4: Writeback disabled -> isWb = 0
        isCall = 0; isLd = 0; isWb = 0; rd = 4'd5;
        pc = 32'h00000040;
        aluResult = 32'h11111111;
        ldResult = 32'h22222222;
        #10;

        $finish;
    end

endmodule
