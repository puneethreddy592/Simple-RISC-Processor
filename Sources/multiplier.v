module multiplier(
    input [31:0] A,         // 32-bit input A
    input [31:0] B,         // 32-bit input B
    input isMul,            // Control signal to enable multiplication
    output [31:0] result    // 32-bit multiplication result
);

    wire [15:0] a = A[15:0];
    wire [15:0] b = B[15:0];

    wire [31:0] product;

    // Partial products
    wire [31:0] pp[15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : partial_products
            assign pp[i] = b[i] ? (a << i) : 32'd0;
        end
    endgenerate

    // Wallace Tree Reduction using carry-save adders
    wire [31:0] sum1, carry1;
    wire [31:0] sum2, carry2;
    wire [31:0] sum3, carry3;
    wire [31:0] sum4, carry4;

    // First level of reduction
    assign {carry1, sum1} = pp[0] + pp[1] + pp[2];
    assign {carry2, sum2} = pp[3] + pp[4] + pp[5];
    assign {carry3, sum3} = pp[6] + pp[7] + pp[8];
    assign {carry4, sum4} = pp[9] + pp[10] + pp[11];

    // Second level
    wire [31:0] temp1, temp2;
    assign temp1 = sum1 + sum2 + carry1;
    assign temp2 = sum3 + sum4 + carry2;

    // Third level
    wire [31:0] temp3;
    assign temp3 = temp1 + temp2 + carry3 + carry4 + pp[12] + pp[13] + pp[14] + pp[15];

    // Final Result
    assign product = temp3;

    // Output logic based on isMul
    assign result = isMul ? product : 32'd0;

endmodule
