library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rechenwerk_tb is end entity;

architecture behav of rechenwerk_tb is
  component rechenwerk is port (
    pc, lit, jumplit : in std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : in std_logic_vector(4 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : in std_logic;
    cpuclk : in std_logic;

    jumpdest : out std_logic_vector(31 downto 0);
    do_jump : out std_logic;

    debug_rd : out std_logic_vector(31 downto 0);
    debug_addr_of_rd : out std_logic_vector(4 downto 0)
  ); end component;

  signal pc, lit, jumplit : std_logic_vector(31 downto 0);
  signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0) := "00000";
  signal aluop : std_logic_vector(4 downto 0);
  signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic := '0';
  signal cpuclk : std_logic := '0';

  signal do_jump : std_logic;
  signal jumpdest : std_logic_vector(31 downto 0);

  signal debug_rd : std_logic_vector(31 downto 0);
  signal debug_addr_of_rd : std_logic_vector( 4 downto 0);
begin
  werk: rechenwerk port map(pc, lit, jumplit, addr_of_rs1, addr_of_rs2, addr_of_rd, aluop, sel_pc_not_rs1, sel_lit_not_rs2, is_jalr, cpuclk, jumpdest, do_jump, debug_rd, debug_addr_of_rd);
  process begin
    -- Befehlsablauf: Ergebnisse benötigen 2 Taktzyklen
    -- 0x00 addi 1 x0 x1 
    -- 0x01 addi 3 x0 x3
    -- 0x02 add  x4 x1 x3
    -- 0x03 jal 0x06 x31 => jal 12 x31
    -- 0x06 jalr 12 x4 x31

    -- addi(1) 1/2
    pc <= x"00000000";
    aluop <= "00000";
    lit <= x"00000001";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00000";
    addr_of_rs2 <= "00000";
    addr_of_rd <= "00001";

    sel_pc_not_rs1 <= '0';
    sel_lit_not_rs2 <= '1';
    is_jalr <= '0';

    cpuclk <= '1';
    wait for 1 fs;

    cpuclk <= '0';
    wait for 1 fs;

    -- addi(3) 1/2, addi(1) 2/2
    pc <= x"00000001";
    aluop <= "00000";
    lit <= x"00000003";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00000";
    addr_of_rs2 <= "00000";
    addr_of_rd <= "00011";

    cpuclk <= '1';
    wait for 1 fs;
    cpuclk <= '0';
    wait for 1 fs;

    -- checke addi(1)
    assert do_jump = '0' report "jumped on addi operation" severity failure;
    assert debug_addr_of_rd = "00001" report "incorrect rd address on addi 1 x0 x1" severity failure;
    assert debug_rd = x"00000001" report "incorrect value for rd" severity failure;

    -- add 1/2, addi(3) 2/2
    pc <= x"00000002";
    aluop <= "00000";
    lit <= x"00000000";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00001";
    addr_of_rs2 <= "00011";
    addr_of_rd <= "11111";

    sel_pc_not_rs1 <= '0';
    sel_lit_not_rs2 <= '0';
    is_jalr <= '0';

    cpuclk <= '1';
    wait for 1 fs;

    cpuclk <= '0';
    wait for 1 fs;

    -- checke addi(3)
    assert do_jump = '0' report "jumped on addi operation" severity failure;
    assert debug_addr_of_rd = "00011" report "incorrect rd address on addi 1 x0 x1" severity failure;
    assert debug_rd = x"00000003" report "incorrect value for rd" severity failure;

    -- jal 1/2, add 2/2
    pc <= x"00000003";
    aluop <= "11011";
    lit <= x"00000001";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00000";
    addr_of_rs2 <= "00000";
    addr_of_rd <= "11111";

    sel_pc_not_rs1 <= '1';
    sel_lit_not_rs2 <= '1';
    is_jalr <= '0';

    cpuclk <= '1';
    wait for 1 fs;

    cpuclk <= '0';
    wait for 1 fs;

    -- checke add

    -- jalr 1/2 , jal 2/2

    -- checke jal

    --  jalr 2/2 (durchtakten)

    -- checke jalr

    -- teste auf datenhazard

    -- addi x1, x3, 3
    pc <= x"00000004";
    aluop <= "00000";
    lit <= x"00000003";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00011";
    addr_of_rs2 <= "00000";
    addr_of_rd <= "00001";

    sel_pc_not_rs1 <= '0';
    sel_lit_not_rs2 <= '1';
    is_jalr <= '0';

    cpuclk <= '1';
    wait for 1 fs;
    
    cpuclk <= '0';
    wait for 1 fs;
    
    -- add x4, x3, x1
    pc <= x"00000005";
    aluop <= "00000";
    lit <= x"00000000";
    jumplit <= x"00000000";
    addr_of_rs1 <= "00001";
    addr_of_rs2 <= "00011";
    addr_of_rd <= "00100";

    sel_pc_not_rs1 <= '0';
    sel_lit_not_rs2 <= '0';
    is_jalr <= '0';

    cpuclk <= '1';
    wait for 1 fs;
    cpuclk <= '0';
    wait for 1 fs;
    -- add ist in execute

    cpuclk <= '1';
    wait for 1 fs;
    cpuclk <= '0';
    wait for 1 fs;
    -- add ist in store

    assert do_jump = '0' report "jumped on addi operation" severity failure;
    assert debug_addr_of_rd = "00100" report "incorrect rd address on addi 1 x0 x1" severity failure;
    assert debug_rd = x"00000009" report "incorrect value for rd" severity failure;

    report "rechenwerk_tb ended - reaching here means TEST OK";
    wait;
  end process;
end architecture;
