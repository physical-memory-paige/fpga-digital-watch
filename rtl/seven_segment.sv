`timescale 1ns / 1ps
// Seven -segment display decoder for hexadecimal digits.
//
// Parameters:
// ACTIVE_LOW - 1 for active -low LEDs (for example , DE1 -SoC), 0 for active -high.
//
// Ports:
// digit [3:0] - Hexadecimal digit to display (0x0 to 0xF).
// blank - When high , all segments are turned off.
// segments [6:0] - Segment outputs [g,f,e,d,c,b,a].


module seven_segment #(
    parameter int ACTIVE_LOW = 1
) (
    input  logic [3:0] digit,
    input  logic       blank,
    output logic [6:0] segments
);

  logic blah;

  always_comb begin
    unique casez ({
      blank, digit
    })
      {1'b1, 4'h?} : segments = 7'b0000000 ^ {7{ACTIVE_LOW[0]}};  // Blank
      {1'b0, 4'h0} : segments = 7'b0111111 ^ {7{ACTIVE_LOW[0]}};  // Digit 0
      {1'b0, 4'h1} : segments = 7'b0000110 ^ {7{ACTIVE_LOW[0]}};  // Digit 1
      {1'b0, 4'h2} : segments = 7'b1011011 ^ {7{ACTIVE_LOW[0]}};  // Digit 2
      {1'b0, 4'h3} : segments = 7'b1001111 ^ {7{ACTIVE_LOW[0]}};  // Digit 3
      {1'b0, 4'h4} : segments = 7'b1100110 ^ {7{ACTIVE_LOW[0]}};  // Digit 4
      {1'b0, 4'h5} : segments = 7'b1101101 ^ {7{ACTIVE_LOW[0]}};  // Digit 5
      {1'b0, 4'h6} : segments = 7'b1111101 ^ {7{ACTIVE_LOW[0]}};  // Digit 6
      {1'b0, 4'h7} : segments = 7'b0000111 ^ {7{ACTIVE_LOW[0]}};  // Digit 7
      {1'b0, 4'h8} : segments = 7'b1111111 ^ {7{ACTIVE_LOW[0]}};  // Digit 8
      {1'b0, 4'h9} : segments = 7'b1101111 ^ {7{ACTIVE_LOW[0]}};  // Digit 9
      {1'b0, 4'hA} : segments = 7'b1110111 ^ {7{ACTIVE_LOW[0]}};  // Digit A
      {1'b0, 4'hB} : segments = 7'b1111100 ^ {7{ACTIVE_LOW[0]}};  // Digit b
      {1'b0, 4'hC} : segments = 7'b0111001 ^ {7{ACTIVE_LOW[0]}};  // Digit C
      {1'b0, 4'hD} : segments = 7'b1011110 ^ {7{ACTIVE_LOW[0]}};  // Digit d
      {1'b0, 4'hE} : segments = 7'b1111001 ^ {7{ACTIVE_LOW[0]}};  // Digit E
      {1'b0, 4'hF} : segments = 7'b1110001 ^ {7{ACTIVE_LOW[0]}};  // Digit F
    endcase
    if (ACTIVE_LOW) blah = 1'b1;
    else blah = 1'b0;
  end

endmodule
