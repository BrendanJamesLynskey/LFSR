// Brendan Lynskey 2025
`default_nettype none

module lfsr_scrambler #(
    parameter WIDTH = 7,
    parameter logic [WIDTH-1:0] TAPS = 7'b1000001,
    parameter logic [WIDTH-1:0] SEED = {WIDTH{1'b1}},
    parameter MODE = 0  // 0 = scramble, 1 = descramble
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic data_in,
    output logic data_out
);

    logic [WIDTH-1:0] shift_reg;
    logic              feedback;

    // Additive scrambler feedback: XOR of tapped positions
    always_comb begin
        feedback = ^(shift_reg & TAPS);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            shift_reg <= SEED;
        end else if (en) begin
            if (MODE == 0) begin
                // Scramble mode: shift in the feedback XOR data_in result
                shift_reg <= {shift_reg[WIDTH-2:0], (data_in ^ feedback)};
            end else begin
                // Descramble mode: shift in the received data_in
                shift_reg <= {shift_reg[WIDTH-2:0], data_in};
            end
        end
    end

    // Output is data XOR feedback for both modes (additive scrambler)
    assign data_out = data_in ^ feedback;

endmodule

`default_nettype wire
