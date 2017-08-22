`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
`include "datapath_cache_if.vh"

module dcache (
	input logic clk,    // Clock
	input logic nRST,   // Asynchronous reset active low
	datapath_cache_if.dcache dcif,
	caches_if dcache
);

	import cpu_types_pkg::*;

	typedef enum logic[4:0] {IDLE, WB1_1, WB2_1, LD1, LD2, CHECK_DIRTY, SNOOP, WB1_D_1, WB1_D_2, WB2_D_1, WB2_D_2, DUMMY1, DUMMY2, HIT_CNT, HALT} dcache_state;
	dcache_state cstate, nstate;

	logic hit, hit0, hit1;
	//logic [7:0] lru;
	word_t hit_counter = 0, hit_cnt_tmp = 0;
	logic [2:0] counter1;
	logic [2:0] counter2;
	logic [2:0] counter;
	dcachef_t dcache_in_addr, addr_curr;
	dcachef_t snoop_add_addr;
	logic nlru;
	logic [2:0] ncounter1;
	logic [2:0] ncounter2;
	logic nWay, Way;
	typedef struct packed {
		logic [25:0] tag;
		logic valid_blk;
		logic dirty_blk;
		word_t [1:0] data_blk;
	} dcachel_t;

	// needs to be be able to store value. Put in if file 
	typedef struct packed {
		logic lru;
		dcachel_t [1:0] way;
	} index_t;

	index_t [7:0] cc_dcache;

	index_t [7:0] n_cc_dcache;

	assign dcache_in_addr = dcachef_t'(dcif.dmemaddr);
	assign snoop_add_addr = dcachef_t'(dcache.ccsnoopaddr);
	assign hit0 = (cc_dcache[dcache_in_addr.idx].way[0].tag == dcache_in_addr.tag && cc_dcache[dcache_in_addr.idx].way[0].valid_blk == 1);
	assign hit1 = (cc_dcache[dcache_in_addr.idx].way[1].tag == dcache_in_addr.tag && cc_dcache[dcache_in_addr.idx].way[1].valid_blk == 1);
	assign hit = hit0 || hit1;
	int i = 0, j = 0;

	assign nlru = (/*(cstate <= LD2 && dcache.dwait) || */(cstate<=IDLE && hit));

	logic lru_bit;
	always_ff @(posedge clk, negedge nRST) 
	begin
		if(!nRST) 
		begin
			cstate <= IDLE;
			Way <= 0;
			counter1<=3'b000;
			counter2<=3'b000;
			cc_dcache <= '{default:0};

		end 
		else 
		begin
			Way <= nWay;
			cstate <= nstate;
			counter1<=ncounter1;
			counter2<=ncounter2;
			cc_dcache <= n_cc_dcache;
			cc_dcache[dcache_in_addr.idx].lru <= nlru ? ~(cc_dcache[dcache_in_addr.idx].lru) : cc_dcache[dcache_in_addr.idx].lru;
			cc_dcache[dcache_in_addr.idx].way[hit1].dirty_blk <= n_cc_dcache[dcache_in_addr.idx].way[hit1].dirty_blk;
			if(cstate <= IDLE && dcif.dmemWEN == 1 && hit)
			begin
				cc_dcache[dcache_in_addr.idx].way[hit1].data_blk[dcache_in_addr.blkoff] <= dcif.dmemstore;

			end

			if(cstate == HALT)
			begin
				
				// for(i = 0; i < 8; i++)
				// begin
				// 	cc_dcache[i].lru <= 0;
				// 	for(j=0; j<2; j++)
				// 	begin
				// 		cc_dcache[i].way[j].tag <= 0;
				// 		cc_dcache[i].way[j].valid_blk <= 0;
				// 		cc_dcache[i].way[j].dirty_blk <= 0;
				// 		cc_dcache[i].way[j].data_blk[0] <= 0;
				// 		cc_dcache[i].way[j].data_blk[1] <= 0;
				// 	end
				// end
			end
			hit_counter <= hit_cnt_tmp;
		end
	end

	always_comb 
	begin
		dcif.dhit = 0;
		dcif.dmemload = 0;
		dcif.flushed = 0;
		//set initial LRU values. Set either bit to 1 or 0
		n_cc_dcache = cc_dcache;
		nstate = cstate;
		ncounter1 = counter1;
		ncounter2 = counter2;
		dcache.dWEN = 0;
		dcache.dREN = 0;
		dcache.daddr = 0;
		hit_cnt_tmp = hit_counter;
		dcache.dstore = 0;
		dcache.ccwrite = 0;
		dcache.cctrans = 0;
		addr_curr = dcachef_t'(dcif.dmemaddr);
		nWay=Way;

		case (cstate)
			IDLE:
			begin
				dcache.cctrans=0;
				if(dcif.halt == 1)
				begin
					nstate = CHECK_DIRTY;
				end

				else if(dcache.ccwait==1)
				begin
					nstate=SNOOP;
				end

				else if(hit == 1 && (dcif.dmemREN == 1)) ///for multicore ccwait must win
				begin
					dcif.dhit = 1;
					hit_cnt_tmp = hit_counter + 1;
					
					dcif.dmemload = cc_dcache[dcache_in_addr.idx].way[hit1].data_blk[dcache_in_addr.blkoff];
					
					
					//update hit counter ++
					nstate = IDLE;
				end
				else if(hit==1 &&  dcif.dmemWEN == 1)
				begin
					dcif.dhit = 1;
					n_cc_dcache[dcache_in_addr.idx].way[hit1].dirty_blk=1;
					hit_cnt_tmp = hit_counter + 1;

				end

				else if(hit == 0 && (dcif.dmemREN == 1 || dcif.dmemWEN == 1))
				begin
					// If there is still space in the cache -- Need to find out how to determine if there is no space

					//lru_bit=cc_dcache[dcache_in_addr.idx].lru;
					if((n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag == addr_curr.tag) && cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk)
					begin

						nstate = WB1_1;
					end

					else if((n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag != addr_curr.tag) && !cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk)
					begin

						nstate = LD1;
					end
					
				end
			end


			SNOOP:
			begin
				dcache.cctrans = 1;
				//dcache.dREN=1;
				if(cc_dcache[snoop_add_addr.idx].way[0].tag == snoop_add_addr.tag && cc_dcache[snoop_add_addr.idx].way[0].dirty_blk)// Dirty &
				begin
					nWay = 0;
					nstate=WB1_1;
					dcache.ccwrite = 1;
				end
				else if(cc_dcache[snoop_add_addr.idx].way[1].tag == snoop_add_addr.tag && cc_dcache[snoop_add_addr.idx].way[1].dirty_blk)
				begin
					nWay = 1;
					nstate=WB1_1;
					dcache.ccwrite = 1;
				end
				else
				begin
					if(dcache.ccinv==1)
					begin
						if(cc_dcache[snoop_add_addr.idx].way[0].tag==snoop_add_addr.tag)
						begin
							n_cc_dcache[snoop_add_addr.idx].way[0].valid_blk=0;
						end
						else if(cc_dcache[snoop_add_addr.idx].way[1].tag==snoop_add_addr.tag)
						begin
							n_cc_dcache[snoop_add_addr.idx].way[1].valid_blk=0;
						end

					end
					nstate = IDLE;
				end


			end
			
			/*DUMMY1:
			begin
				//dcache.ccwrite=1;
				//dcache.cctrans=1;
				if(dcache.ccwait==1)
				begin
					nstate=SNOOP;
				end

				nstate=LD1;
			end*/



			LD1:
			begin
				
				if(dcache.ccwait==1)
				begin
					nstate=SNOOP;
				end

				else if(dcache.dwait == 1)
				begin
					nstate = LD1;
				end
				else
				begin
					//hit_cnt_tmp = hit_counter - 1;
					nstate = LD2;
				end
				dcache.cctrans=1;
				dcache.ccwrite=1;
				// Load Word 1 from mem
				dcache.dREN = 1;
				dcache.daddr = dcif.dmemaddr;
				dcache.dWEN = 0;

				n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk = 0;
				n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].data_blk[dcache_in_addr.blkoff] = dcache.dload;
			end

			LD2:
			begin
				if(dcache_in_addr.blkoff==0)
				begin
					hit_cnt_tmp = hit_counter;
					dcache.cctrans=1;
					dcache.ccwrite=1;
					if(dcache.ccwait==1)
					begin
						nstate=SNOOP;
					end
					else if(dcache.dwait == 1)
					begin
						nstate = LD2;
					end
					else
					begin
						nstate = IDLE;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag = addr_curr.tag;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].valid_blk = 1;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk = 0;
					end

					// Load Word 1 from mem
					dcache.dREN = 1;
					dcache.daddr = dcif.dmemaddr + 4;
					dcache.dWEN = 0;

					
					n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].data_blk[1] = dcache.dload;
				end

				else if(dcache_in_addr.blkoff==1)
				begin
					hit_cnt_tmp = hit_counter;
					dcache.cctrans=1;
					dcache.ccwrite=1;
					if(dcache.ccwait==1)
					begin
						nstate=SNOOP;
					end
					else if(dcache.dwait == 1)
					begin
						nstate = LD2;
					end
					else
					begin
						nstate = IDLE;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag = addr_curr.tag;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].valid_blk = 1;
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk = 0;
					end

					// Load Word 1 from mem
					dcache.dREN = 1;
					dcache.daddr = dcif.dmemaddr - 4;
					dcache.dWEN = 0;

					
					n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].data_blk[0] = dcache.dload;
				end


			end

			WB1_1:
			begin
				if(dcache.ccinv==0)
				begin
					dcache.dWEN = 1;
					dcache.dREN = 0;
					dcache.daddr = {cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag, dcache_in_addr.idx, 1'b0, 2'b00};//is this index correct?
					dcache.dstore = cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].data_blk[0];
					dcache.ccwrite=1;
					if(dcache.dwait == 1)
					begin
						nstate = WB1_1;
					end
					
					else
					begin
						nstate = WB2_1;
					end
				end

				else 
				begin
					dcache.dWEN = 1;
					dcache.dREN = 0;
					dcache.daddr = dcache.ccsnoopaddr;
					dcache.dstore = cc_dcache[snoop_add_addr.idx].way[Way].data_blk[snoop_add_addr.blkoff];
					dcache.ccwrite=1;
					if(dcache.dwait == 1)
					begin
						nstate = WB1_1;
					end
					
					else
					begin
						nstate = WB2_1;
					end
				end

			end

			WB2_1:
			begin
				if(dcache.ccinv==0)
				begin
					dcache.dWEN = 1;
					dcache.dREN = 0;
					dcache.ccwrite=1;
					// dcache.daddr = {cc_dcache[counter1].way[1].tag, dcache_in_addr.idx, 1, 2'b00};
					dcache.daddr = {cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].tag, dcache_in_addr.idx, 1'b1, 2'b00};
					dcache.dstore = cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].data_blk[1];

					//Some condition
					if(dcache.dwait == 0)
					begin
						n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].dirty_blk=0;
					    n_cc_dcache[dcache_in_addr.idx].way[cc_dcache[dcache_in_addr.idx].lru].valid_blk=0;

						nstate = DUMMY2;
					end
				end

				else
				begin
			
					dcache.dWEN = 1;
					dcache.dREN = 0;
					dcache.ccwrite=1;
					dcache.daddr = dcache.ccsnoopaddr;
					dcache.dstore = cc_dcache[snoop_add_addr.idx].way[Way].data_blk[snoop_add_addr.blkoff];

					if(dcache.dwait == 0)
					begin
						n_cc_dcache[snoop_add_addr.idx].way[Way].dirty_blk=0;
						n_cc_dcache[snoop_add_addr.idx].way[Way].valid_blk=0;

						nstate = IDLE;
					end
				end


			end
			
			DUMMY2:
			begin
				nstate=LD1;
			end
			

			CHECK_DIRTY:
			begin
				if(counter1 == 7 && counter2 ==	1)//some condition 
				begin
					nstate = HALT;
				end

				else if(dcache.ccwait==1)
				begin
					nstate=SNOOP;
				end

				else if(cc_dcache[counter1].way[0].dirty_blk == 1 && cc_dcache[counter1].way[0].valid_blk == 1 && counter2 == 0)//some condition 
				begin
					nstate = WB1_D_1;
				end
				else if(cc_dcache[counter1].way[1].dirty_blk == 1 && cc_dcache[counter1].way[1].valid_blk == 1 && counter2 == 1)
				begin
					nstate = WB2_D_1;
				end
				else
				begin
					if(counter2 == 3'b001)
					begin
						ncounter1 = counter1 + 3'b001;
						ncounter2 = 3'b000;
					end
					else
					begin
						ncounter2 = counter2 + 3'b001;
					end
					//counter = counter + 1;
					nstate = CHECK_DIRTY;
				end
			end

			WB1_D_1:
			begin

				dcache.dWEN = 1;
				dcache.dREN = 0;
				//dcache.daddr = {cc_dcache[counter1].cache_data_blk1.tag, cc_dcache[counter1].cache_data_blk1.idx, cc_dcache[counter1].cache_data_blk1.blkoff, 2'b00};
				dcache.daddr = {cc_dcache[counter1].way[0].tag, counter1, 1'b0, 2'b00};

				dcache.dstore = cc_dcache[counter1].way[0].data_blk[0];//which block

				if(dcache.dwait == 1)
				begin
					nstate = WB1_D_1;
				end
				else
				begin
					nstate = WB1_D_2;
				end

				
			end


			WB1_D_2:
			begin
				dcache.dWEN=1;
				dcache.dREN=0;
				dcache.daddr = {cc_dcache[counter1].way[0].tag, counter1, 1'b1, 2'b00}; //Check this

				dcache.dstore = cc_dcache[counter1].way[0].data_blk[1];//which block
				n_cc_dcache[dcache_in_addr.idx].way[0].dirty_blk=0;
				if(dcache.dwait==1)
				begin
					nstate = WB1_D_2;
				end
				else
				begin
					if(counter2 == 3'b001)
					begin
						ncounter1 = counter1 + 3'b001;
						ncounter2 = 3'b000;
					end
					else
					begin
						ncounter2 = counter2 + 3'b001;
					end
					nstate = CHECK_DIRTY;
				end
			end


			WB2_D_1:
			begin
				if(dcache.dwait == 1)
				begin
					nstate = WB2_D_1;
				end
				else
				begin
					nstate = WB2_D_2;
				end

				dcache.dWEN = 1;
				dcache.dREN = 0;
				//dcache.daddr = {cc_dcache[counter1].cache_data_blk1.tag, cc_dcache[counter1].cache_data_blk1.idx, cc_dcache[counter1].cache_data_blk1.blkoff, 2'b00};
				dcache.daddr = {cc_dcache[counter1].way[1].tag, counter1 , 1'b0, 2'b00};
				dcache.dstore = cc_dcache[counter1].way[1].data_blk[0];
			end

			WB2_D_2:
			begin
				dcache.dWEN=1;
				dcache.dREN=0;
				dcache.daddr = {cc_dcache[counter1].way[1].tag, counter1, 1'b1, 2'b00};

				dcache.dstore = cc_dcache[counter1].way[1].data_blk[1];//which block
				n_cc_dcache[dcache_in_addr.idx].way[1].dirty_blk=0;

				if(dcache.dwait==1)
				begin
					nstate = WB2_D_2;
				end
				else
				begin
					if(counter2 == 3'b001)
					begin
						ncounter1 = counter1 + 3'b001;
						ncounter2 = 3'b000;
					end
					else
					begin
						ncounter2 = counter2 + 3'b001;
					end
					nstate = CHECK_DIRTY;
				end
			end

			/*HIT_CNT:
			begin
				// save hit counter -- Specifications on website.
				dcache.dWEN = 1;
				dcache.dREN = 0;
				dcache.daddr = 32'h00003100;
				dcache.dstore = hit_counter;
				if(dcache.dwait == 1)
				begin
					nstate = HIT_CNT;
				end
				else if(dcache.ccwait==1)
				begin
					nstate=SNOOP;
				end
				else
				begin
					nstate = HALT;
				end
			end*/


			/* Invalidate cache blocks on halt */
			HALT:
			begin
				if(dcache.ccwait==1)
				begin
					dcache.cctrans=1;
				end

				dcache.dREN = 0;
				dcache.dWEN = 0;
				dcache.dstore = 0;
				dcif.flushed = 1;
			end

			default : /* default */;
		endcase

	end

endmodule