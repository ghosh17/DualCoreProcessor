`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

import cpu_types_pkg::*;

module request_unit (
	input logic clk,
	input logic nrst,
	request_unit_if.ru ru
);

	// assign ru.imemren = 1;
	assign ru.imemren = nrst;

	always_ff @ (posedge clk, negedge nrst)
	begin
		if(!nrst)
		begin
			ru.dmemren <= 0;
			ru.dmemwen <= 0;
		end
		else
		begin
			if(ru.ihit == 1)
			begin
				ru.dmemren <= ru.memread;
				ru.dmemwen <= ru.memwrite;
			end
			else if(ru.dhit == 1)
			begin
				ru.dmemren <= 0;
				ru.dmemwen <= 0;
			end
		end
	end

endmodule
