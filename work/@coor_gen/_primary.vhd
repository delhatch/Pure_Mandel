library verilog;
use verilog.vl_types.all;
entity Coor_gen is
    generic(
        NUM_PROC        : integer := 4;
        E_ADDR_WIDTH    : integer := 3
    );
    port(
        cclk            : in     vl_logic;
        ckey            : in     vl_logic_vector(3 downto 0);
        creset          : in     vl_logic;
        cdones          : in     vl_logic_vector(3 downto 0);
        clatch_en       : out    vl_logic;
        cengine_addr    : out    vl_logic_vector(2 downto 0);
        cword2engines   : out    vl_logic_vector(82 downto 0);
        frame           : out    vl_logic
    );
end Coor_gen;
