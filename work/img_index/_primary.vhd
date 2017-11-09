library verilog;
use verilog.vl_types.all;
entity img_index is
    port(
        address         : in     vl_logic_vector(7 downto 0);
        clock           : in     vl_logic;
        q               : out    vl_logic_vector(23 downto 0)
    );
end img_index;
