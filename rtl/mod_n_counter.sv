`timescale 1 ns / 1 ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = 0
);

  logic [WIDTH-1:0] next_count;
  always_comb begin
    if (count < WIDTH'(N - 1)) next_count = count + 1;
    else next_count = 0;
  end


  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;


endmodule
