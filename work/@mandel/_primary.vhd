library verilog;
use verilog.vl_types.all;
entity Mandel is
    generic(
        NUM_PROC        : integer := 4
    );
    port(
        SW              : in     vl_logic_vector(17 downto 0);
        KEY             : in     vl_logic_vector(3 downto 0);
        LEDR            : out    vl_logic_vector(17 downto 0);
        LEDG            : out    vl_logic_vector(7 downto 0);
        CLOCK_50        : in     vl_logic;
        VGA_B           : out    vl_logic_vector(7 downto 0);
        VGA_BLANK_N     : out    vl_logic;
        VGA_CLK         : out    vl_logic;
        VGA_G           : out    vl_logic_vector(7 downto 0);
        VGA_HS          : out    vl_logic;
        VGA_R           : out    vl_logic_vector(7 downto 0);
        VGA_SYNC_N      : out    vl_logic;
        VGA_VS          : out    vl_logic
    );
end Mandel;
