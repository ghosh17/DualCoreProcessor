`include "datapath_cache_if.vh"
`include "cache_control_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"

module icache (
	input logic CLK,
	input logic nRST,
	datapath_cache_if.icache dcif,
	caches_if icache
);


// typedef struct packed {
// 		logic [25:0] tag;
// 		logic valid_blk;
// 		logic dirty_blk;
// 		word_t [1:0] data_blk;
// 	} dcachel_t;

// 	// needs to be be able to store value. Put in if file 
// 	typedef struct packed {
// 		logic lru;
// 		dcachel_t [1:0] way;
// 	} index_t;

import cpu_types_pkg::*;
icachef_t icache_in_addr;

assign icache_in_addr=icachef_t'(dcif.imemaddr);

typedef enum logic[2:0] {IDLE, LOAD} icache_state;

icache_state cstate, nstate;

word_t [15:0] data;
word_t [15:0] ndata;
logic [25:0] tag[15:0], ntag;
logic [15:0] valid;
logic [15:0] nvalid;


int i=0;


//Have to have your bits as Registers. Need to remember value- Nick
always_ff @ (posedge CLK,negedge nRST) begin
	
	if (nRST==0) begin
		cstate<=IDLE;
		
		for (i=0; i < 16; i++) 
		begin
			valid[i] <= 0;
			tag[i] <= 0;
			data[i] <= 0;
			
		end

	end 
	
	else 
	begin
		cstate <= nstate;
		tag[icache_in_addr.idx] <= ntag;
		data[icache_in_addr.idx] <= ndata;
		valid[icache_in_addr.idx] <= nvalid;
		
		
	end

end



always_comb begin
	
	
	nstate=IDLE;
	icache.iREN=0;
	dcif.ihit=0;
	ndata=data[icache_in_addr.idx];
	nvalid=valid[icache_in_addr.idx];
	ntag=tag[icache_in_addr.idx];
	
	icache.iaddr=0;
	dcif.imemload=0;

	casez(cstate)
	IDLE:begin

		icache.iREN=0;
		
		if (dcif.imemREN==1 /*&& dcif.halt==0*/) begin

			if (valid[icache_in_addr.idx] == 1 && tag[icache_in_addr.idx] == icache_in_addr.tag) //When you get a hit
			begin
				
				dcif.imemload=data[icache_in_addr.idx];
				dcif.ihit=1;
			end 

			else 
			begin 

				nstate=LOAD;
			end
		end
	end
	
	LOAD:begin  // Set Valid bit in icache - TA
		icache.iREN=1;
		icache.iaddr=dcif.imemaddr;
		ntag=icache_in_addr.tag;
		
		if (icache.iwait == 0) begin
			
			ndata=icache.iload;
			nvalid=1;
			nstate=IDLE;
		end

		else
		begin
			nstate=LOAD;
		end

	end
	endcase
end
endmodule
