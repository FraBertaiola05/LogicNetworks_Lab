library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_piggame_tb is
-- Testbench has no ports
end main_piggame_tb;

architecture Behavioral of main_piggame_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component main_piggame
    port(
        BTN      : in std_logic_vector(4 downto 0);
        CLK      : in std_logic;
        LED      : out std_logic_vector(15 downto 0);
        SSEG_CAT : out std_logic_vector(7 downto 0);
        SSEG_AN  : out std_logic_vector(3 downto 0);
        RST      : in std_logic
    );
    end component;

    -- Inputs
    signal SW  : std_logic_vector(15 downto 0) := (others => '0');
    signal BTN : std_logic_vector(4 downto 0) := (others => '0');
    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';

    -- Outputs
    signal LED      : std_logic_vector(2 downto 0);
    signal SSEG_CAT : std_logic_vector(7 downto 0);
    signal SSEG_AN  : std_logic_vector(3 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 10 ns; -- 100 MHz

    -- Costante per simulare la pressione del tasto
    -- DEVE ESSERE MAGGIORE DEL TEMPO DI DEBOUNCE DEL TUO COMPONENTE
    constant BTN_PRESS_TIME : time := 60 us; 

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: main_piggame port map (
        SW       => SW,
        BTN      => BTN,
        CLK      => CLK,
        LED      => LED,
        SSEG_CAT => SSEG_CAT,
        SSEG_AN  => SSEG_AN,
        RST      => RST
    );

    -- Clock process definitions
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- 1. RESET INIZIALE
        -- Teniamo il reset alto per un po'
        RST <= '1';
        wait for 100 ns;
        RST <= '0';
        
        wait for 100 ns;

        ------------------------------------------------------------
        -- GIOCATORE 0 (Inizia lui)
        ------------------------------------------------------------
        
        -- 2. AZIONE: ROLL (Tasto Centrale - BTN(0))
        -- Premiamo il tasto per un tempo sufficiente a superare il debouncer
        report "Simulazione: Player 0 preme ROLL";
        BTN(0) <= '1';
        wait for BTN_PRESS_TIME; -- Tempo per debounce + tempo per incrementare il dado
        BTN(0) <= '0';
        
        -- Attendiamo che la logica elabori il risultato (Stati ONE -> ROLLHOLD)
        wait for 200 ns; 

        -- 3. AZIONE: HOLD (Tasto Sinistra - BTN(2))
        -- Decidiamo di tenere il punteggio
        report "Simulazione: Player 0 preme HOLD";
        BTN(2) <= '1';
        wait for BTN_PRESS_TIME;
        BTN(2) <= '0';

        -- Attendiamo cambio turno
        wait for 200 ns;
        
        -- CHECK: LED(15) dovrebbe cambiare stato (da 0 a 1 o viceversa)
        -- indicando che ora tocca al Giocatore 1.

        ------------------------------------------------------------
        -- GIOCATORE 1
        ------------------------------------------------------------

        -- 4. AZIONE: ROLL (Tasto Centrale - BTN(0))
        report "Simulazione: Player 1 preme ROLL";
        BTN(0) <= '1';
        wait for BTN_PRESS_TIME;
        BTN(0) <= '0';
        
        wait for 200 ns;

        -- 5. AZIONE: ROLL ANCORA (Rischia!)
        report "Simulazione: Player 1 preme ROLL di nuovo";
        BTN(0) <= '1';
        wait for BTN_PRESS_TIME; 
        BTN(0) <= '0';
        
        wait for 200 ns;

        -- 6. AZIONE: HOLD
        report "Simulazione: Player 1 preme HOLD";
        BTN(2) <= '1';
        wait for BTN_PRESS_TIME;
        BTN(2) <= '0';

        ------------------------------------------------------------
        -- NUOVA PARTITA
        ------------------------------------------------------------
        wait for 500 ns;
        report "Simulazione: Richiesta NEW GAME";
        -- Tasto Su - BTN(1)
        BTN(1) <= '1';
        wait for BTN_PRESS_TIME;
        BTN(1) <= '0';

        wait for 100 ns;

        report "Fine Simulazione";
        wait;
    end process;

end Behavioral;
