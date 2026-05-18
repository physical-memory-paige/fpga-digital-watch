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

module user_top_watch_v4 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
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


  // ------------------
  // Core Functionality
  // ------------------

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );


  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Zero-extend counter values to display outputs
  assign seconds_disp = 7'(seconds);
  assign minutes_disp = 7'(minutes);
  assign hours_disp   = 7'(hours);


  logic rst_seconds;
  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (!rst_seconds),
      .tick(seconds_tick)
  );


  assign minutes_tick = seconds_disp == 7'd59 && seconds_tick;
  assign hours_tick   = minutes_disp == 7'd59 && minutes_tick;



  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  assign rst_seconds  = (mode_enable[0] && button[3]);

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit   = mode_enable[2];

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),  // 2 Hz as per specification
      .DUTY_CYCLES((CYCLES_PER_SECOND * 8) / 20)  // 80% duty cycle (0.8 * PERIOD_CYCLES)
  ) u_flash_pulse_generator (
      .clk(clk),
      .rst(mode_enable == 3'b000),
      .pwm_out(pwm_out)
  );

  assign blank_hours   = !pwm_out && hours_edit;
  assign blank_minutes = !pwm_out && minutes_edit;
  assign blank_seconds = !pwm_out && seconds_edit;


  // --------------
  // Edit Logic
  // --------------


  logic inc_event;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // begin > 0.5s
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // repeat @ 10 Hz
  ) u_inc_event_generator (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_event)
  );
  logic dec_event;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // begin > 0.5s
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // repeat @ 10 Hz
  ) u_dec_event_generator (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_event)
  );

  assign seconds_inc = inc_event && seconds_edit;
  assign minutes_inc = inc_event && minutes_edit;
  assign hours_inc = inc_event && hours_edit;

  assign seconds_dec = dec_event && seconds_edit;
  assign minutes_dec = dec_event && minutes_edit;
  assign hours_dec = dec_event && hours_edit;


  // Unused
  assign led = 10'b0;



endmodule
