library verilog;
use verilog.vl_types.all;
entity VGA_Controller is
    generic(
        H_SYNC_CYC      : integer := 96;
        H_SYNC_BACK     : integer := 48;
        H_SYNC_ACT      : integer := 640;
        H_SYNC_FRONT    : integer := 16;
        H_SYNC_TOTAL    : integer := 800;
        V_SYNC_CYC      : integer := 2;
        V_SYNC_BACK     : integer := 32;
        V_SYNC_ACT      : integer := 480;
        V_SYNC_FRONT    : integer := 11;
        V_SYNC_TOTAL    : integer := 525
    );
    port(
        iCursor_RGB_EN  : in     vl_logic_vector(3 downto 0);
        iCursor_X       : in     vl_logic_vector(9 downto 0);
        iCursor_Y       : in     vl_logic_vector(9 downto 0);
        iCursor_R       : in     vl_logic_vector(9 downto 0);
        iCursor_G       : in     vl_logic_vector(9 downto 0);
        iCursor_B       : in     vl_logic_vector(9 downto 0);
        iRed            : in     vl_logic_vector(9 downto 0);
        iGreen          : in     vl_logic_vector(9 downto 0);
        iBlue           : in     vl_logic_vector(9 downto 0);
        oAddress        : out    vl_logic_vector(19 downto 0);
        oCoord_X        : out    vl_logic_vector(9 downto 0);
        oCoord_Y        : out    vl_logic_vector(9 downto 0);
        oVGA_R          : out    vl_logic_vector(9 downto 0);
        oVGA_G          : out    vl_logic_vector(9 downto 0);
        oVGA_B          : out    vl_logic_vector(9 downto 0);
        oVGA_H_SYNC     : out    vl_logic;
        oVGA_V_SYNC     : out    vl_logic;
        oVGA_SYNC       : out    vl_logic;
        oVGA_BLANK      : out    vl_logic;
        oVGA_CLOCK      : out    vl_logic;
        iCLK_25         : in     vl_logic;
        iRST_N          : in     vl_logic
    );
end VGA_Controller;
