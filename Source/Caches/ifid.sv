`include "cpu_types_pkg.vh"
`include "ifid_if.vh"

module ifid(
	input logic clk,
	input logic nRst,
	ifid_if.ifid ifid
);

	import cpu_types_pkg::*;

	always_ff @ (posedge clk, negedge nRst)
	begin

		if(nRst == 0 /* || ifid.wen == 0 */)
		begin
			ifid.imemload <= '0;
			ifid.imemaddr <= '0;
		end 
		else if(ifid.flushed == 1 && ifid.wen == 1 )
		begin
			ifid.imemload <= '0;
			ifid.imemaddr <= '0;
		end


		else 
		begin
			if(ifid.wen == 1 && ifid.flushed == 0 /*&& ifid.ihit == 1*/)
			begin
				ifid.imemload <= ifid.imemload_input;
				ifid.imemaddr <= ifid.imemaddr_input;
			end
			/* else if(ifid.flushed == 1 || ifid.wen == 0)
			begin
				//being stopped for one cycle and not two??
				ifid.imemload<=0;
				ifid.imemaddr<=0; 
			end */
		end
	end

endmodule
