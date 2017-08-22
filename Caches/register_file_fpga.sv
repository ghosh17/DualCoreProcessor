/*
  Eric Villasenor
  evillase@gmail.com

  register file fpga wrapper
*/

`include "register_file_if.vh"

module register_file_fpga (
  input logic CLOCK_50,
  input logic [3:0] KEY,
  input logic [17:0] SW,
  output logic [17:0] LEDR
);

  // interface
  register_file_if rfif();
  // rf
  register_file RF(CLOCK_50, KEY[2], rfif);

assign rfif.wsel = SW[4:0];
assign rfif.rsel1 = SW[9:5];
assign rfif.rsel2 = SW[14:10];
assign rfif.wdat = {29'b0,SW[17:15]};

assign rfif.WEN = ~KEY[3];

assign LEDR[8:5] = rfif.rdat1[3:0];
assign LEDR[13:10] = rfif.rdat2[3:0];

endmodule

