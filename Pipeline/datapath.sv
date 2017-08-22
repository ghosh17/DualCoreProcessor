/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"
`include "alu_if.vh"
`include "pc_if.vh"
`include "register_file_if.vh"
`include "control_unit_if.vh"
`include "ifid_if.vh"
`include "idex_if.vh"
`include "exmem_if.vh"
`include "memwb_if.vh"
`include "hazard_unit_if.vh"
`include "forward_unit_if.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
	// import types
	import cpu_types_pkg::*;

	parameter PC_INIT = 0;

	control_unit_if control_if();
	// request_unit_if request_if();
	alu_if logic_if();
	register_file_if register_if();
	pc_if prog_if();
	hazard_unit_if hu_if();
	forward_unit_if fu_if();

	alu ALU(logic_if);
	register_file REGISTER(CLK, nRST, register_if);
	control_unit CONTROL(control_if);
	// request_unit REQUEST(CLK, nRST, request_if);
	pc #(.PC_INIT(PC_INIT)) PROG_COUNT(CLK, nRST, prog_if);
	hazard_unit HAZARD(hu_if);
	//forward_unit FORWARD(fu_if,  sll ,  srl, alusrc, MemRead, MemWrite);
	forward_unit FORWARD(fu_if);
	

	/* Pipeline registers */
	ifid_if if_id_if();
	idex_if id_ex_if();
	exmem_if ex_mem_if();
	memwb_if mem_wb_if();

	// logic sll, srl, alusrc, MemRead, MemWrite;
	 
	// assign MemWrite = id_ex_if.MemWrite;

	ifid IFID(CLK, nRST, if_id_if);
	idex IDEX(CLK, nRST, id_ex_if);
	exmem EXMEM(CLK, nRST, ex_mem_if);
	memwb MEMWB(CLK, nRST, mem_wb_if);

	word_t sign_out;
	word_t m6_out, m3_out, m8_out, m9_out, m10_out;
	logic branch_take, ff_nop_counter_wen, branch_counter_wen;
	logic [1:0] ff_nop_counter;
	logic [1:0] branch_counter;

	assign m8_out = (fu_if.forward_b == 2'b00) ? id_ex_if.rdat2 : ((fu_if.forward_b == 2'b01 && id_ex_if.MemWrite != 1) ? m6_out : ((fu_if.forward_b == 2'b10 && id_ex_if.MemWrite != 1) ? ex_mem_if.port_O : id_ex_if.rdat2));
	//(id_ex_if.alusrc == 1) ? id_ex_if.sign_t : ((id_ex_if.sll == 1 || id_ex_if.srl == 1) ? {26'b0, id_ex_if.imemload[10:6]} : id_ex_if.rdat2);
	assign m9_out = (id_ex_if.alusrc == 1) ? id_ex_if.sign_t : ((id_ex_if.sll == 1 || id_ex_if.srl == 1) ? {26'b0, id_ex_if.imemload[10:6]} : m8_out);

	assign m10_out = (fu_if.forward_a == 2'b00) ? id_ex_if.rdat1 : ((fu_if.forward_a == 2'b01 /*&& id_ex_if.MemWrite != 1*/) ? m6_out : ((fu_if.forward_a == 2'b10 /*&& id_ex_if.MemWrite != 1*/) ? ex_mem_if.port_O : id_ex_if.rdat1));

  	// ALU Inputs
	assign logic_if.port_A = m10_out; /*(fu_if.forward_a == 2'b00) ? id_ex_if.rdat1 : ((fu_if.forward_a == 2'b01) ? m6_out : ((fu_if.forward_a == 2'b10) ? ex_mem_if.port_O : id_ex_if.rdat1));*/
  	assign logic_if.port_B = m9_out;
	assign logic_if.aluop = id_ex_if.aluop;

  	// Program Counter Inputs
 	assign prog_if.jump = id_ex_if.jump; // ex_mem_if.jump;
  	assign prog_if.branch = id_ex_if.branch;// ex_mem_if.branch;
	assign prog_if.zflag = (m9_out == m10_out) ? 1 : 0; // (register_if.rdat2 == register_if.rdat1) ? 1 : 0; // ex_mem_if.zero;
	assign prog_if.imem_load = id_ex_if.imemload; // ex_mem_if.imemload;
	assign prog_if.bmemload = id_ex_if.imemload;
	assign prog_if.bmemaddr = id_ex_if.imemaddr;
	assign prog_if.bne = id_ex_if.bne; // ex_mem_if.bne;
	assign prog_if.jr = control_if.jr; // ex_mem_if.jr;
	assign prog_if.jaddr = register_if.rdat1; // ex_mem_if.rdat1;
	assign prog_if.pc_wen = /* !control_if.halt; */ (dpif.ihit == 1 && dpif.dhit == 0 && mem_wb_if.halt == 0 && id_ex_if.MemRead==0 &&id_ex_if.MemWrite == 0) ? 1 : 0; 
	//assign prog_if.pc_wen = dpif.ihit;
	// Datapath Inputs
  	assign dpif.imemaddr = prog_if.imemaddr;
	assign dpif.dmemREN = ex_mem_if.MemRead;
	assign dpif.dmemWEN = ex_mem_if.MemWrite;
	assign dpif.imemREN = 1 && !ex_mem_if.MemRead && !ex_mem_if.MemWrite;
	assign dpif.dmemaddr = ex_mem_if.port_O;
	assign dpif.dmemstore = ex_mem_if.rdat2;
	//assign dpif.halt = mem_wb_if.halt;
	assign dpif.halt = mem_wb_if.halt;
	// Halt Register
	// always_ff @ (posedge CLK, negedge nRST)
	// begin
	// 	if(!nRST)
	// 	begin
	// 		dcif.halt <= 0;
	// 	end
	// 	else
	// 	begin
	// 		if(mem_wb_if.halt == 1)
	// 		begin
	// 			dcif.halt <= mem_wb_if.halt;
	// 		end
	// 	end
	// end

	assign m3_out = (mem_wb_if.MemtoReg == 1) ? mem_wb_if.dmemload : mem_wb_if.port_O;
	assign m6_out = (mem_wb_if.lui == 1 || mem_wb_if.jal_jump == 1) ? mem_wb_if.jal_jump_mux_output : m3_out;

	// Register File Inputs
	assign register_if.WEN = mem_wb_if.RegWrite; // && (dpif.dhit == 1 || dpif.ihit == 1); // || dpif.ihit == 1);
	assign register_if.rsel1 = if_id_if.imemload[25:21];
	assign register_if.rsel2 = if_id_if.imemload[20:16];
	assign register_if.wsel = mem_wb_if.wsel; // (mem_wb_if.jal_jump == 1) ? 5'b11111 : mem_wb_if.jal_jump_mux; // ((mem_wb_if.RegDst == 1) ? dpif.imemload[15:11] : dpif.imemload[20:16]);
	assign register_if.wdat = m6_out; // (control_if.jal_jump == 1) ? prog_if.imemaddr : ((control_if.MemtoReg == 1) ? dpif.dmemload : ((control_if.lui == 1) ? sign_out : logic_if.port_O));

	// Request Unit Inputs
	// assign request_if.memread = control_if.MemRead;
	// assign request_if.memwrite = control_if.MemWrite;
	// assign request_if.ihit = dpif.ihit;
	// assign request_if.dhit = dpif.dhit;

	// Control Unit Inputs
	assign control_if.funct = funct_t'(if_id_if.imemload[5:0]);
	assign control_if.op = opcode_t'(if_id_if.imemload[31:26]);
	assign control_if.zflag = 0; // logic_if.zero;

	// Sign Extension
	always_comb
	begin
		sign_out = {16'h0000, if_id_if.imemload[15:0]};
		if(control_if.Ext_op == 0 && control_if.lui == 0)
		begin
			sign_out = {16'h0000, if_id_if.imemload[15:0]};
		end
		else if(control_if.Ext_op == 1 && control_if.lui == 0)
		begin
			if(if_id_if.imemload[15] == 1'b1)
			begin
				sign_out = {16'hFFFF, if_id_if.imemload[15:0]};
			end
			else
			begin
				sign_out = {16'h0000, if_id_if.imemload[15:0]};
			end
		end
		else if(control_if.lui == 1'b1)
		begin
			sign_out = {if_id_if.imemload[15:0], 16'h0000};
		end
	end 

	// IF/ID
	assign if_id_if.imemaddr_input = prog_if.imemaddr;
	assign if_id_if.imemload_input = dpif.imemload;
	//assign if_id_if.flushed = (branch_take == 1) || (control_if.jump == 1 || control_if.jal_jump == 1 || control_if.jr == 1); // || (branch_counter == 2'b01);
	assign if_id_if.flushed = (branch_take == 1 || id_ex_if.jump==1);
	assign if_id_if.ihit=dpif.ihit;//ihit
	// ID/EX
	assign id_ex_if.MemRead_input = control_if.MemRead; 
	assign id_ex_if.MemWrite_input = control_if.MemWrite;
	assign id_ex_if.RegWrite_input = control_if.RegWrite;
	//assign id_ex_if.jump_input = control_if.jump;
	assign id_ex_if.branch_input = control_if.branch;
	assign id_ex_if.MemtoReg_input = control_if.MemtoReg;
	assign id_ex_if.RegDst_input = control_if.RegDst;
	assign id_ex_if.Ext_op_input = control_if.Ext_op;
	assign id_ex_if.alusrc_input = control_if.alusrc;
	assign id_ex_if.jal_jump_input = control_if.jal_jump;
	assign id_ex_if.halt_input = control_if.halt;
	assign id_ex_if.lui_input = control_if.lui;
	assign id_ex_if.sll_input = control_if.sll;
	assign id_ex_if.srl_input = control_if.srl;
	assign id_ex_if.bne_input = control_if.bne;
	assign id_ex_if.jr_input = control_if.jr;
	assign id_ex_if.imemload_input = if_id_if.imemload; 
	assign id_ex_if.imemaddr_input = if_id_if.imemaddr;
	assign id_ex_if.sign_t_input = sign_out;
	assign id_ex_if.rdat1_input = register_if.rdat1;
	assign id_ex_if.rdat2_input = register_if.rdat2;
	assign id_ex_if.aluop_input = control_if.aluop;
	assign id_ex_if.ihit=dpif.ihit;//ihit
	assign id_ex_if.jump_input=control_if.jump || control_if.jal_jump || control_if.jr;

	// EX/MEM
	assign ex_mem_if.branch_input = id_ex_if.branch;
	assign ex_mem_if.jump_input = id_ex_if.jump;
	assign ex_mem_if.bne_input = id_ex_if.bne; 
	assign ex_mem_if.jr_input = id_ex_if.jr; 
	// assign ex_mem_if.jaddr_input = id_ex_if.jaddr; 
	assign ex_mem_if.port_O_input = logic_if.port_O; 
	assign ex_mem_if.zero_input = logic_if.zero; 
	assign ex_mem_if.lui_input = id_ex_if.lui; 
	assign ex_mem_if.rdat2_input = /*id_ex_if.rdat2*/ (fu_if.forward_b == 2'b00) ? id_ex_if.rdat2 : ((fu_if.forward_b == 2'b01) ? m6_out : ((fu_if.forward_b == 2'b10) ? ex_mem_if.port_O : m8_out)); 
	assign ex_mem_if.RegWrite_input = id_ex_if.RegWrite; 
	assign ex_mem_if.MemtoReg_input = id_ex_if.MemtoReg; 
	assign ex_mem_if.MemRead_input = id_ex_if.MemRead; 
	assign ex_mem_if.MemWrite_input = id_ex_if.MemWrite; 
	assign ex_mem_if.jal_jump_mux_input = (id_ex_if.jal_jump == 1) ? id_ex_if.imemaddr + 4 : id_ex_if.sign_t; 
	assign ex_mem_if.imemload_input = id_ex_if.imemload;
	assign ex_mem_if.rdat1_input = (fu_if.forward_a == 2'b00) ? id_ex_if.rdat1 : ((fu_if.forward_a == 2'b01) ? m6_out : ((fu_if.forward_a == 2'b10) ? ex_mem_if.port_O : id_ex_if.rdat1)); /* id_ex_if.rdat1; */
	assign ex_mem_if.wsel_input = (id_ex_if.jal_jump == 1) ? 5'b11111 : ((id_ex_if.RegDst == 1) ? id_ex_if.imemload[15:11] : id_ex_if.imemload[20:16]);
	assign ex_mem_if.halt_input = id_ex_if.halt; 
	assign ex_mem_if.jal_jump_input = id_ex_if.jal_jump;
	assign ex_mem_if.ihit = dpif.ihit;

	// MEM/WB
	assign mem_wb_if.port_O_input = ex_mem_if.port_O;
	assign mem_wb_if.MemtoReg_input = ex_mem_if.MemtoReg;
	assign mem_wb_if.dmemload_input = dpif.dmemload;
	assign mem_wb_if.RegWrite_input = ex_mem_if.RegWrite;
	assign mem_wb_if.imemload_input = ex_mem_if.imemload;
	// assign mem_wb_if.imemaddr_input =
	assign mem_wb_if.jal_jump_mux_output_input = ex_mem_if.jal_jump_mux;
	assign mem_wb_if.lui_input = ex_mem_if.lui;
	assign mem_wb_if.wsel_input = ex_mem_if.wsel;
	assign mem_wb_if.halt_input = ex_mem_if.halt;
	assign mem_wb_if.jal_jump_input = ex_mem_if.jal_jump;
	assign mem_wb_if.ihit = dpif.ihit;

	/* always_ff @ (posedge CLK, negedge nRST)
	begin
		if(!nRST)
		begin
			mem_wb_if.wen <= 0; // && dpif.ihit && !dpif.dhit;
			ex_mem_if.wen <= 0; // && dpif.ihit && !dpif.dhit;
			id_ex_if.wen <= 0; // && dpif.ihit && !dpif.dhit;
			// if_id_if.wen <= 0; // && dpif.ihit && !dpif.dhit;
		end
		else
		begin
			mem_wb_if.wen <= !hu_if.stall;
			ex_mem_if.wen <= !hu_if.stall;
			id_ex_if.wen <= !hu_if.stall;
			// if_id_if.wen <= !hu_if.stall;
		end
	end */

//Don't use nRST DrJ. Won't work for mapped and fpga 
	assign mem_wb_if.wen = (dpif.ihit || dpif.dhit) && !mem_wb_if.halt;  // !hu_if.stall; 
	assign ex_mem_if.wen = (dpif.ihit || dpif.dhit); // !hu_if.stall;
	assign id_ex_if.wen = /*!ff_nop_counter_wen && */dpif.ihit;
	assign id_ex_if.flushed = (id_ex_if.MemRead==1 || id_ex_if.MemWrite == 1 || id_ex_if.jump==1 || branch_take) ;
	assign if_id_if.wen = /*(!ff_nop_counter_wen) && */dpif.ihit && id_ex_if.MemRead==0 && id_ex_if.MemWrite == 0;

	// HAZARD UNIT
	assign hu_if.idex_register_rt = regbits_t'(id_ex_if.imemload[20:16]);
	assign hu_if.idex_register_rs = regbits_t'(id_ex_if.imemload[25:21]);
	assign hu_if.ifid_register_rs = regbits_t'(if_id_if.imemload[25:21]);
	assign hu_if.ifid_register_rt = regbits_t'(if_id_if.imemload[20:16]);
	assign hu_if.idex_register_rd = (id_ex_if.jal_jump == 1) ? regbits_t'(5'b11111) : ((id_ex_if.RegDst == 1) ? regbits_t'(id_ex_if.imemload[15:11]) : regbits_t'(id_ex_if.imemload[20:16]));
	assign hu_if.idex_memread = id_ex_if.MemRead;
	assign hu_if.idex_lui = id_ex_if.lui;
	assign hu_if.idex_memwrite = id_ex_if.MemWrite;
	assign hu_if.ifid_branch = control_if.branch || control_if.bne;
	assign hu_if.ifid_jump = id_ex_if.jump;

	// FORWARD UNIT
	assign fu_if.exmem_regwrite = ex_mem_if.RegWrite; 
	assign fu_if.memwb_regwrite = mem_wb_if.RegWrite;
	assign fu_if.exmem_register_rd = ex_mem_if.wsel;
	assign fu_if.idex_register_rs = id_ex_if.imemload[25:21];
	assign fu_if.idex_register_rt = id_ex_if.imemload[20:16]; 
	assign fu_if.memwb_register_rd = mem_wb_if.wsel;
	
	// assign fu_if.srl = id_ex_if.srl;
	// assign fu_if.sll = id_ex_if.sll;
	
	assign fu_if.alusrc = id_ex_if.alusrc;
	assign fu_if.MemRead = id_ex_if.MemRead;
	// BNE & BEQ
	assign branch_take = ((id_ex_if.branch == 1) && (m9_out == m10_out)) || ((id_ex_if.bne == 1) && (m9_out != m10_out));

	/*assign ff_nop_counter_wen = (ff_nop_counter == 2'b00 && hu_if.stall == 1) ? 1 : 0; // ((ff_nop_countevr == 2'b01) ? 1 : 0));

	always_ff @(posedge CLK, negedge nRST)
	begin
		if(!nRST) 
		begin
			ff_nop_counter <= 0;
		end 
		else 
		begin
			if(ff_nop_counter_wen == 1)
			begin
				ff_nop_counter <= ff_nop_counter + 1;
			end
			else
			begin
				ff_nop_counter <= 0;
			end
		end
	end

	assign branch_counter_wen = (branch_counter == 2'b00 && branch_take == 1) ? 1 : ((branch_counter == 2'b01) ? 1 : 0);

	always_ff @(posedge CLK or negedge nRST) 
	begin
		if(~nRST) 
		begin
			branch_counter <= 0;
		end 
		else 
		begin
			if(branch_counter_wen == 1)
			begin
				branch_counter <= branch_counter + 1;
			end
			else
			begin
				branch_counter <= 0;
			end
		end
	end*/

endmodule