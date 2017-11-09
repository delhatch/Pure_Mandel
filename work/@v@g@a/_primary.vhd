library verilog;
use verilog.vl_types.all;
entity VGA is
    port(
        writedata_iDATA : in     vl_logic_vector(7 downto 0);
        address_iADDR   : in     vl_logic_vector(18 downto 0);
        write_iWR_en    : in     vl_logic;
        iRST_N          : in     vl_logic;
        clk_iCLK        : in     vl_logic;
        export_VGA_R    : out    vl_logic_vector(7 downto 0);
        export_VGA_G    : out    vl_logic_vector(7 downto 0);
        export_VGA_B    : out    vl_logic_vector(7 downto 0);
        export_VGA_HS   : out    vl_logic;
        export_VGA_VS   : out    vl_logic;
        export_VGA_SYNC : out    vl_logic;
        export_VGA_BLANK: out    vl_logic;
        export_VGA_CLK  : out    vl_logic;
        iCLK_25         : in     vl_logic
    );
end VGA;
