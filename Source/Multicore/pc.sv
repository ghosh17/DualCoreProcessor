`include "cpu_types_pkg.vh"
`include "pc_if.vh"
import cpu_types_pkg::*;

module pc(
input logic clk,
input logic nRst,
pc_if.pc pc
);

parameter PC_INIT = 0;

word_t temp_reg_n, temp_reg_b, temp;
/*assign temp_reg_n = (pc.jump == 1) ? {pc.imemaddr[31:28], pc.imem_load[25:0], 2'b00} : ((pc.jr == 1) ? pc.jaddr : pc.imemaddr);
assign temp = (pc.imem_load[15] == 1) ? (pc.imemaddr + {14'b11111111111111, pc.imem_load[15:0], 2'b00}) : (pc.imemaddr + {14'b00000000000000, pc.imem_load[15:0], 2'b00});
assign temp_reg_b = ((pc.branch == 1 && pc.zflag==1'b1) || (pc.bne == 1 && pc.zflag==1'b0)) ? temp : pc.imemaddr;
*/
assign temp_reg_n = (pc.jump == 1) ? {pc.bmemaddr[31:28], pc.imem_load[25:0], 2'b00} : ((pc.jr == 1) ? pc.jaddr : pc.bmemaddr);
assign temp = (pc.imem_load[15] == 1) ? (pc.bmemaddr + {14'b11111111111111, pc.imem_load[15:0], 2'b00}) : (pc.bmemaddr + {14'b00000000000000, pc.imem_load[15:0], 2'b00});
assign temp_reg_b = ((pc.branch == 1 && pc.zflag==1'b1) || (pc.bne == 1 && pc.zflag==1'b0)) ? temp : pc.bmemaddr;

//change PC and imemload
always_ff @ (posedge clk, negedge nRst)
begin
	if( nRst == 0 )
	begin
		pc.imemaddr <= /*0;*/ PC_INIT;
	end
	else if ((pc.pc_wen == 1) && (pc.jump==1'b0) && (pc.branch==1'b0 /*&& pc.zflag == 0*/) && (pc.bne == 1'b0))
	begin
		pc.imemaddr<=pc.imemaddr+4;
	end

	else if (/*(pc.pc_wen == 1) &&*/ (pc.jump==1'b0) && (pc.branch==1'b1 && pc.zflag==1'b1) && (pc.bne == 1'b0))//branch 
	begin
		if (pc.bmemload[15] == 1'b1)
		begin
			pc.imemaddr <= pc.bmemaddr + 4 + {14'b11111111111111, pc.bmemload[15:0], 2'b00};
		end
		else if(pc.bmemload[15] == 1'b0)
		begin
			pc.imemaddr <= pc.bmemaddr + 4 + {14'b00000000000000, pc.bmemload[15:0], 2'b00};
		end
		// pc.imemaddr <= temp_reg_b;
	end

	else if (/*(pc.pc_wen == 1) &&*/ (pc.jump==1'b0) && (pc.branch==1'b0 && pc.zflag==1'b0) && (pc.bne == 1'b1)) // bne
	begin
		if (pc.bmemload[15] == 1'b1)
		begin
			pc.imemaddr <= pc.bmemaddr + 4 + {14'b11111111111111, pc.bmemload[15:0], 2'b00};
		end
		else if(pc.bmemload[15] == 1'b0)
		begin
			pc.imemaddr <= pc.bmemaddr + 4 + {14'b00000000000000, pc.bmemload[15:0], 2'b00};
		end
		// pc.imemaddr <= temp_reg_b;
	end

	else if (/*(pc.pc_wen == 1) &&*/ (pc.jump==1'b1) && (pc.branch==1'b0 /*&& pc.zflag == 0*/) )//jump instruction
	begin
		pc.imemaddr <= /*{pc.imemaddr[31:28], pc.imem_load[25:0], 2'b00};*/ temp_reg_n; // {pc.imemaddr[31:28], pc.imem_load[25:0], 2'b00};
	end

	else if (/*pc.pc_wen == 1 &&*/ pc.jr == 1)
	begin
		pc.imemaddr <= temp_reg_n;
	end

	else if(pc.pc_wen == 1) 
	begin
		pc.imemaddr <= pc.imemaddr + 4;
	end

	/* else if(pc.pc_wen == 1)
	begin
		pc.imemaddr <= pc.next_pc;
	end */
end

// assign pc.imemaddr = pc.imemaddr;

// always_comb
// begin
// 	if ((pc.pc_wen == 1) && (pc.jump==1'b0) && (pc.branch==1'b0 && pc.zflag == 0))
// 	begin
// 		temp_reg_n = pc.imemaddr+4;
// 	end
// 	else if ((pc.pc_wen == 1) && (pc.jump==1'b1) && (pc.branch==1'b0 && pc.zflag == 0))//jump instruction
// 	begin
// 		temp_reg_n = {pc.imemaddr[31:28], pc.imem_load[25:0], 2'b00};
// 	end
// 	else if ((pc.pc_wen == 1) && (pc.jump==1'b0) && (pc.branch==1'b1 && pc.zflag==1'b1))//branch 
// 	begin
// 		if (pc.imem_load[15] == 1'b1)
// 		begin
// 			temp_reg_n={14'b11111111111111, pc.imem_load[15:0], 2'b00};
// 		end
// 		else if(pc.imem_load[15] == 1'b0)
// 		begin
// 			temp_reg_n={14'b00000000000000, pc.imem_load[15:0], 2'b00};
// 		end
// 	end
// end

endmodule 
