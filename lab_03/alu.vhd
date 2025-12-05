library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU entity definition: inputs must take the sign into account!
entity alu is
  Port (
-- Enter port declarations here:
    -- * A 16 bit input signed "a"
    -- * A 16 bit signed "b" input
    -- * 4 binary inputs for selecting the "add, subtract, multiply, divide" operation
    -- * A 16 bit signed "r" output
    a        : in  signed( 15 downto 0 );
    b        : in  signed( 15 downto 0 );
    add      : in  std_logic;
    subtract : in  std_logic;
    multiply : in  std_logic;
    divide   : in  std_logic;
    r        : out signed( 15 downto 0 )
  );
end alu;

-- Definizione architettura ALU
architecture Behavioral of alu is
  signal moltiplica : signed( 31 downto 0 );
begin

  -- Processo viene eseguito ad ogni variazione su operANdi e operazione selezionata
  process ( a, b, add, subtract, multiply, divide, moltiplica ) begin
    r <= a;                        -- assegnazione di default

    if add = '1' then
      r <= a + b;
    elsif subtract = '1' then
      r <= a - b;
    elsif multiply = '1' then
      moltiplica <= a * b;
      r <= moltiplica( 15 downto 0 );  -- prendo i bit meno significativi
    elsif divide = '1' then
      r <= a / b;                  -- simplify the division by putting something simpler
    end if;
  end process;

end Behavioral;
