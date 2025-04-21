`timescale 1ns / 1ps

module memory_unit_tb;

    // Inputs
    reg clk;
    reg isLd;
    reg isSt;
    reg [31:0] aluResult;
    reg [31:0] op2;

    // Output
    wire [31:0] ldResult;

    // Instantiate the memory_unit
    memory_unit uut (
        .clk(clk),
        .isLd(isLd),
        .isSt(isSt),
        .aluResult(aluResult),
        .op2(op2),
        .ldResult(ldResult)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period = 10ns
    end

    initial begin
        // Initialize inputs
        isLd = 0;
        isSt = 0;
        aluResult = 0;
        op2 = 0;

        #10;

        // STORE: Write 0xCAFEBABE to address 0x00000020
        aluResult = 32'h00000020;
        op2 = 32'hCAFEBABE;
        isSt = 1;
        #10;
        isSt = 0;

        // LOAD: Read from address 0x00000020
        aluResult = 32'h00000020;
        isLd = 1;
        #10;
        isLd = 0;

        // Wait and display the loaded value
        #5;
        $display("Loaded value = 0x%H (expected CAFEBABE)", ldResult);

        #10;
        $finish;
    end

endmodule
