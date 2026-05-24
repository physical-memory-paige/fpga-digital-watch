// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  localparam logic [1:0] BDim = 2'b00;
  localparam logic [1:0] BLow = 2'b01;
  localparam logic [1:0] BMed = 2'b11;
  localparam logic [1:0] BFull = 2'b10;


  localparam int Period = CYCLES_PER_SECOND / 1000;  // Clock cycles in period
  localparam int PeriodWidth = $clog2(Period);
  localparam int BDimDutyCycleDuration = Period / 8;
  localparam int BLowDutyCycleDuration = Period / 4;
  localparam int BMedDutyCycleDuration = Period / 2;
  localparam int BFullDutyCycleDuration = Period / 1;



  wire blank_hours_internal;
  wire blank_minutes_internal;
  wire blank_seconds_internal;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(blank_hours_internal),
      .blank_minutes(blank_minutes_internal),
      .blank_seconds(blank_seconds_internal)
  );
  assign blank_hours   = blank_hours_internal || pwm_out;
  assign blank_minutes = blank_minutes_internal || pwm_out;
  assign blank_seconds = blank_seconds_internal || pwm_out;

  logic [(PeriodWidth-1):0] count;
  mod_n_counter #(
      .N(Period),
      .WIDTH(PeriodWidth)
  ) u_mod_n_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(count)
  );


  wire [1:0] switch_input_mode = sw[9:8];
  logic [(PeriodWidth-1):0] duty_threshold;
  always_comb
    unique case (switch_input_mode)
      BDim:  duty_threshold = PeriodWidth'(BDimDutyCycleDuration - 1);
      BLow:  duty_threshold = PeriodWidth'(BLowDutyCycleDuration - 1);
      BMed:  duty_threshold = PeriodWidth'(BMedDutyCycleDuration - 1);
      BFull: duty_threshold = PeriodWidth'(BFullDutyCycleDuration - 1);
    endcase

  logic pwm_out;
  assign pwm_out = count > duty_threshold;  //= (sw[9:8] == BFull) ? 1'b0 : count > 2;


endmodule
