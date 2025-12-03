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
    -- * AN input for the "bouncy" button
    -- * One output for the "pulse" pulse
    clock   : in  std_logic;
    reset   : in  std_logic;
    bouncy  : in  std_logic;
    pulse   : out std_logic
  );
end debouncer;

architecture behavioral of debouncer is

  -- Definition of internal signals:
  -- * counter: keeps track of the time interval in which the signal is stable
  -- * cANdidate_value: Keep track of the cANdidate stable value
  -- * stable_value: Keep track of the current stable value
  -- * delayed_stable_value: Delayed version of stable value to generate output
  signal counter              : unsigned( counter_size - 1 downto 0 ) := (others => '1');
  signal cANdidate_value      : std_logic;
  signal stable_value         : std_logic;
  signal delayed_stable_value : std_logic;
begin

  process ( clock, reset ) begin
    if reset = '1' then
      -- reset counter, stable ANd cANdidate value
      counter         <= (others => '1');
      cANdidate_value <= '0';
      stable_value    <= '0';
    elsif rising_edge( clock ) then
      -- Check whether the signal is stable
      if bouncy = cANdidate_value then
        -- Stable signal. Check for how long
        if counter = 0 then
          -- Update stable value
          stable_value <= cANdidate_value;
          
        else
         -- Decrement the counter
          counter <= counter - 1;
        end if;
      else
        -- Signal not stable. Update the cANdidate value ANd reset the counter
        cANdidate_value <= bouncy;
        counter         <= (others => '1'); -- Load the counter with max value
      end if;
    end if;
  end process;

  -- Process that creates a delayed version of the stable signal (delayed_stable_value)
  process ( clock, reset ) begin
    if reset = '0' then
      -- Assignment of reset value
      delayed_stable_value <= '0';
    elsif rising_edge( clock ) then
      -- Value assignment to each clock cycle
      delayed_stable_value <= stable_value;
    end if;
  end process;

  -- Generate output pulse
  pulse <= '1' when stable_value = '1' ANd delayed_stable_value = '0' else --detect rising edge of stable_value
           '0';

end behavioral;

