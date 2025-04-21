`timescale 1ns / 1ps

module operand_fetch_unit(
    input  wire        clk,
    input  wire [31:0] inst,
    input  wire [31:0] pc,
    input  wire        isRet,
    input  wire        isSt,
    input  wire        Reset,
    
    // Writeback inputs
    input  wire        isWa,         // Write enable
    input  wire [3:0]  wa,           // Write address
    input  wire [31:0] wd,           // Write data
    
    output wire [31:0] op1,
    output wire [31:0] op2,
    output wire [31:0] immx,
    output wire [31:0] branchTarget
);

    // ----------------------------------------------------------------
    // 1) Register file (16 × 32-bit), all init to zero
    // ----------------------------------------------------------------
    reg [31:0] regfile [0:15];
    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1)
            regfile[i] = i;
    end
    // ----------------------------------------------------------------
    // 2) Writeback support
    // ----------------------------------------------------------------
    always @(negedge clk or posedge Reset ) begin
    if (Reset) begin
        for (i = 0; i < 16; i = i + 1)
            regfile[i] <= 32'd0;
    end else if (isWa) begin
            regfile[wa] <= wd;
        end
    end

    // ----------------------------------------------------------------
    // 2) Field extraction
    // ----------------------------------------------------------------
    wire [3:0] rs1 = isRet ? 4'd15 : inst[21:18];
    wire [3:0] rs2 = isSt  ? inst[25:22] : inst[17:14];

    // ----------------------------------------------------------------
    // 3) Immediate decode (18-bit field: [17:16]=mode, [15:0]=value)
    // ----------------------------------------------------------------
    wire [1:0]  imm_mode = inst[17:16];
    wire [15:0] imm_val  = inst[15:0];
    assign immx = (imm_mode == 2'b00) ? { {16{imm_val[15]}}, imm_val } : // sign-extend
                  (imm_mode == 2'b01) ? { 16'b0, imm_val } :             // zero-extend
                  (imm_mode == 2'b10) ? { imm_val, 16'b0 } :             // high-order
                                      32'hDEADBEEF;

    // ----------------------------------------------------------------
    // 4) Outputs
    // ----------------------------------------------------------------
    // Register read-ports
    assign op1  = regfile[rs1];
    assign op2  = regfile[rs2];


    // Branch target = PC + (inst[26:0] << 2)
    //   inst[26:0] is 27-bit offset (word-aligned), <<4 adds 2-bit zero
    wire [31:0] branchOffset = {3'b000, inst[26:0], 2'b00 };
    assign branchTarget = pc + branchOffset;
    task dump_registers;
        integer i;
        begin
            $display("Register File Contents:");
            for (i = 0; i < 16; i = i + 1)
                $display("R[%0d] = %h", i, regfile[i]);
        end
    endtask

endmodule