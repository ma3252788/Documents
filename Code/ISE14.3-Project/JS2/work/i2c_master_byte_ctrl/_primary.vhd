library verilog;
use verilog.vl_types.all;
entity i2c_master_byte_ctrl is
    generic(
        ST_IDLE         : integer := 0;
        ST_START        : integer := 1;
        ST_READ         : integer := 2;
        ST_WRITE        : integer := 4;
        ST_ACK          : integer := 8;
        ST_STOP         : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        nReset          : in     vl_logic;
        ena             : in     vl_logic;
        clk_cnt         : in     vl_logic_vector(15 downto 0);
        start           : in     vl_logic;
        stop            : in     vl_logic;
        read            : in     vl_logic;
        write           : in     vl_logic;
        ack_in          : in     vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        cmd_ack         : out    vl_logic;
        ack_out         : out    vl_logic;
        dout            : out    vl_logic_vector(7 downto 0);
        i2c_busy        : out    vl_logic;
        i2c_al          : out    vl_logic;
        scl_i           : in     vl_logic;
        scl_o           : out    vl_logic;
        scl_oen         : out    vl_logic;
        sda_i           : in     vl_logic;
        sda_o           : out    vl_logic;
        sda_oen         : out    vl_logic
    );
end i2c_master_byte_ctrl;
