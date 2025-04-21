module cla_8bit(
    input [7:0] A,        // 8-bit input A
    input [7:0] B,        // 8-bit input B
    input Cin,            // Carry-in
    output [7:0] Sum,     // 8-bit sum
    output Cout           // Carry-out
);

    wire [7:0] P, G;      // Propagate and Generate
    wire [8:0] C;         // Carry for each bit (C[0] is Cin, C[8] is Cout)
    
    // Generate and Propagate signals for each bit
    assign P = A ^ B;     // Propagate = A XOR B
    assign G = A & B;     // Generate = A AND B
    
    // Carry generation logic
    assign C[0] = Cin;    // Initial carry-in
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign C[4] = G[3] | (P[3] & C[3]);
    assign C[5] = G[4] | (P[4] & C[4]);
    assign C[6] = G[5] | (P[5] & C[5]);
    assign C[7] = G[6] | (P[6] & C[6]);
    assign C[8] = G[7] | (P[7] & C[7]);
    
    // Sum calculation (A XOR B XOR Carry)
    assign Sum = P ^ C[7:0];
    
    // Carry-out (C[8])
    assign Cout = C[8];

endmodule
module flag_register(
    input clk,
    input reset,
    input write_flags,
    input Eq_in,
    input Gt_in,
    output reg Eq_flag,
    output reg Gt_flag
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Eq_flag <= 0;
            Gt_flag <= 0;
        end else if (write_flags) begin
            Eq_flag <= Eq_in;
            Gt_flag <= Gt_in;
        end
    end

endmodule

module adder_sub(
    input clk,
    input reset,
    input [31:0] A,       // 32-bit input A
    input [31:0] B,       // 32-bit input B
    input isAdd,
    input isSub,
    input isCmp,
    output Gt,       // Control signal: 0 for addition, 1 for subtraction
    output Eq,
    output [31:0] Result, // 32-bit result
    output Cout           // Carry-out of the 32-bit adder/subtractor
);
    flag_register flags (
        .clk(clk),
        .reset(reset),
        .write_flags(isCmp),   // update only during CMP
        .Eq_in(Eq_internal),
        .Gt_in(Gt_internal),
        .Eq_flag(Eq),          // connected to adder_sub's output
        .Gt_flag(Gt)
    );

    wire [7:0] Sum0, Sum1, Sum2, Sum3;   // Sum for each 8-bit CLA
    wire Cout0, Cout1, Cout2, Cout3;      // Carry-out for each CLA
    wire Cin1, Cin2, Cin3;                // Carry-in for next CLAs
    wire [31:0] B_modified;               // Modified B for subtraction
    
    // Modify B for subtraction (two's complement: invert B and add 1)
    assign B_modified = (isSub | isCmp) ? ~B : B; // Invert B if subtracting
    
    // First 8-bit CLA
    cla_8bit cla0 (
        .A(A[7:0]), .B(B_modified[7:0]), .Cin(isSub | isCmp), // Cin = 1 for subtraction
        .Sum(Sum0), .Cout(Cout0)
    );

    // Second 8-bit CLA
    assign Cin1 = Cout0;  // Carry-out from CLA0 is the carry-in for CLA1
    cla_8bit cla1 (
        .A(A[15:8]), .B(B_modified[15:8]), .Cin(Cin1),
        .Sum(Sum1), .Cout(Cout1)
    );

    // Third 8-bit CLA
    assign Cin2 = Cout1;  // Carry-out from CLA1 is the carry-in for CLA2
    cla_8bit cla2 (
        .A(A[23:16]), .B(B_modified[23:16]), .Cin(Cin2),
        .Sum(Sum2), .Cout(Cout2)
    );

    // Fourth 8-bit CLA
    assign Cin3 = Cout2;  // Carry-out from CLA2 is the carry-in for CLA3
    cla_8bit cla3 (
        .A(A[31:24]), .B(B_modified[31:24]), .Cin(Cin3),
        .Sum(Sum3), .Cout(Cout3)
    );

    // Final carry-out
    assign Cout = Cout3;  // Carry-out from CLA3 is the overall carry-out

    // Combine all the sums from the 4 CLAs to form the 32-bit result
    wire [31:0] sum_result;
    assign sum_result = {Sum3, Sum2, Sum1, Sum0};

    // Only assign Result during actual add/sub/cmp
    assign Result = (isAdd | isSub | isCmp) ? sum_result : 32'bz;
    
    // Inside your adder_sub
    wire Eq_internal, Gt_internal;  // internal wires for current comparison
    assign Eq_internal = isCmp && (Result == 32'b0);
    assign Gt_internal = isCmp && ~Result[31] && ~Eq_internal;

endmodule
