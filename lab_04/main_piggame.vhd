library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity main_piggame is
    port(
        SW : in std_logic_vector(15 downto 0); --! Switches for input
        BTN : in std_logic_vector(4 downto 0); --! Buttons for input
        CLK : in std_logic; --! Clock input
        LED : out std_logic_vector(15 downto 0); --! LEDs for output
        SSEG_CAT : out std_logic_vector(7 downto 0); --! Seven Segment Cathodes
        SSEG_AN : out std_logic_vector(3 downto 0); --! Seven Segment Anodes
        RST : in std_logic --! Reset input
    );
end entity main_piggame;

architecture behavioural of main_piggame is
    constant TMR_CNTR_MAX	 : std_logic_vector(16 downto 0) := "11000011010100000"; 
    constant TMR_CNTR_BLINK : std_logic_vector(26 downto 0) := "110000110101000000000000000"; 
    constant TMR_VAL_MAX	 : std_logic_vector(3 downto 0) := "1001"; 

    signal tmrCntr : std_logic_vector(26 downto 0) := (others => '0');
    signal tmrCntrBlink : std_logic_vector(26 downto 0) := (others => '0');
    signal digit0, digit1, digit2, digit3 : std_logic_vector(3 downto 0);
    signal btnReg : std_logic_vector(4 downto 0) := (others => '0');
    signal btnDetect : std_logic := '0';
    signal btnDeBnc : std_logic_vector(4 downto 0) := (others => '0');
    signal lock_cntr_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal RST1, RST2 : std_logic := '0';
    signal LDT1, LDT2 : std_logic := '0';
    signal FP, CP : std_logic := '0';
    signal ENADIE, LDSU, RSSU, BP1 : std_logic := '0';
    signal center_edge, up_edge, down_edge, right_edge, left_edge : std_logic := '0';
    signal HOLD, ROLL, NEWGAME, DIE1, WIN : std_logic := '0';

    --COMPONENTS DEFINITIONS--
component debouncer
  port (
    -- Enter port declarations here:
    -- * A "clock" clock input
    -- * A "reset" reset input
    -- * AN input for the "bouncy" button
    -- * One output for the "pulse" pulse
    clock   : in  std_logic;
    reset   : in  std_logic;
    bouncy  : in  std_logic;
    pulse   : out std_logic
  );
    end component;

component seven_segment_driver
    port(
        clock : in std_logic;
        reset : in std_logic; -- Active High Reset
        digit0 : in std_logic_vector( 3 downto 0 ); -- Rightmost digit
        digit1 : in std_logic_vector( 3 downto 0 );
        digit2 : in std_logic_vector( 3 downto 0 );
        digit3 : in std_logic_vector( 3 downto 0 ); -- Leftmost digit
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 3 downto 0 )
    );
end component;

component datapath 
    port(
        clock  : in std_logic; --! Clock
        reset  : in std_logic; --! Reset
        ENADIE : in std_logic; --! Enable Die to increment
        LDSU   : in std_logic; --! Add DIE to SUR register
        LDT1   : in std_logic; --! Add SUR to TR1 register
        LDT2   : in std_logic; --! Add SUR to TR2 register
        RSSU   : in std_logic; --! Reset SUR register
        RST1   : in std_logic; --! Reset TR1 register
        RST2   : in std_logic; --! Reset TR2 register
        CP     : inout std_logic; --! current player (register outside)
        FP     : inout std_logic; --! First player (register outside)
        DIGIT0 : out std_logic_vector( 3 downto 0 ); --! digit to the right
        DIGIT1 : out std_logic_vector( 3 downto 0 ); --! 2nd digit to the left
        DIGIT2 : out std_logic_vector( 3 downto 0 ); --! 3rd digit to the left
        DIGIT3 : out std_logic_vector( 3 downto 0 ); --! digit to the left
        LEDDIE : out std_logic_vector(2 downto 0); --! LEDs to display the die value
        DIE1   : out std_logic; --! signal that a one has been obtained
        WN     : out std_logic --! WIN has been achieved by a player
    );
end component;

component controluint
    port(
                clock  : in std_logic; --! Clock
        reset  : in std_logic; --! Reset
        ENADIE : in std_logic; --! Enable Die to increment
        LDSU   : in std_logic; --! Add DIE to SUR register
        LDT1   : in std_logic; --! Add SUR to TR1 register
        LDT2   : in std_logic; --! Add SUR to TR2 register
        RSSU   : in std_logic; --! Reset SUR register
        RST1   : in std_logic; --! Reset TR1 register
        RST2   : in std_logic; --! Reset TR2 register
        CP     : inout std_logic; --! current player (register outside)
        FP     : inout std_logic; --! First player (register outside)
        DIGIT0 : out std_logic_vector( 3 downto 0 ); --! digit to the right
        DIGIT1 : out std_logic_vector( 3 downto 0 ); --! 2nd digit to the left
        DIGIT2 : out std_logic_vector( 3 downto 0 ); --! 3rd digit to the left
        DIGIT3 : out std_logic_vector( 3 downto 0 ); --! digit to the left
        LEDDIE : out std_logic_vector(2 downto 0); --! LEDs to display the die value
        DIE1   : out std_logic; --! signal that a one has been obtained
        WN     : out std_logic --! WIN has been achieved by a player
    );
end component;

begin
    --COMPONENT INSTANTIATIONS--
    center_detect: debouncer
    port map(
        clock => CLK,
        reset => RST,
        bouncy => BTN(0),
        pulse => center_edge
    );

    up_detect: debouncer
    port map(
        clock => CLK,
        reset => RST,
        bouncy => BTN(1),
        pulse => up_edge
    );

    down_detect: debouncer
    port map(
        clock => CLK,
        reset => RST,
        bouncy => BTN(3),
        pulse => down_edge
    );

    right_detect: debouncer
    port map(
        clock => CLK,
        reset => RST,
        bouncy => BTN(4),
        pulse => right_edge
    );

    left_detect: debouncer
    port map(
        clock => CLK,
        reset => RST,
        bouncy => BTN(2),
        pulse => left_edge
    );

    thedriver: seven_segment_driver
    port map(
        clock => CLK,
        reset => RST,
        digit0 => digit0,
        digit1 => digit1,
        digit2 => digit2,
        digit3 => digit3,
        CA => SSEG_CAT(0),
        CB => SSEG_CAT(1),
        CC => SSEG_CAT(2),
        CD => SSEG_CAT(3),
        CE => SSEG_CAT(4),
        CF => SSEG_CAT(5),
        CG => SSEG_CAT(6),
        DP => SSEG_CAT(7),
        AN => SSEG_AN
    );

    datapath_inst : datapath
    port map(
        clock  => CLK,
        reset  => RST,
        ENADIE => ENADIE,
        LDSU   => LDSU,
        LDT1   => LDT1,
        LDT2   => LDT2,
        RSSU   => RSSU,
        RST1   => RST1,
        RST2   => RST2,
        CP     => CP,
        FP     => FP,
        DIGIT0 => digit0,
        DIGIT1 => digit1,
        DIGIT2 => digit2,
        DIGIT3 => digit3,
        LEDDIE => LED(2 downto 0),
        DIE1   => DIE1,
        WN     => WIN
    );

    controlunit_inst : controluint
    port map(
        clock  => CLK,
        reset  => RST,
        ENADIE => ENADIE,
        LDSU   => LDSU,
        LDT1   => LDT1,
        LDT2   => LDT2,
        RSSU   => RSSU,
        RST1   => RST1,
        RST2   => RST2,
        CP     => CP,
        FP     => FP,
        DIGIT0 => digit0,
        DIGIT1 => digit1,
        DIGIT2 => digit2,
        DIGIT3 => digit3,
        LEDDIE => LED(2 downto 0),
        DIE1   => DIE1,
        WN     => WIN
    );
    
    --PROCESSES--
    time_blink_process: process(CLK) begin
    end process time_blink_process;

    check_cp: process(CP) begin
    end process check_cp;

end behavioural ;