library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is  
generic (
    counter_size : integer := 12
  );
port (
    clock, reset : in std_logic; 
    bouncy       : in std_logic; 
    pulse    : out std_logic; 
    debounced: out std_logic 
    );
end debouncer;

architecture behavioral of debouncer is

  signal counter : unsigned( counter_size - 1 downto 0 );
  signal candidate_value : std_logic;
  signal stable_value : std_logic;
  signal delayed_stable_value : std_logic;

begin

  process ( clock, reset ) begin
  if reset = '1' then
      counter <= ( others => '1' );
      candidate_value <= '0';
      stable_value <= '0';
      elsif rising_edge( clock ) then
      if bouncy = candidate_value then
         if counter = 0 then
         stable_value <= candidate_value;
         else
         counter <= counter - 1;
         end if;
      else
        candidate_value <= bouncy;
        counter <= ( others => '1' );
      end if;
  end if;
  end process;

  process ( clock, reset ) begin
  if reset = '0' then
    delayed_stable_value <= '0';
    elsif rising_edge( clock ) then
    delayed_stable_value <= stable_value;
    end if;
  end process;

  pulse <= '1' when stable_value = '1' and delayed_stable_value = '0' else '0';
  debounced <= stable_value;
end behavioral;