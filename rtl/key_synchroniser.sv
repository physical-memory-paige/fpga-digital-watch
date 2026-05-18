`timescale 1 ns / 1 ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active-low, asynchronous
    output logic [3:0] key_sync = 4'b0  // active-high, synchronised
);

  logic [3:0] key_ff_1 = 4'b0;

  always_ff @(posedge clk) begin
    key_ff_1 <= ~key_n;
    key_sync <= key_ff_1;
  end

endmodule
