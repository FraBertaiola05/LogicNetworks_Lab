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

entity seven_segment_driver is
    generic (
        size : integer := 20
    );
    Port (
        clock : in std_logic;
        reset : in std_logic; -- Active High Reset
        digit0 : in std_logic_vector( 3 downto 0 ); -- Rightmost digit
        digit1 : in std_logic_vector( 3 downto 0 );
        digit2 : in std_logic_vector( 3 downto 0 );
        digit3 : in std_logic_vector( 3 downto 0 ); -- Leftmost digit
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 3 downto 0 )
    );
end seven_segment_driver;

entity datapath is

    port(
        clock  : in std_logic; --! Clock
        reset  : in std_logic; --! Reset
        ENADIE : in std_logic; --! Enable Die to increment
        LDSU   : in std_logic; --! Add DIE to SUR register
        LDT1   : in std_logic; --! Add SUR to TR1 register
        LDT2   : in std_logic; --! Add SUR to TR2 register
        RSSU   : in std_logic; --! Reset SUR register
        RST1   : in std_logic; --! Reset TR1 register
        RST2   : in std_logic; --! Reset TR2 register
        CP     : inout std_logic; --! current player (register outside)
        FP     : inout std_logic; --! First player (register outside)
        DIGIT0 : out std_logic_vector( 3 downto 0 ); --! digit to the right
        DIGIT1 : out std_logic_vector( 3 downto 0 ); --! 2nd digit to the left
        DIGIT2 : out std_logic_vector( 3 downto 0 ); --! 3rd digit to the left
        DIGIT3 : out std_logic_vector( 3 downto 0 ); --! digit to the left
        LEDDIE : out std_logic_vector(2 downto 0); --! LEDs to display the die value
        DIE1   : out std_logic; --! signal that a one has been obtained
        WN     : out std_logic --! WIN has been achieved by a player
    );
end entity datapath;

entity controlunit is

    port(
        clock  : in std_logic; --! Clock
        reset  : in std_logic; --! Reset
        ROLL   : in std_logic; --! button for the roll
        HOLD   : in std_logic; --! button for hold
        NEWGAME: in std_logic; --! button for new game
        ENADIE : out std_logic; --! Enable Die to increment
        LDSU   : out std_logic; --! Add DIE to SUR register
        LDT1   : out std_logic; --! Add SUR to TR1 register
        LDT2   : out std_logic; --! Add SUR to TR2 register
        RSSU   : out std_logic; --! Reset SUR register
        RST1   : out std_logic; --! Reset TR1 register
        RST2   : out std_logic; --! Reset TR2 register
        BP1    : out std_logic; --! enables blinking
        CP     : inout std_logic; --! current player (register outside)
        FP     : inout std_logic; --! First player (register outside)
        DIE1   : in std_logic; --! signal that the die is at one
        WN     : in std_logic --! WIN has been achieved by a player
    );
end entity controlunit;


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
    if reset = '1' then
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

