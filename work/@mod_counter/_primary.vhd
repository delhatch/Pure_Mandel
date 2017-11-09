library verilog;
use verilog.vl_types.all;
entity Mod_counter is
    generic(
        N               : integer := 10;
        M               : integer := 640
    );
    port(
        clk             : in     vl_logic;
        clk_en          : in     vl_logic;
        reset           : in     vl_logic;
        max_tick        : out    vl_logic;
        q               : out    vl_logic_vector;
        pause           : in     vl_logic
    );
end Mod_counter;
