library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use ieee.std_logic_textio.all;
library work;
use work.Pix_conv_pack.all;

entity tb_rgb_system is
end tb_rgb_system;

architecture arch_tb_rgb_system of tb_rgb_system is

    -- Device Under Test (DUT) component declaration
    component rgb_system
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            start : in  std_logic;
            done  : out std_logic
        );
    end component;

    -- Internal signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;

    constant clk_period : time := 10 ns;

begin

    ------------------------------------------------------------------
    -- Instantiate DUT
    ------------------------------------------------------------------
    uut: rgb_system
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            done  => done
        );

    ------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------
    clk <= not clk after (clk_period / 2);

    ------------------------------------------------------------------
    -- Stimulus process
    ------------------------------------------------------------------
    stim_proc: process
    begin
        -- Initial reset
        rst <= '0' after 23 ns;
        wait for 37 ns;

        -- Start pulse
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Wait for processing to complete
        wait until rising_edge(clk);
        wait until done = '1';

        report "System finished filtering all color channels" severity note;

        wait for 100 ns;
        assert false report "Simulation completed successfully" severity failure;
    end process;

end arch_tb_rgb_system;

