`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"
import cpu_types_pkg::*;

module control_unit(
control_unit_if.cu cont
);

always_comb 
begin


/*

ADDU   $rd,$rs,$rt   R[rd] <= R[rs] + R[rt] (unchecked overflow)
ADD    $rd,$rs,$rt   R[rd] <= R[rs] + R[rt]
AND    $rd,$rs,$rt   R[rd] <= R[rs] AND R[rt]
JR     $rs           PC <= R[rs]
NOR    $rd,$rs,$rt   R[rd] <= ~(R[rs] OR R[rt])
OR     $rd,$rs,$rt   R[rd] <= R[rs] OR R[rt]
SLT    $rd,$rs,$rt   R[rd] <= (R[rs] < R[rt]) ? 1 : 0
SLTU   $rd,$rs,$rt   R[rd] <= (R[rs] < R[rt]) ? 1 : 0
SLL    $rd,$rs,shamt R[rd] <= R[rs] << shamt
SRL    $rd,$rs,shamt R[rd] <= R[rs] >> shamt
SUBU   $rd,$rs,$rt   R[rd] <= R[rs] - R[rt] (unchecked overflow)
SUB    $rd,$rs,$rt   R[rd] <= R[rs] - R[rt]
XOR    $rd,$rs,$rt   R[rd] <= R[rs] XOR R[rt]
---------------------<I-type Instructions>-----------------------
ADDIU  $rt,$rs,imm   R[rt] <= R[rs] + SignExtImm (unchecked overflow)
ADDI   $rt,$rs,imm   R[rt] <= R[rs] + SignExtImm
ANDI   $rt,$rs,imm   R[rt] <= R[rs] & ZeroExtImm
BEQ    $rs,$rt,label PC <= (R[rs] == R[rt]) ? npc+BranchAddr : npc
BNE    $rs,$rt,label PC <= (R[rs] != R[rt]) ? npc+BranchAddr : npc
LUI    $rt,imm       R[rt] <= {imm,16b'0}
LW     $rt,imm($rs)  R[rt] <= M[R[rs] + SignExtImm]
ORI    $rt,$rs,imm   R[rt] <= R[rs] OR ZeroExtImm
SLTI   $rt,$rs,imm   R[rt] <= (R[rs] < SignExtImm) ? 1 : 0
SLTIU  $rt,$rs,imm   R[rt] <= (R[rs] < SignExtImm) ? 1 : 0
SW     $rt,imm($rs)  M[R[rs] + SignExtImm] <= R[rt]
LL     $rt,imm($rs)  R[rt] <= M[R[rs] + SignExtImm]; rmwstate <= addr
SC     $rt,imm($rs)  if (rmw) M[R[rs] + SignExtImm] <= R[rt], R[rt] <= 1 else R[rt] <= 0
XORI   $rt,$rs,imm   R[rt] <= R[rs] XOR ZeroExtImm
---------------------<J-type Instructions>-----------------------
J      label         PC <= JumpAddr
JAL    label         R[31] <= npc; PC <= JumpAddr
---------------------<Other Instructions>------------------------
HALT

*/
		cont.MemRead = 0; //0 for R
		cont.MemWrite = 0; //0 for R
		cont.RegDst = 0; //1 for all R
		cont.jump = 0; //for R
		cont.branch = 0; //0 for R
		cont.MemtoReg = 0; //0 for R
		cont.RegDst = 0; //1 for R
		cont.Ext_op = 0; //either this or I'll create a separate block for sign extension 
		cont.aluop = ALU_OR;//what should aluop's initialization be
		cont.alusrc = 0; // 0 for R
		cont.jal_jump = 0;
		cont.halt = 1'b0;
		cont.lui = 1'b0;
		cont.sll = 0;
		cont.srl = 0;
		cont.bne = 0;
		cont.jr = 0;
		cont.RegWrite = 0;
 
//i type instructions
if(cont.op==RTYPE)
begin
casez(cont.funct)

ADDU:begin //ADDU
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegDst = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegWrite = 1; //1 for R
	cont.Ext_op = 0;//never gonna choose this value in r type. 
	cont.aluop = ALU_ADD;
	cont.alusrc = 0; // 0 for R
	end


ADD:begin//ADD
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_ADD;
	cont.alusrc = 0; // 0 for R
	end
AND:begin//AND
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_AND;
	cont.alusrc = 0; // 0 for R
	end
JR:begin//JR
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 0; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_AND;
	cont.alusrc = 0; // 0 for R
	cont.jr = 1;
	end
NOR:begin//NOR
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_NOR;
	cont.alusrc = 0; // 0 for R
	end

OR:begin//OR
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_OR;
	cont.alusrc = 0; // 0 for R
	end
SLT:begin//SLT
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SLT;
	cont.alusrc = 0; // 0 for R
	end
SLTU:begin//SLTU
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SLTU;
	cont.alusrc = 0; // 0 for R
	end

SLL:begin//SLL
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SLL;
	cont.alusrc = 0; // 0 for R
	cont.sll = 1;
	end
SRL:begin//SRL
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SRL;
	cont.alusrc = 0; // 0 for R
	cont.srl = 1;
	end
SUBU:begin//SUBU
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SUB;
	cont.alusrc = 0; // 0 for R
	end
SUB:begin//SUB
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_SUB;
	cont.alusrc = 0; // 0 for R
	end

XOR:begin//XOR
	cont.MemRead = 0; //0 for R
	cont.MemWrite = 0; //0 for R
	cont.RegWrite = 1; //1 for all R
	cont.jump = 0; //for R
	cont.branch = 0; //0 for R
	cont.MemtoReg = 0; //0 for R
	cont.RegDst = 1; //1 for R
	cont.Ext_op = 0;
	cont.aluop = ALU_XOR;
	cont.alusrc = 0; // 0 for R
	end
endcase 
end

else 
begin
//i type instruction
casez(cont.op)
//ADDIU
ADDIU:begin//ADDIU
	cont.MemRead = 0; //0 for I
	cont.MemWrite = 0; //0 for I
	cont.RegWrite = 1; //1 for all I
	cont.jump = 0; //for I
	cont.branch = 0; //0 for I
	cont.MemtoReg = 0; //0 for I
	cont.RegDst = 0; //1 for I
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end

//ADDI zero
ADDI:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; 
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end

//AND signed $rt,$rs,imm   R[rt] <= R[rs] & ZeroExtImm
ANDI:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; //1 for all 
	cont.jump = 0; //for 
	cont.branch = 0; //0 for 
	cont.MemtoReg = 0; //0 for 
	cont.RegDst = 0; //1 for
	cont.Ext_op = 0;
	cont.aluop = ALU_AND;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end
//BEQ
BEQ:begin
	cont.MemRead = 0; //0 for I
	cont.MemWrite = 0; //0 for I
	cont.RegWrite = 0; 
	cont.jump = 0; //for I
	cont.branch = 1; //1 for BEQ
	cont.MemtoReg = 0; //0 for I
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_SUB;
	cont.alusrc = 0; // 1 for alusrc Lecture notes
	end

//BNE
BNE:begin
	cont.MemRead = 0; //0 for I
	cont.MemWrite = 0; //0 for I
	cont.RegWrite = 0; 
	cont.jump = 0; //for I
	cont.branch = 0; //1 for BEQ
	cont.MemtoReg = 0; //0 for I
	cont.RegDst = 0; //1 for I
	cont.Ext_op = 1;
	cont.aluop = ALU_SUB;
	cont.alusrc = 0; // 1 for alusrc Lecture notes
	cont.bne = 1;
	end


//LUI    $rt,imm       R[rt] <= {imm,16b'0}
LUI:begin
	cont.MemRead = 0; //0 for I
	cont.MemWrite = 0; //0 for I
	cont.RegWrite = 1; 
	cont.jump = 0; //for I
	cont.branch = 0; //1 for BEQ
	cont.MemtoReg = 0; //0 for I
	cont.RegDst = 0; //1 for I
	cont.Ext_op = 1;
	cont.aluop = ALU_OR;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	cont.lui = 1;
	end

//LW     $rt,imm($rs)  R[rt] <= M[R[rs] + SignExtImm]
LW:begin
	cont.MemRead = 1; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; 
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 1; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; 
	end

//ORI    $rt,$rs,imm   R[rt] <= R[rs] OR ZeroExtImm
ORI:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; //1 for all 
	cont.jump = 0; //for 
	cont.branch = 0; //0 for 
	cont.MemtoReg = 0; //0 for 
	cont.RegDst = 0; //1 for
	cont.Ext_op = 0;
	cont.aluop = ALU_OR;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end

//SLTI   $rt,$rs,imm   R[rt] <= (R[rs] < SignExtImm) ? 1 : 0
SLTI:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1;  
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_SLT;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end

//SLTIU  $rt,$rs,imm   R[rt] <= (R[rs] < SignExtImm) ? 1 : 0

SLTIU:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1;  
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_SLT;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end
//SW     $rt,imm($rs)  M[R[rs] + SignExtImm] <= R[rt]
SW:begin
	cont.MemRead = 0; 
	cont.MemWrite = 1;
	cont.RegWrite = 0; 
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0;//z 
	cont.RegDst = 0;//Z 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; 
	end

//LL     $rt,imm($rs)  R[rt] <= M[R[rs] + SignExtImm]; rmwstate <= addr
LL:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1;  
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end

//SC     $rt,imm($rs)  if (rmw) M[R[rs] + SignExtImm] <= R[rt], R[rt] <= 1 else R[rt] <= 0

SC:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1;  
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 1; // 1 for alusrc Lecture notes
	end
//XORI   $rt,$rs,imm   R[rt] <= R[rs] XOR ZeroExtImm
XORI:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; 
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 0;
	cont.aluop = ALU_XOR;
	cont.alusrc = 1; 
	end
//j type
//J
J:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 0; 
	cont.jump = 1; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 1; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 0; 
	end
//JAL
JAL:begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 1; 
	cont.jump = 1; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 1; 
	cont.Ext_op = 1;
	cont.aluop = ALU_ADD;
	cont.alusrc = 0;
	cont.jal_jump = 1;
	end
// HALT
HALT: begin
	cont.MemRead = 0; 
	cont.MemWrite = 0; 
	cont.RegWrite = 0; 
	cont.jump = 0; 
	cont.branch = 0; 
	cont.MemtoReg = 0; 
	cont.RegDst = 0; 
	cont.Ext_op = 0;
	cont.aluop = ALU_ADD;
	cont.alusrc = 0;
	cont.jal_jump = 0;
	cont.halt = 1;
	end

endcase
end

	/* always_comb
	begin

		cont.MemRead = 0; //0 for R
		cont.MemWrite = 0; //0 for R
		cont.RegDst = 0; //1 for all R
		cont.jump = 0; //for R
		cont.branch = 0; //0 for R
		cont.MemtoReg = 0; //0 for R
		cont.RegDst = 0; //1 for R
		cont.Ext_op = 0; //either this or I'll create a separate block for sign extension 
			//cont.aluop = NOP;//what should aluop's initialization be
		cont.alusrc = 0; // 0 for R
		cont.jal_jump = 0;
		cont.halt = 1'b0;

		casez(cont.op)
			ORI:
			begin
				cont.MemRead = 0; 
				cont.MemWrite = 0; 
				cont.RegWrite = 1; //1 for all 
				cont.jump = 0; //for 
				cont.branch = 0; //0 for 
				cont.MemtoReg = 0; //0 for 
				cont.RegDst = 0; //1 for
				cont.Ext_op = 1;
				cont.aluop = ALU_OR;
				cont.alusrc = 1; // 1 for alusrc Lecture notes
			end
			ADDI:
			begin
				cont.MemRead = 0; 
				cont.MemWrite = 0; 
				cont.RegWrite = 1; 
				cont.jump = 0; 
				cont.branch = 0; 
				cont.MemtoReg = 0; 
				cont.RegDst = 0; 
				cont.Ext_op = 1;
				cont.aluop = ALU_ADD;
				cont.alusrc = 1; // 1 for alusrc Lecture notes
			end
			LW:
			begin
				cont.MemRead = 1; 
				cont.MemWrite = 0; 
				cont.RegWrite = 1; 
				cont.jump = 0; 
				cont.branch = 0; 
				cont.MemtoReg = 1; 
				cont.RegDst = 0; 
				cont.Ext_op = 1;
				cont.aluop = ALU_ADD;
				cont.alusrc = 1; 
			end
			HALT:
			begin
				cont.halt = 1'b1;
			end
		endcase

// end */


	end

endmodule
