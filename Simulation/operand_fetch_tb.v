`timescale 1ns / 1ps

module operand_fetch_tb;

    // Inputs
    reg clk;
    reg [31:0] inst;
    reg [31:0] pc;
    reg isRet;
    reg isSt;
    reg Reset;
    reg isWa;
    reg [3:0] wa;
    reg [31:0] wd;

    // Outputs
    wire [31:0] op1;
    wire [31:0] op2;
    wire [31:0] immx;
    wire [31:0] branchTarget;

    // Instantiate the Unit Under Test (UUT)
    operand_fetch_unit uut (
        .clk(clk),
        .inst(inst),
        .pc(pc),
        .isRet(isRet),
        .isSt(isSt),
        .Reset(Reset),
        .isWa(isWa),
        .wa(wa),
        .wd(wd),
        .op1(op1),
        .op2(op2),
        .immx(immx),
        .branchTarget(branchTarget)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("---- Starting operand_fetch_unit Testbench ----");

        // Init inputs
        clk = 0;
        inst = 0;
        pc = 32'h1000_0000;
        isRet = 0;
        isSt = 0;
        Reset = 1;
        isWa = 0;
        wa = 0;
        wd = 0;

        #10;
        Reset = 0;

        // Write to register 4
        isWa = 1;
        wa = 4;
        wd = 32'h12345678;
        #10;
        isWa = 0;

        // Write to register 5
        isWa = 1;
        wa = 5;
        wd = 32'hCAFEBABE;
        #10;
        isWa = 0;

        // Normal instruction: rs1=4, rs2=5, imm_mode=00 (sign-extend), imm_val=0x8001
        inst = {5'b00000, 4'd4, 4'd5, 2'b00, 16'h8001};  // immx should be sign-extended
        isRet = 0;
        isSt = 0;
        #10;

        $display("op1 = %h (expect 12345678)", op1);
        $display("op2 = %h (expect CAFEBABE)", op2);
        $display("immx = %h (expect FFFF8001)", immx);

        // Immediate test: imm_mode = 01 (zero-extend), imm_val = 0xABCD
        inst = {5'b00000, 4'd4, 4'd5, 2'b01, 16'hABCD};
        #10;
        $display("immx = %h (expect 0000ABCD)", immx);

        // Immediate test: imm_mode = 10 (high-order), imm_val = 0x1234
        inst = {5'b00000, 4'd4, 4'd5, 2'b10, 16'h1234};
        #10;
        $display("immx = %h (expect 12340000)", immx);

        // Test isRet: force rs1 to 15
        isRet = 1;
        inst = 32'b0; // rs1 gets ignored
        #10;
        $display("op1 (isRet=1) = %h (expect reg[15])", op1);

        // Test branch target
        inst = 32'b0000001_0000000000000000000000010; // 27-bit offset = 2, branchOffset = 8
        pc = 32'h1000_0000;
        #10;
        $display("branchTarget = %h (expect 1000_0008)", branchTarget);

        $display("---- Testbench Complete ----");
        $finish;
    end
endmodule
