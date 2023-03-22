library ieee;
use ieee.std_logic_1164.all;
use work.sm16_types.all;
-- control Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran 
University
entity control is
 port( CLK : in std_logic;
 RESET : in std_logic;
 START : in std_logic;
 
 WE : out std_logic;
 ALU_OP : out std_logic_vector(1 downto 0);
 B_INV : out std_logic;
 CIN : out std_logic;
 A_SEL : out std_logic;
 B_SEL : out std_logic;
 PC_SEL : out std_logic;
 EN_A : out std_logic;
 EN_PC : out std_logic;
 
 Z_FLAG : in std_logic;
 N_FLAG : in std_logic;
 INSTR_OP : in sm16_opcode);
end control;
-- control Architecture Description
architecture behavorial of control is
 -- control signal values
 -- alu operations
 constant alu_nop : std_logic_vector(1 downto 0) := "00";
 constant alu_and : std_logic_vector(1 downto 0) := "00";
 constant alu_or : std_logic_vector(1 downto 0) := "01";
 constant alu_add : std_logic_vector(1 downto 0) := "10";
 
 -- a select control
 constant a_0 : std_logic := '0';
 constant a_a : std_logic := '1';
 
 -- b select control
 constant b_mem : std_logic := '0';
 constant b_imm : std_logic := '1';
 
 -- pc select
 constant from_plus1 : std_logic := '0';
 constant from_alu : std_logic := '1';
 
 -- register load control
 constant hold : std_logic := '0';
 constant load : std_logic := '1';
 
 -- data memory write enable control
 constant rd : std_logic := '0';
 constant wr : std_logic := '1';
 
 -- b invert control
 constant pos : std_logic := '0';
 constant inv : std_logic := '1';
 
 -- op codes
 constant op_add : sm16_opcode := "000000";
 constant op_sub : sm16_opcode := "000001"; 
 constant op_load : sm16_opcode := "000010";
 constant op_store : sm16_opcode := "000011";
 constant op_addi : sm16_opcode := "000100";
 constant op_seti : sm16_opcode := "000101";
 constant op_jump : sm16_opcode := "000110";
 constant op_jz : sm16_opcode := "000111";
 
 -- definitions of the states the control can be in
 type states is (stopped, running); -- single cycle now, so only one running state
 signal state, next_state : states := stopped;
 
 -- internal write enable, ungated by the clock
 signal pre_we : std_logic;
 
begin
 
 -- write enable is gated when the clock is low
 WE <= pre_we and (not CLK);
 
 -- process to state register
 state_reg: process( CLK, RESET )
 begin
 if( RESET = '1' ) then
 state <= stopped;
 elsif( rising_edge(CLK) ) then
 state <= next_state;
 end if;
 end process state_reg;
 
 -- ############################################ --
 
 -- process to define next state transitions and output signals
 next_state_and_output: process( state, START, INSTR_OP, Z_FLAG, N_FLAG )
 begin
 case state is
 -- Stopped is the stopped state; wait for start
 when stopped =>
 
 if( START /= '1' ) then
 -- issue nop
 EN_A <= hold; EN_PC <= hold;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_nop;
 A_SEL <= a_0; B_SEL <= b_mem;
 
 next_state <= stopped;
 else
 EN_A <= hold; EN_PC <= hold;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_and;
 A_SEL <= a_0; B_SEL <= b_mem;
 
 next_state <= running; -- go to fetch state
 end if;
 
 -- In running state, each instruciton has its own control signals
 when running =>
 
 if instr_op = op_add then
 -- A <- A + Mem
 EN_A <= load; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add;
 A_SEL <= a_a; B_SEL <= b_mem;
 
 next_state <= running;
 
 elsif instr_op = op_sub then
 -- A <- A - Mem
 EN_A <= load; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= inv; CIN <= '1'; ALU_OP <= alu_add;
 A_SEL <= a_a; B_SEL <= b_mem;
 
 next_state <= running;
 
 elsif instr_op = op_seti then
 -- A <- 0 + Immediate
 EN_A <= load; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add;
 A_SEL <= a_0; B_SEL <= b_imm;
 
 next_state <= running;
 
 elsif instr_op = op_jump then
 -- PC <- 0 + Immediate
 EN_A <= hold; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_alu;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add;
 A_SEL <= a_0; B_SEL <= b_imm;
 
 next_state <= running;
 
 elsif instr_op = op_jz then
 -- Because the zero flag comes directly from the A register through the
 -- zero checker component (not from the ALU), the control signals do not
 -- affect the outcome of the check. Therefore, both conditions of the
 -- jump can evaluated in the one cycle for the instruction.
 
 if z_flag = '1' then
 -- successful jump
 -- PC <- 0 + Immediate
 EN_A <= hold; EN_PC <= load; 
 pre_we <= rd; PC_SEL <= from_alu; 
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add; 
 A_SEL <= a_0; B_SEL <= b_imm; 
 
 next_state <= running;
 
 else
 -- unsuccessful jump
 -- PC <- PC + 1 (as normal)
 EN_A <= hold; EN_PC <= load; 
 pre_we <= rd; PC_SEL <= from_alu; 
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_or; 
 A_SEL <= a_0; B_SEL <= b_mem; 
 
 next_state <= running;
 
 end if;
 
 --edit instr mem and data mem, change
 
 
 elsif instr_op = op_load then 
 EN_A <= load; EN_PC <= load; 
 pre_we <= rd; PC_SEL <= from_plus1; 
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add; 
 A_SEL <= a_a; B_SEL <= b_mem; 
 
 
 elsif instr_op = op_store then 
 EN_A <= hold; EN_PC <= load; 
 pre_we <= wr; PC_SEL <= from_plus1; 
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_and; 
 A_SEL <= a_a; B_SEL <= b_mem; 
 
 
 elsif instr_op = op_addi then 
 EN_A <= load; EN_PC <= load; 
 pre_we <= rd; PC_SEL <= from_plus1; 
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_add; 
 A_SEL <= a_a; B_SEL <= b_imm; 
 
 
 
 
 else -- unknown opcode
 -- should never get here, but if it does, set PC<=0 and stop
 EN_A <= hold; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_and;
 A_SEL <= a_0; B_SEL <= b_mem;
 
 next_state <= stopped;
 
 end if;
 
 when others => -- unknown state
 -- should never get here, but if it does, set PC<=0 and stop
 EN_A <= hold; EN_PC <= load;
 pre_we <= rd; PC_SEL <= from_plus1;
 B_INV <= pos; CIN <= '0'; ALU_OP <= alu_and;
 A_SEL <= a_0; B_SEL <= b_mem;
 
 next_state <= stopped;
 end case;
 end process next_state_and_output;
 
end behavorial;