`timescale 1 ns / 1 ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  // Mealy implementation to return high immediately on rising edge

  logic last_sig = 1'b0;

  always_ff @(posedge clk) last_sig <= sig_in;

  always_comb rise = (sig_in > last_sig);

endmodule
