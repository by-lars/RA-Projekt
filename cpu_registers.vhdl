library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_registers is port(
  addr_of_rs1, addr_of_rs2 : in std_logic_vector(4 downto 0);
  rs1, rs2 : out std_logic_vector(31 downto 0);
  addr_of_rd : in std_logic_vector(4 downto 0);
  rd : in std_logic_vector(31 downto 0);
  clk : in std_logic
); end entity;

architecture behav of cpu_registers is

  type reg_array_type is array (0 to 31) of std_logic_vector(31 downto 0);
  signal regs : reg_array_type := ( others => (others=>'0') ); -- reg. zero needs to be 0
begin
  rs1 <= regs(to_integer(unsigned(addr_of_rs1)));
  rs2 <= regs(to_integer(unsigned(addr_of_rs2)));

  process(clk) begin
    if(falling_edge(clk)) then
      if(addr_of_rd /= "00000") then
        regs(to_integer(unsigned(addr_of_rd))) <= rd;
      end if;
    end if;
  end process;
end architecture;
