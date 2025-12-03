library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

architecture Behavioral of seven_segment_driver is

    -- We use a counter to derive the frequency.
    -- We only need the top 2 bits to select 4 displays (00, 01, 10, 11).
    signal flick_counter : unsigned( size - 1 downto 0 ) := (others => '0');
    
    -- The digit to be currently displayed
    signal digit_to_display : std_logic_vector( 3 downto 0 );
    
    -- Helper signal for the multiplexing selection (2 bits)
    signal mux_select : std_logic_vector(1 downto 0);
    
    -- Collect the values of the cathodes here
    signal cathodes : std_logic_vector( 7 downto 0 );

begin

    -- Process: Counter with Active High Reset
    process ( clock, reset ) begin
        if reset = '1' then
            flick_counter <= ( others => '0' );
        elsif rising_edge( clock ) then
            flick_counter <= flick_counter + 1;
        end if;
    end process;

    -- Helper: Select the top 2 bits for 4-state multiplexing
    mux_select <= std_logic_vector(flick_counter( size - 1 downto size - 2 ));

    -- Mux: Select both the Anode and the Data Source based on the counter
    process(mux_select, digit0, digit1, digit2, digit3)
    begin
        case mux_select is
            when "00" =>
                AN <= "1110";             -- Activate Anode 0 (Rightmost)
                digit_to_display <= digit0;
            when "01" =>
                AN <= "1101";             -- Activate Anode 1
                digit_to_display <= digit1;
            when "10" =>
                AN <= "1011";             -- Activate Anode 2
                digit_to_display <= digit2;
            when "11" =>
                AN <= "0111";             -- Activate Anode 3 (Leftmost)
                digit_to_display <= digit3;
            when others =>
                AN <= "1111";             -- Turn off all
                digit_to_display <= (others => '0');
        end case;
    end process;

    -- Decoder: Hex to 7-Segment (Active Low Cathodes)
    with digit_to_display select
        cathodes <=
            -- DP, G, F, E, D, C, B, A  (Mapping: 0 is ON, 1 is OFF)
            "11000000" when "0000", -- 0
            "11111001" when "0001", -- 1
            "10100100" when "0010", -- 2
            "10110000" when "0011", -- 3
            "10011001" when "0100", -- 4
            "10010010" when "0101", -- 5
            "10000010" when "0110", -- 6
            "11111000" when "0111", -- 7
            "10000000" when "1000", -- 8
            "10010000" when "1001", -- 9
            "10001000" when "1010", -- A
            "10000011" when "1011", -- b
            "11000110" when "1100", -- C
            "10100001" when "1101", -- d
            "10000110" when "1110", -- E
            "10001110" when others; -- F

    -- Map internal cathode signal to physical ports
    DP <= cathodes( 7 );
    CG <= cathodes( 6 );
    CF <= cathodes( 5 );
    CE <= cathodes( 4 );
    CD <= cathodes( 3 );
    CC <= cathodes( 2 );
    CB <= cathodes( 1 );
    CA <= cathodes( 0 );

end Behavioral;