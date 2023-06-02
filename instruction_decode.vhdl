library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decode is port (
  instruction, pc_in : in std_logic_vector(31 downto 0);
  pc, lit, jumplit : out std_logic_vector(31 downto 0);
  addr_of_rs1, addr_of_rs2, addr_of_rd : out std_logic_vector(4 downto 0);
  aluop : out std_logic_vector(4 downto 0);
  sel_pc_not_rs1, sel_lit_not_rs2, is_jalr : out std_logic;
  cpuclk : in std_logic
); end entity;

architecture a of instruction_decode is
  component d_reg is generic(
    width : natural
  ); port(
    d_in : in std_logic_vector((width-1) downto 0);
    clk : in std_logic;
    d_out : out std_logic_vector((width-1) downto 0)
  ); end component; 

  signal p_pc, p_lit, p_jumplit : std_logic_vector(31 downto 0);
  signal p_addr_of_rs1, p_addr_of_rs2, p_addr_of_rd :  std_logic_vector(4 downto 0);
  signal p_aluop : std_logic_vector(4 downto 0);
  signal p_sel_pc_not_rs1, p_sel_lit_not_rs2, p_is_jalr : std_logic;

  function slv_to_string ( a: std_logic_vector) return string is
    variable b : string (a'length-1 downto 1) := (others => NUL);
begin
        for i in a'length-1 downto 1 loop
        b(i) := std_logic'image(a((i-1)))(2);
        end loop;
    return b;
end function;
  
begin
  pipeline_lit: d_reg generic map(32) port map(d_in => p_lit, clk => cpuclk, d_out => lit);
  pipeline_pc: d_reg generic map(32) port map(d_in => pc_in, clk => cpuclk, d_out => pc);
  pipeline_jumplit: d_reg generic map(32) port map(d_in => p_jumplit, clk => cpuclk, d_out => jumplit);
  pipeline_rs1: d_reg generic map(5) port map(d_in => p_addr_of_rs1, clk => cpuclk, d_out => addr_of_rs1);
  pipeline_rs2: d_reg generic map(5) port map(d_in => p_addr_of_rs2, clk => cpuclk, d_out => addr_of_rs2);
  pipeline_rd: d_reg generic map(5) port map(d_in => p_addr_of_rd, clk => cpuclk, d_out => addr_of_rd);
  pipeline_aluop: d_reg generic map(5) port map(d_in => p_aluop, clk => cpuclk, d_out => aluop);
  pipeline_sel_1: d_reg generic map(1) port map(d_in(0) => p_sel_pc_not_rs1, clk => cpuclk, d_out(0) => sel_pc_not_rs1);
  pipeline_sel_2: d_reg generic map(1) port map(d_in(0) => p_sel_lit_not_rs2, clk => cpuclk, d_out(0) => sel_lit_not_rs2);
  pipeline_sel_3: d_reg generic map(1) port map(d_in(0) => p_is_jalr, clk => cpuclk, d_out(0) => is_jalr);


  process (instruction) begin

  p_jumplit <= x"00000000";
  p_lit <= x"00000000";

  p_addr_of_rd <= instruction(11 downto 7);
  p_addr_of_rs1 <= instruction(19 downto 15);
  p_addr_of_rs2 <= instruction(24 downto 20);

  p_sel_pc_not_rs1 <= '0';
  p_sel_lit_not_rs2 <= '1';
  p_is_jalr <= '0';
  p_aluop <= "00000";
  
  case instruction(6 downto 0) is
    when "0110111" => -- LUI
      p_addr_of_rs1 <= "00000";
      p_lit(31 downto 12) <= instruction(31 downto 12);

    when "0010111" => -- AUIPC
      p_sel_pc_not_rs1 <= '1';
      p_lit(31 downto 12) <= instruction(31 downto 12);
      
    when "1101111" => -- JAL
      p_sel_pc_not_rs1 <= '1';
      p_aluop <= "10011";
      p_jumplit(20) <= instruction(31); 
      p_jumplit(10 downto 1) <= instruction(30 downto 21);
      p_jumplit(11) <= instruction(20);
      p_jumplit(19 downto 12) <= instruction(19 downto 12); 
      p_jumplit(31 downto 21) <= (31 downto 21 => instruction(31));

    when "1100111" => -- JALR
      p_is_jalr <= '1';
      p_sel_pc_not_rs1 <= '1';
      p_aluop <= "10011";

      p_jumplit(11 downto 0) <= instruction(31 downto 20);
      p_jumplit(31 downto 12) <= (31 downto 12 => instruction(31));
       
    when "1100011" => -- BEQ, BNE; BLT, BGE, BLTU, BGEU
        p_aluop(2 downto 0) <= instruction(14 downto 12);
        p_aluop (4 downto 3 ) <= "11";      
        p_sel_lit_not_rs2 <= '0';
        
        p_jumplit(12) <= instruction(31);
        p_jumplit(10 downto 5) <= instruction(30 downto 25);
        p_jumplit(4 downto 1) <= instruction(11 downto 8);
        p_jumplit(11) <= instruction(7); 
        p_jumplit(31 downto 13) <= (31 downto 13 => instruction(31));

        p_addr_of_rd <= "00000";

    when "0000011" => -- LB, LH, LW, LBU, LHU
      p_lit(11 downto 0) <= instruction(31 downto 20);
      -- sign extension?

    when "0100011" => -- SB, SH, SW
      p_lit(11 downto 0) <= instruction(31 downto 20);
      p_lit(4 downto 0) <= instruction(11 downto 7);
      -- sign extension?
    
    when "0010011" => -- ADDI, SLTI, SLTU, XORI, ORI, ANDI, SLLI, SRLI, SLTI, SLTIU, SRAI
      p_lit(11 downto 0) <= instruction(31 downto 20);
      -- sign extension?
      p_aluop(2 downto 0) <= instruction(14 downto 12);
      p_aluop (4 downto 3 ) <= "00";
    
      if instruction(14 downto 12) = "101" then
        p_aluop(3) <= instruction (30);
        p_lit(4 downto 0) <= instruction(24 downto 20);
      end if;

    when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
      p_aluop(2 downto 0) <= instruction(14 downto 12);
      p_aluop (4 downto 3 ) <= instruction(31 downto 30);
      p_sel_lit_not_rs2 <= '0';

    when others =>
  end case;

end process;
end architecture;
