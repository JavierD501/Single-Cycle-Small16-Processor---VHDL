library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;
-- datapath Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran 
University
entity datapath is
 port( CLK : in std_logic;
 RESET : in std_logic;
 
 -- I/O with Data Memory
 DATA_IN : out sm16_data;
 DATA_OUT : in sm16_data;
 DATA_ADDR : out sm16_address;
 
 -- I/O with Instruction Memory
 INSTR_OUT : in sm16_data;
 INSTR_ADDR : out sm16_address;
 
 -- OpCode sent to the Control
 INSTR_OP : out sm16_opcode;
 
 -- Control Signals to the ALU
 ALU_OP : in std_logic_vector(1 downto 0);
 B_INV : in std_logic;
 CIN : in std_logic;
 
 -- Control Signals from the Accumulator
 ZERO_FLAG : out std_logic;
 NEG_FLAG : out std_logic;
 
 -- ALU Multiplexer Select Signals
 A_SEL : in std_logic;
 B_SEL : in std_logic;
 PC_SEL : in std_logic;
 
 -- Enable Signals for all registers
 EN_A : in std_logic;
 EN_PC : in std_logic);
end datapath;
-- datapath Architecture Description
architecture structural of datapath is
 
 -- declare all components and their ports
 component reg is
 generic( DWIDTH : integer := 8 );
 port( CLK : in std_logic;
 RST : in std_logic;
 CE : in std_logic;
 
 D : in std_logic_vector( DWIDTH-1 downto 0 );
 Q : out std_logic_vector( DWIDTH-1 downto 0 ) );
 end component;
 
 component alu is
 port( A : in sm16_data;
 B : in sm16_data;
 OP : in std_logic_vector(1 downto 0);
 D : out sm16_data;
 CIN : in std_logic;
 B_INV : in std_logic);
 end component;
 
 component adder is
 port( A : in sm16_address;
 B : in sm16_address;
 D : out sm16_address);
 end component;
 
 component mux2 is
 generic( DWIDTH : integer := 16 );
 port( IN0 : in std_logic_vector( DWIDTH-1 downto 0 );
 IN1 : in std_logic_vector( DWIDTH-1 downto 0 );
 SEL : in std_logic;
 DOUT : out std_logic_vector( DWIDTH-1 downto 0 ) );
 end component;
 
 component zero_extend is
 port( A : in sm16_address;
 Z : out sm16_data);
 end component;
 
 component zero_checker is
 port( A : in sm16_data;
 Z : out std_logic);
 end component;
 
 signal zero_16 : sm16_data := "0000000000000000";
 signal alu_a, alu_b, alu_out : sm16_data;
 signal pc_out, pc_in : sm16_address;
 signal a_out, immediate_zero_extend_out : sm16_data;
 
 signal adder_out : sm16_address; 
 
begin
 
 TheAlu: alu port map (
 A => alu_a,
 B => alu_b,
 OP => ALU_OP,
 D => alu_out,
 CIN => CIN,
 B_INV => B_INV
 );
 
 PCadder: adder port map (
 A => pc_out, 
 B => "0000000001", 
 D => adder_out(9 downto 0)
 );
 
 Amux: mux2 generic map ( DWIDTH => 16) 
 port map (
 IN0 => zero_16, -- 00 
 IN1 => a_out, -- 01 
 SEL => A_SEL,
 DOUT => alu_a
 );
 
 Bmux: mux2 generic map ( DWIDTH => 16) 
 port map (
 IN0 => DATA_OUT, -- 00 
 IN1 => immediate_zero_extend_out, -- 01 
 SEL => B_SEL,
 DOUT => alu_b
 );
 PCmux: mux2 generic map ( DWIDTH => 10) 
 port map (
 IN0 => adder_out(9 downto 0), -- 00 
 IN1 => alu_out(9 downto 0), -- 01 
 SEL => PC_SEL,
 DOUT => pc_in
 );
 
 ProgramCounter: reg generic map ( DWIDTH => 10) 
 port map (
 CLK => CLK,
 RST => RESET,
 CE => EN_PC,
 D => pc_in,
 Q => pc_out
 );
 
 Accumulator: reg generic map ( DWIDTH => 16) 
 port map (
 CLK => CLK,
 RST => RESET,
 CE => EN_A,
 D => alu_out,
 Q => a_out
 );
 
 ImmediateZeroExt: zero_extend port map (
 A => INSTR_OUT(9 downto 0),
 Z => immediate_zero_extend_out
 );
 
 ZeroCheck: zero_checker port map (
 A => a_out,
 Z => ZERO_FLAG
 );
 
 NEG_FLAG <= alu_out(15);
 
 DATA_IN <= a_out; 
 DATA_ADDR <= INSTR_OUT(9 downto 0); 
 
 INSTR_OP <= INSTR_OUT(15 downto 10); 
 INSTR_ADDR <= pc_out(9 downto 0); 
 
end structural;