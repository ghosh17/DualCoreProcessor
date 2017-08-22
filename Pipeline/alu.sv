/*
 *Filename: ALU
 * Author: mg280
 * Adit Ghosh
 * 08/28/2016
 */

`include "cpu_types_pkg.vh"
`include "alu_if.vh"

import cpu_types_pkg::*;

module alu(
	alu_if.alu alu_port
);

	logic temp[WORD_W];

//combinational logic
always_comb begin
	
	case (alu_port.aluop)
	ALU_SLL:begin // shift left //change to code bits
	alu_port.port_O = alu_port.port_A << alu_port.port_B;
	alu_port.overflow = 0;
	end

	ALU_SRL:begin //shift right
	alu_port.port_O = alu_port.port_A >> alu_port.port_B; // Shift Right 
	alu_port.overflow = 0;
	end
	ALU_AND:begin //and
	alu_port.port_O = alu_port.port_A & alu_port.port_B;
	alu_port.overflow = 0;
	end
	ALU_OR:begin //or
	alu_port.port_O = alu_port.port_A | alu_port.port_B;
	alu_port.overflow = 0;
	end
	ALU_XOR:begin //xor
	alu_port.port_O = alu_port.port_A ^ alu_port.port_B;
	alu_port.overflow = 0;
	end
	ALU_NOR:begin //nor
	alu_port.port_O = ~(alu_port.port_A | alu_port.port_B);
	alu_port.overflow = 0;
	end
	ALU_ADD:begin //signed add
	alu_port.port_O = $signed(alu_port.port_A) + $signed(alu_port.port_B);
	if ( (alu_port.port_A[WORD_W - 1] == 1 && alu_port.port_B[WORD_W - 1] == 1 && alu_port.port_O[WORD_W - 1] == 0) || (alu_port.port_A[WORD_W - 1] == 1 && alu_port.port_B[WORD_W - 1] == 1 && alu_port.port_O[WORD_W - 1] == 0)) 
	begin
		alu_port.overflow = 1;
	end
	else 
	begin
		alu_port.overflow = 0;	
	end
	end
	ALU_SUB:begin //signed subtract
	alu_port.port_O = $signed(alu_port.port_A) - $signed(alu_port.port_B);
	if( ((alu_port.port_A[WORD_W - 1] ^ alu_port.port_B[WORD_W - 1])) && ((alu_port.port_A[WORD_W - 1] ^ alu_port.port_O[WORD_W - 1]) == 1))
	
	begin
		alu_port.overflow = 1;
	end
	else
	begin
		alu_port.overflow = 0;
	end
	end
	ALU_SLT:begin //Set less than //IDK
	if ($signed(alu_port.port_A) < $signed(alu_port.port_B)) begin
		alu_port.port_O=1;
		end
	else begin
		alu_port.port_O=0;
	end
	alu_port.overflow = 0;
	end
	
	ALU_SLTU:begin //unsigned less than
	if (alu_port.port_A < alu_port.port_B) begin
		alu_port.port_O=1;
		end
	else begin
		alu_port.port_O=0;
	end
	alu_port.overflow = 0;
	end

	endcase
end

assign alu_port.zero = alu_port.port_O ? 0 : 1;
assign alu_port.negative = alu_port.port_O[WORD_W - 1] ? 1 : 0;

endmodule
