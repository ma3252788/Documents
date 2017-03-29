library verilog;
use verilog.vl_types.all;
entity i2c_master_bit_ctrl is
    generic(
        idle            : integer := 0;
        start_a         : integer := 1;
        start_b         : integer := 2;
        start_c         : integer := 4;
        start_d         : integer := 8;
        start_e         : integer := 16;
        stop_a          : integer := 32;
        stop_b          : integer := 64;
        stop_c          : integer := 128;
        stop_d          : integer := 256;
        rd_a            : integer := 512;
        rd_b            : integer := 1024;
        rd_c            : integer := 2048;
        rd_d            : integer := 4096;
        wr_a            : integer := 8192;
        wr_b            : integer := 16384;
        wr_c            : integer := 32768;
        wr_d            : integer := 65536
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        nReset          : in     vl_logic;
        clk_cnt         : in     vl_logic_vector(15 downto 0);
        ena             : in     vl_logic;
        cmd             : in     vl_logic_vector(3 downto 0);
        cmd_ack         : out    vl_logic;
        busy            : out    vl_logic;
        al              : out    vl_logic;
        din             : in     vl_logic;
        dout            : out    vl_logic;
        scl_i           : in     vl_logic;
        scl_o           : out    vl_logic;
        scl_oen         : out    vl_logic;
        sda_i           : in     vl_logic;
        sda_o           : out    vl_logic;
        sda_oen         : out    vl_logic
    );
end i2c_master_bit_ctrl;
