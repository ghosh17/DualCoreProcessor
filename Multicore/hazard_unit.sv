`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"

module hazard_unit (
	hazard_unit_if.hu huif
);

	import cpu_types_pkg::*;

	/* assign huif.stall = (((huif.idex_memread == 1) || (huif.idex_lui == 1) || (huif.idex_memwrite == 1) || (huif.ifid_jump == 1) || (huif.ifid_branch == 1))
			&& ((huif.idex_register_rt == huif.ifid_register_rs) || 
				(huif.idex_register_rt == huif.ifid_register_rt))) ? 1 : 0;
	assign huif.prog_en = !huif.stall; */

	// For load instructions 
	always_comb
	begin
		huif.stall = 0;
		huif.prog_en = 1;
		if((((huif.idex_memread == 1) || (huif.idex_lui == 1) || (huif.idex_memwrite == 1))//load 
			&& ((huif.idex_register_rt == huif.ifid_register_rs) 
			||	(huif.idex_register_rt == huif.ifid_register_rt))) 
			|| (huif.ifid_jump == 1) || (huif.ifid_branch == 1) || (huif.idex_memwrite == 1))
		begin
			huif.stall = 1;
			huif.prog_en = 0;
		end

	end

endmodule // hazard_unit