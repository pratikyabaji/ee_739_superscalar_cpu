library ieee;
use std.textio.all; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity reservation_station is
    port (
        -- clock reset
        clock : in std_logic;
        reset : in std_logic;
        al_issue_enable : in std_logic_vector(no_al_pipelines - 1 downto 0);
        ls_issue_enable : in std_logic_vector(no_ls_pipelines - 1 downto 0);

        ir_valid : in bit_array(rs_input_size - 1 downto 0);
        pc_in :in word_array(rs_input_size - 1 downto 0);
        op_code: in nibble_array(rs_input_size - 1 downto 0);
        destination_tag: in operand_array(rs_input_size - 1 downto 0);
        orignal_destination: in operand_array(rs_input_size - 1 downto 0);
        operand_1_value: in word_array(rs_input_size - 1 downto 0);
        operand_1_value_valid: in bit_array(rs_input_size - 1 downto 0);
        operand_2_value: in word_array(rs_input_size - 1 downto 0);
        operand_2_value_valid: in bit_array(rs_input_size - 1 downto 0);
        compliment_bit : in bit_array(rs_input_size - 1 downto 0);
        imm6            : in imm6(rs_input_size-1 downto 0);
        imm9            : in imm9(rs_input_size-1 downto 0);
        C : in bit_array(rs_input_size - 1 downto 0);
        Z : in bit_array(rs_input_size - 1 downto 0);


        ir_valid_al : out bit_array(no_al_pipelines - 1 downto 0);
        pc_al       : out word_array(no_al_pipelines - 1 downto 0);
        op_code_al     : out nibble_array(no_al_pipelines - 1 downto 0);
        destination_tag_al : out operand_array(no_al_pipelines - 1 downto 0);
        orignal_destination_tag_al : out operand_array(no_al_pipelines - 1 downto 0);
        operand_1_value_al : out word_array(no_al_pipelines - 1 downto 0); 
        operand_2_value_al : out word_array(no_al_pipelines - 1 downto 0); 
        compliment_bit_al  : out bit_array(no_al_pipelines - 1 downto 0);
        C_al  : out bit_array(no_al_pipelines - 1 downto 0);
        Z_al  : out bit_array(no_al_pipelines - 1 downto 0);

        ir_valid_ls : out bit_array(no_ls_pipelines - 1 downto 0);
        pc_ls       : out word_array(no_ls_pipelines - 1 downto 0);
        op_code_ls     : out nibble_array(no_ls_pipelines - 1 downto 0);
        destination_tag_ls : out operand_array(no_ls_pipelines - 1 downto 0);
        orignal_destination_tag_ls : out operand_array(no_ls_pipelines - 1 downto 0);
        operand_1_value_ls : out word_array(no_ls_pipelines - 1 downto 0); 
        operand_2_value_ls : out word_array(no_ls_pipelines - 1 downto 0); 
        compliment_bit_ls  : out bit_array(no_ls_pipelines - 1 downto 0);
        C_ls  : out bit_array(no_ls_pipelines - 1 downto 0);
        Z_ls  : out bit_array(no_ls_pipelines - 1 downto 0);

        tag   : in std_logic_vector(tag_size - 1 downto 0);
        value : in std_logic_vector(15 downto 0);
        valid_bit : in std_logic
    );
end reservation_station;

architecture behavorial of reservation_station is
    type rs_entry is record
        pc : std_logic_vector(15 downto 0);
        op_code : std_logic_vector(3 downto 0);
        destination_tag : std_logic_vector(2 downto 0);
        orignal_destination : std_logic_vector(2 downto 0);
        operand_1_value : std_logic_vector(15 downto 0);
        operand_1_value_valid : std_logic;
        operand_2_value : std_logic_vector(15 downto 0);
        operand_2_value_valid : std_logic;
        compliment : std_logic;
        C : std_logic;
        Z : std_logic;
        ready : std_logic;
        valid : std_logic;
        busy : std_logic;
    end record;

    type rs_array is array (0 to rs_size - 1) of rs_entry ;

    signal reservation_station : rs_array := (others => (pc => x"0000", op_code => x"0", destination_tag => b"000", orignal_destination => b"000", operand_1_value => x"0000", operand_1_value_valid => '0', operand_2_value => x"0000", operand_2_value_valid => '0' ,
    compliment => '0', C => '0', Z => '0', ready => '0', valid => '0', busy => '0'));
    signal head : integer := 0;
    signal al_tail : integer := 0;
    signal ls_tail : integer := 0;
    
    signal al_issue_box : operand_array(2 downto 0);
    
begin
    rs_process:process(clock)
    variable l : integer:=0;
    variable m : integer:=0;

    begin
        if reset = '1' then
            reset_loop:for i in 0 to rs_size - 1 loop
                reservation_station(i).pc <=x"0000";
                reservation_station(i).op_code <=x"0";
                reservation_station(i).destination_tag <=b"000";
                reservation_station(i).orignal_destination <=b"000";
                reservation_station(i).operand_1_value <=x"0000";
                reservation_station(i).operand_1_value_valid <='0';
                reservation_station(i).operand_2_value <=x"0000";
                reservation_station(i).operand_2_value_valid <='0';
                reservation_station(i).compliment <='0';
                reservation_station(i).C <='0';
                reservation_station(i).Z <='0';
                reservation_station(i).ready <='0';
                reservation_station(i).valid <='0';
                reservation_station(i).busy <='0';
                head <= 0;
            end loop reset_loop;
        else
            if falling_edge(clock) then
                -- loading the instructions
                load_loop: for i in 0 to rs_input_size - 1 loop
                    if ir_valid(i) = '1' and reservation_station((head+i) mod rs_size).valid = '0' then
                        if op_code(i) = b"0001" or op_code(i) = b"0010" then
                            reservation_station((head+i) mod rs_size).pc <=pc_in(i);
                            reservation_station((head+i) mod rs_size).op_code <=op_code(i);
                            reservation_station((head+i) mod rs_size).destination_tag <=destination_tag(i);
                            reservation_station((head+i) mod rs_size).orignal_destination <=orignal_destination(i);
                            reservation_station((head+i) mod rs_size).operand_1_value <=operand_1_value(i);
                            reservation_station((head+i) mod rs_size).operand_1_value_valid <=operand_1_value_valid(i);
                            reservation_station((head+i) mod rs_size).operand_2_value <=operand_2_value(i);
                            reservation_station((head+i) mod rs_size).operand_2_value_valid <=operand_2_value_valid(i);
                            reservation_station((head+i) mod rs_size).compliment <=compliment_bit(i);
                            reservation_station((head+i) mod rs_size).C <=C(i);
                            reservation_station((head+i) mod rs_size).Z <=Z(i);
                            reservation_station((head+i) mod rs_size).ready <='0';
                            reservation_station((head+i) mod rs_size).valid <='1';
                            reservation_station((head+i) mod rs_size).busy <='0';
                            head <= (head+i+1) mod rs_size;
                        elsif op_code(i) = b"0000" or op_code(i) = b"0100" then
                            reservation_station((head+i) mod rs_size).pc <=pc_in(i);
                            reservation_station((head+i) mod rs_size).op_code <=op_code(i);
                            reservation_station((head+i) mod rs_size).destination_tag <=destination_tag(i);
                            reservation_station((head+i) mod rs_size).orignal_destination <=orignal_destination(i);
                            reservation_station((head+i) mod rs_size).operand_1_value <=operand_1_value(i);
                            reservation_station((head+i) mod rs_size).operand_1_value_valid <=operand_1_value_valid(i);
                            reservation_station((head+i) mod rs_size).operand_2_value(15 downto 6) <=b"0000000000";
                            reservation_station((head+i) mod rs_size).operand_2_value(5 downto 0) <=imm6(i);
                            reservation_station((head+i) mod rs_size).operand_2_value_valid <='1';
                            reservation_station((head+i) mod rs_size).compliment <='0';
                            reservation_station((head+i) mod rs_size).C <='0';
                            reservation_station((head+i) mod rs_size).Z <='0';
                            reservation_station((head+i) mod rs_size).ready <='0';
                            reservation_station((head+i) mod rs_size).valid <='1';
                            reservation_station((head+i) mod rs_size).busy <='0';
                            head <= (head+i+1) mod rs_size;
                        elsif op_code(i) = b"0011" or op_code(i) = b"1100" then
                            reservation_station((head+i) mod rs_size).pc <=pc_in(i);
                            reservation_station((head+i) mod rs_size).op_code <=op_code(i);
                            reservation_station((head+i) mod rs_size).destination_tag <=destination_tag(i);
                            reservation_station((head+i) mod rs_size).orignal_destination <=orignal_destination(i);
                            reservation_station((head+i) mod rs_size).operand_1_value <=x"0000";
                            reservation_station((head+i) mod rs_size).operand_1_value_valid <='1';
                            reservation_station((head+i) mod rs_size).operand_2_value(15 downto 9) <=b"0000000";
                            reservation_station((head+i) mod rs_size).operand_2_value(8 downto 0) <=imm9(i);
                            reservation_station((head+i) mod rs_size).operand_2_value_valid <='1';
                            reservation_station((head+i) mod rs_size).compliment <='0';
                            reservation_station((head+i) mod rs_size).C <='0';
                            reservation_station((head+i) mod rs_size).Z <='0';
                            reservation_station((head+i) mod rs_size).ready <='1';
                            reservation_station((head+i) mod rs_size).valid <='1';
                            reservation_station((head+i) mod rs_size).busy <='0';
                            head <= (head+i+1) mod rs_size;
                        elsif op_code(i) = b"1000" or op_code(i) = b"1001" or op_code(i) = b"1011" or op_code(i) = b"0100"then
                            reservation_station((head+i) mod rs_size).pc <=pc_in(i);
                            reservation_station((head+i) mod rs_size).op_code <=op_code(i);
                            reservation_station((head+i) mod rs_size).destination_tag <=imm6(i)(5 downto 3);
                            reservation_station((head+i) mod rs_size).operand_1_value <=operand_1_value(i);
                            reservation_station((head+i) mod rs_size).orignal_destination <=orignal_destination(i);
                            reservation_station((head+i) mod rs_size).operand_1_value_valid <=operand_1_value_valid(i);
                            reservation_station((head+i) mod rs_size).operand_2_value <=operand_2_value(i);
                            reservation_station((head+i) mod rs_size).operand_2_value_valid <=operand_2_value_valid(i);
                            reservation_station((head+i) mod rs_size).compliment <=imm6(i)(2);
                            reservation_station((head+i) mod rs_size).C <=imm6(i)(1);
                            reservation_station((head+i) mod rs_size).Z <=imm6(i)(0);
                            reservation_station((head+i) mod rs_size).ready <='0';
                            reservation_station((head+i) mod rs_size).valid <='1';
                            reservation_station((head+i) mod rs_size).busy <='0';
                            head <= (head+i+1) mod rs_size;
                        else
                            -- op_code(i) = b"1101" or op_code = b"1111" or op_code(i) = b"0110" or op_code(i) = b"0111" then
                            reservation_station((head+i) mod rs_size).pc <=pc_in(i);
                            reservation_station((head+i) mod rs_size).op_code <=op_code(i);
                            reservation_station((head+i) mod rs_size).destination_tag <=destination_tag(i);
                            reservation_station((head+i) mod rs_size).orignal_destination <=orignal_destination(i);
                            reservation_station((head+i) mod rs_size).operand_1_value <=operand_1_value(i);
                            reservation_station((head+i) mod rs_size).operand_1_value_valid <=operand_1_value_valid(i);
                            reservation_station((head+i) mod rs_size).operand_2_value(15 downto 9) <=b"0000000";
                            reservation_station((head+i) mod rs_size).operand_2_value(8 downto 0) <=imm9(i);
                            reservation_station((head+i) mod rs_size).operand_2_value_valid <='1';
                            reservation_station((head+i) mod rs_size).compliment <='0';
                            reservation_station((head+i) mod rs_size).C <='0';
                            reservation_station((head+i) mod rs_size).Z <='0';
                            reservation_station((head+i) mod rs_size).ready <='0';
                            reservation_station((head+i) mod rs_size).valid <='1';
                            reservation_station((head+i) mod rs_size).busy <='0';
                            head <= (head+i+1) mod rs_size;
                        end if;
                    end if;
                end loop load_loop;
                
                al_issue_loop_00:for i in 0 to rs_size - 1 loop
                    if reservation_station(i).ready = '1' and reservation_station(i).valid = '1' and l < no_al_pipelines then
                        reservation_station(i).busy <= '1'; 
                        reservation_station(i).valid <= '0'; 
                        l := (l+1) mod no_al_pipelines;
                    end if;
                end loop;

                ls_issue_loop_00:for i in 0 to rs_size - 1 loop
                    if reservation_station(i).ready = '1' and reservation_station(i).valid = '1' and m < no_ls_pipelines then
                        reservation_station(i).busy <= '1'; 
                        reservation_station(i).valid <= '0'; 
                        m := (m+1) mod no_ls_pipelines;
                    end if;
                end loop;

                ready_bit_loop:for i in 0 to rs_size - 1 loop
                    if reservation_station(i).valid = '1' then
                        if  reservation_station(i).operand_1_value_valid = '1' and reservation_station(i).operand_2_value_valid = '1' then
                            reservation_station(i).ready <= '1';
                        end if;
                    end if;
                end loop;

                update_openad_1:for i in 0 to rs_size - 1 loop
                    if reservation_station(i).valid = '1' and reservation_station(i).operand_1_value_valid = '0' and reservation_station(i).operand_1_value(tag_size - 1 downto 0) = tag then
                        reservation_station(i).operand_1_value <= value;
                        reservation_station(i).operand_1_value_valid <= '1';
                    end if;
                end loop;

                update_openad_2:for i in 0 to rs_size - 1 loop
                    if reservation_station(i).valid = '1' and reservation_station(i).operand_2_value_valid = '0' and reservation_station(i).operand_2_value(tag_size - 1 downto 0) = tag then
                        reservation_station(i).operand_2_value <= value;
                        reservation_station(i).operand_2_value_valid <= '1';
                    end if;
                end loop;
            end if;
        end if;
    end process rs_process;

    issue_process:process(clock)
    variable j: integer := 0;
    variable k: integer := 0;
    variable al_issued_flag : std_logic_vector(no_al_pipelines - 1 downto 0) := (others => '0');
    variable ls_issued_flag : std_logic_vector(no_ls_pipelines - 1 downto 0) := (others => '0');

    begin
        j := 0;
        k := 0;
        al_issued_flag := (others => '0');
        ls_issued_flag := (others => '0');

        for i in 0 to no_al_pipelines - 1 loop
            if al_issued_flag(i) = '0' then
                ir_valid_al(i)<='0';
                pc_al(i)<= x"0000";  
                op_code_al(i)<=x"0";
                destination_tag_al(i)<= b"000";
                operand_1_value_al(i)<=x"0000";
                operand_2_value_al(i)<=x"0000";
                compliment_bit_al(i)<='0';
                C_al(i)<='0';
                Z_al(i)<='0';
            end if;
        end loop;

        for i in 0 to no_ls_pipelines - 1 loop
            if ls_issued_flag(i) = '0' then
                ir_valid_ls(i)<='0';
                pc_ls(i)<= x"0000";  
                op_code_ls(i)<=x"0";
                destination_tag_ls(i)<= b"000";
                operand_1_value_ls(i)<=x"0000";
                operand_2_value_ls(i)<=x"0000";
                compliment_bit_ls(i)<='0';
                C_ls(i)<='0';
                Z_ls(i)<='0';
            end if;
        end loop;

        for i in 0 to 10 loop

        end loop;
        al_issue_loop_01:for i in 0 to rs_size - 1 loop
            if reservation_station(i).ready = '1' and reservation_station(i).valid = '1' and j < no_al_pipelines then
            if not (reservation_station(i).op_code = "0100" or reservation_station(i).op_code = "0101") then
                ir_valid_al(j)<='1';
                pc_al(j)<= reservation_station(i).pc;  
                op_code_al(j)<=reservation_station(i).op_code;
                destination_tag_al(j)<=reservation_station(i).destination_tag;
                orignal_destination_tag_al(j)<=reservation_station(i).orignal_destination;
                operand_1_value_al(j)<=reservation_station(i).operand_1_value;
                operand_2_value_al(j)<=reservation_station(i).operand_2_value;
                compliment_bit_al(j)<=reservation_station(i).compliment;
                C_al(j)<=reservation_station(i).C;
                Z_al(j)<=reservation_station(i).Z;
                al_issued_flag(j) := '1';
                j := (j + 1);
            end if;
            end if;
        end loop;

        ls_issue_loop_01:for i in 0 to rs_size - 1 loop
            if reservation_station(i).ready = '1' and reservation_station(i).valid = '1' and k < no_ls_pipelines then
            if (reservation_station(i).op_code = "0100" or reservation_station(i).op_code = "0101") then
                ir_valid_ls(k)<='1';
                pc_ls(k)<=reservation_station(i).pc;  
                op_code_ls(k)<=reservation_station(i).op_code;    
                destination_tag_ls(k)<=reservation_station(i).destination_tag;
                orignal_destination_tag_ls(k)<=reservation_station(i).orignal_destination;
                operand_1_value_ls(k)<=reservation_station(i).operand_1_value; 
                operand_2_value_ls(k)<=reservation_station(i).operand_2_value; 
                compliment_bit_ls(k)<=reservation_station(i).compliment; 
                C_ls(k)<=reservation_station(i).C;  
                Z_ls(k)<=reservation_station(i).Z;
                ls_issued_flag(k) := '1';
                k := (k + 1);
            end if;
            end if;
        end loop;

    end process issue_process;

    -- sim_process:process(clock)
    -- variable out_line :line;
    -- variable cycle_count: integer:= 0;
    -- file output_file : text open write_mode is "../../sim/reservation_station.txt";
    -- begin
    --     if falling_edge(clock) then
    --         cycle_count := cycle_count + 1; 
    --         writeline(output_file, out_line);
    --         write(output_file, "Cycle : "); 
    --         write(output_file, integer'image(cycle_count));  
    --         writeline(output_file, out_line);
    --         write(output_file, "RS   |  PC  | op_code | destination_tag | operand1_value | operand1_value_valid | operand2_value | operand2_value_valid | compliment | C | Z | ready | valid | busy "); 
    --         writeline(output_file, out_line);
    --         for i in 0 to rs_size - 1 loop
    --             write(output_file, integer'image(i));
    --             write(output_file, "    |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(reservation_station(i).pc))));
    --             write(output_file, "   |  "); 
    --             write(output_file, to_string_std_logic_vector(reservation_station(i).op_code));
    --             write(output_file, "   |       "); 
    --             write(output_file, integer'image(to_integer(unsigned(reservation_station(i).destination_tag))));
    --             write(output_file, "         |       "); 
    --             write(output_file, integer'image(to_integer(unsigned(reservation_station(i).operand_1_value))));
    --             write(output_file, "        |       "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).operand_1_value_valid));
    --             write(output_file, "              |       "); 
    --             write(output_file, integer'image(to_integer(unsigned(reservation_station(i).operand_2_value))));
    --             write(output_file, "        |       "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).operand_2_value_valid));
    --             write(output_file, "              |       "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).compliment));    
    --             write(output_file, "    | "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).C));
    --             write(output_file, " | "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).Z));
    --             write(output_file, " |   "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).ready));
    --             write(output_file, "   |  "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).valid));
    --             write(output_file, "    |  "); 
    --             write(output_file, to_string_std_logic(reservation_station(i).busy));
    --             writeline(output_file, out_line);
    --         end loop;
    --         write(out_line, LF); 
    --     end if;
    -- end process sim_process;
end architecture behavorial;