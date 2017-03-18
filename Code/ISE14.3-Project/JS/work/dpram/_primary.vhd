library verilog;
use verilog.vl_types.all;
entity dpram is
    port(
        addra           : in     vl_logic_vector(15 downto 0);
        addrb           : in     vl_logic_vector(12 downto 0);
        clka            : in     vl_logic;
        clkb            : in     vl_logic;
        dina            : in     vl_logic_vector(7 downto 0);
        doutb           : out    vl_logic_vector(63 downto 0);
        ena             : in     vl_logic;
        enb             : in     vl_logic;
        wea             : in     vl_logic
    );
end dpram;
