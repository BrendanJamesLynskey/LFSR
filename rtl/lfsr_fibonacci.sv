// Brendan Lynskey 2025
`default_nettype none

module lfsr_fibonacci #(
    parameter WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'b01110001,
    parameter logic [WIDTH-1:0] SEED = {WIDTH{1'b1}}
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             en,
    output logic [WIDTH-1:0] lfsr_out,
    output logic             feedback_bit
);

    logic [WIDTH-1:0] lfsr_reg;

    // Fibonacci feedback: XOR of all tapped bit positions
    always_comb begin
        feedback_bit = ^(lfsr_reg & TAPS);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            lfsr_reg <= SEED;
        end else if (en) begin
            // Shift right, new MSB = feedback
            lfsr_reg <= {feedback_bit, lfsr_reg[WIDTH-1:1]};
        end
    end

    assign lfsr_out = lfsr_reg;

endmodule

`default_nettype wire
