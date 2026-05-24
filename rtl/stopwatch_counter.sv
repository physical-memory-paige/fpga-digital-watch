`timescale 1 ns / 1 ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  localparam int NCentiseconds = 100;
  localparam int NSeconds = 60;
  localparam int NMinutes = 100;
  localparam int WCentiseconds = 7;
  localparam int WSeconds = 6;
  localparam int WMinutes = 7;

  logic centisecond_tick;

  cascade_counter #(
      .N2(NMinutes),
      .N1(NSeconds),
      .N0(NCentiseconds),
      .W2(WMinutes),
      .W1(WSeconds),
      .W0(WCentiseconds)
  ) u_cs_s_m_counter (
      .clk(clk),
      .rst(rst),
      .enable(centisecond_tick && enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_centisecond_timer (
      .clk (clk),
      .run (enable && !rst),
      .tick(centisecond_tick)
  );

endmodule
