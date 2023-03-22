library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;
-- instr_memory Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran 
University
entity instr_memory is
 port( DIN : in sm16_data;
 ADDR : in sm16_address;
 DOUT : out sm16_data;
 WE : in std_logic);
end instr_memory;
-- instr_memory Architecture Description
architecture behavioral of instr_memory is
 subtype ramword is bit_vector(15 downto 0);
 type rammemory is array (0 to 1023) of ramword;
 ----------------------------------------------
 ----------------------------------------------
 ---- This is where you put your program -----
 ----------------------------------------------
 ----------------------------------------------
 -- add 000000 addi 000100
 -- sub 000001 seti 000101
 -- load 000010 jump 000110
 -- store 000011 jz 000111
 signal ram : rammemory := ("0000100000000000", --load the first value (0)
 "0000000000000001", --add the increment (2)
 "0000000000000101", --add to get the new sum
 "0000110000000101", --store the new sum
 "0001010000000000", --seti zero
 "0000100000000010", --load n value
 "0000010000000100", --subtract counter(1) from n
 "0000110000000010", --store new n value
 "0001010000000000", --seti zero
 "0000100000000101", --load sum
 "0000000000000011", --add sum to overall
 "0000110000000011", --store the overall sum
 "0001010000000000", --seti zero
 "0001110000000000", --jz n (jump back until n=0)
 others => "0000000000000000");
begin
 DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
 
 ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';
end behavioral;
