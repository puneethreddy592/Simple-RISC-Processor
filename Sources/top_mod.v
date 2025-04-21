`timescale 1ns / 1ps
module top_mod (
    input  wire clk,
    input  wire reset
);

    // === FETCH STAGE ===
    wire [31:0] inst_fetch;
    wire [31:0] pc_fetch;
    wire isBranchTaken_exe;
    wire [31:0] branchPC_exe;

    fetch_unit U_FETCH (
        .clk(clk),
        .reset(reset),
        .isBranchTaken(isBranchTaken_exe),
        .branchPC(branchPC_exe),
        .inst(inst_fetch),
        .pc_out(pc_fetch)
    );

    // === IF/OF PIPELINE ===
    reg [31:0] if_of_inst, if_of_pc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_of_inst <= 32'b0;
            if_of_pc   <= 32'b0;
        end else begin
            if_of_inst <= inst_fetch;
            if_of_pc   <= pc_fetch;
        end
    end

    // === CONTROL UNIT ===
    wire isSt, isLd, isBeq, isBgt, isRet, isImmediate, isWb, isUbranch, isCall;
    wire isAdd, isSub, isCmp, isMul, isDiv, isMod, isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov;

    control_unit U_CTRL (
        .inst(if_of_inst),
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

    // === OPERAND FETCH UNIT ===
    wire [31:0] op1, op2, immx, branchTarget;

    operand_fetch_unit U_OP_FETCH (
        .clk(clk),
        .inst(if_of_inst),
        .pc(if_of_pc),
        .isRet(isRet),
        .isSt(isSt),
        .Reset(reset),
        .isWa(isWa_m),        // <- connected to writeback output
        .wa(wa_m),
        .wd(wd_m),
        .op1(op1),
        .op2(op2),
        .immx(immx),
        .branchTarget(branchTarget)
    );

    // === OF/EX PIPELINE ===
    reg [31:0] of_ex_inst, of_ex_pc, of_ex_branchTarget;
    reg [31:0] of_ex_op1, of_ex_op2, of_ex_immx;
    reg        of_ex_isImmediate;

    // Registered control signals
    reg r_isSt, r_isLd, r_isBeq, r_isBgt, r_isRet, r_isWb, r_isUbranch, r_isCall;
    reg r_isAdd, r_isSub, r_isCmp, r_isMul, r_isDiv, r_isMod;
    reg r_isLsl, r_isLsr, r_isAsr, r_isOr, r_isAnd, r_isNot, r_isMov;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            of_ex_inst         <= 32'b0;
            of_ex_pc           <= 32'b0;
            of_ex_branchTarget <= 32'b0;
            of_ex_op1          <= 32'b0;
            of_ex_op2          <= 32'b0;
            of_ex_immx         <= 32'b0;
            of_ex_isImmediate  <= 1'b0;

            r_isSt <= 0; r_isLd <= 0; r_isBeq <= 0; r_isBgt <= 0;
            r_isRet <= 0; r_isWb <= 0;
            r_isUbranch <= 0; r_isCall <= 0;

            r_isAdd <= 0; r_isSub <= 0; r_isCmp <= 0;
            r_isMul <= 0; r_isDiv <= 0; r_isMod <= 0;
            r_isLsl <= 0; r_isLsr <= 0; r_isAsr <= 0;
            r_isOr  <= 0; r_isAnd <= 0; r_isNot <= 0;
            r_isMov <= 0;
        end else begin
            of_ex_inst         <= if_of_inst;
            of_ex_pc           <= if_of_pc;
            of_ex_branchTarget <= branchTarget;
            of_ex_op1          <= op1;
            of_ex_op2          <= op2;
            of_ex_immx         <= immx;
            of_ex_isImmediate  <= isImmediate;

            r_isSt <= isSt; r_isLd <= isLd; r_isBeq <= isBeq; r_isBgt <= isBgt;
            r_isRet <= isRet; r_isWb <= isWb;
            r_isUbranch <= isUbranch; r_isCall <= isCall;

            r_isAdd <= isAdd; r_isSub <= isSub; r_isCmp <= isCmp;
            r_isMul <= isMul; r_isDiv <= isDiv; r_isMod <= isMod;
            r_isLsl <= isLsl; r_isLsr <= isLsr; r_isAsr <= isAsr;
            r_isOr  <= isOr;  r_isAnd <= isAnd; r_isNot <= isNot;
            r_isMov <= isMov;
        end
    end

    // === EXECUTE UNIT ===
    wire [31:0] aluResult;
    wire Gt, Eq;

    execute_unit U_EXE (
        .op1(of_ex_op1),
        .op2(of_ex_op2),
        .immx(of_ex_immx),
        .isImmediate(of_ex_isImmediate),
        .isBeq(r_isBeq),
        .isBgt(r_isBgt),
        .isUbranch(r_isUbranch),
        .isRet(r_isRet),
        .branchTarget(of_ex_branchTarget),
        .isAdd(r_isAdd), .isSub(r_isSub), .isCmp(r_isCmp),
        .isMul(r_isMul), .isDiv(r_isDiv), .isMod(r_isMod),
        .isLSL(r_isLsl), .isLSR(r_isLsr), .isASR(r_isAsr),
        .isAnd(r_isAnd), .isOr(r_isOr), .isNot(r_isNot),
        .isMov(r_isMov), .isCall(r_isCall),
        .aluSignals(5'b00000),
        .aluResult(aluResult),
        .isBranchTaken(isBranchTaken_exe),
        .branchPC(branchPC_exe),
        .Gt(Gt),
        .Eq(Eq)
    );

    // === EX/MA PIPELINE ===
    reg [31:0] ex_ma_inst, ex_ma_pc;
    reg [31:0] ex_ma_op2, ex_ma_aluResult;
    reg        ex_ma_isLd, ex_ma_isSt, ex_ma_isCall, ex_ma_isWb;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_ma_inst      <= 32'b0;
            ex_ma_pc        <= 32'b0;
            ex_ma_op2       <= 32'b0;
            ex_ma_aluResult <= 32'b0;
            ex_ma_isLd      <= 1'b0;
            ex_ma_isSt      <= 1'b0;
            ex_ma_isCall    <= 1'b0;
            ex_ma_isWb      <= 1'b0;
        end else begin
            ex_ma_inst      <= of_ex_inst;
            ex_ma_pc        <= of_ex_pc;
            ex_ma_op2       <= of_ex_op2;
            ex_ma_aluResult <= aluResult;
            ex_ma_isLd      <= r_isLd;
            ex_ma_isSt      <= r_isSt;
            ex_ma_isCall    <= r_isCall;
            ex_ma_isWb      <= r_isWb;
        end
    end

    // === MEMORY UNIT ===
    wire [31:0] ldResult;

    memory_unit U_MEM (
        .clk(clk),
        .isLd(ex_ma_isLd),
        .isSt(ex_ma_isSt),
        .aluResult(ex_ma_aluResult),
        .op2(ex_ma_op2),
        .ldResult(ldResult)
    );
        // === MA/WB PIPELINE ===
    reg [31:0] ma_wb_inst, ma_wb_pc;
    reg [31:0] ma_wb_aluResult, ma_wb_ldResult;
    reg        ma_wb_isLd, ma_wb_isCall, ma_wb_isWb;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ma_wb_inst      <= 32'b0;
            ma_wb_pc        <= 32'b0;
            ma_wb_aluResult <= 32'b0;
            ma_wb_ldResult  <= 32'b0;
            ma_wb_isLd      <= 1'b0;
            ma_wb_isCall    <= 1'b0;
            ma_wb_isWb      <= 1'b0;
        end else begin
            ma_wb_inst      <= ex_ma_inst;
            ma_wb_pc        <= ex_ma_pc;
            ma_wb_aluResult <= ex_ma_aluResult;
            ma_wb_ldResult  <= ldResult;
            ma_wb_isLd      <= ex_ma_isLd;
            ma_wb_isCall    <= ex_ma_isCall;
            ma_wb_isWb      <= ex_ma_isWb;
        end
    end
    wire isWa_m;
    wire [3:0] wa_m;
    wire [31:0] wd_m;

    reg_writeback_unit U_WB (
        .isWb(ma_wb_isWb),
        .isLd(ma_wb_isLd),
        .isCall(ma_wb_isCall),
        .rd(ma_wb_inst[25:22]),         // Assuming rd is in bits [25:22]
        .aluResult(ma_wb_aluResult),
        .ldResult(ma_wb_ldResult),
        .pc(ma_wb_pc),
        .isWa(isWa_m),
        .wa(wa_m),
        .wd(wd_m)
    );

endmodule
