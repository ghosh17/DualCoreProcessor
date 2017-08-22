`include "forward_unit_if.vh"
`include "cpu_types_pkg.vh"

module forward_unit (
	forward_unit_if.fu fuif
	// input logic sll,
	// input logic srl,
	// input logic alusrc,
	// input logic MemRead,
	// input logic MemWrite
);

	import cpu_types_pkg::*;

	always_comb
	begin

		fuif.forward_a = 2'b00;
		fuif.forward_b = 2'b00;

		// EX HAZARD
		/*

		*/
		if((fuif.exmem_regwrite == 1)
			&& (fuif.exmem_register_rd != 0)
			&& (fuif.exmem_register_rd == fuif.idex_register_rs))
		begin
			fuif.forward_a = 2'b10;
		end
		else if((fuif.memwb_regwrite == 1)
			&& (fuif.memwb_register_rd != 0)
			 /* && !((fuif.exmem_regwrite == 1)) */ /*&& !((fuif.exmem_register_rd != 0)*/ // && !((fuif.exmem_register_rd == fuif.idex_register_rs))
			&& (fuif.memwb_register_rd == fuif.idex_register_rs))
		begin
			fuif.forward_a = 2'b01;
		end

		if ((fuif.exmem_regwrite == 1)
			&& (fuif.exmem_register_rd != 0)
			&& (fuif.exmem_register_rd == fuif.idex_register_rt))
		begin
			fuif.forward_b = 2'b10;
			if((fuif.MemRead==0)&& (fuif.MemWrite==0) && (fuif.alusrc == 1))
			begin
				fuif.forward_b = 2'b11;
			end
		end

		else if((fuif.memwb_regwrite == 1)
			&& (fuif.memwb_register_rd != 0)
			/* && (!((fuif.exmem_regwrite == 1))) */ /*&& !((fuif.exmem_register_rd != 0)*/ // && !((fuif.exmem_register_rd == fuif.idex_register_rt))
			&& (fuif.memwb_register_rd == fuif.idex_register_rt))
		begin
			fuif.forward_b = 2'b01;
		end

		// if(fuif.forward_a == 2'b00)
		// begin
		// 	// MEM HAZARD
		// 	if((fuif.memwb_regwrite == 1)
		// 		&& (fuif.memwb_register_rd != 0)
		// 		 /* && !((fuif.exmem_regwrite == 1)) */ /*&& !((fuif.exmem_register_rd != 0)*/ && !((fuif.exmem_register_rd == fuif.idex_register_rs))
		// 		&& (fuif.memwb_register_rd == fuif.idex_register_rs))
		// 	begin
		// 		fuif.forward_a = 2'b01;
		// 	end
		// end

		// if(fuif.forward_b == 2'b00)
		// begin
		// 	/*else if*/ if((fuif.memwb_regwrite == 1)
		// 		&& (fuif.memwb_register_rd != 0)
		// 		/* && (!((fuif.exmem_regwrite == 1))) */ /*&& !((fuif.exmem_register_rd != 0)*/ && !((fuif.exmem_register_rd == fuif.idex_register_rt))
		// 		&& (fuif.memwb_register_rd == fuif.idex_register_rt))
		// 	begin
		// 		fuif.forward_b = 2'b01;
		// 	end
		// end
	end

endmodule // forward_unit