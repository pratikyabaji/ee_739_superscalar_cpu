library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity ir_memory is
    port (
        -- inputs
        clock   : in std_logic;
        pc_in   : in std_logic_vector(15 downto 0); 
        
        -- output
        ir_op    : out word_array(fetch_width-1 downto 0);
        pc_op    : out word_array(fetch_width-1 downto 0)
    );
end ir_memory;

architecture behavioral of ir_memory is
    type memoryType is array (0 to 2**16 - 1) of std_logic_vector(7 downto 0);
    signal IR_memory: memoryType:=( b"00011000", b"10001000", b"00010100", b"01101000", others => x"A0");
begin
    ir_memory_process:process(pc_in)
    begin
        ir_op(0)(7 downto 0) <= IR_memory(to_integer(unsigned(pc_in)));
        ir_op(0)(15 downto 8) <= IR_memory(to_integer(unsigned(pc_in+1)));
        pc_op(0) <= pc_in;
        ir_op(1)(7 downto 0) <= IR_memory(to_integer(unsigned(pc_in+2)));
        ir_op(1)(15 downto 8) <= IR_memory(to_integer(unsigned(pc_in+3)));
        pc_op(1) <= pc_in+2;
    end process ir_memory_process;
end behavioral;