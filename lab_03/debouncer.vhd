library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  generic (
    counter_size : integer := 12
  );
  port (
    -- Enter port declarations here:
    -- * A "clock" clock input
    -- * A "reset" reset input
    -- * An input for the "bouncy" button
    -- * One output for the "pulse" pulse
  );
end debouncer;

architecture behavioral of debouncer is

  -- Definition of internal signals:
  -- * counter: keeps track of the time interval in which the signal is stable
  -- * candidate_value: Keep track of the candidate stable value
  -- * stable_value: Keep track of the current stable value
  -- * delayed_stable_value: Delayed version of stable value to generate output
begin

  process ( clock, reset ) begin
    if reset = '0' then
      -- reset counter, stable and candidate value
    elsif rising_edge( clock ) then
      -- Check whether the signal is stable
      if bouncy = candidate_value then
        -- Stable signal. Check for how long
        if counter = 0 then
          -- Update stable value
          
        else
         -- Decrement the counter
          
        end if;
      else
        -- Signal not stable. Update the candidate value and reset the counter
      end if;
    end if;
  end process;

  -- Process that creates a delayed version of the stable signal (delayed_stable_value)
  process ( clock, reset ) begin
    if reset = '0' then
      -- Assignment of reset value
    elsif rising_edge( clock ) then
      -- Value assignment to each clock cycle
    end if;
  end process;

  -- Generate output pulse
  pulse <= '1' when stable_value = ... and delayed_stable_value = ... else
           '0';

end behavioral;

