library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1 is port (
  cpuclk : in std_logic;

  debug_rd : out std_logic_vector(31 downto 0);
  debug_addr_of_rd : out std_logic_vector(4 downto 0)
); end entity;


architecture behav of milestone1 is

  component instruction_fetch is port (
    jumpdest : in std_logic_vector(31 downto 0);
    do_jump : in std_logic;
    cpuclk : in std_logic;
    pc, ir : out std_logic_vector(31 downto 0)
  ); end component;

  signal pc, ir : std_logic_vector(31 downto 0);


  component instruction_decode is port (
    instruction, pc_in : in std_logic_vector(31 downto 0);
    pc, lit, jumplit : out std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
    aluop : out std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
    cpuclk : in std_logic
  ); end component;

  signal pc2, lit, jumplit : std_logic_vector(31 downto 0);
  signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0);
  signal aluop : std_logic_vector(4 downto 0);
  signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic;


  component rechenwerk is port (
    pc, lit, jumplit : in std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : in std_logic_vector(4 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : in std_logic; -- ansteuersignale der MPX in Op-Fetch
    cpuclk : in std_logic;

    jumpdest : out std_logic_vector(31 downto 0); -- werden zurueckgefuehrt an Instruction fetch
    do_jump : out std_logic;

    debug_rd : out std_logic_vector(31 downto 0);  -- only for testbenches
    debug_addr_of_rd : out std_logic_vector(4 downto 0)
  ); end component;

  signal jumpdest : std_logic_vector(31 downto 0);
  signal do_jump : std_logic;

begin
  my_i_f: instruction_fetch  port map(jumpdest, do_jump, cpuclk, pc, ir);
  my_i_d: instruction_decode port map(ir, pc,
                                      pc2, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd,
                                      aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk);
  my_rewe: rechenwerk        port map(pc2, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd,
                                      aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk,
                                      jumpdest, do_jump, debug_rd, debug_addr_of_rd);
end architecture;
