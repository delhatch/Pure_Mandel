library verilog;
use verilog.vl_types.all;
entity Engine is
    generic(
        MAX_ITERATIONS  : integer := 255
    );
    port(
        my_addr         : in     vl_logic_vector(2 downto 0);
        engine_addr     : in     vl_logic_vector(2 downto 0);
        in_word         : in     vl_logic_vector(82 downto 0);
        latch_en        : in     vl_logic;
        eRST            : in     vl_logic;
        Engine_CLK      : in     vl_logic;
        req_ack         : in     vl_logic;
        out_word        : out    vl_logic_vector(26 downto 0);
        available       : out    vl_logic;
        service_req     : out    vl_logic
    );
end Engine;
