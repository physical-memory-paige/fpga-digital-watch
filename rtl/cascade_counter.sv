`timescale 1 ns / 1 ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  logic p0_rollover;
  assign p0_rollover = (count0 == W0'(N0 - 1)) && enable;
  logic p1_rollover;
  assign p1_rollover = (count1 == W1'(N1 - 1)) && p0_rollover;

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_p0_count (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );
  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_p1_count (
      .clk(clk),
      .rst(rst),
      .enable(p0_rollover),
      .count(count1)
  );
  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_p2_count (
      .clk(clk),
      .rst(rst),
      .enable(p1_rollover),
      .count(count2)
  );

  //   always_comb begin

  //   end

  //   always_ff @(posedge clk)
  //     if (rst) {count0, count1, count2} <= '0;
  //     else if (enable) {count0, count1, count2} <= {next_count0, next_count1, next_count2};



endmodule
