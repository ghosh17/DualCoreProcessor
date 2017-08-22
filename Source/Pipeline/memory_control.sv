/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;
  parameter cpid = 0;//parameter or logic?	
  logic cp_id;
	
	// assign ccif.ramWEN = ccif.dWEN[cpid];
	// assign ccif.ramREN = (((ccif.dREN[cpid] == 1) || (ccif.iREN[cpid] == 1)) && (ccif.dWEN[cpid] == 0)) ? 1 : 0;
	// assign ccif.iload = /* ccif.ramload;*/ (ccif.iREN[cpid] == 1 && ccif.ramload != 32'hbad1bad1) ? ccif.ramload : 0;
	// assign ccif.dload = /* ccif.ramload;*/ (ccif.dREN[cpid] == 1 && ccif.ramload != 32'hbad1bad1) ? ccif.ramload : 0;
	// assign ccif.ramstore = (ccif.dWEN[cpid] == 1) ? ccif.dstore : 0; //ccif.dstore[cpid]; // (ccif.dWEN[cpid] == 1) ? ccif.dstore[cpid] : 0;
	// assign ccif.ramaddr = (ccif.dREN[cpid] == 1 || ccif.dWEN[cpid] == 1) ? ccif.daddr : /*ccif.iaddr;*/ ((ccif.iREN[cpid] == 1) ? ccif.iaddr : 0);




//Set up default values
// ccif.iwait[cpid] = 1;
// ccif.dwait[cpid] = 1;
/* ccif.ramstore = 0;
ccif.dload[cpid] = 0;
ccif.iload[cpid] = 0;
ccif.ramaddr = 0;
ccif.ramREN = 0;
ccif.ramWEN = 0; */
// ccif.ccwrite = 0;
// ccif.cctrans = 0;
// ccif.ccwait = 0;
// ccif.ccinv = 0;
// ccif.ccsnoopaddr = 0;


//ramstate cases
/*

*/

//assignLD1 cp_id = ccif.dWEN[1] ? 1 : 0;  
	
typedef enum logic[4:0] {IDLE, WB1, WB2, WB1_2, WB2_2, LD1, LD2, C1, C2, SNOOP} mem_control_state;
	mem_control_state cstate, nstate;

always_ff @(posedge CLK, negedge nRST) 
	begin
		if(!nRST) 
		begin
			cstate <= IDLE;
		end
		else 
		begin
			cstate <= nstate;
		end
	end


	always_comb 
		begin
			////////////

			ccif.ramREN = 0;
			ccif.ramWEN = 0;
			ccif.iwait = 2'b11;
			ccif.dwait = 2'b11;
			ccif.ramstore = '{default:0};
			ccif.ramaddr = '{default:0};
			
			ccif.ccinv[0]=0;
			ccif.ccinv[1]=0;
			ccif.ccwait[0]=0;
			ccif.ccwait[1]=0;
			ccif.ccsnoopaddr = 16'h0;
			nstate=cstate;
			case (cstate)
			IDLE:
			begin



				if(ccif.dWEN[0]==1)
				begin
					nstate=WB1;
				end
				else if(ccif.dWEN[1]==1)
				begin
					nstate=WB1_2;
				end


				else if(ccif.cctrans[0]==1||ccif.cctrans[1]==1)
				begin
					nstate=SNOOP;
					// if(ccif.cctrans[0])begin
					// 	ccif.ccwait[1] = 1;
					// end else begin
					// 	ccif.ccwait[0] = 1;
					// end
				end

				else if(ccif.iREN)
				begin
					if(ccif.iREN[0])
					begin
						ccif.ramaddr = ccif.iaddr[0];
					end
					else 
					begin
						ccif.ramaddr = ccif.iaddr[1];
					end

					ccif.ramREN = 1;
					ccif.ramWEN = 0;
					if(ccif.ramstate==ACCESS)
					begin
						if(ccif.iREN[0])
						begin
							ccif.iwait[0] = 0;
							ccif.ramaddr = ccif.iaddr[0];
							ccif.iload[0] = ccif.ramload;
							nstate=IDLE;
						end
						else
						begin
							ccif.iload[1] = ccif.ramload;
							ccif.ramaddr = ccif.iaddr[1];
							ccif.iwait[1] = 0;
							nstate=IDLE;
						end
						
					end
				
				end

				
			end
			
			WB1:
			begin
				
				
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramstore = ccif.dstore[0];
					ccif.ramREN = 0;
					ccif.ramWEN = 1;

					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[0]=0;
						nstate = WB2;
					end
					
					else
					begin
						
						nstate = WB1;
					end
				
				end


			WB1_2:
				begin
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramstore = ccif.dstore[1];
					ccif.ramREN = 0;
					ccif.ramWEN = 1;

					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[1]=0;
						nstate = WB2_2;
					end
					
					else
					begin
						
						nstate = WB1_2;
					end
				end


			

			WB2:
		
				 begin
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramstore = ccif.dstore[0];
					ccif.ramREN = 0;
					ccif.ramWEN = 1;

					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[0]=0;
						nstate = IDLE;
					end
					
					else
					begin
						
						nstate = WB2;
					end
				end


			WB2_2:
				 begin
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramstore = ccif.dstore[1];
					ccif.ramREN = 0;
					ccif.ramWEN = 1;

					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[1]=0;
						nstate = IDLE;
					end
					
					else
					begin
						nstate = WB2_2;
					end
				 end
			

			SNOOP:
			begin
				if(ccif.dREN[0]==1)
				begin
					ccif.ccsnoopaddr[1] = ccif.daddr[0];
					ccif.ccwait[1]=1;
					if(ccif.ccwrite[0]==1)
					begin
						ccif.ccinv[1]=1;
					end
					
					if((ccif.cctrans[1]==1)&&(ccif.ccwrite[1]==0))
					begin
						nstate=LD1;
					end
					else if((ccif.cctrans[1]==1)&&(ccif.ccwrite[1]==1))
					begin
						nstate=C1;
					end
				end

				else if(ccif.dREN[1]==1)
				begin
					ccif.ccsnoopaddr[0] = ccif.daddr[1];
					ccif.ccwait[0]=1;
					if(ccif.ccwrite[1]==1)
					begin
						ccif.ccinv[0]=1;
					end
					
					if((ccif.cctrans[0]==1)&&(ccif.ccwrite[0]==0))
					begin
					
						nstate=LD1;
					end
					else if((ccif.cctrans[0]==1)&&(ccif.ccwrite[0]==1))
					begin
						
						nstate=C1;
					end
				end

			end

			C1:
			begin
				if(ccif.dREN[0]==1)
				begin
					ccif.ccinv[1]=1;
					ccif.dload[0]=ccif.dstore[1];
					ccif.ramWEN = 1;
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramstore = ccif.dstore[1];
					ccif.ccsnoopaddr[1] = ccif.daddr[0];
					////////////////////////////////////////
 					if(ccif.ramstate==ACCESS)
 					begin
 						ccif.dwait[1]=0;
						ccif.dwait[0]=0;
 						nstate=C2;//dwait + ACCESS
 					end
 					else begin
						nstate = C1;
					end
				end

				else if(ccif.dREN[1]==1)
				begin
					ccif.ccinv[0]=1;
					ccif.dload[1]=ccif.dstore[0];
					ccif.ramWEN = 1;
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramstore = ccif.dstore[0];
					ccif.ccsnoopaddr[0] = ccif.daddr[1];
					////////////////////////////////////////
					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[1]=0;
						ccif.dwait[0]=0;
						nstate=C2;
					end
					else begin
						nstate = C1;
					end
				end
			end

			C2:
			begin
				if(ccif.dREN[0]==1)
				begin
					ccif.ccinv[1]=1;
					ccif.dload[0]=ccif.dstore[1];
					ccif.ramWEN = 1;
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramstore = ccif.dstore[1];
					ccif.ccsnoopaddr[1] = ccif.daddr[0];
					if(ccif.ramstate==ACCESS)
 					begin
 						ccif.dwait[1]=0;
						ccif.dwait[0]=0;
						nstate=IDLE;
					end
					else begin
						nstate = C2;
					end
				end

				else if(ccif.dREN[1]==1)
				begin
					ccif.ccinv[0]=1;
					ccif.ccsnoopaddr[0] = ccif.daddr[1];
					ccif.dload[1]=ccif.dstore[0];
					ccif.ramWEN = 1;
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramstore = ccif.dstore[0];
					if(ccif.ramstate==ACCESS)
 					begin
 						ccif.dwait[1]=0;
						ccif.dwait[0]=0;
						nstate=IDLE;
					end
					else begin
						nstate = C2;
					end
				end
			end

			LD1:
			begin
				
				if(ccif.dREN[0])
				begin
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramREN = 1;
				
					
					ccif.dload[0] = ccif.ramload;
					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[0]=0;
						nstate = LD2;
					end

					else
					begin
						nstate = LD1;
					end
				end
				else if(ccif.dREN[1])
				begin
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramREN = 1;
					
					
					ccif.dload[1] = ccif.ramload;
					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[1]=0;
						nstate = LD2;
					end

					else
					begin
						nstate = LD1;
					end
				end


				

			
				
				
			end

			LD2:
			begin
				
				if(ccif.dREN[0])
				begin
					ccif.ramaddr = ccif.daddr[0];
					ccif.ramREN = 1;
					ccif.ramWEN = 0;
					//ccif.ramaddr = ccif.daddr[0];
					
					ccif.dload[0] = ccif.ramload;
					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[0]=0;
						nstate = IDLE;
					end

					else
					begin
						nstate = LD2;
					end
				end
				else if(ccif.dREN[1])
				begin
					ccif.ramaddr = ccif.daddr[1];
					ccif.ramREN = 1;
					ccif.ramWEN = 0;
					
					
					ccif.dload[1] = ccif.ramload;
					if(ccif.ramstate==ACCESS)
					begin
						ccif.dwait[1]=0;
						nstate = IDLE;
					end

					else
					begin
						nstate = LD2;
					end
				end
			end


			
				//dcache.dREN = 1;
				//dcache.daddr = dcif.dmemaddr + 4;
				//dcache.dWEN = 0;

				
				


			endcase

	end

endmodule
