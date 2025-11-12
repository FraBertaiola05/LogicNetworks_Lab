
library ieee;
use ieee.std_logic_1164.all;

entity tb_car_parking is 
end tb_car_parking;

architecture testbench of tb_car_parking is 
    component Car_Parking_System_VHDL is
        port (
            clk : in std_logic;
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
    end component;
-- testbanch signals 
--inputs 
    signal clk_tb          : std_logic := '0';
    signal reset_n_tb      : std_logic := '0';
    signal front_sensor_tb : std_logic := '0';
    signal back_sensor_tb  : std_logic := '0';
    signal password_1_tb   : std_logic_vector(1 downto 0) := (others => '0');
    signal password_2_tb   : std_logic_vector(1 downto 0) := (others => '0');
--outputs 
    signal GREEN_LED_tb : std_logic;
    signal RED_LED_tb   : std_logic;
    signal HEX_1_tb     : std_logic_vector(6 downto 0);
    signal HEX_2_tb     : std_logic_vector(6 downto 0);
    
-- 2. Added clock period constant
    constant clk_period : time := 20 ns;

begin

    DUT: Car_Parking_System_VHDL
        port map (
            clk          => clk_tb,
            reset_n      => reset_n_tb,
            front_sensor => front_sensor_tb,
            back_sensor  => back_sensor_tb,
            password_1   => password_1_tb,
            password_2   => password_2_tb,
            GREEN_LED    => GREEN_LED_tb,
            RED_LED      => RED_LED_tb,
            HEX_1        => HEX_1_tb,
            HEX_2        => HEX_2_tb
        );


    clk_tb <= not clk_tb after clk_period / 2;

    stimulus: process
    begin
        -- reset asserted 
        report "Starting Testbench - Applying Reset";
                reset_n_tb <= '0';
                front_sensor_tb <= '0';
                back_sensor_tb  <= '0';
                password_1_tb   <= "00";
                password_2_tb   <= "00";
                wait for 100 ns;   
        -- de asset reset 
        reset_n_tb <= '1';
        report "reset released; System should go in IDLE state";
        wait for clk_period; 
    -- scenario: normal entry
        report "Starting Scenario : normal entry";     
            -- 1. Car arrives at front sensor
            front_sensor_tb <= '1';
            wait for clk_period;
            -- System should move to WAIT_PASSWORD
            report "  Car at front sensor. State should be WAIT_PASSWORD.";
            
            -- 2. Wait 10 clock cycles 
            report "  Waiting 12 cycles for password delay...";
            wait for 10 * clk_period;

            -- 3. Input correct password 
            report "  Entering correct password (0110).";
            password_1_tb <= "01";
            password_2_tb <= "10";
            wait for clk_period;
            -- System should transition to RIGHT_PASS

            -- 4. Verify: GREEN LED blinks and display "GO"
            report "  Password entered. State should be RIGHT_PASS (Green LED, 'GO').";
            wait for 20 * clk_period; -- Wait for car to move
            
            -- 5. Car moves off front sensor and onto back sensor
            report "  Car moving through. Front sensor '0', Back sensor '1'.";
            front_sensor_tb <= '0';
            back_sensor_tb  <= '1';
            wait for clk_period;

            -- 6. Car passes back sensor. System returns to IDLE.
            report "  Car passed. Back sensor '0'.";
            back_sensor_tb  <= '0'; 
            password_1_tb   <= "00"; -- Reset password inputs
            password_2_tb   <= "00";
            wait for clk_period;
            report "  Scenario 1 Complete. System should be IDLE.";
            wait for 10 * clk_period; -- Wait for signals to settle
    -- scenario: wrong password 
        report "Starting scenario: wrong password";
            
            -- 1. Car arrives at front sensor
            front_sensor_tb <= '1';
            wait for clk_period;
            report "  Car at front sensor. State should be WAIT_PASSWORD.";
            
            -- 2. Wait 10 clock cycles
            report "  Waiting 10 cycles for password delay...";
            wait for 10 * clk_period;

            -- 3. Input wrong password 
            report "  Entering wrong password (0000).";
            password_1_tb <= "00";
            password_2_tb <= "00";
            wait for clk_period;
            -- System should transition to WRONG_PASS

            -- 4. Verify: RED LED blinks, display "EE"
            report "  Wrong password entered. State should be WRONG_PASS (Red LED, 'EE').";
            wait for 20 * clk_period; -- Stay in wrong state for a bit

            -- 5. Input correct password (0110)
            report "  Entering correct password (0110).";
            password_1_tb <= "01";
            password_2_tb <= "10";
            wait for clk_period;
            
            -- 6. Verify: System transitions to RIGHT_PASS
            report "  Correct password entered. State should be RIGHT_PASS (Green LED, 'GO').";
            wait for 20 * clk_period;
            
            -- Cleanup: Pass the car through to return to IDLE
            report "  Cleaning up: Passing car.";
            front_sensor_tb <= '0';
            back_sensor_tb  <= '1';
            wait for clk_period;
            back_sensor_tb  <= '0';
            password_1_tb   <= "00";
            password_2_tb   <= "00";
            report "  Scenario 2 Complete. System should be IDLE.";
            wait for 10 * clk_period;


    -- ** Scenario : Multiple Cars  **
        report "Starting Scenario : Multiple Cars";
            
            -- 1. Car 1 enters with correct password -> RIGHT_PASS
            report "  Car 1 at front sensor.";
            front_sensor_tb <= '1';
            wait for 10 * clk_period;
            report "  Car 1 entering correct password.";
            password_1_tb <= "01";
            password_2_tb <= "10";
            wait for clk_period;
            report "  Car 1 accepted. State should be RIGHT_PASS.";
            
            -- 2. Car 1 is passing (front='0', back='1') and Car 2 arrives at front sensor (front='1')
            --    Result: front_sensor='1' AND back_sensor='1'
            report "  Car 1 passing, Car 2 arrives (front='1', back='1').";
            front_sensor_tb <= '1'; -- Car 2 arrives
            back_sensor_tb  <= '1'; -- Car 1 is passing
            wait for clk_period;
            
            -- 3. Verify: System enters STOP state
            report "  State should be STOP (Red LED, 'SP').";
            wait for 20 * clk_period;
            
            -- 4. Car 1 clears the gate (back='0') and Car 2 is still at the front (front='1')
            --    This should transition from STOP -> WAIT_PASSWORD
            report "  Car 1 clears. Car 2 at front. (front='1', back='0').";
            back_sensor_tb <= '0';
            password_1_tb <= "00"; -- Clear password
            password_2_tb <= "00";
            wait for clk_period;
            report "  State should be WAIT_PASSWORD for Car 2.";

            -- 5. Process Car 2 normally
            report "  Waiting 12 cycles for Car 2 password.";
            wait for 10 * clk_period;
            report "  Entering correct password for Car 2.";
            password_1_tb <= "01";
            password_2_tb <= "10";
            wait for clk_period;
            report "  Car 2 accepted. State should be RIGHT_PASS.";
            
            -- Pass Car 2 through
            report "  Passing Car 2.";
            front_sensor_tb <= '0';
            back_sensor_tb  <= '1';
            wait for clk_period;
            back_sensor_tb  <= '0';
            password_1_tb   <= "00";
            password_2_tb   <= "00";
            wait for clk_period;

            -- End simulation
            report "  Scenario 3 Complete. System should be IDLE.";
            report "All scenarios complete. Stopping simulation.";
            wait;
    end process;

end testbench;