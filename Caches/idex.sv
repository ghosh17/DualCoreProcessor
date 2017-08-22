`include "cpu_types_pkg.vh"
`include "ifid_if.vh"
import cpu_types_pkg::*;

module idex(
input logic clk,
input logic nRst,
idex_if.idex idex
);


always_ff @ (posedge clk, negedge nRst)
begin

	if(nRst == 0)
	begin
		idex.imemload<=0;
		idex.imemaddr<=0;
		idex.MemRead<=0;
		idex.MemWrite<=0;
		idex.RegWrite<=0;
		
		idex.branch<=0;
		idex.MemtoReg<=0;
		idex.RegDst<=0;
		idex.Ext_op<=0;
		idex.alusrc<=0;
		idex.jal_jump<=0;
		idex.halt<=0;
		idex.lui<=0;
		idex.sll<=0;
		idex.srl<=0;
		idex.bne<=0;
		idex.jr<=0;
		idex.imemload<=0;
		idex.imemaddr<=0;
		idex.sign_t<=0;
		idex.rdat1<=0;
		idex.rdat2<=0;
		idex.aluop<=ALU_OR;
		idex.jaddr<=0;
		idex.jump<=0;
	end
	

	else if(idex.flushed == 1 && idex.wen == 1) begin
		idex.imemload<=0;
		idex.imemaddr<=0;
		idex.MemRead<=0;
		idex.MemWrite<=0;
		idex.RegWrite<=0;
		
		idex.branch<=0;
		idex.MemtoReg<=0;
		idex.RegDst<=0;
		idex.Ext_op<=0;
		idex.alusrc<=0;
		idex.jal_jump<=0;
		idex.halt<=0;
		idex.lui<=0;
		idex.sll<=0;
		idex.srl<=0;
		idex.bne<=0;
		idex.jr<=0;
		idex.imemload<=0;
		idex.imemaddr<=0;
		idex.sign_t<=0;
		idex.rdat1<=0;
		idex.rdat2<=0;
		idex.aluop<=ALU_OR;
		idex.jaddr<=0;
		idex.jump<=0;
	end


	else 
	begin
		if(idex.wen == 1 /*&& idex.ihit == 1*/)
		begin
			idex.imemload<=idex.imemload_input;
			idex.imemaddr<=idex.imemaddr_input;
			idex.MemRead<=idex.MemRead_input;
			idex.MemWrite<=idex.MemWrite_input;
			idex.RegWrite<=idex.RegWrite_input;
			
			idex.branch<=idex.branch_input;
			idex.MemtoReg<=idex.MemtoReg_input;
			idex.RegDst<=idex.RegDst_input;
			idex.Ext_op<=idex.Ext_op_input;
			idex.alusrc<=idex.alusrc_input;
			idex.jal_jump<=idex.jal_jump_input;
			idex.halt<=idex.halt_input;
			idex.lui<=idex.lui_input;
			idex.sll<=idex.sll_input;
			idex.srl<=idex.srl_input;
			idex.bne<=idex.bne_input;
			idex.jr<=idex.jr_input;
			idex.sign_t<=idex.sign_t_input;
			idex.rdat1<=idex.rdat1_input;
			idex.rdat2<=idex.rdat2_input;
			idex.aluop<=idex.aluop_input;
			idex.jaddr<=idex.jaddr_input;
			idex.jump<=idex.jump_input;
		end

		/* else if(idex.wen == 0)
		begin
			idex.imemload<=0;
			idex.imemaddr<=0;
			idex.MemRead<=0;
			idex.MemWrite<=0;
			idex.RegWrite<=0;
			idex.jump<=0;
			idex.branch<=0;
			idex.MemtoReg<=0;
			idex.RegDst<=0;
			idex.Ext_op<=0;
			idex.alusrc<=0;
			idex.jal_jump<=0;
			idex.halt<=0;
			idex.lui<=0;
			idex.sll<=0;
			idex.srl<=0;
			idex.bne<=0;
			idex.jr<=0;
			idex.imemload<=0;
			idex.imemaddr<=0;
			idex.sign_t<=0;
			idex.rdat1<=0;
			idex.rdat2<=0;
			idex.aluop<=ALU_OR;
			idex.jaddr<=0;
		end */
	end


end

endmodule