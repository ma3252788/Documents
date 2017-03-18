library verilog;
use verilog.vl_types.all;
entity i2c_master_top is
    generic(
        ARST_LVL        : integer := 0
    );
    port(
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        arst_i          : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(2 downto 0);
        wb_dat_i        : in     vl_logic_vector(7 downto 0);
        wb_dat_o        : out    vl_logic_vector(7 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_inta_o       : out    vl_logic;
        scl_pad_i       : in     vl_logic;
        scl_pad_o       : out    vl_logic;
        scl_padoen_o    : out    vl_logic;
        sda_pad_i       : in     vl_logic;
        sda_pad_o       : out    vl_logic;
        sda_padoen_o    : out    vl_logic
    );
end i2c_master_top;
