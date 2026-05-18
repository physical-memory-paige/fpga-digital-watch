`timescale 1 ns / 1 ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed = 1'b0
);

  always_ff @(posedge clk)
    if (disarm) armed <= 1'b0;
    else if (arm) armed <= 1'b1;

endmodule
