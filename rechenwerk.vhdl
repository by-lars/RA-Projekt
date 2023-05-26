library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rechenwerk is port (
  pc, lit, jumplit : in std_logic_vector(31 downto 0);
  addr_of_rs1, addr_of_rs2, addr_of_rd : in std_logic_vector(4 downto 0);
  aluop : in std_logic_vector(4 downto 0);
  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : in std_logic; -- ansteuersignale der MPX in Op-Fetch
  cpuclk : in std_logic;

  jumpdest : out std_logic_vector(31 downto 0); -- werden zurueckgefuehrt an Instruction fetch
  do_jump : out std_logic;

  debug_rd : out std_logic_vector(31 downto 0);  -- only for testbenches
  debug_addr_of_rd : out std_logic_vector(4 downto 0)
); end entity;

architecture behav of rechenwerk is

  component alu is port (
    op1, op2 : in std_logic_vector(31 downto 0);
    aluout : out std_logic_vector(31 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    do_jump : out std_logic
  ); end component;
  signal op1, op2 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal aluout : std_logic_vector(31 downto 0) := x"ffffffff";

  component cpu_registers is port(
    addr_of_rs1, addr_of_rs2 : in std_logic_vector(4 downto 0);
    rs1, rs2 : out std_logic_vector(31 downto 0);
    addr_of_rd : in std_logic_vector(4 downto 0);
    rd : in std_logic_vector(31 downto 0);
    clk : in std_logic
  ); end component;
  signal rs1, rs2 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal rd : std_logic_vector(31 downto 0) := x"ffffffff";

  component d_reg is generic(
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  component mpx is port (
    a, b : in std_logic_vector(31 downto 0);
    sel : in std_logic;
    mpx_out : out std_logic_vector(31 downto 0)
  ); end component;


  signal pipeline_mpx_to_op1 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal pipeline_mpx_to_op2 : std_logic_vector(31 downto 0) := x"ffffffff";
  signal pipeline_mpx_to_adder : std_logic_vector(31 downto 0) := x"ffffffff";

  signal pipeline_jumpdest_a : std_logic_vector(31 downto 0) := x"ffffffff";
  signal pipeline_jumpdest_b : std_logic_vector(31 downto 0) := x"ffffffff";

  signal pipeline_aluop : std_logic_vector(4 downto 0) := "11111"; 

  signal pipeline_addr_rd_1 : std_logic_vector(4 downto 0) := "11111"; 
  signal pipeline_addr_rd_2 : std_logic_vector(4 downto 0) := "11111"; 


begin
  -- Multiplexer
  pipeline_mpx_to_op1 <= rs1 when sel_pc_not_rs1 = '0' else pc;
  pipeline_mpx_to_op2 <= rs2 when sel_lit_not_rs2 = '0' else lit;
  pipeline_mpx_to_adder <= rs1 when is_jalr = '1' else pc;
  
  -- Pipeline Registers
  dreg_mpx_to_op1: d_reg generic map(32) port map(d_in => pipeline_mpx_to_op1, clk => cpuclk, d_out => op1);
  dreg_mpx_to_op2: d_reg generic map(32) port map(d_in => pipeline_mpx_to_op2, clk => cpuclk, d_out => op2);
  dreg_mpx_jumplit: d_reg generic map(32) port map(d_in => pipeline_mpx_to_adder, clk => cpuclk, d_out => pipeline_jumpdest_b);
  dreg_jumplit: d_reg generic map(32) port map(d_in => jumplit, clk => cpuclk, d_out => pipeline_jumpdest_a);

  dreg_aluop: d_reg generic map(5) port map(d_in => aluop, clk => cpuclk, d_out => pipeline_aluop);
  dreg_aluout: d_reg generic map(32) port map(d_in => aluout, clk => cpuclk, d_out => rd);

  dreg_addr_rd_1: d_reg generic map(5) port map(d_in => addr_of_rd, clk => cpuclk, d_out => pipeline_addr_rd_1);
  dreg_addr_rd_2: d_reg generic map(5) port map(d_in => pipeline_addr_rd_1, clk => cpuclk, d_out => pipeline_addr_rd_2);

  -- Register
  regs: cpu_registers port map(addr_of_rs1 => addr_of_rs1, addr_of_rs2 => addr_of_rs2, rs1 => rs1, rs2 => rs2, addr_of_rd => pipeline_addr_rd_2, rd => rd, clk => cpuclk);

  -- Alu
  alu_map: alu port map(op1 => op1, op2 => op2, aluout => aluout, aluop => pipeline_aluop, do_jump => do_jump);

  jumpdest <= std_logic_vector(unsigned(pipeline_jumpdest_a) + unsigned(pipeline_jumpdest_b));

  debug_rd <= rd;
  debug_addr_of_rd <= pipeline_addr_rd_2;

end architecture;
