`timescale 1ns / 1ps

module divider_tb ;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg isDiv;
    reg isMod;

    // Output
    wire [31:0] result;

    // Instantiate the Unit Under Test (UUT)
    divider uut (
        .A(A),
        .B(B),
        .isDiv(isDiv),
        .isMod(isMod),
        .result(result)
    );

    initial begin
        $display("Time\tisDiv\tisMod\tA\t\tB\t\tResult");
        $monitor("%0t\t%b\t%b\t%h\t%h\t%h", $time, isDiv, isMod, A, B, result);

        // Test 1: Quotient of 100 / 5
        A = 32'd100;
        B = 32'd5;
        isDiv = 1;
        isMod = 0;
        #10;

        // Test 2: Remainder of 100 / 7
        A = 32'd100;
        B = 32'd7;
        isDiv = 0;
        isMod = 1;
        #10;

        // Test 3: Both signals low (should return 0)
        A = 32'd55;
        B = 32'd9;
        isDiv = 0;
        isMod = 0;
        #10;

        // Test 4: Division by zero (should return 0)
        A = 32'd1234;
        B = 32'd0;
        isDiv = 1;
        isMod = 0;
        #10;

        // Test 5: Remainder by zero (should return 0)
        A = 32'd5678;
        B = 32'd0;
        isDiv = 0;
        isMod = 1;
        #10;

        // Test 6: isDiv and isMod both high (priority to isDiv)
        A = 32'd49;
        B = 32'd5;
        isDiv = 1;
        isMod = 1;
        #10;

        // Test 7: Large numbers
        A = 32'hFFFFFFFE;
        B = 32'h0000FFFF;
        isDiv = 1;
        isMod = 0;
        #10;

        $finish;
    end

endmodule
