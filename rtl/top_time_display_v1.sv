`timescale 1 ns / 1 ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  localparam int NHours = 24;
  localparam int NMinutes = 60;
  localparam int NSeconds = 60;

  localparam int WHours = 5;
  localparam int WMinutes = 6;
  localparam int WSeconds = 6;

  logic hms_enable = 1;
  logic [WHours-1:0] hours;
  logic [WMinutes-1:0] minutes;
  logic [WSeconds-1:0] seconds;

  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;

  logic clk_tick;

  localparam logic [1:0] State1hz = 2'b00;
  localparam logic [1:0] State25hz = 2'b01;
  localparam logic [1:0] State1khz = 2'b10;
  localparam logic [1:0] State50Mhz = 2'b11;
  logic [1:0] clock_freq = State50Mhz;

  logic [3:0] digit5;
  logic [3:0] digit4;
  logic [3:0] digit3;
  logic [3:0] digit2;
  logic [3:0] digit1;
  logic [3:0] digit0;

  hms_counter #() hmsc (
      .clk(CLOCK_50),
      .enable(clk_tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  restartable_rate_generator #(CYCLES_PER_SECOND) rrg1hz (
      .clk (CLOCK_50),
      .run (clock_freq == State1hz),
      .tick(tick_1hz)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 50) rrg25hz (
      .clk (CLOCK_50),
      .run (clock_freq == State25hz),
      .tick(tick_25hz)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 1_000) rrg1khz (
      .clk (CLOCK_50),
      .run (clock_freq == State1khz),
      .tick(tick_1khz)
  );



  seven_segment #() ss_hex5 (
      .digit(digit5),
      .blank(1'b0),
      .segments(HEX5)
  );
  seven_segment #() ss_hex4 (
      .digit(digit4),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment #() ss_hex3 (
      .digit(digit3),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment #() ss_hex2 (
      .digit(digit2),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment #() ss_hex1 (
      .digit(digit1),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment #() ss_hex0 (
      .digit(digit0),
      .blank(1'b0),
      .segments(HEX0)
  );

  binary_to_bcd #() b2b_hours (
      .bin (7'(hours)),
      .tens(digit5),
      .ones(digit4)
  );
  binary_to_bcd #() b2b_minutes (
      .bin (7'(minutes)),
      .tens(digit3),
      .ones(digit2)
  );
  binary_to_bcd #() b2b_seconds (
      .bin (7'(seconds)),
      .tens(digit1),
      .ones(digit0)
  );

  always_ff @(posedge CLOCK_50) begin
    clock_freq <= SW;
    $display("Tick! %d, %f, %d, %d, %d", $time, $realtime, seconds, minutes, hours);
  end

  always_comb begin
    unique case (clock_freq)
      State1hz:   clk_tick = tick_1hz;
      State25hz:  clk_tick = tick_25hz;
      State1khz:  clk_tick = tick_1khz;
      State50Mhz: clk_tick = 1'b1;
    endcase
  end

  initial begin
    $monitor(seconds, minutes, hours);
  end

endmodule
