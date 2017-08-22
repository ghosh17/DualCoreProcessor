`include "cpu_types_pkg.vh"
`include "alu_if.vh"

module alu_fpga (
	input logic [17:0] SW,
	input logic [3:0] KEY,
	output logic [17:0] LEDR,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5,
	output logic [6:0] HEX6,
	output logic [6:0] HEX7
);

	import cpu_types_pkg::*;

	alu_if aluif ();
	word_t register_b;

	alu DUT(
		.alu_port(aluif)	
	);

	/* Storage for register_b */
	always_ff @ (SW[17])
	begin
		if(SW[17] == 1)
		begin
			register_b <= {15'b000000000000000, SW[16:0]};//16 or 15??
		end
	end

	/* Port Assignments for register B */
	assign aluif.port_A = {15'b000000000000000, SW[16:0]};
	assign aluif.port_B = register_b;

	/* ALUOP key assignment */
	assign aluif.aluop[0] = ~KEY[0];
	assign aluif.aluop[1] = ~KEY[1];
	assign aluif.aluop[2] = ~KEY[2];
	assign aluif.aluop[3] = ~KEY[3];
	
	/* ALU flag assignments */
	assign LEDR[0] = aluif.zero;
	assign LEDR[1] = aluif.overflow;
	assign LEDR[2] = aluif.negative;

	always_comb
	begin
		unique casez (aluif.port_O[3:0])
			'h0: HEX0 = 7'b1000000;
			'h1: HEX0 = 7'b1111001;
			'h2: HEX0 = 7'b0100100;
			'h3: HEX0 = 7'b0110000;
			'h4: HEX0 = 7'b0011001;
			'h5: HEX0 = 7'b0010010;
			'h6: HEX0 = 7'b0000010;
			'h7: HEX0 = 7'b1111000;
			'h8: HEX0 = 7'b0000000;
			'h9: HEX0 = 7'b0010000;
			'ha: HEX0 = 7'b0001000;
			'hb: HEX0 = 7'b0000011;
			'hc: HEX0 = 7'b0100111;
			'hd: HEX0 = 7'b0100001;
			'he: HEX0 = 7'b0000110;
			'hf: HEX0 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[7:4])
			'h0: HEX1 = 7'b1000000;
			'h1: HEX1 = 7'b1111001;
			'h2: HEX1 = 7'b0100100;
			'h3: HEX1 = 7'b0110000;
			'h4: HEX1 = 7'b0011001;
			'h5: HEX1 = 7'b0010010;
			'h6: HEX1 = 7'b0000010;
			'h7: HEX1 = 7'b1111000;
			'h8: HEX1 = 7'b0000000;
			'h9: HEX1 = 7'b0010000;
			'ha: HEX1 = 7'b0001000;
			'hb: HEX1 = 7'b0000011;
			'hc: HEX1 = 7'b0100111;
			'hd: HEX1 = 7'b0100001;
			'he: HEX1 = 7'b0000110;
			'hf: HEX1 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[11:8])
			'h0: HEX2 = 7'b1000000;
			'h1: HEX2 = 7'b1111001;
			'h2: HEX2 = 7'b0100100;
			'h3: HEX2 = 7'b0110000;
			'h4: HEX2 = 7'b0011001;
			'h5: HEX2 = 7'b0010010;
			'h6: HEX2 = 7'b0000010;
			'h7: HEX2 = 7'b1111000;
			'h8: HEX2 = 7'b0000000;
			'h9: HEX2 = 7'b0010000;
			'ha: HEX2 = 7'b0001000;
			'hb: HEX2 = 7'b0000011;
			'hc: HEX2 = 7'b0100111;
			'hd: HEX2 = 7'b0100001;
			'he: HEX2 = 7'b0000110;
			'hf: HEX2 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[15:12])
			'h0: HEX3 = 7'b1000000;
			'h1: HEX3 = 7'b1111001;
			'h2: HEX3 = 7'b0100100;
			'h3: HEX3 = 7'b0110000;
			'h4: HEX3 = 7'b0011001;
			'h5: HEX3 = 7'b0010010;
			'h6: HEX3 = 7'b0000010;
			'h7: HEX3 = 7'b1111000;
			'h8: HEX3 = 7'b0000000;
			'h9: HEX3 = 7'b0010000;
			'ha: HEX3 = 7'b0001000;
			'hb: HEX3 = 7'b0000011;
			'hc: HEX3 = 7'b0100111;
			'hd: HEX3 = 7'b0100001;
			'he: HEX3 = 7'b0000110;
			'hf: HEX3 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[19:16])
			'h0: HEX4 = 7'b1000000;
			'h1: HEX4 = 7'b1111001;
			'h2: HEX4 = 7'b0100100;
			'h3: HEX4 = 7'b0110000;
			'h4: HEX4 = 7'b0011001;
			'h5: HEX4 = 7'b0010010;
			'h6: HEX4 = 7'b0000010;
			'h7: HEX4 = 7'b1111000;
			'h8: HEX4 = 7'b0000000;
			'h9: HEX4 = 7'b0010000;
			'ha: HEX4 = 7'b0001000;
			'hb: HEX4 = 7'b0000011;
			'hc: HEX4 = 7'b0100111;
			'hd: HEX4 = 7'b0100001;
			'he: HEX4 = 7'b0000110;
			'hf: HEX4 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[23:20])
			'h0: HEX5 = 7'b1000000;
			'h1: HEX5 = 7'b1111001;
			'h2: HEX5 = 7'b0100100;
			'h3: HEX5 = 7'b0110000;
			'h4: HEX5 = 7'b0011001;
			'h5: HEX5 = 7'b0010010;
			'h6: HEX5 = 7'b0000010;
			'h7: HEX5 = 7'b1111000;
			'h8: HEX5 = 7'b0000000;
			'h9: HEX5 = 7'b0010000;
			'ha: HEX5 = 7'b0001000;
			'hb: HEX5 = 7'b0000011;
			'hc: HEX5 = 7'b0100111;
			'hd: HEX5 = 7'b0100001;
			'he: HEX5 = 7'b0000110;
			'hf: HEX5 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[27:24])
			'h0: HEX6 = 7'b1000000;
			'h1: HEX6 = 7'b1111001;
			'h2: HEX6 = 7'b0100100;
			'h3: HEX6 = 7'b0110000;
			'h4: HEX6 = 7'b0011001;
			'h5: HEX6 = 7'b0010010;
			'h6: HEX6 = 7'b0000010;
			'h7: HEX6 = 7'b1111000;
			'h8: HEX6 = 7'b0000000;
			'h9: HEX6 = 7'b0010000;
			'ha: HEX6 = 7'b0001000;
			'hb: HEX6 = 7'b0000011;
			'hc: HEX6 = 7'b0100111;
			'hd: HEX6 = 7'b0100001;
			'he: HEX6 = 7'b0000110;
			'hf: HEX6 = 7'b0001110;
		endcase

		unique casez (aluif.port_O[31:28])
			'h0: HEX7 = 7'b1000000;
			'h1: HEX7 = 7'b1111001;
			'h2: HEX7 = 7'b0100100;
			'h3: HEX7 = 7'b0110000;
			'h4: HEX7 = 7'b0011001;
			'h5: HEX7 = 7'b0010010;
			'h6: HEX7 = 7'b0000010;
			'h7: HEX7 = 7'b1111000;
			'h8: HEX7 = 7'b0000000;
			'h9: HEX7 = 7'b0010000;
			'ha: HEX7 = 7'b0001000;
			'hb: HEX7 = 7'b0000011;
			'hc: HEX7 = 7'b0100111;
			'hd: HEX7 = 7'b0100001;
			'he: HEX7 = 7'b0000110;
			'hf: HEX7 = 7'b0001110;
		endcase
	end

	
endmodule
