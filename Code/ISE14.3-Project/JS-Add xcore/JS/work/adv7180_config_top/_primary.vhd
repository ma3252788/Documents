library verilog;
use verilog.vl_types.all;
entity adv7180_config_top is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        ADV7180_SCL     : out    vl_logic;
        ADV7180_SDA     : out    vl_logic;
        finish          : out    vl_logic
    );
end adv7180_config_top;
