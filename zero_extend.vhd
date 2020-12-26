library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- zero_extend Entity Description

entity zero_extend is
   port(
      A: in sm16_address;
      Z: out sm16_data
   );
end zero_extend;


-- zero_extend Architecture Description
architecture dataflow of zero_extend is

--signal zero_6 : sm16_opcode := "000000";

begin

	Z(15 downto 10) <= "000000";
	Z(9 downto 0) <= A;

end dataflow;
