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

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;

  logic clk_tick;

  localparam logic [1:0] State1hz = 2'b00;
  localparam logic [1:0] State25hz = 2'b01;
  localparam logic [1:0] State1khz = 2'b10;
  localparam logic [1:0] State50Mhz = 2'b11;

  wire [3:0] digit_a[6];
  wire [6:0] hex_a  [6];
  wire [6:0] value_a[3];

  assign {value_a[0], value_a[1], value_a[2]} = {7'(seconds), 7'(minutes), 7'(hours)};
  assign {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = {
    hex_a[0], hex_a[1], hex_a[2], hex_a[3], hex_a[4], hex_a[5]
  };


  hms_counter hmsc (
      .clk(CLOCK_50),
      .enable(clk_tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  restartable_rate_generator #(CYCLES_PER_SECOND) rrg1hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1hz)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 50) rrg25hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25hz)
  );
  restartable_rate_generator #(CYCLES_PER_SECOND / 1_000) rrg1khz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1khz)
  );

  genvar i;
  generate
    for (i = 0; i < 6; i++) begin : g_ss_display
      seven_segment u_ss_hex (
          .digit(digit_a[i]),
          .blank(1'b0),
          .segments(hex_a[i])
      );
    end

    for (i = 0; i < 3; i++) begin : g_bin_to_bcd
      binary_to_bcd u_b2b (
          .bin (value_a[i]),
          .tens(digit_a[2*i+1]),
          .ones(digit_a[2*i])
      );
    end
  endgenerate

  always_comb begin
    unique case (SW)
      State1hz:   clk_tick = tick_1hz;
      State25hz:  clk_tick = tick_25hz;
      State1khz:  clk_tick = tick_1khz;
      State50Mhz: clk_tick = 1'b1;
    endcase
  end

endmodule
