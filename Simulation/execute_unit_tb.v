`timescale 1ns / 1ps

module execute_unit_tb;

    // Inputs
    reg [31:0] op1, op2, immx;
    reg isImmediate;
    reg isBeq, isBgt, isUbranch, isRet;
    reg isAdd, isSub, isCmp, isMul, isDiv, isMod;
    reg isLSL, isLSR, isASR;
    reg isAnd, isOr, isNot, isMov;
    reg [4:0] aluSignals;
    reg [31:0] branchTarget;
    reg isCall;
    reg clk, reset;

    // Outputs
    wire [31:0] aluResult;
    wire isBranchTaken;
    wire [31:0] branchPC;
    wire Gt, Eq;

    // DUT
    execute_unit dut (
        .op1(op1),
        .op2(op2),
        .immx(immx),
        .isImmediate(isImmediate),
        .clk(clk),
        .reset(reset),
        .isBeq(isBeq),
        .isBgt(isBgt),
        .isUbranch(isUbranch),
        .isRet(isRet),
        .branchTarget(branchTarget),
        .isCall(isCall),
        .isAdd(isAdd), .isSub(isSub), .isCmp(isCmp),
        .isMul(isMul),
        .isDiv(isDiv), .isMod(isMod),
        .isLSL(isLSL), .isLSR(isLSR), .isASR(isASR),
        .isAnd(isAnd), .isOr(isOr), .isNot(isNot),
        .isMov(isMov),
        .aluSignals(aluSignals),
        .aluResult(aluResult),
        .isBranchTaken(isBranchTaken),
        .branchPC(branchPC),
        .Gt(Gt),
        .Eq(Eq)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset and signal initializer
    task reset_signals;
    begin
        isAdd = 0; isSub = 0; isCmp = 0;
        isMul = 0; isDiv = 0; isMod = 0;
        isLSL = 0; isLSR = 0; isASR = 0;
        isAnd = 0; isOr = 0; isNot = 0; isMov = 0;
        isBeq = 0; isBgt = 0; isUbranch = 0; isRet = 0; isCall = 0;
    end
    endtask

    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        #10 reset = 0;

        immx = 32'd5;
        op1 = 32'd10;
        op2 = 32'd3;
        branchTarget = 32'hDEADBEEF;
        aluSignals = 5'b0;
        isImmediate = 0;

        $display("==== ALU TEST ====");

        // Test Add
        reset_signals(); isAdd = 1;
        #10 $display("ADD: %d + %d = %d", op1, op2, aluResult);

        // Test Sub
        reset_signals(); isSub = 1;
        #10 $display("SUB: %d - %d = %d", op1, op2, aluResult);

        // Test CMP
        reset_signals(); isCmp = 1;
        #10 $display("CMP: GT=%b, EQ=%b", Gt, Eq);

        // Test Mul
        reset_signals(); isMul = 1;
        #10 $display("MUL: %d * %d = %d", op1, op2, aluResult);

        // Test Div
        reset_signals(); isDiv = 1;
        #10 $display("DIV: %d / %d = %d", op1, op2, aluResult);

        // Test Mod
        reset_signals(); isMod = 1;
        #10 $display("MOD: %d %% %d = %d", op1, op2, aluResult);

        // Test LSL
        reset_signals(); isLSL = 1;
        #10 $display("LSL: %d << %d = %d", op1, op2[4:0], aluResult);

        // Test LSR
        reset_signals(); isLSR = 1;
        #10 $display("LSR: %d >> %d = %d", op1, op2[4:0], aluResult);

        // Test ASR
        op1 = -32'd16;
        reset_signals(); isASR = 1;
        #10 $display("ASR: %d >>> %d = %d", op1, op2[4:0], aluResult);

        // Test AND
        op1 = 32'hF0F0F0F0; op2 = 32'h0F0F0F0F;
        reset_signals(); isAnd = 1;
        #10 $display("AND: %h & %h = %h", op1, op2, aluResult);

        // Test OR
        reset_signals(); isOr = 1;
        #10 $display("OR: %h | %h = %h", op1, op2, aluResult);

        // Test NOT
        reset_signals(); isNot = 1;
        #10 $display("NOT: ~%h = %h", op1, aluResult);

        // Test MOV
        op1 = 0; op2 = 0; immx = 32'h12345678;
        isImmediate = 1;
        reset_signals(); isMov = 1;
        #10 $display("MOV: %h", aluResult);

        // Test Branch Call
        reset_signals(); isCall = 1;
        #10 $display("CALL: isBranchTaken=%b, branchPC=%h", isBranchTaken, branchPC);

        // Test Return
        reset_signals(); isRet = 1; op1 = 32'hCAFEBABE;
        #10 $display("RET: isBranchTaken=%b, branchPC=%h", isBranchTaken, branchPC);

        $finish;
    end

endmodule
