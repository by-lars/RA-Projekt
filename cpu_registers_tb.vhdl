library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_registers_tb is end cpu_registers_tb;

architecture behav of cpu_registers_tb is

  component cpu_registers is port(
    addr_of_rs1, addr_of_rs2 : in std_logic_vector(4 downto 0);
    rs1, rs2 : out std_logic_vector(31 downto 0);
    addr_of_rd : in std_logic_vector(4 downto 0);
    rd : in std_logic_vector(31 downto 0);
    clk : in std_logic
  ); end component;
  signal addr_of_rs1, addr_of_rs2 : std_logic_vector(4 downto 0) := "00000"; -- discard warnings by presetting
  signal rs1, rs2 : std_logic_vector(31 downto 0);
  signal addr_of_rd : std_logic_vector(4 downto 0) := "00000";
  signal rd : std_logic_vector(31 downto 0);
  signal clk : std_logic := '0';

begin
  my_cpu_registers : cpu_registers port map (addr_of_rs1, addr_of_rs2, rs1, rs2, addr_of_rd, rd, clk);

  process begin
    addr_of_rs1 <= "00000";
    addr_of_rs2 <= "00001";
    wait for 1 fs;
   
    -- Check x0
    clk <= '1';
    wait for 1 fs;

    addr_of_rd <= "00000";
    rd <= (rd'high downto 0 => '1');
    
    clk <= '0';
    wait for 1 fs;
    assert rs1 = (rd'high downto 0 => '0') report "Register x0 was illegaly writte to" severity failure;

    -- Check write and read
    clk <= '1';
    wait for 1 fs;

    addr_of_rd <= "00001";
    rd <= (rd'high downto 0 => '1');
    wait for 1 fs;
    
    clk <= '0';
    wait for 1 fs;
    assert rs2 = (rs2'high downto 0 => '1') report "Read Failed" severity failure;
    wait for 1 fs;
    
    assert rs2 = (rs2'high downto 0 => '1') report "Read Failed" severity failure;


    -- Check write, then read
    clk <= '1';
    wait for 1 fs;

    addr_of_rd <= "00011";
    rd <= (rd'high downto 0 => '1');
    wait for 1 fs;
  
    clk <= '0';
    wait for 1 fs;

    addr_of_rd <= "00000";
    addr_of_rs1 <= "00011";
    wait for 1 fs;

    clk <= '1';
    wait for 1 fs;

    clk <= '0';
    wait for 1 fs;

    assert rs1 = (rs1'high downto 0 => '1') report "Write Failed" severity failure;



    -- Check for false writes on high_edge
    clk <= '1';
    wait for 1 fs;

    addr_of_rd <= "00001";
    rd <= (rd'high downto 0 => '0');
    wait for 1 fs;

    addr_of_rs1 <= "00001";
    wait for 1 fs;

    assert rs1 /= (rs1'high downto 0 => '0') report "Falsy written on high edge" severity failure;
    

    report "cpu_registers_tb finished - test OK";
    wait;
  end process;
end architecture;
