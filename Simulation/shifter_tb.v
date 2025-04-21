module shifter_tb;
    // Test signals
    reg [31:0] A;
    reg [31:0] B;
    reg isMul;
    wire [31:0] result;
    
    // Expected result for verification
    reg [31:0] expected;
    
    // Instantiate the module under test
    shifter dut (
        .A(A),
        .B(B),
        .isMul(isMul),
        .result(result)
    );
    
    // Test variables
    integer i;
    integer errors;
    
    initial begin
        // Initialize signals
        A = 32'h0;
        B = 32'h0;
        isMul = 1'b0;
        errors = 0;
        
        // Wait for stabilization
        #10;
        
        $display("Starting w_multiplier testbench...");
        $display("-------------------------------------");
        
        // Test 1: isMul = 0 (should output 0)
        A = 32'hFFFFFFFF;
        B = 32'hFFFFFFFF;
        isMul = 1'b0;
        expected = 32'h0;
        #10;
        check_result("Test 1: isMul=0");
        
        // Test 2: Simple multiplication
        A = 32'h00000005;
        B = 32'h00000007;
        isMul = 1'b1;
        expected = 32'h00000023; // 5 * 7 = 35 (0x23)
        #10;
        check_result("Test 2: 5 * 7");
        
        // Test 3: Larger values
        A = 32'h0000FFFF;
        B = 32'h0000FFFF;
        isMul = 1'b1;
        expected = 32'hFFFE0001; // 65535 * 65535 = 4,294,836,225 (0xFFFE0001)
        #10;
        check_result("Test 3: 0xFFFF * 0xFFFF");
        
        // Test 4: Only use lower 16 bits
        A = 32'hFFFF0003;
        B = 32'hFFFF0002;
        isMul = 1'b1;
        expected = 32'h00000006; // 3 * 2 = 6
        #10;
        check_result("Test 4: Lower 16 bits only");
        
        // Test 5: Zero case
        A = 32'h00001234;
        B = 32'h00000000;
        isMul = 1'b1;
        expected = 32'h00000000; // anything * 0 = 0
        #10;
        check_result("Test 5: Zero case");
        
        // Test random values
        for (i = 0; i < 20; i = i + 1) begin
            A = $random;
            B = $random;
            isMul = 1'b1;
            expected = (A[15:0] * B[15:0]);
            #10;
        end
        
        // Test random values with isMul off
        for (i = 0; i < 5; i = i + 1) begin
            A = $random;
            B = $random;
            isMul = 1'b0;
            expected = 32'h0;
            #10;
        end
        
        // Summary
        $display("-------------------------------------");
        $display("Testbench completed with %0d errors", errors);
        if (errors == 0)
            $display("SUCCESS: All tests passed!");
        else
            $display("FAILURE: Some tests failed!");
            
        $finish;
    end
    
    // Task to check result and print
    task check_result;
        input [200:0] test_name;
        begin
            if (result !== expected) begin
                $display("ERROR in %s:", test_name);
                $display("  A = 0x%h", A);
                $display("  B = 0x%h", B);
                $display("  isMul = %b", isMul);
                $display("  Expected: 0x%h", expected);
                $display("  Got:      0x%h", result);
                errors = errors + 1;
            end else begin
                $display("PASSED %s", test_name);
            end
        end
    endtask
    
endmodule