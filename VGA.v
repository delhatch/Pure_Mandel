module VGA (
   // Host Side
	input [7:0] writedata_iDATA,   // Data going into the dual-port RAM.
	input [18:0] address_iADDR,     // 640x480 = 307,200 8-bit locations. 2^19 = 524,288
	input write_iWR_en,
	input iRST_N,
	input clk_iCLK,		//	Host Clock for writes into memory.
	//	Export Side
	output [7:0] export_VGA_R,
	output [7:0] export_VGA_G,
	output [7:0] export_VGA_B,
	output export_VGA_HS,
	output export_VGA_VS,
	output export_VGA_SYNC,
	output export_VGA_BLANK,
	output export_VGA_CLK,
	input  iCLK_25	    // VGA pixel clock in.
);

wire [18:0] mVGA_ADDR;   // Between the VGA_Controller and the dual-port memory.
wire [9:0] L_VGA_R, L_VGA_G, L_VGA_B;  // Output of VGA_Controller is 10-bit video.
wire [7:0] index;
wire [7:0] b_data; 
wire [7:0] g_data;  
wire [7:0] r_data;
wire [9:0] mMouse_R;
wire [9:0] mMouse_G;
wire [9:0] mMouse_B;
wire [23:0] bgr_data_raw;
reg [23:0] bgr_data;

assign mMouse_R = {r_data,2'b00};  // Pad the 8-bit color data to 10 bits for the VGA_Controller.
assign mMouse_G = {g_data,2'b00};
assign mMouse_B = {b_data,2'b00};
assign export_VGA_R = L_VGA_R[9:2];  // DE2 VGA DAC is an 8-bit DAC.
assign export_VGA_G = L_VGA_G[9:2];
assign export_VGA_B = L_VGA_B[9:2];

VGA_Controller		u0	(	//	Host Side
								.iCursor_RGB_EN( 4'b0111 ),  // Disable cursor. Enable r,g,b outputs.
								.iCursor_X( 10'd100 ),
								.iCursor_Y( 10'd100 ),
								.iCursor_R( 10'hfff ),
								.iCursor_G( 10'hfff ),
								.iCursor_B( 10'hfff ),							
								.oAddress( mVGA_ADDR ),
								.iRed ( mMouse_R ),
								.iGreen ( mMouse_G ),
								.iBlue ( mMouse_B ),
								//	VGA Side
								.oVGA_R( L_VGA_R ),
								.oVGA_G( L_VGA_G ),
								.oVGA_B( L_VGA_B ),
								.oVGA_H_SYNC( export_VGA_HS ),
								.oVGA_V_SYNC( export_VGA_VS ),
								.oVGA_SYNC( export_VGA_SYNC ),
								.oVGA_BLANK( export_VGA_BLANK ),
								.oVGA_CLOCK( export_VGA_CLK ),    // Is simply assigned ~iCLK_25 in this module.
								//	Control Signal
								.iCLK_25( iCLK_25 ),
								.iRST_N( iRST_N )
							);

// Holds the image. Each 8-bit value refers to a 24-bit color in the look-up table.
my_img_data img_data_inst (
   .rdaddress( mVGA_ADDR ),
   .rdclock( iCLK_25 ),
	.wrclock( clk_iCLK ),     // From the Engine2VGA interface.
   .q( index ),
   .wraddress( address_iADDR ),  // From the Engine2VGA interface.
   .wren( write_iWR_en ),// From the Engine2VGA interface.
	.data( writedata_iDATA )  //     // From the Engine2VGA interface.
   );

//Color LUT output
img_index	img_index_inst (
	.address ( index ),
	.clock ( export_VGA_CLK ),
	.q ( bgr_data_raw)
	);	

//will latch valid data at falling edge;
always @( posedge iCLK_25 ) 
   bgr_data <= bgr_data_raw;

assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0];

endmodule

