library ieee;
use std.textio.all; 
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity carry_flag is
    port (
        clock : in std_logic;
        reset : in std_logic;

        -- to modify carry_flag
        c_in : in std_logic;
        tag  : in std_logic_vector(2 downto 0);
        c_in_valid : in std_logic;

        -- to modify carry rename flag
        c_rename_in : in std_logic_vector(total_no_pipelines - 1 downto 0);
        c_rename_tag_in : in operand_array(total_no_pipelines - 1 downto 0);
        c_rename_in_valid  : in std_logic_vector(total_no_pipelines - 1 downto 0);

        c_out : out operand_array(fetch_width - 1 downto 0);
        c_valid: out std_logic_vector(fetch_width - 1 downto 0)
    );
end carry_flag;

architecture behavorial of carry_flag is
    signal carry_flag : std_logic := '0';
    variable busy_bit   : std_logic := '0';
    variable carry_tag  : std_logic_vector(2 downto 0) := b"000";

    type carry_rename is record
        valid  : std_logic;
        busy   : std_logic;
        carry_flag_rr : std_logic;
    end record;

    type carry_rename_array is array (0 to 7) of carry_rename;
    signal carry_rename_flag_file : carry_rename_array := (others => (busy => '0', valid => '0', carry_flag_rr => '0'));
begin
    carry_write_process:process(clock)
    begin
        if falling_edge(clock) then
            if c_in_valid = '1' then
                if carry_tag = tag then
                    busy_bit := '1';
                    carry_flag <= c_in;
                end if;
            end if;
        end if;
    end process carry_write_process; 

    carry_rename_write:process(clock)
    begin
        if falling_edge(clock) then
            for i in 0 to total_no_pipelines - 1 loop
                if c_rename_in_valid(i) = '1' then
                    carry_rename_flag_file(to_integer(unsigned(c_rename_tag_in(i)))).carry_flag_rr <= c_rename_in(i);
                end if;
            end loop;
        end if;
    end process carry_rename_write;

    carry_read_process:process(clock)
    begin
        for i in 0 to fetch_width - 1 loop
            if busy_bit = '0' then
                c_out(i)(0) <= carry_flag;
                c_out(i)(2 downto 1) <= b"00";
                c_valid(i) <= '1';
            else
                c_out(i) <= (carry_tag + 1);
                c_valid(i) <= '0';
                carry_tag := (carry_tag + 1);
            end if;
            busy_bit := '1';
        end loop;
    end process carry_read_process;

end architecture behavorial;