`timescale 1ns / 1ps
module multiplier(
    input [31:0] A,         // 32-bit input A
    input [31:0] B,         // 32-bit input B
    input isMul,            // Control signal to enable multiplication
    output [31:0] result    // 32-bit multiplication result
);
    wire [15:0] a = A[15:0];
    wire [15:0] b = B[15:0];
    wire [31:0] product;
    
    // Generate 16 partial products with proper sign extension
    wire [31:0] pp[15:0];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : partial_products
            assign pp[i] = b[i] ? ({16'b0, a} << i) : 32'b0;
        end
    endgenerate
    
    // Stage 1: Reduce 16 partial products to 11 rows
    // Layer 1 (pp0, pp1, pp2) -> s1_1, c1_1
    wire [31:0] s1_1, c1_1;
    compressor3to2 comp1_1(pp[0], pp[1], pp[2], s1_1, c1_1);
    
    // Layer 2 (pp3, pp4, pp5) -> s1_2, c1_2
    wire [31:0] s1_2, c1_2;
    compressor3to2 comp1_2(pp[3], pp[4], pp[5], s1_2, c1_2);
    
    // Layer 3 (pp6, pp7, pp8) -> s1_3, c1_3
    wire [31:0] s1_3, c1_3;
    compressor3to2 comp1_3(pp[6], pp[7], pp[8], s1_3, c1_3);
    
    // Layer 4 (pp9, pp10, pp11) -> s1_4, c1_4
    wire [31:0] s1_4, c1_4;
    compressor3to2 comp1_4(pp[9], pp[10], pp[11], s1_4, c1_4);
    
    // Layer 5 (pp12, pp13, pp14) -> s1_5, c1_5
    wire [31:0] s1_5, c1_5;
    compressor3to2 comp1_5(pp[12], pp[13], pp[14], s1_5, c1_5);
    
    // Stage 2: Reduce 11 rows to 8 rows
    // Layer 1 (s1_1, c1_1 << 1, s1_2) -> s2_1, c2_1
    wire [31:0] s2_1, c2_1;
    wire [31:0] shifted_c1_1 = {c1_1[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp2_1(s1_1, shifted_c1_1, s1_2, s2_1, c2_1);
    
    // Layer 2 (c1_2 << 1, s1_3, c1_3 << 1) -> s2_2, c2_2
    wire [31:0] s2_2, c2_2;
    wire [31:0] shifted_c1_2 = {c1_2[30:0], 1'b0}; // Shift left by 1
    wire [31:0] shifted_c1_3 = {c1_3[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp2_2(shifted_c1_2, s1_3, shifted_c1_3, s2_2, c2_2);
    
    // Layer 3 (s1_4, c1_4 << 1, s1_5) -> s2_3, c2_3
    wire [31:0] s2_3, c2_3;
    wire [31:0] shifted_c1_4 = {c1_4[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp2_3(s1_4, shifted_c1_4, s1_5, s2_3, c2_3);
    
    // Stage 3: Reduce 8 rows to 6 rows
    // Layer 1 (s2_1, c2_1 << 1, s2_2) -> s3_1, c3_1
    wire [31:0] s3_1, c3_1;
    wire [31:0] shifted_c2_1 = {c2_1[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp3_1(s2_1, shifted_c2_1, s2_2, s3_1, c3_1);
    
    // Layer 2 (c2_2 << 1, s2_3, c2_3 << 1) -> s3_2, c3_2
    wire [31:0] s3_2, c3_2;
    wire [31:0] shifted_c2_2 = {c2_2[30:0], 1'b0}; // Shift left by 1
    wire [31:0] shifted_c2_3 = {c2_3[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp3_2(shifted_c2_2, s2_3, shifted_c2_3, s3_2, c3_2);
    
    // Remaining pp lines: s3_1, c3_1, s3_2, c3_2, c1_5, pp[15]
    
    // Stage 4: Reduce 6 rows to 4 rows
    // Layer 1 (s3_1, c3_1 << 1, s3_2) -> s4_1, c4_1
    wire [31:0] s4_1, c4_1;
    wire [31:0] shifted_c3_1 = {c3_1[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp4_1(s3_1, shifted_c3_1, s3_2, s4_1, c4_1);
    
    // Layer 2 (c3_2 << 1, c1_5 << 1, pp[15]) -> s4_2, c4_2
    wire [31:0] s4_2, c4_2;
    wire [31:0] shifted_c3_2 = {c3_2[30:0], 1'b0}; // Shift left by 1
    wire [31:0] shifted_c1_5 = {c1_5[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp4_2(shifted_c3_2, shifted_c1_5, pp[15], s4_2, c4_2);
    
    // Stage 5: Final reduction to 2 rows
    wire [31:0] s5_1, c5_1;
    wire [31:0] shifted_c4_1 = {c4_1[30:0], 1'b0}; // Shift left by 1
    wire [31:0] shifted_c4_2 = {c4_2[30:0], 1'b0}; // Shift left by 1
    compressor3to2 comp5_1(s4_1, s4_2, shifted_c4_1, s5_1, c5_1);
    
    wire [31:0] shifted_c5_1 = {c5_1[30:0], 1'b0}; // Shift left by 1
    
    // Final carry-propagate addition
    assign product = s5_1 + shifted_c5_1 + shifted_c4_2;
    
    // Output logic based on isMul
    assign result = isMul ? product : 32'd0;
endmodule

// 3-to-2 compressor (uses full adders)
module compressor3to2(
    input [31:0] in1,
    input [31:0] in2,
    input [31:0] in3,
    output [31:0] sum,
    output [31:0] carry
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : comp_loop
            full_adder fa(in1[i], in2[i], in3[i], sum[i], carry[i]);
        end
    endgenerate
endmodule

// Full adder
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

// 32-bit Half adder
module half_adder_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum,
    output [31:0] cout
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : ha_loop
            assign sum[i] = a[i] ^ b[i];
            assign cout[i] = a[i] & b[i];
        end
    endgenerate
endmodule
