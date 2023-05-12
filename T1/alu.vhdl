library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is port (
  op1, op2 : in std_logic_vector(31 downto 0);
  aluout : out std_logic_vector(31 downto 0);
  aluop : in std_logic_vector(4 downto 0);
  do_jump : out std_logic
); end entity;


architecture a of alu is 
  function to_std_logic(L: BOOLEAN) return std_ulogic is begin
    if L then return('1'); else return('0'); end if;
  end function to_std_logic;
begin
  process (op1, op2, aluop) begin
    
    do_jump <= '0';

    case aluop is 
      -- BIN OPS
      when "00000" => -- add
        aluout <= std_logic_vector(unsigned(op1) + unsigned(op2));
      
      when "00001" => -- sll 
        aluout <= std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))));  
       
      when "00010" => -- slt (signed)
        if(signed(op1) < signed(op2)) then
          aluout <= (aluout'high downto 1 => '0', others => '1');
        else
          aluout <= (aluout'high downto 0 => '0');
        end if;

      when "00011" => -- sltu (unsigned)
        if(unsigned(op1) < unsigned(op2)) then
          aluout <= (aluout'high downto 1 => '0', others => '1');
        else
          aluout <= (aluout'high downto 0 => '0');
        end if;

      when "00100" => -- xor
        for i in 0 to aluout'high loop
          aluout(i) <= op1(i) xor op2(i);
        end loop;
    
      when "00101" => -- srl
        aluout <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))));  
        
      when "00110" => -- or
        aluout <= op1 or op2;

      when "00111" => -- and
        aluout <= op1 and op2;

      when "01000" => -- sub
        aluout <= std_logic_vector(unsigned(op1) - unsigned(op2));
        
      when "01101" => -- sra
        aluout <= std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0)))));  

      -- -- BRANCHING
      when "10000" | "11000"=> -- beq
        do_jump <= to_std_logic(op1 = op2);

      when "10001" | "11001"=> -- bne
        do_jump <= to_std_logic(op1 /= op2);

      when "10010" | "11010" => -- do not jump
          do_jump <= '0';

      when "10011" | "11011" => -- jal, jalr
          do_jump <= '1';
          aluout <= std_logic_vector((unsigned(op1) + 4)); 

      when "10100" | "11100" => -- blt
        do_jump <= to_std_logic(signed(op1) < signed(op2));

      when "10101" | "11101" => -- bge
        do_jump <= to_std_logic(signed(op1) >= signed(op2));

      when "10110" | "11110" => -- bltu
        do_jump <= to_std_logic(unsigned(op1) < unsigned(op2));
   
      when "10111" | "11111" => -- bgeu
        do_jump <= to_std_logic(unsigned(op1) >= unsigned(op2));
      
      when others =>
    end case;

  end process;
end architecture;
