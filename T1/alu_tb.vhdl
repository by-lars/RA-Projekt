library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is end entity;

architecture a of alu_tb is
  component alu is port (
    op1, op2 : in std_logic_vector(31 downto 0);
    aluout : out std_logic_vector(31 downto 0);
    aluop : in std_logic_vector(4 downto 0);
    do_jump : out std_logic
  ); end component;
  signal op1, op2 : std_logic_vector(31 downto 0);
  signal aluout : std_logic_vector(31 downto 0);
  signal aluop : std_logic_vector(4 downto 0);
  signal do_jump : std_logic;
  signal result: std_logic_vector( 31 downto 0);

  function to_std_logic(L: BOOLEAN) return std_ulogic is begin
    if L then return('1'); else return('0'); end if;
  end function to_std_logic;

begin
  my_alu: alu port map(op1, op2, aluout, aluop, do_jump);

  process
    variable v_op1 : integer;
    variable v_op2 : integer;
  begin
    -- ADD 
    aluop <= "00000";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(unsigned(op1) + unsigned(op2)) then
            report "addition falsch" severity failure;
            end if;
          if do_jump /= '0' then
            report "do_jump bei addition falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- SLL
      aluop <= "00001";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2(4 downto 0))))) then
            report "sll falsch" severity failure;
            end if;
          if do_jump /= '0' then
            report "do_jump bei sll falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- SLT 
      aluop <= "00010";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;

          if aluout(0) /= to_std_logic(signed(op1) < signed(op2)) then
            report "slt slt falsch" severity failure;
          end if;

          if do_jump /= '0' then
            report "do_jump bei slt falsch" severity failure;
          end if;

        end loop;
      end loop;

      -- SLTU 
      aluop <= "00011";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
         
          if aluout(0) /= to_std_logic(unsigned(op1) < unsigned(op2)) then
            report "sltu slt falsch" severity failure;
          end if;

          if do_jump /= '0' then
            report "do_jump bei slt falsch" severity failure;
          end if;

        end loop;
      end loop;

      -- XOR 
      aluop <= "00100";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          
          for n in 0 to aluout'high loop
            if aluout(n) /= (op1(n) xor op2(n)) then 
              report "xor falsch" severity failure;
            end if;
          end loop;
  
          if do_jump /= '0' then
            report "do_jump bei xor falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- SRL 
      aluop <= "00101";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0))))) then
            report "srl falsch" severity failure;
          end if;
          if do_jump /= '0' then
            report "do_jump bei srl falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- OR 
      aluop <= "00110";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= (op1 or op2) then
            report "or falsch" severity failure;
          end if;
          if do_jump /= '0' then
            report "do_jump bei or falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- AND 
      aluop <= "00111";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= ( op1 and op2) then
            report "and falsch" severity failure;
            end if;
          if do_jump /= '0' then
            report "do_jump bei and falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- SUB 
      aluop <= "01000";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(unsigned(op1) - unsigned(op2)) then
            report "sub falsch" severity failure;
            end if;
          if do_jump /= '0' then
            report "do_jump bei sub falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- SRA 
      aluop <= "01101";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0))))) then
            report "sra falsch" severity failure;
          end if;
          if do_jump /= '0' then
            report "do_jump bei sra falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BEQ 
      aluop <= "10000";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(op1 = op2) then
            report "do_jump bei beq falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BNE 
      aluop <= "10001";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(op1 /= op2) then
            report "do_jump bei bne falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- 'DO NOT JUMP'
      aluop <= "10010";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= '0' then
            report "do_jump bei do not jump falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- JAL JALR
      aluop <= "10011";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if aluout /= std_logic_vector(unsigned(op1) + 4) then
            report "jal/jalr falsch" severity failure;
            end if;
          if do_jump /= '1' then
            report "do_jump bei jal/jalr falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BLT
      aluop <= "10100";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(signed(op1) < signed(op2)) then
            report "do_jump bei BLT falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BGE
      aluop <= "10101";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(signed(op1) >= signed(op2)) then
            report "do_jump bei bge falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BLTU
      aluop <= "10110";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(unsigned(op1) < unsigned(op2)) then
            report "do_jump bei bltu falsch" severity failure;
          end if;
        end loop;
      end loop;

      -- BGEU
      aluop <= "10111";
      for i in 0 to 31 loop
        for j in 0 to 31 loop
          op1 <= std_logic_vector(shift_left(to_unsigned(1,32),i));
          op2 <= std_logic_vector(shift_left(to_unsigned(1,32),j));
          wait for 1 fs;
          if do_jump /= to_std_logic(unsigned(op1) >= unsigned(op2)) then
            report "do_jump bei BGEU falsch" severity failure;
          end if;
        end loop;
      end loop;


    report "end of alu_tb -- reaching here is: test OK";
    wait; -- simulation beenden
  end process;
end architecture;

