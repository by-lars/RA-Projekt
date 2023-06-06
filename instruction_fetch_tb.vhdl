library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch_tb is end instruction_fetch_tb;

architecture behav of instruction_fetch_tb is

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
  end;

  component instruction_fetch is port (
    jumpdest : in std_logic_vector(31 downto 0);
    do_jump : in std_logic;
    cpuclk : in std_logic;
    pc, ir : out std_logic_vector(31 downto 0)
  ); end component;

  signal jumpdest : std_logic_vector(31 downto 0);
  signal do_jump : std_logic;
  signal cpuclk : std_logic;
  signal pc, ir : std_logic_vector(31 downto 0);

  type rom_type is array (0 to 255) of std_logic_vector(31 downto 0);
  signal rom : rom_type := (
                   -- main:
    x"12300093",   --   addi	x1,zero,0x123   ; 0x123
    x"0ff00113",   --   addi	x2,zero,0xff    ; 0xff
    x"002081b3",   --   add	x3,x1,x2        ; 0x222
                   -- 
    x"00800fef",   --   jal	x31,skip
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- skip:
                   -- 
                   -- ; test all arith/log reg-reg instructions, results should be:
    x"55506213",   --   ori	x4,zero,0x555 ; 0x555
    x"33304293",   --   xori	x5,zero,0x333 ; 0x333
    x"00520333",   --   add	x6,x4,x5     ; 0x888
    x"405203b3",   --   sub	x7,x4,x5     ; 0x222
    x"00521433",   --   sll	x8,x4,x5     ; ...
    x"005224b3",   --   slt	x9,x4,x5     ; 0
    x"00523533",   --   sltu	x10,x4,x5    ; 0
    x"005245b3",   --   xor	x11,x4,x5    ; 0x666
    x"00525633",   --   srl	x12,x4,x5    ; 0
    x"405256b3",   --   sra	x13,x4,x5    ; 0
    x"00526733",   --   or	x14,x4,x5    ; 0x777
    x"005277b3",   --   and	x15,x4,x5    ; 0x111
                   -- 
                   -- ; test all arith/log literal instructions, results should be:
    x"55506213",   --   ori	x4,zero,0x555     ; 0x555
    x"fff20813",   --   addi	x16,x4,0xffffffff ; 0x554
    x"12322893",   --   slti	x17,x4,0x123      ; 0
    x"80023913",   --   sltiu	x18,x4,0xfffff800 ; 1
    x"12324993",   --   xori	x19,x4,0x123      ; 0x476
    x"80226a13",   --   ori	x20,x4,0xfffff802 ; 0xfffffd57
    x"81f27a93",   --   andi	x21,x4,0xfffff81f ; 0x15
    x"00421b13",   --   slli	x22,x4,4          ; 0x5550
    x"00425b93",   --   srli	x23,x4,4          ; 0x55
    x"40825c13",   --   srai	x24,x4,8          ; 5
                   -- 
                   -- ; test all branches, some shall be taken, some not
    x"55506213",   --   ori	x4,zero,0x555     ; 0x555
    x"33304293",   --   xori	x5,zero,0x333     ; 0x333
    x"00420463",   --   beq	x4,x4,take_it_1
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_1:
    x"00421463",   --   bne	x4,x4,do_not_take_it_1
    x"44500093",   --   addi	x1,zero,0x445   ; 0x445
                   -- do_not_take_it_1:
    x"00525463",   --   bge	x4,x5,take_it_2
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_2:
    x"00524463",   --   blt	x4,x5,do_not_take_it_2
    x"44600093",   --   addi	x1,zero,0x446   ; 0x446
                   -- do_not_take_it_2:
    x"00527463",   --   bgeu	x4,x5,take_it_3
    x"32100093",   --   addi	x1,zero,0x321   ; never expect: 0x321
                   -- take_it_3:
    x"00526463",   --   bltu	x4,x5,do_not_take_it_3
    x"4c600093",   --   addi	x1,zero,0x4c6   ; 0x4c6
                   -- do_not_take_it_3:
                   -- 
                   -- ; test remaining instructions
    x"12345cb7",   --   lui	x25,0x12345	; 0x12345000
    x"00000d17",   --   auipc   x26,0           ; 0xa8
    x"0b800f13",   --   addi	x30,zero,hier_gehts_weiter-main
    x"000f0fe7",   --   jalr	x30,x31,0
    x"32300093",   --   addi	x1,zero,0x323   ; never expect: 0x323
                   -- hier_gehts_weiter:
                   -- 
    x"04200093",   --   addi	x1,zero,0x42    ; 0x42 special value: stop simulation

  others=>x"00000000");
begin
  my_instruction_fetch : instruction_fetch port map(jumpdest, do_jump, cpuclk, pc, ir);

  process
  begin
    
    -- Sync
    loopy_waity: for i in 0 to 10 loop
      cpuclk <= '1'; wait for 1 fs;
      cpuclk <= '0'; wait for 1 fs;

      if(ir = rom(0)) then
        exit;
      end if;

      if(i = 10) then
        report "Sync failed after 10 cycles - tf u doin" severity failure;
      end if;
    end loop loopy_waity;


    report "pc is " & to_string(pc);
    assert pc = x"00000000" report "(1) PC did not do the thing - pc is dis: " & to_string(pc) severity failure;
    assert ir = rom(0) report "(1) Was machen sachen? - ir is dis: " & to_string(ir) severity failure;

    -- test first instruction
    loopy: for i in 0 to 6 loop
      cpuclk <= '1'; wait for 1 fs;
      cpuclk <= '0'; wait for 1 fs;
      assert ir = x"00000013" report "(2) wo noop?" severity failure;  
    end loop loopy;

    cpuclk <= '1'; wait for 1 fs;
    cpuclk <= '0'; wait for 1 fs;

    report "pc is " & to_string(pc);
    assert pc = x"00000004" report "(2) PC did not do the thing - pc is dis: " & to_string(pc) severity failure;
    assert ir = rom(1) report "(2) Was machen sachen? - ir is dis: " & to_string(ir) severity failure;

    -- test second instruction
    loopy_dodoppy: for i in 0 to 6 loop
      cpuclk <= '1'; wait for 1 fs;
      cpuclk <= '0'; wait for 1 fs;
      assert ir = x"00000013" report "wo noop?" severity failure;  
    end loop loopy_dodoppy;

    cpuclk <= '1'; wait for 1 fs;
    cpuclk <= '0'; wait for 1 fs;

    report "pc is " & to_string(pc);
    assert pc = x"00000008" report "(3) PC did not do the thing - pc is dis: " & to_string(pc) severity failure;
    assert ir = rom(2) report "(3) Was machen sachen? - ir is dis: " & to_string(ir) severity failure;
  
    -- test jump
    loopy_dododoppy_beep_boop: for i in 0 to 6 loop
      cpuclk <= '1'; wait for 1 fs;
      cpuclk <= '0'; wait for 1 fs;

      assert ir = x"00000013" report "wo noop?" severity failure;  
    end loop loopy_dododoppy_beep_boop;

    cpuclk <= '1'; wait for 1 fs;
    cpuclk <= '0'; wait for 1 fs;
    do_jump <= '1';
    jumpdest <= x"00000010";

    cpuclk <= '1'; wait for 1 fs;
    cpuclk <= '0'; wait for 1 fs;

    assert pc = x"00000010" report "wo jump?" severity failure;
    
    report "instruction_fetch_tb finished - test OK";
    wait;

  end process;
end architecture;




