// Calculating engine. Executes the mandelbrot algorithm.
module Engine (
   input [`E_ADDR_WIDTH:0] my_addr,
	input [`E_ADDR_WIDTH:0] engine_addr,
	input [82:0] in_word,
	input latch_en,             // also indicates "GO" (assuming the address matches)
	input eRST,
	input Engine_CLK,
	input req_ack,              // enables portions of the latched in_word onto the out_word bus.
	output [26:0] out_word,     // tri-state bus. 10 bits of x, 9 bits of y, 8 bits of iterations.
	output reg available,
	output reg service_req
);

parameter MAX_ITERATIONS = 255;  // Do not exceed 65535.
localparam	state_a = 3'b000,
				state_b = 3'b001,
				state_c = 3'b010,
				state_d = 3'b011,
				state_e = 3'b100,
				state_f = 3'b101,
				state_g = 3'b110;

// Wire declarations
reg [2:0] state = 3'b000;
reg signed [31:0] NewRe, OldRe, NewIm, OldIm;
reg signed [31:0] shorttemp;
reg signed [63:0] temp1, temp2, temp3, temp4;
reg [15:0] ItrCounter;  // Numer of iterations completed w/o escaping
reg [82:0] latched_word;
wire [15:0] eMaxItr;
wire [31:0] eRegRe, eRegIm;
wire [9:0] x_coor;
wire [8:0] y_coor;
wire address_match;

assign x_coor = latched_word[82:73];
assign y_coor = latched_word[72:64];
assign eRegRe = latched_word[63:32];
assign eRegIm = latched_word[31:0];
assign eMaxItr = MAX_ITERATIONS;

// Tri-state output example from "Verilog HDL Synthesis" pg.94
assign out_word = req_ack ? {x_coor, y_coor, ItrCounter[7:0]} : 27'hzzzzzzz;
// The Coor_gen block (generator of coordinates) is trying to give me new coordinates.
assign address_match = (engine_addr == my_addr) ? 1'b1 : 1'b0;

// State machine ------------------------------------------------
always @ ( posedge Engine_CLK or posedge eRST ) begin
   if ( eRST ) begin
     state <= state_a;
	  available <= 1'b1;   // Signal that this engine is available.
	  end
	else
	case( state )
	   state_a : begin
						NewRe <= 0;
						OldRe <= 0;
						NewIm <= 0;
						OldIm <= 0;
						ItrCounter <= 0;
						service_req <= 0;    // No result yet.
						// Stay here until address matches and latch_en = 1.
						if( (address_match == 1'b1) && (latch_en == 1'b1) ) begin
						   state <= state_b;
							latched_word <= in_word;
							available <= 1'b0;  // Signal that this engine is now busy.
							end
						else begin
						   available <= 1'b1;   // Signal that this engine is available.
							state <= state_a;
					      end
						end
		
		state_b : begin
		        available <= 1'b0;   // Signal that this engine is busy.
						OldRe <= NewRe;
						OldIm <= NewIm;
						state <= state_c;
					 end
		
		state_c : begin
						//NewRe <= ((OldRe * OldRe)>>>24) - ((OldIm * OldIm)>>>24) + eRegRe;
						temp1 = (OldRe * OldRe)>>>24;
						temp2 = (OldIm * OldIm)>>>24;
						NewRe <= temp1 - temp2 + eRegRe;
						//NewIm <= (((2 * OldRe) * OldIm)>>>24) + eRegIm;
						temp4 = (OldRe * OldIm)>>>24;
						NewIm <= (2 * temp4) + eRegIm;
						state <= state_d;
					 end
					 
		state_d : begin
		            temp1 <= ((NewRe * NewRe) >>> 24);
		            temp2 <= ((NewIm * NewIm) >>> 24);
						    if( (temp1 + temp2) > 32'h04000000 ) begin
						      //service_req <= 1'b1;
							    state <= state_f;
							    end
						    else begin
							    ItrCounter <= ItrCounter + 1;
							    state <= state_e;
							   end
					     end
					 
		state_e : begin
						if( ItrCounter == eMaxItr ) begin
							//service_req <= 1'b1;
							state <= state_f;
							end
						else state <= state_b;
					 end
					 
		state_f : begin  // hold here until we get an ack signal
		            service_req <= 1'b1;
		            if( ~req_ack ) state <= state_f;
		              else state <= state_g;
		          end
		          
    state_g : begin		// hold here until req_ack falls and
                      // coord gen is ready to assign a new coordinate.
                  service_req <= 1'b0;  // Being serviced. Stop asking.
						if( (req_ack) || (latch_en) ) state <= state_g;
						else begin
						available <= 1'b1;   // Signal that this engine is now available.
						state <= state_a;
						end
				  end
					     				 
		default : state <= state_a;
		
	endcase
end     // end of state logic

endmodule
