// Brendan Lynskey 2025

package lfsr_pkg;

    // Standard maximal-length tap positions
    // Taps encoded as bitmask: bit[i]=1 means tap at position i
    // For polynomial x^n + x^a + x^b + ... + 1, set bits a, b, ..., 0
    // Polynomials referenced from Xilinx XAPP052 / ITU-T standards

    // ---------------------------------------------------------------
    // PRBS polynomials (ITU-T standard)
    // ---------------------------------------------------------------
    // PRBS-7:  x^7 + x^6 + 1  — taps at bits 6, 0
    localparam logic [6:0]  PRBS7_TAPS  = 7'b1000001;

    // PRBS-15: x^15 + x^14 + 1  — taps at bits 14, 0
    localparam logic [14:0] PRBS15_TAPS = 15'b100000000000001;

    // PRBS-31: x^31 + x^28 + 1  — taps at bits 28, 0
    localparam logic [30:0] PRBS31_TAPS = 31'b0010000000000000000000000000001;

    // ---------------------------------------------------------------
    // Common maximal-length polynomials (tap positions as bitmask)
    // ---------------------------------------------------------------
    // x^4 + x^3 + 1  — taps at bits 3, 0
    localparam logic [3:0]  TAPS_4  = 4'b1001;

    // x^8 + x^6 + x^5 + x^4 + 1  — taps at bits 6, 5, 4, 0
    localparam logic [7:0]  TAPS_8  = 8'b01110001;

    // x^16 + x^15 + x^13 + x^4 + 1  — taps at bits 14, 12, 3, 0
    localparam logic [15:0] TAPS_16 = 16'b0101000000001001;

    // x^32 + x^22 + x^2 + x^1 + 1  — taps at bits 21, 1, 0
    localparam logic [31:0] TAPS_32 = 32'h00200003;

    // ---------------------------------------------------------------
    // Scrambler polynomials
    // ---------------------------------------------------------------
    // ATM self-synchronous scrambler: x^43 + x^18 + 1
    // Taps at bits 17 and 0
    localparam logic [42:0] ATM_SCRAMBLER_TAPS = 43'h00000020001;

endpackage
