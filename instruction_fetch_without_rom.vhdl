library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch_without_rom is port (
  jumpdest : in std_logic_vector(31 downto 0);
  do_jump : in std_logic;
  cpuclk : in std_logic;
  pc, ir : out std_logic_vector(31 downto 0);
  pc_to_memory : out std_logic_vector(31 downto 0);
  ir_from_memory : in std_logic_vector(31 downto 0);
  mem_ready : in std_logic
); end entity;


architecture behav of instruction_fetch_without_rom is
  component d_reg is generic(
    width : natural := 32
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal p_pc : std_logic_vector(31 downto 0) := x"00000000";
  signal p_p_pc : std_logic_vector(31 downto 0) := x"00000000";
  signal p_ir : std_logic_vector(31 downto 0) := x"00000013";
  
  signal pc_incr : std_logic_vector(31 downto 0) := x"00000000";

  signal counter : natural := 0;
begin
  pipeline_pc_out: d_reg generic map (32) port map (d_in => p_pc, clk => cpuclk, d_out => pc);
  pp_pipeline_pc: d_reg generic map (32) port map (d_in => p_p_pc, clk => cpuclk, d_out => p_pc);
  pipeline_ir_out: d_reg generic map (32) port map (d_in => p_ir, clk => cpuclk, d_out => ir);

  pc_incr <= std_logic_vector(unsigned(p_pc) + 4) when counter = 5 else p_pc; 
  p_p_pc <= jumpdest when do_jump = '1' else pc_incr; 
      
  p_ir <= ir_from_memory when counter = 5 else x"00000013";
  pc_to_memory <= p_pc;
  
  process(cpuclk) begin
    if(falling_edge(cpuclk)) then
      counter <= (counter + 1) mod 8;
    end if;
  end process;
end architecture;
