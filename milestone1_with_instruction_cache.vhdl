library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1 is port (
  cpuclk : in std_logic;

  debug_rd : out std_logic_vector(31 downto 0);
  debug_addr_of_rd : out std_logic_vector(4 downto 0);
  debug_mem_ready : out std_logic
); end entity;


architecture behav of milestone1 is

  component instruction_fetch_without_rom is port (
    jumpdest : in std_logic_vector(31 downto 0);
    do_jump : in std_logic;
    cpuclk : in std_logic;
    pc, ir : out std_logic_vector(31 downto 0);
    pc_to_memory : out std_logic_vector(31 downto 0);
    ir_from_memory : in std_logic_vector(31 downto 0);
    mem_ready : in std_logic
  ) ; end component;

  signal pc, ir, pc_to_memory : std_logic_vector(31 downto 0);


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


  component instruction_cache is port(
    pc_value : in std_logic_vector(31 downto 0);
    ir_2_cpu : out std_logic_vector(31 downto 0);
    cpuclk : in std_logic;
    cachehit : out std_logic
  ); end component;
  signal ir_2_cpu : std_logic_vector(31 downto 0);
  signal cachehit : std_logic;

begin
  my_i_f: instruction_fetch_without_rom  port map(jumpdest, do_jump, cpuclk, pc, ir, pc_to_memory, ir_2_cpu, cachehit);
  my_i_d: instruction_decode port map(ir, pc,
                                      pc2, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd,
                                      aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk);
  my_rewe: rechenwerk        port map(pc2, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd,
                                      aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk,
                                      jumpdest, do_jump, debug_rd, debug_addr_of_rd);
  my_i_cache: instruction_cache port map(pc_to_memory, ir_2_cpu, cpuclk, cachehit);

  debug_mem_ready <= cachehit;
end architecture;
