module Coor_gen (
	input cclk,
	input [3:0] ckey,
	input creset,
	input [3:0] cdones,  // one-hot. 4 engines
	output clatch_en,
	output [2:0] cengine_addr,  // address of the engine the latch is intended for.
	output [82:0] cword2engines,    // x,y in int and fractional integer. To engines.
	output frame    // pulses at the start, and at the end, of a frame.
);

parameter NUM_PROC = 4;
parameter E_ADDR_WIDTH = 3;// log2( NUM_PROC );  // Number of bits in engine address bus.
localparam step_size = 32'h02666666; // This is 0.0046875 (the step size) multiplied by 2**9.

wire [9:0] x_value;
wire [8:0] y_value;
wire y_max_tick;
wire null_wire;

wire cpause;
//reg [3:0] reg_dones;   // number of engines = 4
reg signed [63:0] temp1, temp2, temp3, temp4, temp5, temp6;
reg signed [31:0] outx, outy;
//reg [3:0] reg_cdones;
reg [3:0] big_cengine_addr;  // one more bit than c_engine_addr

assign cengine_addr = big_cengine_addr[2:0];

//TODO: convert x_value, y_value to fractional representations
always @ ( x_value ) begin
   temp1 = x_value;
   temp2 = temp1 <<< 15; // would be <<< 24 to align, but then divide by 2**9.
   temp3 = (temp2 * step_size)>>>24;
   outx = temp3 - 32'h02000000;
end

always @ ( y_value ) begin
   temp4 = y_value;
   temp5 = temp4 <<< 15;
   temp6 = (temp5 * step_size)>>>24;
	outy = 32'h01200000 - temp6;
end

assign cword2engines = { x_value, y_value, outx, outy };

// Search for an available engine. cengine_addr = lowest number'd available engine.
// Tested.
//integer j;
//always @( cdones )
//  for( j=3; j>=0; j=j-1 )   // number of engines = 4
//    if( cdones[j] == 1 ) cengine_addr = j;

//always @ ( posedge cclk ) reg_cdones <= cdones;

always @ ( negedge cclk )  // Flag the lowest numbered engine needing service.
	casex( cdones )
		4'bxxx1 : big_cengine_addr = 4'b0000;
		4'bxx10 : big_cengine_addr = 4'b0001;
		4'bx100 : big_cengine_addr = 4'b0010;
		4'b1000 : big_cengine_addr = 4'b0011;
		default : big_cengine_addr = 4'b1000;
	endcase
// cpause = 1 if no engine has a "done" signal high. STOP the counters and wait!
// Tested.
//  Need to use registered version, or not?
//always @ ( posedge cclk )
//	begin
//	   reg_dones <= cdones;   // register in the done signals prior to use.
//	end
	
assign cpause = big_cengine_addr[3]; // high if all reg_cdones are low, ie, all engines are busy.
assign clatch_en = ~cpause;

Mod_counter #( .N(10), .M(640) ) x_cntr (   // 10 bit counter, counts 0 to 639.
		.clk( cclk ),
		.clk_en( y_max_tick ),
		.pause( cpause ),
		.reset( creset ),
		.q( x_value ),
		.max_tick( null_wire )
);

assign frame = ((x_value <100) ) ? 1'b1 : 1'b0;

Mod_counter #( .N(9), .M(480) ) y_cntr  (   // 9 bit counter, counts 0 to 479.
		.clk( cclk ),
		.clk_en( 1'b1 ),
		.pause( cpause ),
		.reset( creset ),
		.q( y_value ),
		.max_tick( y_max_tick )
);

function integer log2(input integer n); // 1 in = 2. 2 in = 2. 4 in = 3. etc...
	integer i;
	begin
		log2 = 1;
		for( i=0; 2**i < n; i = i+1 )
			log2 = i + 1;
	end
endfunction

endmodule