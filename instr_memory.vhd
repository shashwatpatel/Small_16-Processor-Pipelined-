library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;

-- instr_memory Entity Description

entity instr_memory is
    port( DIN : in sm16_data;
          ADDR : in sm16_address;
          DOUT : out sm16_data;
          WE : in std_logic);
end instr_memory;

-- instr_memory Architecture Description
architecture behavioral of instr_memory is
    subtype ramword is bit_vector(15 downto 0);
    type rammemory is array (0 to 1023) of ramword;

    -- add   0000           addi 0100
    -- sub   0001           seti 0101
    -- load  0010           jump 0110
    -- store 0011           jz   0111
    signal ram : rammemory := (  
                               "0010000000000000", -- 0: load 0
                               "0111000000000011",  -- 1: if r0=0 jump to pos 3, should jump
                               "0101000000000001",  -- 2:  seti A 1, skipped
                               "0101010000000010",  -- 3:  seti B 2, exe
                               "0010000000000001", -- 4: load 2, exe
                               "0111000000000110",  -- 5:  if r0=0 jump to pos 6 , shouldnt jump
                               "0101100000000011",  -- 6:  seti C 3
                               "0101110000000100",  -- 7:  seti D 4
                               
                               "0110000000001100" , --8 jump to 12
                               "0100100000000100", --9 addi 4 --skipped
                               "0100100000000101", --10 addi 5 --skipped
                               
                               "0011000000000011",  -- 11:  store A 0, skipped
                               "0011010000000100",  -- 12:  store B 1, exe
                               "0011100000000101",  -- 13:  store C 2, exe
                               "0011110000000110",  -- 14:  store D 3, exe
                               
                               
                               others => "0000000000000000");

begin

    DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
    
    ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';

end behavioral;
