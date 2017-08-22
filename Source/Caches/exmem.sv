`include "cpu_types_pkg.vh"
`include "exmem_if.vh"
import cpu_types_pkg::*;

module exmem(
input logic clk,
input logic nRst,
exmem_if.exmem exmem
);


always_ff @ (posedge clk, negedge nRst)
begin

	if(nRst==0)
	begin
		exmem.branch<=0;
		exmem.jump<=0;
		exmem.bne<=0;
		exmem.jr<=0;
		exmem.jaddr<=0;
		exmem.port_O<=0;
		exmem.zero<=0;
		exmem.lui<=0;
		exmem.rdat2<=0;
		exmem.RegWrite<=0;
		exmem.MemtoReg<=0;
		exmem.MemRead<=0;
		exmem.MemWrite<=0;
		exmem.jal_jump_mux<=0;
		exmem.imemload<=0;
		exmem.rdat1<=0;
		exmem.wsel<=0;
		exmem.halt<=0;
		exmem.jal_jump<=0;
	end
	else begin
		if(exmem.wen == 1 /*&& exmem.ihit == 1*/)
		begin
			exmem.branch<=exmem.branch_input;
			exmem.jump<=exmem.jump_input;
			exmem.bne<=exmem.bne_input;
			exmem.jr<=exmem.jr_input;
			exmem.jaddr<=exmem.jaddr_input;
			exmem.port_O<=exmem.port_O_input;
			exmem.zero<=exmem.zero_input;
			exmem.lui<=exmem.lui_input;
			exmem.rdat2<=exmem.rdat2_input;
			exmem.RegWrite<=exmem.RegWrite_input;
			exmem.MemtoReg<=exmem.MemtoReg_input;
			exmem.MemRead<=exmem.MemRead_input;
			exmem.MemWrite<=exmem.MemWrite_input;
			exmem.jal_jump_mux<=exmem.jal_jump_mux_input;
			exmem.imemload<=exmem.imemload_input;
			exmem.rdat1<=exmem.rdat1_input;
			exmem.wsel<=exmem.wsel_input;
			exmem.halt<=exmem.halt_input;
			exmem.jal_jump<=exmem.jal_jump_input;
		end
	end


end

endmodule
