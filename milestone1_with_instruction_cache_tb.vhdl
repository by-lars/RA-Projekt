library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity milestone1_with_instruction_cache_tb is end entity;

architecture behav of milestone1_with_instruction_cache_tb is
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
  end function;

  component milestone1 is port (
    cpuclk : in std_logic;

    debug_rd : out std_logic_vector(31 downto 0);
    debug_addr_of_rd : out std_logic_vector(4 downto 0);
    debug_mem_ready : out std_logic
  ); end component;

  signal cpuclk : std_logic;
  signal debug_rd : std_logic_vector(31 downto 0);
  signal debug_addr_of_rd : std_logic_vector(4 downto 0);
  signal debug_mem_ready : std_logic;
  signal wtf : std_logic_vector( 3 downto 0) := "1111";
  signal dont : std_logic := '0';

  type exrd is array (0 to 255) of std_logic_vector(31 downto 0);
  signal expectrd : exrd := (
                   -- main:
    x"00000123",   --   addi    x1,zero,0x123
                   -- loop:
    x"00108093",   --   addi    x1,x1,1
    x"ffdfffef",   --   jal     x31,loop

  others=>x"00000000");

begin
  my_cpu: milestone1  port map(cpuclk, debug_rd, debug_addr_of_rd, debug_mem_ready);

  process
    variable counter : integer := 0;
    variable value : integer := 291;
  begin
    cpuclk <= '0'; wait for 1 fs;

    -- beginn loop with 1.000 cycles
      giant_ass_loop: for i in 999 downto 0 loop
          cpuclk <= '1'; wait for 1 fs;
          cpuclk <= '0'; wait for 1 fs;

          --report "debug_rd: " & to_string(debug_rd) & "/ cache: " & to_string_logic(debug_mem_ready);
          --report integer'image(value);

          --aluout <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))));  
          
          --report to_string(wtf);
          
          if wtf(0) = '0' and dont = '0' then 
            counter := counter +1; 
          end if;
          
          wtf <= std_logic_vector(shift_right(unsigned(wtf), 1));
          wtf(3) <= debug_mem_ready;
          
          if debug_addr_of_rd = "11111" then
            dont <= '1';
            wtf(3 downto 1) <= "111";
          end if;

          if(debug_addr_of_rd = "00001") then
            dont <= '0';
          end if;

      end loop giant_ass_loop;
    report integer'image(counter);
    assert counter <= 20 report "too many cache misses" severity failure;
    --report "Oh, oh, nothing done ..." severity failure;
    wait;
  end process;
end architecture;
