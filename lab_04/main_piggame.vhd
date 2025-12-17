library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_piggame is
    port(
        SW       : in std_logic_vector(15 downto 0);
        BTN      : in std_logic_vector(4 downto 0); -- BTN(0):Center, BTN(1):Up, BTN(2):Left
        CLK      : in std_logic;
        LED      : out std_logic_vector(2 downto 0);
        SSEG_CAT : out std_logic_vector(7 downto 0);
        SSEG_AN  : out std_logic_vector(3 downto 0);
        RST      : in std_logic
    );
end entity main_piggame;

architecture behavioural of main_piggame is
    -- Costanti per timer (non critiche per questa modifica)
    signal tmrCntrBlink : std_logic_vector(26 downto 0) := (others => '0');
    
    -- Segnali per i collegamenti
    signal digit0, digit1, digit2, digit3 : std_logic_vector(3 downto 0);
    
    -- Segnali di controllo gioco
    signal HOLD, ROLL, NEWGAME : std_logic := '0';
    signal ENADIE, LDSU, RSSU, BP1 : std_logic := '0';
    signal RST1, RST2, LDT1, LDT2 : std_logic := '0';
    signal FP, CP : std_logic := '0';
    signal DIE1, WIN : std_logic := '0';

    -- NOTA: Ho rimosso i segnali intermedi inutilizzati (center_edge, btnReg, ecc.)
    -- per pulizia, dato che colleghiamo BTN direttamente.

    --COMPONENTS DEFINITIONS--
    
    -- [RIMOSSO] Component Debouncer non più necessario
    -- component debouncer ... end component;

    component seven_segment_driver
        port(
            clock : in std_logic;
            reset : in std_logic;
            digit0 : in std_logic_vector( 3 downto 0 );
            digit1 : in std_logic_vector( 3 downto 0 );
            digit2 : in std_logic_vector( 3 downto 0 );
            digit3 : in std_logic_vector( 3 downto 0 );
            CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
            AN : out std_logic_vector( 3 downto 0 )
        );
    end component;

    component datapath 
        port(
            clock   : in std_logic;
            reset   : in std_logic;
            ENADIE  : in std_logic;
            LDSU    : in std_logic;
            LDT1    : in std_logic;
            LDT2    : in std_logic;
            RSSU    : in std_logic;
            RST1    : in std_logic;
            RST2    : in std_logic;
            CP      : inout std_logic;
            FP      : inout std_logic;
            DIGIT0  : out std_logic_vector( 3 downto 0 );
            DIGIT1  : out std_logic_vector( 3 downto 0 );
            DIGIT2  : out std_logic_vector( 3 downto 0 );
            DIGIT3  : out std_logic_vector( 3 downto 0 );
            LEDDIE  : out std_logic_vector(2 downto 0);
            DIE1    : out std_logic;
            WN      : out std_logic
        );
    end component;

    component controlunit 
        port(
            clock   : in std_logic;
            reset   : in std_logic;
            ROLL    : in std_logic;
            HOLD    : in std_logic;
            NEWGAME : in std_logic;
            ENADIE  : out std_logic;
            LDSU    : out std_logic;
            LDT1    : out std_logic;
            LDT2    : out std_logic;
            RSSU    : out std_logic;
            RST1    : out std_logic;
            RST2    : out std_logic;
            BP1     : out std_logic;
            CP      : inout std_logic;
            FP      : inout std_logic;
            DIE1    : in std_logic;
            WN      : in std_logic
        );
    end component;

begin

    -- =========================================================================
    -- COLLEGAMENTI DIRETTI (Senza Debouncer)
    -- =========================================================================
    -- Qui colleghiamo direttamente il pulsante fisico al segnale logico.
    -- Nota: In simulazione è perfetto. Su hardware reale potrebbe fare
    -- qualche rimbalzo ("bounce"), ma per questo gioco spesso è tollerabile.
    
    ROLL    <= BTN(0); -- Tasto Centro = Lancia Dado
    NEWGAME <= BTN(1); -- Tasto Su     = Nuova Partita
    HOLD    <= BTN(2); -- Tasto Sinistra = Tieni Punteggio

    -- =========================================================================
    -- ISTANZIAZIONI COMPONENTI
    -- =========================================================================

    thedriver: seven_segment_driver
    port map(
        clock  => CLK,
        reset  => RST,
        digit0 => digit0,
        digit1 => digit1,
        digit2 => digit2,
        digit3 => digit3,
        CA => SSEG_CAT(0), CB => SSEG_CAT(1), CC => SSEG_CAT(2), CD => SSEG_CAT(3),
        CE => SSEG_CAT(4), CF => SSEG_CAT(5), CG => SSEG_CAT(6), DP => SSEG_CAT(7),
        AN => SSEG_AN
    );

    datapath_inst : datapath
    port map(
        clock   => CLK,
        reset   => RST,
        ENADIE  => ENADIE,
        LDSU    => LDSU,
        LDT1    => LDT1,
        LDT2    => LDT2,
        RSSU    => RSSU,
        RST1    => RST1,
        RST2    => RST2,
        CP      => CP,
        FP      => FP,
        DIGIT0  => digit0,
        DIGIT1  => digit1,
        DIGIT2  => digit2,
        DIGIT3  => digit3,
        LEDDIE  => LED(2 downto 0),
        DIE1    => DIE1,
        WN      => WIN
    );

    controlunit_inst : controlunit
    port map(
        clock   => CLK,
        reset   => RST,
        ROLL    => ROLL,    -- Collegato diretto a BTN(0)
        HOLD    => HOLD,    -- Collegato diretto a BTN(2)
        NEWGAME => NEWGAME, -- Collegato diretto a BTN(1)
        ENADIE  => ENADIE,
        LDSU    => LDSU,
        LDT1    => LDT1,
        LDT2    => LDT2,
        RSSU    => RSSU,
        RST1    => RST1,
        RST2    => RST2,
        BP1     => BP1,
        CP      => CP,
        FP      => FP,
        DIE1    => DIE1,
        WN      => WIN
    ); 
    
    -- =========================================================================
    -- PROCESSI ACCESSORI
    -- =========================================================================
    
    -- Visualizza il giocatore corrente sul LED 15

    


end behavioural;