library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_control is port(
    write : out std_logic;
    cachehit : in std_logic;
    clk : in std_logic
); end entity;

architecture behav of cache_control is
    function to_std_logic(L: BOOLEAN) return std_ulogic is begin
        if L then return('1'); else return('0'); end if;
      end function to_std_logic;
    
begin
    process(clk) 
        variable counter : integer := 0;
    begin

    if(falling_edge(clk)) then
        
        if(cachehit = '0' and counter = 0) then
            counter := 5;
        end if;

        if(counter > 0) then 
            counter := counter - 1;
        end if;

        write <= to_std_logic(counter = 1);
    end if;
  end process;
end architecture;
