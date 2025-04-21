`timescale 1ns / 1ps

module top_mod_tb;
    reg clk;
    reg reset;

    // Instantiate top_mod
    top_mod uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Reset and stimulus
    initial begin
        $dumpfile("top_mod_tb.vcd");
        $dumpvars(0, top_mod_tb);

        reset = 1;
        #10;
        reset = 0;
        // Run simulation for some cycles
        repeat (20) begin
            @(posedge clk);
    
            $display("\nCycle: %0t", $time);
            $display("========================");
            $display("FETCH     | PC: %h | Inst: %h", uut.pc_fetch, uut.inst_fetch);
            $display("IF/OF     | PC: %h | Inst: %h", uut.if_of_pc, uut.if_of_inst);
            $display("OF/EX     | PC: %h | Inst: %h | op1: %h | op2: %h | immx: %h", uut.of_ex_pc, uut.of_ex_inst, uut.of_ex_op1, uut.of_ex_op2, uut.of_ex_immx);
            $display("EX/MA     | PC: %h | Inst: %h | ALU Result: %h | op2: %h", uut.ex_ma_pc, uut.ex_ma_inst, uut.ex_ma_aluResult, uut.ex_ma_op2);
            $display("MA/WB     | PC: %h | Inst: %h | ALU Result: %h | LD Result: %h", uut.ma_wb_pc, uut.ma_wb_inst, uut.ma_wb_aluResult, uut.ma_wb_ldResult);
            $display("WB        | Write Enable: %b | Write Addr: %h | Write Data: %h", uut.isWa_m, uut.wa_m, uut.wd_m);
            uut.U_OP_FETCH.dump_registers();
        end 
        

        $finish;
    end
endmodule
