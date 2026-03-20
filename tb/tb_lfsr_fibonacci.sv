// Brendan Lynskey 2025
`default_nettype none
`timescale 1ns / 1ps

module tb_lfsr_fibonacci;

    localparam WIDTH = 4;
    localparam logic [WIDTH-1:0] TAPS = 4'b1001;  // x^4 + x^3 + 1
    localparam logic [WIDTH-1:0] SEED = 4'b1111;
    localparam MAX_LEN = (1 << WIDTH) - 1;  // 15

    logic             clk;
    logic             rst;
    logic             en;
    logic [WIDTH-1:0] lfsr_out;
    logic             feedback_bit;

    integer total_tests = 0;
    integer pass_count  = 0;
    integer fail_count  = 0;

    task check(input string name, input logic [WIDTH-1:0] actual, expected);
        total_tests++;
        if (actual === expected) begin
            pass_count++;
            $display("[PASS] %s", name);
        end else begin
            fail_count++;
            $display("[FAIL] %s: got %h, expected %h", name, actual, expected);
        end
    endtask

    lfsr_fibonacci #(
        .WIDTH (WIDTH),
        .TAPS  (TAPS),
        .SEED  (SEED)
    ) dut (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        .lfsr_out     (lfsr_out),
        .feedback_bit (feedback_bit)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Track unique states
    logic [MAX_LEN:0] state_seen;
    integer unique_count;
    integer cycle_count;

    initial begin
        $dumpfile("tb_lfsr_fibonacci.vcd");
        $dumpvars(0, tb_lfsr_fibonacci);

        // Initialise
        rst = 1;
        en  = 0;
        state_seen = '0;
        unique_count = 0;
        cycle_count = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        // Check initial state after reset
        @(negedge clk);
        check("Reset loads SEED", lfsr_out, SEED);

        // Record initial state
        if (!state_seen[lfsr_out]) begin
            state_seen[lfsr_out] = 1'b1;
            unique_count++;
        end

        // Run for MAX_LEN cycles and count unique states
        for (int i = 0; i < MAX_LEN; i++) begin
            @(posedge clk);
            @(negedge clk);
            cycle_count++;

            if (i < MAX_LEN - 1) begin
                // Record unique states (not the last one, which should be back to SEED)
                if (!state_seen[lfsr_out]) begin
                    state_seen[lfsr_out] = 1'b1;
                    unique_count++;
                end
            end
        end

        // After MAX_LEN shifts, should return to SEED
        check("Returns to SEED after max-length cycle", lfsr_out, SEED);

        // Check unique state count
        total_tests++;
        if (unique_count == MAX_LEN) begin
            pass_count++;
            $display("[PASS] Unique states = %0d (expected %0d)", unique_count, MAX_LEN);
        end else begin
            fail_count++;
            $display("[FAIL] Unique states = %0d (expected %0d)", unique_count, MAX_LEN);
        end

        // Verify state 0 never appeared
        total_tests++;
        if (!state_seen[0]) begin
            pass_count++;
            $display("[PASS] Zero state never reached");
        end else begin
            fail_count++;
            $display("[FAIL] Zero state was reached (invalid for maximal LFSR)");
        end

        // Test enable gating: disable and verify state holds
        en = 0;
        @(posedge clk);
        @(negedge clk);
        begin
            logic [WIDTH-1:0] held_state;
            held_state = lfsr_out;
            @(posedge clk);
            @(negedge clk);
            check("Enable gating holds state", lfsr_out, held_state);
        end

        $display("");
        $display("=== Fibonacci LFSR Testbench Summary ===");
        $display("Tests: %0d | Pass: %0d | Fail: %0d", total_tests, pass_count, fail_count);
        $finish;
    end

endmodule

`default_nettype wire
