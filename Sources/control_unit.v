module control_unit(
    input  wire [31:0] inst,
    output wire isSt,
    output wire isLd,
    output wire isBeq,
    output wire isBgt,
    output wire isRet,
    output wire isImmediate,
    output wire isWb,
    output wire isUbranch,
    output wire isCall,
    // ALU signals
    output wire isAdd,
    output wire isSub,
    output wire isCmp,
    output wire isMul,
    output wire isDiv,
    output wire isMod,
    output wire isLsl,
    output wire isLsr,
    output wire isAsr,
    output wire isOr,
    output wire isAnd,
    output wire isNot,
    output wire isMov
);

    wire [4:0] op = inst[31:27];  // Extract bits 31 to 27 (op5 to op0)
    wire I = inst[26];

    assign isSt         =  op == 5'b01111; // op5.op4.op3.op2.op1 = 00001
    assign isLd         =  op == 5'b01110;
    assign isBeq        =  op == 5'b10000;
    assign isBgt        =  op == 5'b10001;
    assign isRet        =  op == 5'b10100;
    assign isImmediate  =  I;

    assign isWb = ~((op[4]) | (~op[4] & op[2] & op[0] & (op[3] | ~op[1]))) | (op == 5'b10011);

    assign isUbranch    = (op[4] & ~op[3]) & (~op[2] & op[1] | op[2] & ~op[1] & ~op[0]);
    assign isCall       =  op == 5'b10011;

    assign isAdd        =  (op == 5'b00000) | (op[4:1] == 4'b0111);  // matches both entries in table
    assign isSub        =  op == 5'b00001;
    assign isCmp        =  op == 5'b00101;
    assign isMul        =  op == 5'b00010;
    assign isDiv        =  op == 5'b00011;
    assign isMod        =  op == 5'b00100;
    assign isLsl        =  op == 5'b01010;
    assign isLsr        =  op == 5'b01011;
    assign isAsr        =  op == 5'b01100;
    assign isOr         =  op == 5'b00111;
    assign isAnd        =  op == 5'b00110;
    assign isNot        =  op == 5'b01000;
    assign isMov        =  op == 5'b01001;
    
endmodule
