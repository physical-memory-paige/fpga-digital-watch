`timescale 1 ns / 1 ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train);

  rising_edge_detector button_rise_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) button_hold_detector (
      .clk(clk),
      .button(button),
      .held(held)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) pulse_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );


endmodule
