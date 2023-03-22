library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.sm16_types.all;
-- alu Entity Description
-- From Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity alu is
 port(
 A: in sm16_data;
 B: in sm16_data;
 OP: in std_logic_vector(1 downto 0);
 D: out sm16_data;
 CIN,B_INV: in std_logic
 );
end alu;
-- alu Architecture Description
architecture rtl of alu is
 signal pre_D : sm16_data;
begin
 ArithProcess: process(A,B,CIN,B_INV,OP)
 variable operand1, operand2 : sm16_data;
 variable carry_ext : std_logic_vector(1 downto 0);
 constant zero : sm16_data := "0000000000000000";
 begin
 carry_ext := '0' & CIN; -- needed to make CIN positive
 operand1 := A;
 if B_INV = '0' then
operand2 := B;
 else
operand2 := not B; -- needed for subtract
 end if;
 case OP is
 when "00" =>
 pre_D <= operand1 and operand2; -- bitwise AND
 when "01" =>
 pre_D <= operand1 or operand2; -- bitwise OR
 when "10" =>
 pre_D <= operand1 + operand2 + carry_ext; -- add or subtract
 
 when "11" =>
 pre_D <= operand1(7 downto 0) * operand2(7 downto 0); --allows for multiplication
 
 when others =>
pre_D <= zero;
assert false
report "Illegal ALU operation" severity error;
 end case;
 end process ArithProcess; 
 D <= pre_D;
 
end rtl;