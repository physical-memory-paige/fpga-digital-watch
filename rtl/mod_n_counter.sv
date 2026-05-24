`timescale 1 ns / 1 ps

module mod_n_counter #(
    parameter int N = 4,  // Maximum value attained N-1
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = 0
);

  logic [WIDTH-1:0] next_count;

  assign next_count = (count < WIDTH'(N - 1)) ? count + WIDTH'(1) : '0;

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;


endmodule
