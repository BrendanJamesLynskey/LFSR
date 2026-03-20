// Brendan Lynskey 2025

module lfsr_galois #(
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

    // Galois feedback: LSB is the feedback bit
    assign feedback_bit = lfsr_reg[0];

    always_ff @(posedge clk) begin
        if (rst) begin
            lfsr_reg <= SEED;
        end else if (en) begin
            // Shift right; at tap positions, XOR shifted bit with feedback (LSB)
            lfsr_reg[WIDTH-1] <= 1'b0;
            for (int i = WIDTH-1; i > 0; i--) begin
                if (TAPS[i])
                    lfsr_reg[i-1] <= lfsr_reg[i] ^ feedback_bit;
                else
                    lfsr_reg[i-1] <= lfsr_reg[i];
            end
            // MSB gets the feedback bit (equivalent to wrapping)
            lfsr_reg[WIDTH-1] <= feedback_bit;
        end
    end

    assign lfsr_out = lfsr_reg;

endmodule

`default_nettype wire
