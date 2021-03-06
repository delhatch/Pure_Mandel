module Coor_gen_tb;

reg clk, reset;
reg [3:0] dones;
wire [3:0] key;
wire latch;
wire [2:0] engine_addr;
wire [82:0] word;

assign key[3:0] = 4'b0000;


// define the clock
initial
begin
	clk = 1'b0;
	forever #100 clk = ~clk;
end

// define input sequence
initial
begin
	#0 reset = 1'b1; 
	#150 reset = 1'b0; dones = 5'b1111;
	@ (posedge clk);
	@ (negedge clk) dones = 5'b1110;
	@ (posedge clk);
	@ (negedge clk) dones = 5'b1100;
	@ (posedge clk);
	@ (negedge clk) dones = 5'b0000;
		@ (posedge clk);	@ (posedge clk);
	@ (negedge clk) dones = 5'b0010;
		@ (posedge clk);
	@ (negedge clk) dones = 5'b0000;
	
end

Coor_gen u1 (
	.cclk( clk ),
	.ckey( key ),
	.creset( reset ),
	.cdones( dones ),
	.clatch_en( latch ),
	.cengine_addr( engine_addr ),
	.cword2engines( word )    // x,y in int and fractional integer. To engines.
	);
	
endmodule