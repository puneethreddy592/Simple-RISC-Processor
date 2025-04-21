`timescale 1ns / 1ps

module control_unit_tb;

    // Inputs
    reg [31:0] inst;

    // Outputs
    wire isSt, isLd, isBeq, isBgt, isRet, isImmediate, isWb, isUbranch, isCall;
    wire isAdd, isSub, isCmp, isMul, isDiv, isMod, isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov;

    // Instantiate the Unit Under Test (UUT)
    control_unit uut (
        .inst(inst),
        .isSt(isSt),
        .isLd(isLd),
        .isBeq(isBeq),
        .isBgt(isBgt),
        .isRet(isRet),
        .isImmediate(isImmediate),
        .isWb(isWb),
        .isUbranch(isUbranch),
        .isCall(isCall),
        .isAdd(isAdd),
        .isSub(isSub),
        .isCmp(isCmp),
        .isMul(isMul),
        .isDiv(isDiv),
        .isMod(isMod),
        .isLsl(isLsl),
        .isLsr(isLsr),
        .isAsr(isAsr),
        .isOr(isOr),
        .isAnd(isAnd),
        .isNot(isNot),
        .isMov(isMov)
    );

    // Task to display all control signals
    task display_signals;
    begin
        $display("inst = %b", inst);
        $display("isSt=%b, isLd=%b, isBeq=%b, isBgt=%b, isRet=%b, isImmediate=%b, isWb=%b", isSt, isLd, isBeq, isBgt, isRet, isImmediate, isWb);
        $display("isUbranch=%b, isCall=%b", isUbranch, isCall);
        $display("ALU: isAdd=%b, isSub=%b, isCmp=%b, isMul=%b, isDiv=%b, isMod=%b", isAdd, isSub, isCmp, isMul, isDiv, isMod);
        $display("     isLsl=%b, isLsr=%b, isAsr=%b, isOr=%b, isAnd=%b, isNot=%b, isMov=%b\n", isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov);
    end
    endtask

    initial begin
        $display("Starting control_unit_tb...");

        // Test 1: ADD (00000)
        inst = 32'b00000_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 2: SUB (00001)
        inst = 32'b00001_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 3: MUL (00010)
        inst = 32'b00010_1_00000000000000000000000000000;
        #10; display_signals();

        // Test 4: LD (01110)
        inst = 32'b01110_1_00000000000000000000000000000;
        #10; display_signals();

        // Test 5: ST (01111)
        inst = 32'b01111_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 6: BEQ (10000)
        inst = 32'b10000_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 7: CALL (10011)
        inst = 32'b10011_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 8: NOT (01000)
        inst = 32'b01000_1_00000000000000000000000000000;
        #10; display_signals();

        // Test 9: MOV (01001)
        inst = 32'b01001_0_00000000000000000000000000000;
        #10; display_signals();

        // Test 10: RET (10100)
        inst = 32'b10100_0_00000000000000000000000000000;
        #10; display_signals();

        $display("Testbench completed.");
        $finish;
    end

endmodule
