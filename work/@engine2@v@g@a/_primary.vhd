library verilog;
use verilog.vl_types.all;
entity Engine2VGA is
    port(
        engine_req      : in     vl_logic_vector(3 downto 0);
        req_ack         : out    vl_logic_vector(3 downto 0);
        write_iWR_en    : out    vl_logic;
        clk_iCLK        : in     vl_logic;
        reset           : in     vl_logic
    );
end Engine2VGA;
