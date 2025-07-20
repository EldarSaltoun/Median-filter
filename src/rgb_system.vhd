library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Pix_conv_pack.all;

entity rgb_system is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        start   : in  std_logic;
        done    : out std_logic
    );
end rgb_system;

architecture arch_rgb_system of rgb_system is

    -- RED control and data signals
    signal rom_addr_r, ram_addr_r : std_logic_vector(7 downto 0);
    signal write_en_r, buff_en_r  : std_logic;
    signal data_in_r, data_out_r  : std_logic_vector(row_len downto 0);
    signal done_r                 : std_logic;

    -- GREEN control and data signals
    signal rom_addr_g, ram_addr_g : std_logic_vector(7 downto 0);
    signal write_en_g, buff_en_g  : std_logic;
    signal data_in_g, data_out_g  : std_logic_vector(row_len downto 0);
    signal done_g                 : std_logic;

    -- BLUE control and data signals
    signal rom_addr_b, ram_addr_b : std_logic_vector(7 downto 0);
    signal write_en_b, buff_en_b  : std_logic;
    signal data_in_b, data_out_b  : std_logic_vector(row_len downto 0);
    signal done_b                 : std_logic;

begin

    ------------------------------------------------------------------
    -- RED Path
    ------------------------------------------------------------------
    control_R : entity work.control
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            done     => done_r,
            write_en => write_en_r,
            buff_en  => buff_en_r,
            rom_cnt  => rom_addr_r,
            ram_cnt  => ram_addr_r
        );

    pipe_R : entity work.pipe
        port map (
            clk      => clk,
            rst      => rst,
            write_en => write_en_r,
            buff_en  => buff_en_r,
            rom_cnt  => rom_addr_r,
            ram_cnt  => ram_addr_r,
            rom_data => data_in_r,
            DATAOUT  => data_out_r
        );

    ROM_R : entity work.ROM_RED
        port map (
            address => rom_addr_r,
            clock   => clk,
            q       => data_in_r
        );

    RAM_R : entity work.RAM_RED
        port map (
            address => ram_addr_r,
            clock   => clk,
            data    => data_out_r,
            wren    => write_en_r,
            q       => open
        );

    ------------------------------------------------------------------
    -- GREEN Path
    ------------------------------------------------------------------
    control_G : entity work.control
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            done     => done_g,
            write_en => write_en_g,
            buff_en  => buff_en_g,
            rom_cnt  => rom_addr_g,
            ram_cnt  => ram_addr_g
        );

    pipe_G : entity work.pipe
        port map (
            clk      => clk,
            rst      => rst,
            write_en => write_en_g,
            buff_en  => buff_en_g,
            rom_cnt  => rom_addr_g,
            ram_cnt  => ram_addr_g,
            rom_data => data_in_g,
            DATAOUT  => data_out_g
        );

    ROM_G : entity work.ROM_GREEN
        port map (
            address => rom_addr_g,
            clock   => clk,
            q       => data_in_g
        );

    RAM_G : entity work.RAM_GREEN
        port map (
            address => ram_addr_g,
            clock   => clk,
            data    => data_out_g,
            wren    => write_en_g,
            q       => open
        );

    ------------------------------------------------------------------
    -- BLUE Path
    ------------------------------------------------------------------
    control_B : entity work.control
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            done     => done_b,
            write_en => write_en_b,
            buff_en  => buff_en_b,
            rom_cnt  => rom_addr_b,
            ram_cnt  => ram_addr_b
        );

    pipe_B : entity work.pipe
        port map (
            clk      => clk,
            rst      => rst,
            write_en => write_en_b,
            buff_en  => buff_en_b,
            rom_cnt  => rom_addr_b,
            ram_cnt  => ram_addr_b,
            rom_data => data_in_b,
            DATAOUT  => data_out_b
        );

    ROM_B : entity work.ROM_BLUE
        port map (
            address => rom_addr_b,
            clock   => clk,
            q       => data_in_b
        );

    RAM_B : entity work.RAM_BLUE
        port map (
            address => ram_addr_b,
            clock   => clk,
            data    => data_out_b,
            wren    => write_en_b,
            q       => open
        );

    ------------------------------------------------------------------
    -- Final Done Signal
    ------------------------------------------------------------------
    done <= done_r and done_g and done_b;

end arch_rgb_system;

