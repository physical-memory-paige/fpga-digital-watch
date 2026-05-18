`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CounterWidth = $clog2(HOLD_CYCLES + 1);

  logic rst;
  logic enable;

  logic [CounterWidth-1:0] count;

  mod_n_counter #(
      .N(HOLD_CYCLES + 1),
      .WIDTH(CounterWidth)
  ) held_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count)
  );

  assign rst = !button;

  assign enable = count < CounterWidth'(HOLD_CYCLES);

  assign held = count == CounterWidth'(HOLD_CYCLES);

endmodule
