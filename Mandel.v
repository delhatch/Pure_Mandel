// Creates VGA mandelbrot w/ pure logic. No Nios.
// Number of mandelbrot engines to instantiate
`define NUM_PROC 12
// Number of bits in engine address bus.
`define E_ADDR_WIDTH 4
// Note: With 12 engines, the max clock freq. is around 92 MHz with DE2-115 (EP4CE115F29C7).
//       It can calculate 13.56 frames per second.
//    With only 4 engines, fmax is ~100 MHz. 5.04 frames per second.

module Mandel (
	input [17:0] SW,
	input [3:0] KEY,
	output reg [17:0] LEDR,
	output [7:0] LEDG,
	input CLOCK_50,
   //////// VGA //////////
	output [7:0] VGA_B, // Blue
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS
);

wire top_reset;    // Tied to KEY[0]
wire [`NUM_PROC-1:0] dones;
wire latch, top_wr_enable, engine_clock, VGA_clock;
wire [`E_ADDR_WIDTH-1:0] top_engine_addr;
wire [82:0] word;
wire [18:0] ram_address;
wire [7:0] ram_data;
wire [`NUM_PROC-1:0]req_ack_bus;
wire [`NUM_PROC-1:0] top_eng_req;
wire [26:0] engine_word;
wire top_frame;

assign LEDG[0] = top_frame;
assign ram_address = engine_word[26:17] + ( engine_word[16:8] * 640 ); // x+y*640
assign ram_data = engine_word[7:0];
assign top_reset = SW[0];

Coor_gen #( .C_ADDR_WIDTH(`E_ADDR_WIDTH) ) u1 (
	.cclk( engine_clock ),		// into
	.ckey( KEY ),				// into
	.creset( top_reset ),	// into
	.cdones( dones ),			// into
	.clatch_en( latch ),			// outof. Tells specified engine to latch the word (and go).
	.cengine_addr( top_engine_addr ),  // outof. Addr of an available engine.
	.cword2engines( word ), // outof. 10 bits for x, 9 for y, 32*2 for fractional integer versions
	.frame( top_frame )
);
//-----  Instantiate calculating engines ---------------------
Engine e0 (
   .my_addr( 4'b0000 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock ),
	.req_ack( req_ack_bus[0] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[0] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[0] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e1 (
   .my_addr( 4'b0001 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[1] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[1] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[1] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e2 (
   .my_addr( 4'b0010 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[2] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[2] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[2] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e3 (
   .my_addr( 4'b0011 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[3] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[3] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[3] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e4 (
   .my_addr( 4'b0100 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock ),
	.req_ack( req_ack_bus[4] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[4] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[4] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e5 (
   .my_addr( 4'b0101 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[5] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[5] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[5] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e6 (
   .my_addr( 4'b0110 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[6] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[6] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[6] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e7 (
   .my_addr( 4'b0111 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[7] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[7] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[7] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e8 (
   .my_addr( 4'b1000 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock ),
	.req_ack( req_ack_bus[8] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[8] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[8] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e9 (
   .my_addr( 4'b1001 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[9] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[9] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[9] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e10 (
   .my_addr( 4'b1010 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[10] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[10] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[10] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
Engine e11 (
   .my_addr( 4'b1011 ),
	.engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
	.in_word( word ),   // 82-bit word from coordinator generator.
	.latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
	.eRST( top_reset ),
	.Engine_CLK( engine_clock),
	.req_ack( req_ack_bus[11] ),   // Number of this Engine.
	.out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
	.available( dones[11] ),      // output of engine. tells coordinator generator to feed me new coor.s
	.service_req( top_eng_req[11] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
);
//-------  Done instantiating the engines -----------------------
Engine2VGA u3 (
   .engine_req( top_eng_req ),  // 3:0 Number of engines. one-hot coded.
	.req_ack( req_ack_bus ),     // 3:0 Acknowledge the request. In response, the engine will place it's word on the bus.
	.write_iWR_en( top_wr_enable ),  // outof. Goes to dual-port RAM.
	.clk_iCLK( engine_clock ),
	.reset( top_reset )
);

VGA vpg (
   .writedata_iDATA( ram_data ),   // This comes from part of the tri-state bus coming from the engines
	.address_iADDR( ram_address ),  // This too.
	.write_iWR_en( top_wr_enable ), // comes from Engine2VGA.
	.iRST_N( ~top_reset ),
	.clk_iCLK( engine_clock ),      // clock for the dual-port RAM.
	.export_VGA_R( VGA_R ),
	.export_VGA_G( VGA_G ),
	.export_VGA_B( VGA_B ),
	.export_VGA_HS( VGA_HS ),
	.export_VGA_VS( VGA_VS ),
	.export_VGA_SYNC( VGA_SYNC_N ),
	.export_VGA_BLANK( VGA_BLANK_N ),
	.export_VGA_CLK( VGA_CLK ),   // out to the VGA connector
	.iCLK_25( VGA_clock )         // VGA pixel clock in.
);

// Set up Engine PLL. Output c0 is 100 MHz for the computation engines.
engine_pll u2 (
	.inclk0( CLOCK_50 ),
	.c0( engine_clock )
	//.c1( VGA_clock )
);

// Set up PLL. Output c0 is 27.125 MHz for the VGA generator.
vga_pll u4 (
	.inclk0( CLOCK_50 ),
	.c0( VGA_clock )
	//.c1( VGA_clock )
);

// If an engine is working then light up it's LED. (1->LED = illuminated)
// Tested.
integer h;
always @( dones )
begin
  for (h=0; h<`NUM_PROC; h=h+1) LEDR[h] = dones[h];
end

function integer log2(input integer n); // 1 in = 2. 2 in = 2. 4 in = 3. etc...
	integer i;
	begin
		log2 = 1;
		for( i=0; 2**i < n; i = i+1 )
			log2 = i + 1;
	end
endfunction

endmodule