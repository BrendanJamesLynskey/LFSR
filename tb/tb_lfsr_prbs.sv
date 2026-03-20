// Brendan Lynskey 2025
`default_nettype none
`timescale 1ns / 1ps

module tb_lfsr_prbs;

    localparam PRBS_TYPE  = 7;
    localparam PRBS_WIDTH = 7;
    localparam MAX_LEN    = (1 << PRBS_TYPE) - 1;  // 127

    logic                   clk;
    logic                   rst;
    logic                   en;
    logic                   prbs_out;
    logic [PRBS_WIDTH-1:0]  lfsr_state;

    integer total_tests = 0;
    integer pass_count  = 0;
    integer fail_count  = 0;

    task check_int(input string name, input integer actual, expected);
        total_tests++;
        if (actual == expected) begin
            pass_count++;
            $display("[PASS] %s", name);
        end else begin
            fail_count++;
            $display("[FAIL] %s: got %0d, expected %0d", name, actual, expected);
        end
    endtask

    task check_bit(input string name, input logic actual, expected);
        total_tests++;
        if (actual === expected) begin
            pass_count++;
            $display("[PASS] %s", name);
        end else begin
            fail_count++;
            $display("[FAIL] %s: got %b, expected %b", name, actual, expected);
        end
    endtask

    lfsr_prbs #(
        .PRBS_TYPE (PRBS_TYPE)
    ) dut (
        .clk        (clk),
        .rst        (rst),
        .en         (en),
        .prbs_out   (prbs_out),
        .lfsr_state (lfsr_state)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Track unique states
    logic [127:0] state_seen;  // Enough for PRBS-7
    integer unique_count;
    integer ones_count;
    logic [PRBS_WIDTH-1:0] initial_state;

    initial begin
        $dumpfile("tb_lfsr_prbs.vcd");
        $dumpvars(0, tb_lfsr_prbs);

        rst = 1;
        en  = 0;
        state_seen = '0;
        unique_count = 0;
        ones_count = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        @(negedge clk);
        initial_state = lfsr_state;

        // Verify initial state is not zero
        total_tests++;
        if (lfsr_state != '0) begin
            pass_count++;
            $display("[PASS] Initial state is non-zero");
        end else begin
            fail_count++;
            $display("[FAIL] Initial state is zero");
        end

        // Record initial state
        state_seen[lfsr_state] = 1'b1;
        unique_count++;

        // Run for MAX_LEN cycles
        for (int i = 0; i < MAX_LEN; i++) begin
            @(posedge clk);
            @(negedge clk);

            // Count ones in PRBS output for balance check
            if (prbs_out) ones_count++;

            if (i < MAX_LEN - 1) begin
                if (!state_seen[lfsr_state]) begin
                    state_seen[lfsr_state] = 1'b1;
                    unique_count++;
                end
            end
        end

        // Verify sequence length
        check_int("Unique states in PRBS-7 sequence", unique_count, MAX_LEN);

        // Verify return to initial state after MAX_LEN cycles
        total_tests++;
        if (lfsr_state === initial_state) begin
            pass_count++;
            $display("[PASS] Returns to initial state after %0d cycles", MAX_LEN);
        end else begin
            fail_count++;
            $display("[FAIL] Did not return to initial state after %0d cycles", MAX_LEN);
        end

        // Check approximate balance: in a PRBS-7 (127-bit) sequence,
        // expect 64 ones and 63 zeros
        check_int("PRBS-7 ones count (expect 64)", ones_count, 64);

        // Verify zero state never appeared
        total_tests++;
        if (!state_seen[0]) begin
            pass_count++;
            $display("[PASS] Zero state never reached");
        end else begin
            fail_count++;
            $display("[FAIL] Zero state was reached");
        end

        $display("");
        $display("=== PRBS Testbench Summary ===");
        $display("Tests: %0d | Pass: %0d | Fail: %0d", total_tests, pass_count, fail_count);
        $finish;
    end

endmodule

`default_nettype wire
