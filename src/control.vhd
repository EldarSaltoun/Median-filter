library IEEE;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.Pix_conv_pack.all;

entity control is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        start    : in  STD_LOGIC;
        done     : out STD_LOGIC;
        write_en : out STD_LOGIC;
        buff_en  : out STD_LOGIC;
        rom_cnt  : out STD_LOGIC_VECTOR (7 downto 0);
        ram_cnt  : out STD_LOGIC_VECTOR (7 downto 0)
    );
end control;

architecture arch_control of control is

    -- FSM state declarations
    type state is (
        IDLE, first_row0, run, last_row0, last_row1,
        bef_last, close, finish
    );
    signal current_state, next_state : state;

    -- Counters for ROM and RAM addressing
    signal rom_Tcnt, ram_Tcnt : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal internal_done : STD_LOGIC := '0';

begin

    -- Output signal assignments
    rom_cnt <= rom_Tcnt;
    ram_cnt <= ram_Tcnt;
    done    <= internal_done;

    -- State transition and counter logic
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            rom_Tcnt <= (others => '0');
            ram_Tcnt <= (others => '0');
            internal_done <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;

            -- Counter behavior depending on state
            if current_state = first_row0 then
                rom_Tcnt <= rom_Tcnt + 1;

            elsif current_state = run then
                if rom_Tcnt < x"FF" then
                    rom_Tcnt <= rom_Tcnt + 1;
                end if;
                if rom_Tcnt > 4 then
                    ram_Tcnt <= ram_Tcnt + 1;
                end if;

            elsif current_state = last_row0 or
                  current_state = last_row1 or
                  current_state = bef_last then
                if rom_Tcnt < x"FF" then
                    rom_Tcnt <= rom_Tcnt + 1;
                end if;
                ram_Tcnt <= ram_Tcnt + 1;
            end if;

            if next_state = finish then
                internal_done <= '1';
            else
                internal_done <= '0';
            end if;
        end if;
    end process;

    -- Next-state and output logic for FSM
    process(current_state, start, rom_Tcnt, ram_Tcnt)
    begin
        write_en <= '0';
        buff_en  <= '0';
        next_state <= current_state;

        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= first_row0;
                end if;

            when first_row0 =>
                buff_en <= '1';
                next_state <= run;

            when run =>
                buff_en  <= '1';
                if rom_Tcnt > 4 then
                    write_en <= '1';
                end if;

                if unsigned(ram_Tcnt) = 252 then
                    next_state <= last_row0;
                else
                    next_state <= run;
                end if;

            when last_row0 =>
                buff_en  <= '1';
                write_en <= '1';
                next_state <= last_row1;

            when last_row1 =>
                buff_en  <= '1';
                write_en <= '1';
                next_state <= bef_last;

            when bef_last =>
                write_en <= '1';
                next_state <= close;

            when close =>
                next_state <= finish;

            when finish =>
                -- Hold state until reset
                null;
        end case;
    end process;

end arch_control;

