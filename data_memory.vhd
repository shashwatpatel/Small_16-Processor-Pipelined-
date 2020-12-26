library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;

-- data_memory Entity Description

entity data_memory is
    port( DIN : in sm16_data;
          ADDR : in sm16_address;
          DOUT : out sm16_data;
          WE : in std_logic);
end data_memory;

-- data_memory Architecture Description
architecture behavioral of data_memory is
    subtype ramword is bit_vector(15 downto 0);
    type rammemory is array (0 to 1023) of ramword;
    ----------------------------------------------
    ----------------------------------------------
    -----  This is where you put your data -------
    ----------------------------------------------
    ----------------------------------------------
    signal ram : rammemory := ("0000000000000000",  --  0: data_array[0]
                               "0000000000000010",  --  1: data_array[1]
                               "0000000000000011",  --  2: data_array[2]
                               "0000000000000100",  --  3: data_array[3]
                               "0000000000000101",  --  4: data_array[4]                                         
                               "0000000000000000",  --  5: data_array[5]
                               "0000000000000000",  --  6: data_array[6]
                               "0000000000000000",  --  7: data_array[7]
                               "0000000000000000",  --  8: data_array[8]
                               "0000000000000000",  --  9: data_array[9]
                               "0000000000000000",  --  10: data_array[10]
                               
                               others => "0000000000000000");
 
begin

    DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
    
    ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';

end behavioral;
