`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  generate
    if (DUTY_CYCLES == 0) begin : g_special1
      assign pwm_out = 1'b0;
    end else if (DUTY_CYCLES >= PERIOD_CYCLES) begin : g_special2
      assign pwm_out = 1'b1;
    end else begin : g_general
      localparam int Counterwidth = $clog2(PERIOD_CYCLES);


      logic [Counterwidth-1:0] count;
      logic [Counterwidth-1:0] next_count;

      // Next-state logic
      always_comb
        if (count < Counterwidth'(PERIOD_CYCLES - 1)) next_count = count + 1;
        else next_count = 0;

      // Updating state
      always_ff @(posedge clk)
        if (rst) count <= '0;
        else count <= next_count;

      // Output logic
      always_comb
        if (count <= Counterwidth'(DUTY_CYCLES - 1)) pwm_out = 1'b1;
        else pwm_out = 1'b0;
    end
  endgenerate

endmodule
