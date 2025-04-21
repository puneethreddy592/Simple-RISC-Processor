module adder_sub_tb;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg isAdd;
    reg isSub;
    reg isCmp;
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] Result;
    wire Cout;
    wire Gt;
    wire Eq;

    // Clock generation: 10 time units period
    initial clk = 0;
    always #5 clk = ~clk;

    // Instantiate the Unit Under Test (UUT)
    adder_sub uut (
        .A(A),
        .B(B),
        .isAdd(isAdd),
        .isSub(isSub),
        .isCmp(isCmp),
        .Gt(Gt),
        .Eq(Eq),
        .Result(Result),
        .Cout(Cout),
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $display("Time\tA\t\t\tB\t\t\tisAdd isSub isCmp | Result\t\t\tCout Eq Gt");
        $display("----------------------------------------------------------------------------------");

        // Apply reset
        reset = 1;
        #10;
        reset = 0;

        // Test ADD: 15 + 10
        A = 32'd15; B = 32'd10;
        isAdd = 1; isSub = 0; isCmp = 0;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        // Test SUB: 20 - 5
        A = 32'd20; B = 32'd5;
        isAdd = 0; isSub = 1; isCmp = 0;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        // Test CMP: 30 > 10 => Gt = 1
        A = 32'd30; B = 32'd10;
        isAdd = 0; isSub = 0; isCmp = 1;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        // Test CMP: 25 == 25 => Eq = 1
        A = 32'd25; B = 32'd25;
        isAdd = 0; isSub = 0; isCmp = 1;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        // Test CMP: 10 < 20 => Gt = 0, Eq = 0
        A = 32'd10; B = 32'd20;
        isAdd = 0; isSub = 0; isCmp = 1;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        // Test SUB: 5 - 10 => Negative result
        A = 32'd5; B = 32'd10;
        isAdd = 0; isSub = 1; isCmp = 0;
        #10;
        @(posedge clk);
        $display("%0t\t%0d\t%0d\t%b\t%b\t%b\t| %0d\t\t%b\t%b\t%b", $time, A, B, isAdd, isSub, isCmp, Result, Cout, Eq, Gt);

        $finish;
    end

endmodule
