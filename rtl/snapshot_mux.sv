`timescale 1 ns / 1 ps
module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);


  logic [WIDTH-1:0] snapshot_d = '0;

  always_ff @(posedge clk) if (!hold) snapshot_d <= d;

  assign q = (hold) ? snapshot_d : d;

endmodule
