`timescale 1ns / 1ps
module reg_writeback_unit (
    input  wire        isWb,
    input  wire        isLd,
    input  wire        isCall,
    input  wire [3:0]  rd,
    input  wire [31:0] aluResult,
    input  wire [31:0] ldResult,
    input  wire [31:0] pc,
    output wire        isWa,
    output wire [3:0]  wa,
    output wire [31:0] wd
);

    assign wd   = isCall ? (pc + 32'd4) :
                  isLd   ? ldResult :
                           aluResult;

    assign wa   = isCall ? 4'd15 : rd;
    assign isWa = isWb;

endmodule

