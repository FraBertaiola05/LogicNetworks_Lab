library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    generic(
        divider : integer := 10 
    );
    port(
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end entity;

architecture Behavioral of prescaler is
    signal counter : integer := 0;
    signal clk_reg : std_logic := '0';
begin

    process(clk_in, reset)
    begin
        if reset = '0' then
            counter <= 0;
            clk_reg <= '0';

        elsif rising_edge(clk_in) then
            if counter = (divider/2 - 1) then
                clk_reg <= not clk_reg;  -- toggling dell'uscita
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_reg;

end architecture;
