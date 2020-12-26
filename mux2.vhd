library IEEE;
use IEEE.std_logic_1164.all;

entity mux2 is
   generic( DWIDTH : integer := 16 );
   port( IN0 : in std_logic_vector( DWIDTH-1 downto 0 );
         IN1 : in std_logic_vector( DWIDTH-1 downto 0 );
         SEL : in std_logic;
         DOUT : out std_logic_vector( DWIDTH-1 downto 0 ) );
end mux2;

architecture behavioral of mux2 is
begin

  with SEL select
  DOUT <= IN0 when '0',
          IN1 when '1',
          (others => 'X') when others;

end behavioral;
