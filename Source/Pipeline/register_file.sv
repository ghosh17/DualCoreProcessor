/*
Filename: Register File 
Author:  mg280
*/

`include "register_file_if.vh"

module register_file(
		     input logic clk, 
		     input logic nRst,
		     register_file_if.rf rfif
		     );

   import cpu_types_pkg::*;

   word_t register[31:0];

   always_ff @ (negedge clk, negedge nRst) begin
      if(nRst==0) begin
	 register<='{default:0};
      end
      else if ((rfif.WEN==1) && (rfif.wsel != 0)) begin
	 register[rfif.wsel] <= rfif.wdat;
      end
   end


   always_comb begin
      if(rfif.rsel1 >= 0 && rfif.rsel1 <= 5'b11111) begin
	 rfif.rdat1 = register[rfif.rsel1];
      end
      else begin
	rfif.rdat1 = 0;
      end

      if(rfif.rsel2 >= 0 && rfif.rsel2 <= 5'b11111) begin
	 rfif.rdat2 = register[rfif.rsel2];
      end
      else begin
	rfif.rdat2 = 0;
      end
   end

endmodule
