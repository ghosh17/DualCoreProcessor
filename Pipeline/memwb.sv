`include "cpu_types_pkg.vh"
`include "memwb_if.vh"
import cpu_types_pkg::*;

module memwb(
input logic clk,
input logic nRst,
memwb_if.memwb memwb
);


always_ff @ (posedge clk, negedge nRst)
begin

	if(nRst==0)
	begin
		memwb.imemload<=0;
		memwb.imemaddr<=0;
		memwb.port_O<=0;
		memwb.MemtoReg<=0;
		memwb.dmemload<=0;
		memwb.RegWrite<=0;
		memwb.jal_jump_mux_output<=0;
		memwb.wsel<=0;
		memwb.lui<=0;
		memwb.halt<=0;
		memwb.jal_jump<=0;
	end
	else begin
		if(memwb.wen == 1 /*&& memwb.ihit == 1*/)
		begin
			memwb.imemload<=memwb.imemload_input;
			memwb.imemaddr<=memwb.imemaddr_input;
			memwb.port_O<=memwb.port_O_input;
			memwb.MemtoReg<=memwb.MemtoReg_input;
			memwb.dmemload<=memwb.dmemload_input;
			memwb.RegWrite<=memwb.RegWrite_input;
			memwb.jal_jump_mux_output<=memwb.jal_jump_mux_output_input;
			memwb.wsel<=memwb.wsel_input;
			memwb.lui<=memwb.lui_input;
			memwb.halt<=memwb.halt_input;
			memwb.jal_jump<=memwb.jal_jump_input;
		end
	end


end

endmodule