library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
    port (
        c_bit : in std_logic;
        z_bit : in std_logic;
        compliment : in std_logic;
        op_code : in std_logic_vector(3 downto 0);

        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        B_comp : in std_logic_vector(15 downto 0);
        C : in std_logic_vector(16 downto 0);
        

        alu_out : out std_logic_vector(15 downto 0); 
        carry : out std_logic;
        zero  : out std_logic
    );
end alu;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity add16 is
    port (
        add_a : in std_logic_vector(15 downto 0);
        add_b : in std_logic_vector(15 downto 0);

        add_op : out std_logic_vector(16 downto 0)
    );
end add16;

architecture add_bhavorial of add16 is
    begin
        add_op <= ('0' & add_a) + ('0' & add_b);
end architecture add_bhavorial;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity add17 is
    port (
        add_a : in std_logic_vector(16 downto 0);
        add_b : in std_logic_vector(16 downto 0);

        add_op : out std_logic_vector(16 downto 0)
    );
end add17;

architecture add_bhavorial of add17 is
    begin
        add_op <= (add_a) + (add_b);
end architecture add_bhavorial;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sub is
    port (
        sub_a : in std_logic_vector(15 downto 0);
        sub_b : in std_logic_vector(15 downto 0);

        sub_op : out std_logic_vector(16 downto 0)
    );
end sub;

architecture sub_bhavorial of sub is
    begin
        sub_op <= ('0' & sub_a) - ('0' & sub_b);
end architecture sub_bhavorial;


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity nand_ab is
    port (
        nand_a : in std_logic_vector(15 downto 0);
        nand_b : in std_logic_vector(15 downto 0);

        nand_op : out std_logic_vector(15 downto 0)
    );
end nand_ab;

architecture nand_bhavorial of nand_ab is
    begin
        nand_op <= nand_a nand nand_b;
end architecture nand_bhavorial;

architecture behavorial of alu is
    component add16 is
        port (
            add_a : in std_logic_vector(15 downto 0);
            add_b : in std_logic_vector(15 downto 0);
    
            add_op : out std_logic_vector(16 downto 0)
        );
    end component;

    component add17 is
        port (
            add_a : in std_logic_vector(16 downto 0);
            add_b : in std_logic_vector(16 downto 0);
    
            add_op : out std_logic_vector(16 downto 0)
        );
    end component;

    component nand_ab is
        port (
            nand_a : in std_logic_vector(15 downto 0);
            nand_b : in std_logic_vector(15 downto 0);
    
            nand_op : out std_logic_vector(15 downto 0)
        );
    end component;

    component sub is
        port (
            sub_a : in std_logic_vector(15 downto 0);
            sub_b : in std_logic_vector(15 downto 0);
    
            sub_op : out std_logic_vector(16 downto 0)
        );
    end component;

    signal A_in, B_In : std_logic_vector(15 downto 0);

    signal add_op : std_logic_vector(16 downto 0);

    signal add_carry_op : std_logic_vector(16 downto 0);

    signal sub_op : std_logic_vector(16 downto 0);
    
    signal nand_op : std_logic_vector(15 downto 0);

    signal alu_output : std_logic_vector(15 downto 0);

begin
    inst_add:add16
    port map(
        add_a => A_in,
        add_b => B_in,
        add_op => add_op
    );

    inst_add_c:add17
    port map(
        add_a => add_op,
        add_b => C,
        add_op => add_carry_op
    );

    inst_sub:sub
    port map(
        sub_a => A,
        sub_b => B,
        sub_op => sub_op
    );

    inst_nand:nand_ab
    port map(
        nand_a => A_in,
        nand_b => B_in,
        nand_op => nand_op
    );

    alu_process_1:process(A, B_comp, C, compliment)
    begin
        if compliment = '1' then
            A_in <= A;
            B_in <= B_comp;
        else
            A_in <= A;
            B_in <= B;
        end if;
    end process alu_process_1;

    alu_process_2: process(op_code, c_bit, z_bit, add_op, sub_op, nand_op, add_carry_op)
    begin
        case op_code is
            when "0001" | "0000" | "0011" =>
                if c_bit = '1' and z_bit = '1' then
                    alu_output <= add_carry_op(15 downto 0);
                    carry   <= add_carry_op(16);
                else
                    alu_output <= add_op(15 downto 0);
                    carry   <= add_op(16);
                end if;

            when "1001" | "1000" | "1011" =>
                alu_output <= sub_op(15 downto 0);
                carry   <= sub_op(16);

            when others =>
                alu_output <= nand_op;
                carry <= '0'; -- Default value
        end case;
    end process alu_process_2;

    alu_process_3:process(alu_output)
    begin
        alu_out <= alu_output;
        zero <= not ((((alu_output(0) or alu_output(1)) or (alu_output(2) or alu_output(3)))
                or ((alu_output(4) or alu_output(5)) or (alu_output(6) or alu_output(7))))
                or (((alu_output(8) or alu_output(9)) or (alu_output(10) or alu_output(11)))
                or ((alu_output(12) or alu_output(13)) or (alu_output(14) or alu_output(15)))));
    end process alu_process_3;
    
end architecture behavorial;