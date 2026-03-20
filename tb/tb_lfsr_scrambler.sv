// Brendan Lynskey 2025
`default_nettype none
`timescale 1ns / 1ps

module tb_lfsr_scrambler;

    localparam WIDTH = 7;
    localparam logic [WIDTH-1:0] TAPS = 7'b1000001;  // x^7 + x^6 + 1
    localparam logic [WIDTH-1:0] SEED = 7'b1111111;
    localparam NUM_BITS = 64;

    logic clk;
    logic rst;
    logic en;

    // Scrambler signals
    logic scram_data_in;
    logic scram_data_out;

    // Descrambler signals
    logic descram_data_out;

    integer total_tests = 0;
    integer pass_count  = 0;
    integer fail_count  = 0;

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

    // Scrambler instance (MODE = 0)
    lfsr_scrambler #(
        .WIDTH (WIDTH),
        .TAPS  (TAPS),
        .SEED  (SEED),
        .MODE  (0)
    ) u_scrambler (
        .clk      (clk),
        .rst      (rst),
        .en       (en),
        .data_in  (scram_data_in),
        .data_out (scram_data_out)
    );

    // Descrambler instance (MODE = 1)
    lfsr_scrambler #(
        .WIDTH (WIDTH),
        .TAPS  (TAPS),
        .SEED  (SEED),
        .MODE  (1)
    ) u_descrambler (
        .clk      (clk),
        .rst      (rst),
        .en       (en),
        .data_in  (scram_data_out),
        .data_out (descram_data_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test data patterns
    logic [NUM_BITS-1:0] test_data;
    logic [NUM_BITS-1:0] recovered_data;
    logic [NUM_BITS-1:0] scrambled_data;
    integer bit_idx;

    initial begin
        $dumpfile("tb_lfsr_scrambler.vcd");
        $dumpvars(0, tb_lfsr_scrambler);

        // -------------------------------------------------------
        // Test 1: Known data pattern — alternating bits
        // -------------------------------------------------------
        $display("--- Test pattern: alternating 10101010... ---");
        test_data = 64'hAAAA_AAAA_AAAA_AAAA;

        rst = 1;
        en  = 0;
        scram_data_in = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        // Feed data through scrambler -> descrambler pipeline
        for (bit_idx = 0; bit_idx < NUM_BITS; bit_idx++) begin
            scram_data_in = test_data[bit_idx];
            @(posedge clk);
            @(negedge clk);
            recovered_data[bit_idx] = descram_data_out;
            scrambled_data[bit_idx] = scram_data_out;
        end

        // Verify round-trip
        total_tests++;
        if (recovered_data === test_data) begin
            pass_count++;
            $display("[PASS] Round-trip: alternating pattern recovered correctly");
        end else begin
            fail_count++;
            $display("[FAIL] Round-trip: alternating pattern mismatch");
            $display("       Sent:      %h", test_data);
            $display("       Recovered: %h", recovered_data);
        end

        // Verify scrambled data differs from input
        total_tests++;
        if (scrambled_data !== test_data) begin
            pass_count++;
            $display("[PASS] Scrambled data differs from input");
        end else begin
            fail_count++;
            $display("[FAIL] Scrambled data is same as input (no scrambling)");
        end

        // -------------------------------------------------------
        // Test 2: All zeros
        // -------------------------------------------------------
        $display("--- Test pattern: all zeros ---");
        test_data = 64'h0;

        rst = 1;
        en  = 0;
        scram_data_in = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        for (bit_idx = 0; bit_idx < NUM_BITS; bit_idx++) begin
            scram_data_in = test_data[bit_idx];
            @(posedge clk);
            @(negedge clk);
            recovered_data[bit_idx] = descram_data_out;
            scrambled_data[bit_idx] = scram_data_out;
        end

        total_tests++;
        if (recovered_data === test_data) begin
            pass_count++;
            $display("[PASS] Round-trip: all-zeros pattern recovered correctly");
        end else begin
            fail_count++;
            $display("[FAIL] Round-trip: all-zeros pattern mismatch");
        end

        // All-zeros through scrambler should produce non-zero output (LFSR sequence)
        total_tests++;
        if (scrambled_data !== 64'h0) begin
            pass_count++;
            $display("[PASS] Scrambler produces non-zero output for zero input");
        end else begin
            fail_count++;
            $display("[FAIL] Scrambler produced all-zero output for zero input");
        end

        // -------------------------------------------------------
        // Test 3: All ones
        // -------------------------------------------------------
        $display("--- Test pattern: all ones ---");
        test_data = 64'hFFFF_FFFF_FFFF_FFFF;

        rst = 1;
        en  = 0;
        scram_data_in = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        for (bit_idx = 0; bit_idx < NUM_BITS; bit_idx++) begin
            scram_data_in = test_data[bit_idx];
            @(posedge clk);
            @(negedge clk);
            recovered_data[bit_idx] = descram_data_out;
        end

        total_tests++;
        if (recovered_data === test_data) begin
            pass_count++;
            $display("[PASS] Round-trip: all-ones pattern recovered correctly");
        end else begin
            fail_count++;
            $display("[FAIL] Round-trip: all-ones pattern mismatch");
        end

        // -------------------------------------------------------
        // Test 4: Pseudo-random pattern
        // -------------------------------------------------------
        $display("--- Test pattern: pseudo-random ---");
        test_data = 64'hDEAD_BEEF_CAFE_BABE;

        rst = 1;
        en  = 0;
        scram_data_in = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;
        en  = 1;

        for (bit_idx = 0; bit_idx < NUM_BITS; bit_idx++) begin
            scram_data_in = test_data[bit_idx];
            @(posedge clk);
            @(negedge clk);
            recovered_data[bit_idx] = descram_data_out;
        end

        total_tests++;
        if (recovered_data === test_data) begin
            pass_count++;
            $display("[PASS] Round-trip: pseudo-random pattern recovered correctly");
        end else begin
            fail_count++;
            $display("[FAIL] Round-trip: pseudo-random pattern mismatch");
            $display("       Sent:      %h", test_data);
            $display("       Recovered: %h", recovered_data);
        end

        $display("");
        $display("=== Scrambler Testbench Summary ===");
        $display("Tests: %0d | Pass: %0d | Fail: %0d", total_tests, pass_count, fail_count);
        $finish;
    end

endmodule

`default_nettype wire
