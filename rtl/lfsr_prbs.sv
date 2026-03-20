// Brendan Lynskey 2025
`default_nettype none

module lfsr_prbs #(
    parameter PRBS_TYPE = 7  // 7, 15, or 31
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    output logic prbs_out,
    output logic [PRBS_WIDTH-1:0] lfsr_state
);

    // Derive width from PRBS type
    localparam PRBS_WIDTH = PRBS_TYPE;

    // Select taps based on PRBS type
    // Taps encode polynomial terms below x^n, including x^0 (+1)
    localparam logic [PRBS_WIDTH-1:0] PRBS_TAPS =
        (PRBS_TYPE == 7)  ? 7'b1000001 :
        (PRBS_TYPE == 15) ? 15'b100000000000001 :
        (PRBS_TYPE == 31) ? 31'b0010000000000000000000000000001 :
                            {PRBS_WIDTH{1'b0}};

    logic feedback;

    lfsr_fibonacci #(
        .WIDTH (PRBS_WIDTH),
        .TAPS  (PRBS_TAPS),
        .SEED  ({PRBS_WIDTH{1'b1}})
    ) u_lfsr (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        .lfsr_out     (lfsr_state),
        .feedback_bit (feedback)
    );

    // PRBS output is the LSB of the shift register
    assign prbs_out = lfsr_state[0];

endmodule

`default_nettype wire
