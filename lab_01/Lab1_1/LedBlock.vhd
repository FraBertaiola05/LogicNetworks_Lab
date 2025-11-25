library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_block is
    port(
        clock   : in  std_logic;
        en      : in  std_logic;
        led_out : out std_logic
    );
end led_block;

architecture Behavioral of led_block is
    signal led_state : std_logic := '0';
begin
    process(clock)
    begin
        if clock'event then
            if en = '1' then
                led_state <= not led_state;
            end if;
        end if;
    end process;

    led_out <= led_state;
end Behavioral;