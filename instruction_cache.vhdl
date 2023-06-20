library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_cache is port(
  pc_value : in std_logic_vector(31 downto 0);
  ir_2_cpu : out std_logic_vector(31 downto 0);
  cpuclk : in std_logic;
  cachehit : out std_logic  -- heisst in der cpu dann "mem_ready"
); end entity;


architecture behav of instruction_cache is
  function to_std_logic(L: BOOLEAN) return std_ulogic is begin
    if L then return('1'); else return('0'); end if;
  end function to_std_logic;

  type reg_array_type is array (0 to 2047) of std_logic_vector(52 downto 0);
  signal cache : reg_array_type := ( others => (others=>'0') ); -- reg. zero needs to be 0

  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi	x1,x1,1
    x"ffdfffef",   --   jal	x31,loop
  others=>x"00000000");

  component cache_control is port(
    write : out std_logic;
    cachehit : in std_logic;
    clk : in std_logic
  ); end component;
  
  signal s_cachehit : std_logic := '0';
  signal s_write : std_logic := '0';

begin
  ir_2_cpu <= cache(to_integer(unsigned(pc_value(11 downto 2))))(31 downto 0);
  s_cachehit <= to_std_logic(pc_value(31 downto 12) = cache(to_integer(unsigned(pc_value(11 downto 2))))(52 downto 33)) 
      and cache(to_integer(unsigned(pc_value(11 downto 2))))(32); 

  cachehit <= s_cachehit;
  
  cc: cache_control port map(s_write, s_cachehit, cpuclk);

  process(cpuclk) begin
    if(falling_edge(cpuclk)) then
      if(s_write = '1') then
        cache(to_integer(unsigned(pc_value(11 downto 2))))(31 downto 0) <= rom(to_integer(unsigned(pc_value(31 downto 2))));
        cache(to_integer(unsigned(pc_value(11 downto 2))))(32) <= '1';
        cache(to_integer(unsigned(pc_value(11 downto 2))))(52 downto 33) <= pc_value(31 downto 12);
      end if;
    end if;
  end process;

end architecture;
