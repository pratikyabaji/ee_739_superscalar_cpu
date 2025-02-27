library ieee;
use std.textio.all; 
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity zero_flag is
    port (
        clock : in std_logic;
        reset : in std_logic;

        -- to modify zero_flag
        z_in : in std_logic;
        tag  : in std_logic_vector(2 downto 0);
        z_in_valid : in std_logic;

        -- to modify zero rename flag
        z_rename_in : in std_logic_vector(total_no_pipelines - 1 downto 0);
        z_rename_tag_in : in operand_array(total_no_pipelines - 1 downto 0);
        z_rename_in_valid  : in std_logic_vector(total_no_pipelines - 1 downto 0);

        z_out : out operand_array(fetch_width - 1 downto 0);
        z_valid: out std_logic_vector(fetch_width - 1 downto 0)
    );
end zero_flag;

architecture behavorial of zero_flag is
    signal zero_flag : std_logic := '0';
    variable busy_bit   : std_logic := '0';
    variable zero_tag  : std_logic_vector(2 downto 0) := b"000";

    type zero_rename is record
        valid  : std_logic;
        busy   : std_logic;
        zero_flag : std_logic;
    end record;

    type zero_rename_array is array (0 to 7) of zero_rename;
    signal zero_rename_flag_file : zero_rename_array := (others => (busy => '0', valid => '0', zero_flag => '0'));
begin
    zero_write_process:process(clock)
    begin
        if falling_edge(clock) then
            if z_in_valid = '1' then
                if zero_tag = tag then
                    busy_bit := '1';
                    zero_flag <= z_in;
                end if;
            end if;
        end if;
    end process zero_write_process; 

    zero_rename_write:process(clock)
    begin
        if falling_edge(clock) then
            for i in 0 to total_no_pipelines - 1 loop
                if z_rename_in_valid(i) = '1' then
                    zero_rename_flag_file(to_integer(unsigned(z_rename_tag_in(i)))).zero_flag <= z_rename_in(i);
                end if;
            end loop;
        end if;
    end process zero_rename_write;

    zero_read_process:process(clock)
    begin
        for i in 0 to fetch_width - 1 loop
            if busy_bit = '0' then
                z_out(i)(0) <= zero_flag;
                z_out(i)(2 downto 1) <= b"00";
                z_valid(i) <= '1';
            else
                z_out(i) <= (zero_tag + 1);
                z_valid(i) <= '0';
                zero_tag := (zero_tag + 1);
            end if;
            busy_bit := '1';
        end loop;
    end process zero_read_process;

end architecture behavorial;