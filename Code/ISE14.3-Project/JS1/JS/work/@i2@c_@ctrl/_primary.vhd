library verilog;
use verilog.vl_types.all;
entity I2C_Ctrl is
    generic(
        PRER_LO         : integer := 0;
        PRER_HI         : integer := 1;
        CTR             : integer := 2;
        RXR             : integer := 3;
        TXR             : integer := 3;
        CR              : integer := 4;
        SR              : integer := 4;
        TXR_R           : integer := 5;
        CR_R            : integer := 6;
        IDLE            : integer := 1;
        STATE1          : integer := 2;
        STATE2          : integer := 4;
        STATE3          : integer := 8;
        STATE4          : integer := 16;
        STATE5          : integer := 32;
        STATE6          : integer := 64;
        STATE7          : integer := 128;
        STATE8          : integer := 256;
        STATE9          : integer := 512;
        STATE10         : integer := 1024;
        STATE11         : integer := 2048;
        STATE12         : integer := 4096;
        STATE13         : integer := 8192;
        STATE14         : integer := 16384;
        STATE15         : integer := 32768;
        STATE16         : integer := 65536;
        STATE17         : integer := 131072;
        STATE18         : integer := 262144;
        STATE19         : integer := 524288;
        STATE20         : integer := 1048576;
        STATE_DELAY     : integer := 2097152
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        ack             : in     vl_logic;
        err             : in     vl_logic;
        rty             : in     vl_logic;
        sel             : out    vl_logic;
        rom_data        : in     vl_logic_vector(7 downto 0);
        cyc             : out    vl_logic;
        stb             : out    vl_logic;
        we              : out    vl_logic;
        dout            : out    vl_logic_vector(7 downto 0);
        adr             : out    vl_logic_vector(2 downto 0);
        rom_addr        : out    vl_logic_vector(5 downto 0);
        Finish          : out    vl_logic
    );
end I2C_Ctrl;
