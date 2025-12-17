library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binbcd is
    Port ( 
        clock  : in std_logic;
        reset  : in std_logic;
        bin    : in std_logic_vector(6 downto 0); -- Input binary (0-99)
        digit0 : out std_logic_vector(3 downto 0); -- Ones digit
        digit1 : out std_logic_vector(3 downto 0)  -- Tens digit
    );
end binbcd;

architecture Behavioral of binbcd is
begin
    process(clock, reset)
        variable temp_bin : integer range 0 to 127;
    begin
        if reset = '1' then
            digit0 <= (others => '0');
            digit1 <= (others => '0');
        elsif rising_edge(clock) then
            -- Convert std_logic_vector to integer
            temp_bin := to_integer(unsigned(bin));
            
            -- Simple separation of tens and units for 0-99 range
            if temp_bin > 99 then
                digit1 <= "1001"; -- Cap at 99 if overflow
                digit0 <= "1001";
            else
                digit1 <= std_logic_vector(to_unsigned(temp_bin / 10, 4));
                digit0 <= std_logic_vector(to_unsigned(temp_bin mod 10, 4));
            end if;
        end if;
    end process;
end Behavioral;