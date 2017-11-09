// Gets results from engines that have results, and puts the results
//   into the dual-port VGA RAM.
// Runs at the clock rate of the engines.
module Engine2VGA (
//   input [26:0] engine_word,  // 10 bits of x, 9 bits of y, 8 bits of itr: {x_coor, y_coor, ItrCounter[7:0]}
	input [3:0] engine_req,    // one-hot coded.
	output reg [3:0] req_ack,  // acknowledge the request. In response, the engine will place it's word on the bus.
	// Dual-port RAM side
//   output [7:0] writedata_iDATA,   // Data going into the dual-port RAM.
//	output [18:0] address_iADDR,     // 640x480 = 307,200 8-bit locations. 2^19 = 524,288
	output reg write_iWR_en,
	input clk_iCLK,		//	Host Clock for writes into memory. Is the engine clock.
	input reset
);
 
localparam	state_a = 3'b000,
				state_b = 3'b001,
				state_c = 3'b010,
				state_d = 3'b011;
				//state_e = 3'b100,
				//state_f = 3'b101,
				//state_g = 3'b110,
				//state_h = 3'b111;
reg [2:0] state = 0;

// Below needs to be 1 bit wider than 2LOG(NUM_ENGINES-1). MSB will indicate "no engines need service"
//reg [4:0] engine_addr;   // Binary-valued address of a single engine that is requesting service.

//wire req_exists;
//wire [4:0] engine_req;  // One more bit wide than size of engine_req.
                        // MSB will be set to 1 to indicate "no engines need service"
//reg [3:0] L_engine_req; // One more bit wide than size of engine_req.
                        // MSB will be set to 1 to indicate "no engines need service"
reg [4:0] calc_req_ack;  // one-hot. indicates which engine will get ack'd. If zero, nobody asking.

//assign req_exists = ( |(engine_req) ); // high if any engine has a result.

// As the data comes onto the input bus from the engine, pass it to the RAM. 
//assign address_iADDR = engine_word[26:17] + ( engine_word[16:8] * 480 ); // x+y*480
//assign writedata_iDATA = engine_word[7:0];

always @ ( posedge clk_iCLK or posedge reset ) begin
   if( reset ) begin
	   state <= state_a;
	   write_iWR_en <= 1'b0;      // Tell RAM not writing to it.
		end
	else
	   case( state )
		   state_a : begin
						   //L_engine_req <= { engine_req };   // Save the status of all engine requests.
						   write_iWR_en <= 1'b0;      // Tell RAM not writing to it.
						   req_ack <= 0;              // Tell all engines to get off the bus.
						   // Stay here until request exists
						   state <= ( |(calc_req_ack) ) ? state_b : state_a;
					    end
		
			state_b : begin
		               req_ack <= calc_req_ack;   // Tell the engine it has been selected.
					   	write_iWR_en <= 1'b1;      // Get RAM ready for a write.
					   	state <= state_c;
					    end
		
			state_c : begin
					   	write_iWR_en <= 1'b0;
					   	req_ack <= 0;           // Assumes hold time for WR to RAM = zero-ish.
					   	state <= state_d;
					    end
		
			state_d : begin   // just wait for the engine to drop it's req line
					   	state <= state_a;
					    end
					    					    
		default : state <= state_a;
	endcase
end

// Look for an engine that has signalled it has a result. engine_addr -> lowest number'd available engine.
// If no engine is available, it stops at the value NUM_ENGINES + 1, with that value.
//integer j;                 // Note: integer must be a signed type for countdown to work!
//always @( L_engine_req ) begin
//  engine_addr = 0;
//  for( j=4; j>=0; j=j-1 )   // number of engines = 4
//    if( (L_engine_req[j] == 1) || (j==4) ) engine_addr = j; // binary value of highest engine available. Or max.
//end

always @ ( negedge clk_iCLK )  // Flag the lowest numbered engine needing service.
	casex( engine_req )
		4'bxxx1 : calc_req_ack = 4'b0001;
		4'bxx10 : calc_req_ack = 4'b0010;
		4'bx100 : calc_req_ack = 4'b0100;
		4'b1000 : calc_req_ack = 4'b1000;
		default : calc_req_ack = 4'b0000;
	endcase

//assign word_available = req_ack[NUM_ENGINES];// MSB only goes high when no engine is requesting service.
//assign word_available = ~req_ack[4];

// Tell the selected engine to put it's word onto the bus.
//integer i;
//always @( engine_addr ) begin  // Calc one-hot code for the selected engine.
//  calc_req_ack = 0;
//  for( i=0; i<=5; i=i+1 )   // number of engines = 4. loop max is NUM_ENGINES+1.
//    if( i == engine_addr ) calc_req_ack[i] = 1'b1; // req_ack[NUM_ENGINES]=0 if an engine needs serviceing.
//end


endmodule