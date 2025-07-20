library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package Pix_conv_pack is

    -- Image and pixel configuration constants
    constant pic_width  : positive := 256;
    constant pic_height : positive := 256;
    constant color_size : positive := 8;
    constant row_len    : positive := (color_size * pic_width) - 1;  -- 2047 for 8-bit color and 256-pixel width

    -- Pixel and array type definitions
    subtype pixel     is std_logic_vector((color_size - 1) downto 0);
    type pixel_arr    is array(natural range <>) of pixel;
    type Buffer_3R    is array(0 to 2) of pixel_arr(0 to pic_width + 1);
    type mask         is array(0 to 2) of pixel_arr(0 to 2);

    -- Conversion and processing functions
    function Conv_stdV_2_Arr(arg : std_logic_vector) return pixel_arr;
    function Conv_Arr_2_stdV(arg : pixel_arr) return std_logic_vector;
    function median(row : pixel_arr(0 to 2)) return pixel;
    function medianOfMedians(mask_in : mask) return pixel;

end Pix_conv_pack;


package body Pix_conv_pack is

    -- Helper function to convert std_logic_vector to string (for debug reporting)
    function vector_to_string(v : std_logic_vector) return string is
        variable result : string(1 to v'length);
    begin
        for i in v'range loop
            if v(i) = '1' then
                result(v'length - i) := '1';
            else
                result(v'length - i) := '0';
            end if;
        end loop;
        return result;
    end function;


    -- Converts a flat std_logic_vector into an array of pixels (no reversal)
    function Conv_stdV_2_Arr(arg : std_logic_vector) return pixel_arr is
        variable flat_vector : std_logic_vector(0 to arg'length - 1);
        variable result      : pixel_arr(0 to (arg'length / color_size) - 1);
    begin
        flat_vector := arg;
        report "Starting Conv_stdV_2_Arr conversion" severity note;

        for i in 0 to result'length - 1 loop
            if (i * color_size < flat_vector'length and ((i + 1) * color_size) - 1 < flat_vector'length) then
                result(i) := flat_vector(i * color_size to ((i + 1) * color_size) - 1);
            else
                report "Index out of range in Conv_stdV_2_Arr at i = " & integer'image(i) severity error;
            end if;
        end loop;

        report "Finished Conv_stdV_2_Arr conversion" severity note;
        return result;
    end function;


    -- Converts an array of pixels into a flat std_logic_vector (no reversal)
    function Conv_Arr_2_stdV(arg : pixel_arr) return std_logic_vector is
        variable flat_array : pixel_arr(arg'range);
        variable result     : std_logic_vector((arg'length * color_size) - 1 downto 0);
    begin
        flat_array := arg;
        report "Starting Conv_Arr_2_stdV conversion" severity note;

        for i in flat_array'range loop
            if ((i + 1) * color_size) - 1 < result'length then
                result(((i + 1) * color_size) - 1 downto i * color_size) := flat_array(i);
            else
                report "Index out of range in Conv_Arr_2_stdV at i = " & integer'image(i) severity error;
            end if;
        end loop;

        report "Finished Conv_Arr_2_stdV conversion" severity note;
        return result;
    end function;


    -- Returns the median value of 3 pixels
    function median(row : pixel_arr(0 to 2)) return pixel is
        variable med_out : pixel := (others => '0');
    begin
        report "Calculating median" severity note;

        if row'length /= 3 then
            report "Invalid row size in median function. Expected length: 3, got: " & integer'image(row'length) severity error;
        end if;

        if (row(0) >= row(1) and row(0) <= row(2)) or (row(0) >= row(2) and row(0) <= row(1)) then
            med_out := row(0);
        elsif (row(1) >= row(0) and row(1) <= row(2)) or (row(1) >= row(2) and row(1) <= row(0)) then
            med_out := row(1);
        elsif (row(2) >= row(0) and row(2) <= row(1)) or (row(2) >= row(1) and row(2) <= row(0)) then
            med_out := row(2);
        else
            report "All elements are equal in median function" severity warning;
        end if;

        report "Median calculated: " & vector_to_string(med_out) severity note;
        return med_out;
    end function;


    -- Returns the median of medians from a 3x3 pixel mask
    function medianOfMedians(mask_in : mask) return pixel is
        variable row_buff : pixel_arr(0 to 2) := (others => (others => '0'));
        variable MoM_out  : pixel := (others => '0');
    begin
        report "Calculating median of medians" severity note;

        if mask_in'length /= 3 or mask_in(0)'length /= 3 then
            report "Invalid mask size in medianOfMedians function. Expected size: 3x3, got: " &
                   integer'image(mask_in'length) & "x" & integer'image(mask_in(0)'length) severity error;
        end if;

        for i in 0 to 2 loop
            row_buff(i) := median(mask_in(i)(0 to 2));
        end loop;

        MoM_out := median(row_buff);
        report "Median of medians calculated: " & vector_to_string(MoM_out) severity note;
        return MoM_out;
    end function;

end package body Pix_conv_pack;

