module divider (
    input [31:0] A,        // Dividend
    input [31:0] B,        // Divisor
    input isDiv,           // Return quotient if high
    input isMod,           // Return remainder if high
    output [31:0] result   // Output (quotient or remainder)
);

    wire [31:0] quotient;
    wire [31:0] remainder;

    assign quotient  = (B != 0) ? A / B : 32'd0;
    assign remainder = (B != 0) ? A % B : 32'd0;

    assign result = (isDiv) ? quotient :
                    (isMod) ? remainder :
                    32'd0;

endmodule
