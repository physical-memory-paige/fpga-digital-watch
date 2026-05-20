`timescale 1ns / 1ps


module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;

  always_comb begin
    if (up) begin
      next_count = (count < WIDTH'(MAX)) ? count + WIDTH'(1) : WIDTH'(0);
    end else begin
      next_count = (count > WIDTH'(0)) ? count - WIDTH'(1) : WIDTH'(MAX);
    end
  end

  always_ff @(posedge clk) begin
    if (rst) count <= 0;
    else if (enable) count <= next_count;
  end


endmodule
