module memory_unit (
    input wire clk,
    input wire isLd,
    input wire isSt,
    input wire [31:0] aluResult,   // Effective memory address
    input wire [31:0] op2,         // Data to write
    output reg [31:0] ldResult     // Data to read
);

    // Internal 1 MB data memory = 262144 words of 32 bits
    reg [31:0] mem [0:262143];

    // MAR and MDR as wires
    wire [31:0] mar;
    wire [31:0] mdr;
    wire [17:0] word_addr;

    assign mar = aluResult;
    assign mdr = op2;
    assign word_addr = mar[19:2];  // Convert byte address to word address

    // Memory read/write logic
    always @(posedge clk) begin
        if (isSt)
            mem[word_addr] <= mdr;

        if (isLd)
            ldResult <= mem[word_addr];
    end

endmodule
