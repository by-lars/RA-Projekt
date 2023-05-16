library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_reg is generic(
  width : natural := 32
); port(
  d_in : in std_logic_vector((width-1) downto 0);
  clk : in std_logic;
  d_out : out std_logic_vector((width-1) downto 0)
); end entity;

architecture behav of d_reg is
begin
process(clk) begin
  if(falling_edge(clk)) then
    d_out <= d_in;
  end if;
end process;


  
end architecture;
