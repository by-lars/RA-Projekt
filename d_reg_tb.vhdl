library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_reg_tb is end d_reg_tb;

architecture behav of d_reg_tb is

  component d_reg is generic(
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component;

  signal d_in : std_logic_vector(7 downto 0);
  signal d_out : std_logic_vector(7 downto 0) := x"01";
  signal clk : std_logic := '1';
  
begin
  pipeline_register8: d_reg generic map(width => 8) port map (d_in, clk, d_out);
  process begin
  
    for i in 1 to 20 loop
      clk <= '1';
      wait for 1 fs;

      d_in <= std_logic_vector(to_unsigned(i, d_in'length));
      wait for 1 fs;

      clk <= '0';
      wait for 1 fs;

      assert d_out = std_logic_vector(to_unsigned(i, d_out'length)) report "Write Failed" severity failure;
    end loop;

    clk <= '1';
    wait for 1 fs;

    d_in <= x"09";
    clk <= '0';
    wait for 1 fs;
    assert d_out = x"09" report "Write Failed" severity failure;    

    d_in <= x"06";
    clk <= '0';
    wait for 1 fs;
    assert d_out = x"09" report "Illegal write" severity failure;    

    d_in <= x"00";
    clk <= '1';
    wait for 1 fs;
    assert d_out = x"09" report "Write did not persist" severity failure;    

    d_in <= x"08";
    clk <= '1';
    wait for 1 fs;
    assert d_out = x"09" report "Write did not persist" severity failure;    

    report "d_reg_tb finished - test OK";
    wait;
  end process;
end architecture;
