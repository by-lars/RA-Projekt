library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decode_tb is end entity;

architecture a of instruction_decode_tb is

  -- die folgende funktion mag nuetzlich sein; wenn man sie
  -- nicht braucht: loeschen oder auskommentieren
  function to_string(arg : std_logic_vector) return string is
    variable result : string (1 to arg'length);
    variable v : std_logic_vector (result'range) := arg;
  begin
    for i in result'range loop
      case v(i) is
        when 'U' => result(i) := 'U';
        when 'X' => result(i) := 'X';
        when '0' => result(i) := '0';
        when '1' => result(i) := '1';
        when 'Z' => result(i) := 'Z';
        when 'W' => result(i) := 'W';
        when 'L' => result(i) := 'L';
        when 'H' => result(i) := 'H';
        when '-' => result(i) := '-';
      end case;
    end loop;
    return result;
  end;

  component instruction_decode is port (
    instruction, pc_in : in std_logic_vector(31 downto 0);
    pc, lit, jumplit : out std_logic_vector(31 downto 0);
    addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
    aluop : out std_logic_vector(4 downto 0);
    sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
    cpuclk : in std_logic
  ); end component;
  signal instruction, pc_in : std_logic_vector(31 downto 0);
  signal pc, lit, jumplit : std_logic_vector(31 downto 0);
  signal addr_of_rs1, addr_of_rs2, addr_of_rd : std_logic_vector(4 downto 0);
  signal aluop : std_logic_vector(4 downto 0);
  signal sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : std_logic;
  signal cpuclk : std_logic;

begin
  my_decode : instruction_decode port map(instruction, pc_in,
					  pc, lit, jumplit,
					  addr_of_rs1, addr_of_rs2, addr_of_rd,
					  aluop,
					  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr,
					  cpuclk);

  process begin
    cpuclk <= '0';
    wait for 1 fs;

    instruction <= (31 downto 7 => '1', others => '0');
    instruction(6 downto 0) <= "0110111";

    pc_in <= x"00000001";

    cpuclk <= '1';
    wait for 1 fs;

    cpuclk <= '0';
    wait for 1 fs;

    assert addr_of_rs1 = "00000" report "addr_of_rs1 not x0" severity failure; 
    assert addr_of_rd = "11111" report "addr_of_rd not x31" severity failure; 
    assert sel_pc_not_rs1 = '0' report "sel_pc_not_rs1 was not 0" severity failure; 
    assert sel_lit_not_rs2 = '1' report "sel_lit_not_rs2 was not 1" severity failure; 
    assert pc = x"00000001" report "pc wrong" severity failure; 
    assert lit = x"fffff000" report "lit is wrong" severity failure; 


    report "end of instruction_decode_tb -- reaching here is: test OK";
    wait;
  end process;
end architecture;
