library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity accumulator is
  Port (
    -- Put here the different ports needed:
    clock : in std_logic;-- * One input for the clock                           "clock"
    reset : in std_logic; -- * One input for the reset                           "reset"
    acc_init : in std_logic;-- * The input that reset the outputs (Central Button) "acc_init".
    acc_enable : in std_logic;-- * An input that enables the out of the accumulator  "acc_enable"
    acc_in : in signed (15 downto 0);-- * An ipunt of a 16 bit signed                        "acc_in"
    acc_out : out signed (15 downto 0)-- * An output of a 16 bit signed                       "acc_out"
  );
end accumulator;

architecture Behavioral of accumulator is begin

  process ( clock, reset ) begin
    if reset = '1' then
      -- put the reset values
      acc_out<=(others =>'0');
    elsif rising_edge( clock ) then
      if acc_init = '1' then
         acc_out <= (others => '0');
      elsif acc_enable = '1' then
         acc_out <= acc_in;
      end if;
      
      -- If neither is '1', the accumulator holds its previous value (implicit memory)
    end if;
  end process;
end Behavioral;
