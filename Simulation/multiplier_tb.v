`timescale 1ns / 1ps

module multiplier_tb;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg isMul;

    // Output
    wire [31:0] result;

    // Instantiate the Unit Under Test (UUT)
    multiplier uut (
        .A(A),
        .B(B),
        .isMul(isMul),
        .result(result)
    );

    initial begin
        $display("Time\tisMul\tA\t\tB\t\tResult");
        $monitor("%0t\t%b\t%h\t%h\t%h", $time, isMul, A, B, result);

        // Test 1: Multiply lower 16 bits of 10 * 5
        A = 32'h0000000A;
        B = 32'h00000005;
        isMul = 1;
        #10;

        // Test 2: Multiply lower 16 bits of 1000 * 20
        A = 32'h000003E8;
        B = 32'h00000014;
        isMul = 1;
        #10;

        // Test 3: Multiply with isMul = 0 (should return 0)
        A = 32'h0000000A;
        B = 32'h00000005;
        isMul = 0;
        #10;

        // Test 4: Upper 16 bits are set, but they should be ignored
        A = 32'hABCD000A;
        B = 32'h12340005;
        isMul = 1;
        #10;

        // Test 5: Large values within 16-bit range
        A = 32'h0000FFFF;
        B = 32'h0000FFFF;
        isMul = 1;
        #10;

        // Test 6: Zero multiplication
        A = 32'h00000000;
        B = 32'h00000023;
        isMul = 1;
        #10;

        $finish;
    end

endmodule
