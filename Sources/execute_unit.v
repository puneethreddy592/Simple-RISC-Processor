`timescale 1ns / 1ps

module execute_unit(
    input [31:0] op1,
    input [31:0] op2,
    input [31:0] immx,
    input isImmediate,
    input clk,
    input reset,

    // Branch and control signals
    input isBeq,
    input isBgt,
    input isUbranch,
    input isRet,
    input [31:0] branchTarget,
    
    // ALU control signals
    input isAdd, isSub, isCmp,
    input isMul,
    input isDiv, isMod,
    input isLSL, isLSR, isASR,
    input isAnd, isOr, isNot,
    input isMov,
    input isCall,

    input [4:0] aluSignals, // Can be extended as needed

    output [31:0] aluResult,
    output isBranchTaken,
    output [31:0] branchPC,
    output Gt,
    output Eq
);

    // Internal operand B selection
    wire [31:0] B = isImmediate ? immx : op2;

    // ALU result wires
    wire [31:0] addsub_result;
    wire addsub_gt, addsub_eq, addsub_cout;

    wire [31:0] mul_result;
    wire [31:0] divmod_result;
    wire [31:0] shift_result;
    wire [31:0] logic_result;
    wire [31:0] mov_result;

    // Adder/Subtractor/Compare
    adder_sub u_adder_sub (
        .clk(clk),
        .reset(reset),
        .A(op1),
        .B(B),
        .isAdd(isAdd),
        .isSub(isSub),
        .isCmp(isCmp),
        .Gt(addsub_gt),
        .Eq(addsub_eq),
        .Result(addsub_result),
        .Cout(addsub_cout)
    );

    // Multiplier
    multiplier u_multiplier (
        .A(op1),
        .B(B),
        .isMul(isMul),
        .result(mul_result)
    );

    // Divider / Modulo
    divider u_divider (
        .A(op1),
        .B(B),
        .isDiv(isDiv),
        .isMod(isMod),
        .result(divmod_result)
    );

    // Shifter
    shifter u_shifter (
        .A(op1),
        .shift_amount(B[4:0]), // Assuming shift amount comes from B
        .isLSL(isLSL),
        .isLSR(isLSR),
        .isASR(isASR),
        .result(shift_result)
    );

    // Logic and Move operations
    assign logic_result = isAnd ? (op1 & B) :
                          isOr  ? (op1 | B) :
                          isNot ? (~op1)    :
                          32'b0;

    assign mov_result = isMov ? B : 32'b0;

    // ALU output mux
    assign aluResult = isAdd || isSub || isCmp ? addsub_result :
                       isMul                   ? mul_result     :
                       isDiv || isMod          ? divmod_result  :
                       isLSL || isLSR || isASR ? shift_result   :
                       isAnd || isOr || isNot  ? logic_result   :
                       isMov                   ? mov_result     :
                       32'b0;

    // Branch logic
    wire beq_taken = isBeq && addsub_eq;
    wire bgt_taken = isBgt && addsub_gt;
    assign isBranchTaken = isUbranch || beq_taken || bgt_taken || isCall || isRet;
    assign Gt = addsub_gt;
    assign Eq = addsub_eq;
    // Branch PC selection
    assign branchPC = isRet ? op1 : branchTarget;

endmodule
