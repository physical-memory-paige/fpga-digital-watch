`timescale 1 ns / 1 ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = 0,
    output logic counter_enable = 0,
    output logic lap_hold = 0
);

  // Note:
  // The counter_rst output is high for exactly one clock cycle when asserted: as soon as
  // rise_lap falls, the FSM exits the Reset state.

  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;


  assign next_counter_rst = {counter_rst, counter_enable, lap_hold, rise_start_stop, rise_lap} == 5'b00001;

  assign next_counter_enable = counter_enable ^ (rise_start_stop && !rise_lap);

  assign next_lap_hold = lap_hold ^ ((rise_lap && !rise_start_stop) && (counter_enable || lap_hold));


  always_ff @(posedge clk) begin
    counter_rst <= next_counter_rst;

    if (next_counter_rst) begin
      counter_enable <= 1'b0;
      lap_hold <= 1'b0;
    end else begin
      counter_enable <= next_counter_enable;
      lap_hold <= next_lap_hold;
    end
  end


endmodule
