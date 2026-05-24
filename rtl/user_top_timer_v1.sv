`timescale 1 ns / 1 ps


module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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



  /*
    Note Since edit_mode_selector has no reset pin, preventing a user from simultaneously
    triggering both run and edit modes is non-trivial. If run were given priority, the timer
    would immediately enter edit mode when next stopped. The simplest solution — and
    one the formal verification tool accepts — is to allow both modes to be active for a single
    clock cycle, after which edit mode takes priority and the run transition is cancelled.
  */


  // ------------------
  // Core Functionality
  // ------------------

  /* verilator lint_off UNUSEDSIGNAL */
  logic seconds_borrow_out;
  logic minutes_borrow_out;
  logic hours_borrow_out;
  /* verilator lint_on UNUSEDSIGNAL */

  logic running = 1'b0;

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic seconds_clr;
  //   logic seconds_borrow_out;
  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_editable_seconds (
      .clk(clk),
      .clr(seconds_clr),
      .tick(seconds_tick && running),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow_out)
  );

  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic minutes_clr;
  //   logic minutes_borrow_out;
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_editable_minutes (
      .clk(clk),
      .clr(minutes_clr),
      .tick(minutes_tick && running),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow_out)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic hours_clr;
  //   logic hours_borrow_out;
  logic [4:0] hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_editable_hours (
      .clk(clk),
      .clr(hours_clr),
      .tick(hours_tick && running),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(hours_borrow_out)
  );

  // Zero-extend counter values to display outputs
  assign seconds_disp = 7'(seconds);
  assign minutes_disp = 7'(minutes);
  assign hours_disp   = 7'(hours);

  // Derive 1 Hz from the system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (running),
      .tick(seconds_tick)
  );


  logic all_zeroes;
  assign all_zeroes = (hours == 0 && minutes == 0 && seconds == 0);

  always_ff @(posedge clk) begin
    // stop timer when entering edit mode
    if (mode_enable != 3'b000) running <= 1'b0;
    // stop timer if current or previous state had all counters at zero
    else if (all_zeroes && running) running <= 1'b0;
    // otherwise toggle running on start button
    else if (start_rise && !all_zeroes) running <= !running;
  end

  assign minutes_tick = seconds == '0 && seconds_tick;
  assign hours_tick = minutes == '0 && minutes_tick;

  assign seconds_clr = '0;
  assign minutes_clr = '0;
  assign hours_clr = '0;

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_edit_mode_select (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit   = mode_enable[2];

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND * 8) / 20)
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
  logic inc_pulse;
  logic inc_rise;
  rising_edge_detector u_inc_rise_detector (
      .clk(clk),
      .sig_in(button[1]),
      .rise(inc_rise)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // begin > 0.5s
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // repeat @ 10 Hz
  ) u_inc_event_generator (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  logic dec_event;
  logic dec_pulse;
  logic dec_rise;
  rising_edge_detector u_dec_rise_detector (
      .clk(clk),
      .sig_in(button[0]),
      .rise(dec_rise)
  );
  wire start_rise = dec_rise;  // The dec button is also the start button

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // begin > 0.5s
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // repeat @ 10 Hz
  ) u_dec_event_generator (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  assign inc_event = inc_pulse || inc_rise;
  assign dec_event = dec_pulse || dec_rise;

  assign seconds_inc = inc_event && seconds_edit;
  assign minutes_inc = inc_event && minutes_edit;
  assign hours_inc = inc_event && hours_edit;

  assign seconds_dec = dec_event && seconds_edit;
  assign minutes_dec = dec_event && minutes_edit;
  assign hours_dec = dec_event && hours_edit;


  // Unused
  assign led = '0;


`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif
endmodule
