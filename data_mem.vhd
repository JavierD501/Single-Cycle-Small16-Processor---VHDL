library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;
-- data_memory Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran 
University
entity data_memory is
 port( DIN : in sm16_data;
 ADDR : in sm16_address;
 DOUT : out sm16_data;
 WE : in std_logic);
end data_memory;
-- data_memory Architecture Description
architecture behavioral of data_memory is
 subtype ramword is bit_vector(15 downto 0);
 type rammemory is array (0 to 1023) of ramword;
 ----------------------------------------------
 ----------------------------------------------
 ----- This is where you put your data -------
 ----------------------------------------------
 ----------------------------------------------
 signal ram : rammemory := ("0000000000000000", -- 0: array[0]=0 first value
 "0000000000000010", -- 1: array[1]=2 increment
 "0000000000000101", -- 2: array[2]=5 number of values in sequence
 "0000000000000000", -- 3: array[3]=0 sum of the sequence
 "0000000000000001", -- 4: array[4]=1 static 1
 "0000000000000000", -- 5: array[5]=0 individual sums
 others => "0000000000000000");
begin
 DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
 
 ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';
end behavioral;
