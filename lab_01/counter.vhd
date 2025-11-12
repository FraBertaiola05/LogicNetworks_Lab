library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 
generic(ClockFrequencyHz : integer);
port( clk : in std_logic;
        reset_n : in std_logic; -- Active low
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); 
        HEX_2 : out std_logic_vector(6 downto 0)
        );
end Car_Parking_System_VHDL;

architecture arch of Car_Parking_System_VHDL is
    --State declarations
    type parking_state is (Idle, Wait_pass, Pass_correct, Stop, Wrong_pass, Right_pass);
    signal State : parking_state;
    --Counter
    signal Counter : integer range 0 to ClockFrequencyHz * 60;


begin
    process(clk) is
    begin
    end process;

end arch ; -- arch
