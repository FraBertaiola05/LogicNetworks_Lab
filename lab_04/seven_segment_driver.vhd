library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_driver is
    generic (
        size : integer := 20
    );
    Port (
        clock  : in std_logic;
        reset  : in std_logic;
        digit0 : in std_logic_vector(3 downto 0); -- Rightmost digit (Ones)
        digit1 : in std_logic_vector(3 downto 0); -- 2nd digit (Tens)
        digit2 : in std_logic_vector(3 downto 0); -- 3rd digit (Player 2 Ones)
        digit3 : in std_logic_vector(3 downto 0); -- Leftmost digit (Player 2 Tens)
        CA     : out std_logic_vector(7 downto 0); -- Segments A-G + DP
        AN     : out std_logic_vector(3 downto 0)  -- Anodes
    );
end entity seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    -- 18-bit counter for ~380Hz refresh rate (100MHz / 2^18)
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal LED_BCD : std_logic_vector(3 downto 0);
    signal sel     : std_logic_vector(1 downto 0);
begin

    -- 1. Refresh Counter
    process(clock, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clock) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Use top 2 bits to select active digit
    sel <= std_logic_vector(refresh_counter(19 downto 18));

    -- 2. Anode Switching (Active LOW)
    process(sel)
    begin
        case sel is
            when "00" => AN <= "1110"; -- Activate Digit 0 (Rightmost)
            when "01" => AN <= "1101"; -- Activate Digit 1
            when "10" => AN <= "1011"; -- Activate Digit 2
            when "11" => AN <= "0111"; -- Activate Digit 3 (Leftmost)
            when others => AN <= "1111";
        end case;
    end process;

    -- 3. Digit Selection Logic
    process(sel, digit0, digit1, digit2, digit3)
    begin
        case sel is
            when "00" => LED_BCD <= digit0;
            when "01" => LED_BCD <= digit1;
            when "10" => LED_BCD <= digit2;
            when "11" => LED_BCD <= digit3;
            when others => LED_BCD <= "0000";
        end case;
    end process;

    -- 4. Cathode Decoding (Active LOW)
    -- FIXED MAPPING FOR BASYS 3: 
    -- Bit 6=A, 5=B, 4=C, 3=D, 2=E, 1=F, 0=G (DP is Bit 7)
    process(LED_BCD)
    begin
        case LED_BCD is
            when "0000" => CA <= "10000001"; -- 0
            when "0001" => CA <= "11001111"; -- 1
            when "0010" => CA <= "10010010"; -- 2
            when "0011" => CA <= "10000110"; -- 3
            when "0100" => CA <= "11001100"; -- 4
            when "0101" => CA <= "10100100"; -- 5
            when "0110" => CA <= "10100000"; -- 6
            when "0111" => CA <= "10001111"; -- 7
            when "1000" => CA <= "10000000"; -- 8
            when "1001" => CA <= "10000100"; -- 9
            when others => CA <= "11111111"; -- OFF
        end case;
    end process;

end Behavioral;