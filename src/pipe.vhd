library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.Pix_conv_pack.all;

entity pipe is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        write_en   : in  std_logic;
        buff_en    : in  std_logic;
        rom_cnt    : in  std_logic_vector(7 downto 0);
        ram_cnt    : in  std_logic_vector(7 downto 0);
        rom_data   : in  std_logic_vector(row_len downto 0);
        ram_we     : out std_logic;
        DATAOUT    : out std_logic_vector(row_len downto 0)
    );
end pipe;

architecture arch_pipe of pipe is

    signal buffer_in        : pixel_arr(0 to pic_width - 1);
    signal buffer_out       : Buffer_3R;
    signal corr_row         : pixel_arr(0 to pic_width - 1);
    signal filtered_output  : std_logic_vector(row_len downto 0);

begin
    -- Output assignments
    DATAOUT <= filtered_output;
    ram_we  <= write_en;

    -- Convert input vector to pixel array
    buffer_in <= Conv_stdV_2_Arr(rom_data);

    -- Line buffer shift logic
    process(clk, rst)
    begin
        if rst = '1' then
            buffer_out <= (others => (others => (others => '0')));
        elsif rising_edge(clk) then
            if buff_en = '1' then
                buffer_out(2) <= buffer_out(1);
                buffer_out(1) <= buffer_out(0);
                buffer_out(0) <= buffer_in(0) & buffer_in & buffer_in(buffer_in'high);
            end if;
        end if;
    end process;

    -- Median filtering logic
    process(clk, rst)
        variable temp_mask : mask;
    begin
        if rst = '1' then
            corr_row <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if buff_en = '1' then
                for i in 1 to pic_width loop  -- Skip boundaries
                    for row in 0 to 2 loop
                        for col in -1 to 1 loop
                            temp_mask(row)(col + 1) := buffer_out(row)(i + col);
                        end loop;
                    end loop;
                    corr_row(i - 1) <= medianOfMedians(temp_mask);
                end loop;
            end if;
        end if;
    end process;

    -- Convert filtered row to output vector
    filtered_output <= Conv_Arr_2_stdV(corr_row);

end arch_pipe;

