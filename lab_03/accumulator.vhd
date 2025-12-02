library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity accumulator is
  Port (
    -- Put here the different ports needed:
    -- * One input for the clock                           "clock"
    -- * One input for the reset                           "reset"
    -- * The input that reset the outputs (Central Button) "acc_init".
    -- * An input that enables the out of the accumulator  "acc_enable"
    -- * An ipunt of a 16 bit signed                        "acc_in"
    -- * An output of a 16 bit signed                       "acc_out"
  );
end accumulator;

architecture Behavioral of accumulator is begin

  process ( clock, reset ) begin
    if reset = '1' then
      -- put the reset values
    elsif rising_edge( clock ) then
      -- if acc_init is active reset the outputs otherwise acc_enable is enable
      -- put the input accessible to the ouput.
      if ...  then

      elsif ... then

      end if;
    end if;
  end process;

end Behavioral;
