module Engine (
   input [2:0] my_addr,
	input [2:0] engine_addr,
   //input signed [31:0] eRegRe, eRegIm,  // (x,y)
	input [82:0] word,
	//input [15:0] eMaxItr,
	//input GO,
	input latch_en,  // also indicates "GO" (assuming the address matches)
	input eRST_N,
	input Engine_CLK,
	input ack,
	//output reg [15:0] ItrCounter,  // Numer of iterations completed w/o escaping
	output [15:0] count_output,
	//output reg eDONE  // DONE output. Signals x,y escaped, or it hit MaxItr.
	output reg service_req
);

parameter MAX_ITERATIONS = 255;  // Do not exceed 65535.
localparam	state_a = 3'b000,
				state_b = 3'b001,
				state_c = 3'b010,
				state_d = 3'b011,
				state_e = 3'b100,
				state_f = 3'b101,
				state_g = 3'b110,
				state_h = 3'b111;

// Wire declarations
reg [2:0] cur_state = 3'b000, next_state = 3'b000;
reg signed [31:0] NewRe, OldRe, NewIm, OldIm;
reg signed [31:0] shorttemp;
reg signed [63:0] temp1, temp2, temp3, temp4;
wire [15:0] eMaxItr;
wire [31:0] eRegRe, eRegIm;
wire [9:0] x_coor;
wire [8:0] y_coor;
wire address_match;

assign x_coor = word[82:73];
assign y_coor = word[72:64];
assign eRegRe = word[63:32];
assign eRegIm = word[31:0];
assign eMaxItr = MAX_ITERATIONS;

// Tri-state output example from "Verilog HDL Synthesis" pg.94
assign count_output = GateCtrl ? ItrCounter : 16'hzzzz;

always @ ( engine_addr )
   if( engine_addr == my_addr ) address_match = 1'b1;
//assign eWR_ItrCounter_DATA = ItrCounter;

// State machine
//----------Seq Logic-----------------------------
always @ (posedge Engine_CLK or negedge eRST_N ) begin
   if ( ~eRST_N ) begin
     cur_state <= state_a;
   end
	else begin
     cur_state <= next_state;
   end
end

always @ ( negedge Engine_CLK or negedge eRST_N ) begin
   if( ~eRST_N )
	   next_state <= state_a;
	else
	case( cur_state )
	   state_a : begin
						eDONE <= 1'b0;
						NewRe <= 0;
						OldRe <= 0;
						NewIm <= 0;
						OldIm <= 0;
						ItrCounter <= 0;
						service_req <=0;
						// Stay here until address matches and latch_en = 1.
						if( (address_match == 1'b1) && (latch_en == 1'b1) ) next_state = state_b;
						else next_state = state_a;
					 end
		
		state_b : begin
						OldRe <= NewRe;
						OldIm <= NewIm;
						next_state = state_c;
					 end
		
		state_c : begin
						//NewRe <= ((OldRe * OldRe)>>>24) - ((OldIm * OldIm)>>>24) + eRegRe;
						temp1 = (OldRe * OldRe)>>>24;
						temp2 = (OldIm * OldIm)>>>24;
						temp3 = temp1 - temp2;
						NewRe <= temp3 + eRegRe;
						//NewIm <= (((2 * OldRe) * OldIm)>>>24) + eRegIm;
						temp4 = (OldRe * OldIm)>>>24;
						NewIm <= (2 * temp4) + eRegIm;
						next_state = state_d;
					 end
					 
		state_d : begin
		        temp1 = (NewRe * NewRe) >>> 24;
		        temp2 = (NewIm * NewIm) >>> 24;
		        shorttemp = temp1 + temp2;
						//if( (((NewRe*NewRe)>>>24) + ((NewIm*NewIm)>>>24)) > 32'h04000000 ) begin
						if( shorttemp > 32'h04000000 ) begin
						   service_req <= 1'b1;
							next_state = state_f;
							end
						else begin
							ItrCounter <= ItrCounter + 1;
							next_state = state_e;
							end
					 end
					 
		state_e : begin
						if( ItrCounter == eMaxItr ) begin
							service_req <= 1'b1;
							next_state = state_f;
							end
						else next_state = state_b;
					 end
					 
		state_f : begin    // service_req = 1. Waiting for service.
						if( ack == 1'b1 ) next_state = state_g;
						else next_state = state_f;
					 end
					 
		state_g : begin
						GateCtrl <= 1;   // Put my stuff onto the VGA bus
						if( ack == 1'b1 ) next_state = state_g;
						else next_state = state_h;
					 end
						
		state_h : begin
						GateCtrl <= 0;   // Reliquish control of the VGA bus
						eDone <= 1;
						next_state = state_a;
					 end	
						
		default : next_state = state_a;
		
	endcase
end     // end of state logic

endmodule
