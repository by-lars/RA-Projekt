library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_cache_tb is end entity;

architecture behav of instruction_cache_tb is


	function to_string_logic(v : std_logic) return string is
		variable result : string (1 to 1);
	begin
		case v is
			when 'U' => result(1) := 'U';
			when 'X' => result(1) := 'X';
			when '0' => result(1) := '0';
			when '1' => result(1) := '1';
			when 'Z' => result(1) := 'Z';
			when 'W' => result(1) := 'W';
			when 'L' => result(1) := 'L';
			when 'H' => result(1) := 'H';
			when '-' => result(1) := '-';
		end case;
		
		return result;
	end function;

  component instruction_cache is port(
    pc_value : in std_logic_vector(31 downto 0);
    ir_2_cpu : out std_logic_vector(31 downto 0);
    cpuclk : in std_logic;
    cachehit : out std_logic
  ); end component;
  signal pc_value : std_logic_vector(31 downto 0) := x"00000000";
  signal ir_2_cpu : std_logic_vector(31 downto 0);
  signal cpuclk : std_logic := '0';
  signal cachehit : std_logic := '0';

  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi	x1,x1,1
    x"ffdfffef",   --   jal	x31,loop
  others=>x"00000000");

begin
  my_cache: instruction_cache port map(pc_value, ir_2_cpu, cpuclk, cachehit);

  process
  begin
    --report "cache test has no tests yet --- failure" severity failure;

    -- read from cache => cache miss and wait for 5 cycles
    wait for 1 fs;
    
    assert cachehit = '0' report "Result first read: Cache hit, Expected: Cache miss" severity failure;

    -- wait for 5 cycles
      loopy: for i in 4 downto 0 loop
          cpuclk <= '1'; wait for 1 fs;
          cpuclk <= '0'; wait for 1 fs;
      end loop loopy;

      assert cachehit = '1' report "Not a cache hit" severity failure;
      assert ir_2_cpu = rom(0) report "Value not found after 5 write cycles" severity failure;

    report "cache test end --- looks ok";
    wait;
  end process;
end architecture;
