module shifter (
    input [31:0] A,
    input [4:0] shift_amount,  // 5-bit shift amount
    input isLSL,
    input isLSR,
    input isASR,
    output [31:0] result
);
    wire [1:0] sel;
    wire [31:0] stage1, stage2, stage3, stage4, stage5;

    // Priority encoder: No shift gets highest priority
    assign sel = (!isLSL && !isLSR && !isASR) ? 2'b00 :
                 isLSL ? 2'b01 :
                 isLSR ? 2'b10 :
                 isASR ? 2'b11 :
                 2'b00;  // Default

    // Shift by 1
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : shift1
            wire lsl = (i >= 1) ? A[i-1] : 1'b0;
            wire lsr = (i <= 30) ? A[i+1] : 1'b0;
            wire asr = (i <= 30) ? A[i+1] : A[31];
            wire no  = A[i];
            assign stage1[i] = (shift_amount[0]) ? 
                (sel == 2'b01 ? lsl :
                 sel == 2'b10 ? lsr :
                 sel == 2'b11 ? asr : no) : A[i];
        end
    endgenerate

    // Shift by 2
    generate
        for (i = 0; i < 32; i = i + 1) begin : shift2
            wire lsl = (i >= 2) ? stage1[i-2] : 1'b0;
            wire lsr = (i <= 29) ? stage1[i+2] : 1'b0;
            wire asr = (i <= 29) ? stage1[i+2] : stage1[31];
            wire no  = stage1[i];
            assign stage2[i] = (shift_amount[1]) ? 
                (sel == 2'b01 ? lsl :
                 sel == 2'b10 ? lsr :
                 sel == 2'b11 ? asr : no) : stage1[i];
        end
    endgenerate

    // Shift by 4
    generate
        for (i = 0; i < 32; i = i + 1) begin : shift4
            wire lsl = (i >= 4) ? stage2[i-4] : 1'b0;
            wire lsr = (i <= 27) ? stage2[i+4] : 1'b0;
            wire asr = (i <= 27) ? stage2[i+4] : stage2[31];
            wire no  = stage2[i];
            assign stage3[i] = (shift_amount[2]) ? 
                (sel == 2'b01 ? lsl :
                 sel == 2'b10 ? lsr :
                 sel == 2'b11 ? asr : no) : stage2[i];
        end
    endgenerate

    // Shift by 8
    generate
        for (i = 0; i < 32; i = i + 1) begin : shift8
            wire lsl = (i >= 8) ? stage3[i-8] : 1'b0;
            wire lsr = (i <= 23) ? stage3[i+8] : 1'b0;
            wire asr = (i <= 23) ? stage3[i+8] : stage3[31];
            wire no  = stage3[i];
            assign stage4[i] = (shift_amount[3]) ? 
                (sel == 2'b01 ? lsl :
                 sel == 2'b10 ? lsr :
                 sel == 2'b11 ? asr : no) : stage3[i];
        end
    endgenerate

    // Shift by 16
    generate
        for (i = 0; i < 32; i = i + 1) begin : shift16
            wire lsl = (i >= 16) ? stage4[i-16] : 1'b0;
            wire lsr = (i <= 15) ? stage4[i+16] : 1'b0;
            wire asr = (i <= 15) ? stage4[i+16] : stage4[31];
            wire no  = stage4[i];
            assign stage5[i] = (shift_amount[4]) ? 
                (sel == 2'b01 ? lsl :
                 sel == 2'b10 ? lsr :
                 sel == 2'b11 ? asr : no) : stage4[i];
        end
    endgenerate

    assign result = stage5;
endmodule
