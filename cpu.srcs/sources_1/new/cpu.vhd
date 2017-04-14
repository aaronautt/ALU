----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 05:19:26 PM
-- Design Name: 
-- Module Name: cpu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
  PORT(clk : in STD_LOGIC;
       clk_250, clk100k : in STD_LOGIC;
       reset : in STD_LOGIC;
       Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
       Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
       OutportA, OutportB : out STD_LOGIC_VECTOR(6 downto 0);
       btn_in : in STD_LOGIC_VECTOR(1 downto 0));
end cpu;

-- entity cpu is
--   PORT(clk : in STD_LOGIC;
--        clk_250 : in STD_LOGIC;
--        reset : in STD_LOGIC;
--        Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
--        Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
--        OutportA, OutportB : out STD_LOGIC_VECTOR(6 downto 0);
--        btn_in : in STD_LOGIC_VECTOR(1 downto 0);
--        PCt : out UNSIGNED(8 downto 0);
--        IRt : out STD_LOGIC_VECTOR(7 downto 0);
--        MDRt : out STD_LOGIC_VECTOR(7 downto 0);
--        At,Bt,Ct : out SIGNED(7 downto 0);
--        Nt,Zt,Vt : out STD_LOGIC;
--        DATAt : out STD_LOGIC_VECTOR(7 downto 0));
-- end cpu;


architecture a of cpu is
-- ----------- Declare the ALU component ----------
component alu is
port(A, B : in SIGNED(7 downto 0);
        F : in STD_LOGIC_VECTOR(2 downto 0);
        Y : out SIGNED(7 downto 0);
    N,V,Z : out STD_LOGIC);
end component;
-- ------------ Declare signals interfacing to ALU -------------
signal ALU_A, ALU_B : SIGNED(7 downto 0);
signal ALU_FUNC : STD_LOGIC_VECTOR(2 downto 0);
signal ALU_OUT : SIGNED(7 downto 0);
signal ALU_N, ALU_V, ALU_Z : STD_LOGIC;

-- ------------ Declare the 512x8 RAM component --------------
component microram is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	 );
end component;

--  component microram_sim is
--  port (  CLOCK   : in STD_LOGIC ;
--  		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
--  		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
--  		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
--  		WE	: in STD_LOGIC 
--  	 );
-- end component;

---------------PWM component ----------------------------------
component PWM is
  Port (clk : in std_logic;
        DC : in std_logic_vector(7 downto 0); -- a number between 0 and 100
        LED_sig : out std_logic);
end component;


-- ---------- Declare signals interfacing to RAM ---------------
signal RAM_DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);  -- DATAOUT output of RAM
signal ADDR : STD_LOGIC_VECTOR(8 downto 0);	         -- ADDRESS input of RAM
signal RAM_WE : STD_LOGIC;



-- ---------- Declare the state names and state variable -------------
type STATE_TYPE is (Fetch, Operand, Memory, Memory2, Execute, Execute2);
signal CurrState : STATE_TYPE;
-- ---------- Declare the internal CPU registers -------------------
signal PC : UNSIGNED(8 downto 0);
signal IR : STD_LOGIC_VECTOR(7 downto 0);
signal MDR : STD_LOGIC_VECTOR(7 downto 0);

--Added the additional C register for the clear bit function
signal A,B,C : SIGNED(7 downto 0);
signal N,Z,V : STD_LOGIC;
-- ---------- Declare the common data bus ------------------
signal DATA : STD_LOGIC_VECTOR(7 downto 0);
signal DATA_QU : STD_LOGIC_VECTOR(7 downto 0);

-- -----------------------------------------------------
-- This function returns TRUE if the given op code is a
-- 4-phase instruction rather than a 2-phase instruction
-- -----------------------------------------------------	
function Is4Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
  variable MSB5 : STD_LOGIC_VECTOR(4 downto 0);
  variable MSB3 : STD_LOGIC_VECTOR(2 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB3 := DATA(7 downto 5);
  MSB5 := DATA(7 downto 3);
  if(MSB5 = "00000" or MSB3 = "011") then
	 RETVAL := true;
  else
	 RETVAL := false;
  end if;
 return RETVAL;
end function;

-----------------------------------------------------------------
--Function for BCD, takes in an 8 bit # from 0 to 99, returns an 8 bit number
--where bit 7-4 are the 10's digit and 3-0 are the 1's digit
-----------------------------------------------------------------
function BCD_conv(constant input : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
  variable output : STD_LOGIC_VECTOR(6 downto 0);
begin
  
  case input is
    when "0000" => output := "0000001";  -- '0'
    when "0001" => output := "1001111";  -- '1'
    when "0010" => output := "0010010";  -- '2'
    when "0011" => output := "0000110";  -- '3'
    when "0100" => output := "1001100";  -- '4' 
    when "0101" => output := "0100100";  -- '5'
    when "0110" => output := "0100000";  -- '6'
    when "0111" => output := "0001111";  -- '7'
    when "1000" => output := "0000000";  -- '8'
    when "1001" => output := "0000100";  -- '9'
    when others => output := "1110111";  -- dash in the middle for everything else
  end case;

  return output;
end function;

-----------------------------------------------------------------------------
--Function for clear bit that clears a specified bit in a vector
-----------------------------------------------------------------------------
function clear_bit(constant input : STD_LOGIC_VECTOR(7 downto 0); constant clr_bit : integer)
  return STD_LOGIC_VECTOR is
  variable output : STD_LOGIC_VECTOR(7 downto 0);
begin
  output := input;
  output(clr_bit) := '0';
  return output;
end function;

  
	
-- --------- Declare variables that indicate which registers are to be written --------
-- --------- from the DATA bus at the start of the next Fetch cycle. ------------------
signal Exc_RegWrite : STD_LOGIC;        -- Latch data bus in A or B
signal Exc_CCWrite : STD_LOGIC;         -- Latch ALU status bits in CCR
signal Exc_IOWrite : STD_LOGIC;         -- Latch data bus in I/O
signal Exc_DoubleWrite : STD_LOGIC; -- latch both data into seven seg I/O
signal Exc_DBWrite : STD_LOGIC;         --debounce flag
signal Exc_ClrWrite : STD_LOGIC;        -- clear bit flag
signal Exc_PWMWrite : STD_LOGIC;        --pwm write flag
-- flag for debounce state, 00 means it's not running, 01 means it's running,
--10 means it finished and returned true, 11, means it finished and returned false
signal debounce_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal debounce_count1, debounce_count0 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal debounce_out1, debounce_out0 : STD_LOGIC_VECTOR(7 downto 0);
signal last_Inport1, last_Inport0 : STD_LOGIC := '0';

----------------------------------------------------------------------
-- extra 9 bit register to hold last memory location
signal last_reg : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
----------------------------------------------------------------------
--clear bit signals
----------------------------------------------------------------------
signal clr_bit_reg : STD_LOGIC_VECTOR(7 downto 0);

----------PWM signals
signal pwm_dc : STD_LOGIC_VECTOR(7 downto 0);
begin

--PCt <= PC;
--IRt <= IR;
--MDRt <= MDR;
--At <= A;
--Bt <= B;
--Ct <= C;
--Nt <= N;
--Zt <= Z;
--Vt <= V;
--DATAt <= DATA;

-- ------------ Instantiate the ALU component ---------------
U1 : alu PORT MAP (ALU_A, ALU_B, ALU_FUNC, ALU_OUT, ALU_N, ALU_V, ALU_Z);
			
-- ------------ Drive the ALU_FUNC input ----------------
ALU_FUNC <= IR(6 downto 4);
	
-- ------------ Instantiate the RAM component -------------
U2 : microram PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

--U2 : microram_sim PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

-----------------Instantiate PWM controller
P1 : PWM port map(clk => clk100k, DC => pwm_dc, LED_sig => Outport1(7));



-- ---------------- Generate RAM write enable ---------------------
-- The address and data are presented to the RAM during the Memory phase, 
-- hence this is when we need to set RAM_WE high.
process (CurrState,IR)
begin
  if((CurrState = Memory and IR(7 downto 2) = "000001") or
     (CurrState = Memory2)) then
	  RAM_WE <= '1';
  else
	  RAM_WE <= '0';
  end if;
end process;

-------------------------------------------------------------------
--debounce process
-- constantly checks to see if inports are changin and updates two
--registers for debounced output
------------------------------------------------------------------
process (clk, DATA, IR, Inport0)
begin
  if rising_edge(clk) then
    debounce_count1 <= debounce_count1 + 1;
    debounce_count0 <= debounce_count0 + 1;
    if last_Inport1 /= Inport0(1) or Inport0(1) = '1' then
      debounce_count1 <= "0000";
      last_Inport1 <= Inport0(1);
      debounce_out1 <= "00000000";
    end if;

    if last_Inport0 /= Inport0(0) or Inport0(0) = '1' then
      debounce_count0 <= "0000";
      last_Inport0 <= Inport0(0);
      debounce_out0 <= "00000000";
    end if;


    if (debounce_count0 = "0011" and last_Inport0 = Inport0(0) and Inport0(0) = '0') then
      debounce_out0 <= "00000001";
      debounce_count0 <= "0000";
      last_Inport0 <= Inport0(0);
    end if;

    if (debounce_count1 = "0011" and last_Inport1 = Inport0(1) and Inport0(1) = '0') then
      debounce_out1 <= "00000001";
      last_Inport1 <= Inport0(1);
      debounce_count1 <= "0000";
    end if;
    end if;

  end process;


          


	
-- ---------------- Generate address bus --------------------------
with CurrState select
	 ADDR <= STD_LOGIC_VECTOR(PC) when Fetch,
			 STD_LOGIC_VECTOR(PC) when Operand,  -- really a don't care
  IR(1) & MDR when Memory,
  last_reg when Memory2,
			 STD_LOGIC_VECTOR(PC) when Execute,
			 STD_LOGIC_VECTOR(PC) when others;   -- just to be safe
				
-- --------------------------------------------------------------------
-- This is the next-state logic for the 4-phase state machine.
-- --------------------------------------------------------------------
process (clk,reset)
  variable temp : integer;
begin
  if(reset = '1') then
    CurrState <= Fetch;
    PC <= (others => '0');
    IR <= (others => '0');
    MDR <= (others => '0');
    A <= X"01";
    B <= (others => '0');
    N <= '0';
    Z <= '0';
    V <= '0';
    Outport0 <= (others => '0');
    Outport1 <= (others => '0');
    OutportB <= (others => '1');
    OutportA <= (others => '1');
    temp := 0;
  elsif(rising_edge(clk)) then
    case CurrState is
		  when Fetch => IR <= DATA;
                    if(Is4Phase(DATA)) then
                      PC <= PC + 1;
                      --temp := temp + 1;
                      CurrState <= Operand;
                    --elsif (DATA(7 downto 5) = "011") then
                    --  PC <= PC + 1;
                    --  temp := temp + 1;
                    --  CurrState <= Operand;
                    else
                      CurrState <= Execute;
                    end if;

      when Operand => MDR <= DATA;
                      CurrState <= Memory;

      when Memory =>
        CurrState <= Execute;
        last_reg <= ADDR;

      when Memory2 => CurrState <= Execute2;

      when Execute2 =>
        PC <= PC + 1;
        CurrState <= Fetch;


      when Execute => --if(temp = 2) then 
		                    PC <= PC + 1;
                      --else
                        --PC <= PC + 1;
                        --temp := temp +1;
                      --end if;
                      CurrState <= Fetch;
                      --if Exc_ClrWrite = '1' then
                      --  CurrState <= Memory2;
                      --else
                      --  CurrState <= Fetch;
                      --end if;

                      
                      if(Exc_RegWrite = '1') then   -- Writing result to A or B
                        if(IR(0) = '0') then
                          A <= SIGNED(DATA);
                        else
                          B <= SIGNED(DATA);
                        end if;
                      end if;
                      
                      if(Exc_CCWrite = '1') then    -- Updating flag bits
                        V <= ALU_V;
                        N <= ALU_N;
                        Z <= ALU_Z;
                      end if;


                      if(Exc_IOWrite = '1') then    -- Write to Outport0 or OutPort1
                        if(IR(1) = '0') then
                          Outport0 <= DATA;
                        else
                          --The top bit of outport1 is ignored, so that the PWM
                          --can have control of this LED
                          Outport1(6 downto 0) <= DATA(6 downto 0);
                        end if;
                      end if;

                      if(Exc_DoubleWrite = '1') then -- write to seven seg s
                        OutportA <= BCD_conv(std_logic_vector(DATA(3 downto 0)));
                        OutportB <= BCD_conv(std_logic_vector(DATA(7 downto 4)));
                      end if;

                      if(Exc_DBWrite = '1') then
                          if(IR(0) = '0') then
                            A <= signed(DATA);
                          else
                            B <= signed(DATA);
                          end if;
                      end if;

                      if Exc_ClrWrite = '1' then
                        C <= signed(clear_bit(DATA, conv_integer(unsigned(IR(4 downto 2)))));
                        CurrState <= Memory2;
                        N <= ALU_N; -- set flag bits
                        Z <= ALU_Z;
                      end if;

                        if Exc_PWMWrite = '1' then
                          pwm_dc <= DATA;
                        end if;
                      
			when Others => CurrState <= Fetch;
		end case;
	end if;
end process;

	
process (CurrState,RAM_DATA_OUT,A,B,ALU_OUT,Inport0,Inport1,IR) 
variable bcd_temp : STD_LOGIC_VECTOR(13 downto 0);
begin
-- Set these to 0 in each phase unless overridden, just so we don't
-- generate latches (which are unnecessary).
  
  Exc_RegWrite <= '0';
  Exc_CCWrite <= '0';
  Exc_IOWrite <= '0';
  Exc_DoubleWrite <= '0';
  Exc_DBWrite <= '0';
  Exc_ClrWrite <= '0';
  Exc_PWMWrite <= '0';

-- Same idea
  ALU_A <= A;
  ALU_B <= B;

-- Same idea
  DATA <= RAM_DATA_OUT;

  case CurrState is
    when Fetch | Operand => DATA <= RAM_DATA_OUT;
                            
    when Memory => if(IR(0) = '0') then
                     DATA <= STD_LOGIC_VECTOR(A);
                   else
                     DATA <= STD_LOGIC_VECTOR(B);
                   end if;

    when Memory2 => DATA <= STD_LOGIC_VECTOR(C); -- This should write the
                                                 -- edited value of C to the
                                                 -- data location

    when Execute2 =>
      null; -- trying to just add some time here.

    when Execute => case IR(7 downto 1) is
      when "1000000" 			-- ADD R
                            | "1001000"			-- SUB R
                            | "1100000"			-- XOR R
                            | "1111000" =>			-- CLR R
        DATA <= STD_LOGIC_VECTOR(ALU_OUT);
        Exc_RegWrite <= '1';
        Exc_CCWrite <= '1';
        
      when "1010000"			-- LSL R
        | "1011000"			-- LSR R
        | "1101000"			-- COM R
        | "1110000" =>			-- NEG R
        if(IR(0) = '0') then
          ALU_A <= A;
        else
          ALU_A <= B;
        end if;
                    
                    DATA <= STD_LOGIC_VECTOR(ALU_OUT);
                    Exc_RegWrite <= '1';
						        Exc_CCWrite <= '1'; 
    when "0000100"|"0000101" =>          -- OUT R,P
      if(IR(0) = '0') then
        DATA <= STD_LOGIC_VECTOR(A);
      else
        DATA <= STD_LOGIC_VECTOR(B);
      end if;
      Exc_IOWrite <= '1';
      
    when "0000110"|"0000111" =>	         -- IN P,R
      if(IR(1) = '0') then
        DATA <= Inport0;
      else
        DATA <= Inport1;
      end if;
      Exc_RegWrite <= '1';
      
    when "0000000"|"0000001" =>          -- LOAD M,R
      DATA <= RAM_DATA_OUT;
      Exc_RegWrite <= '1';

    when "0011000" => --PWM duty cycle PWMD R #0011000R
      if(IR(0) = '0') then
        DATA <= STD_LOGIC_VECTOR(A);
      else
        DATA <= STD_LOGIC_VECTOR(B);
      end if;
      Exc_PWMWrite <= '1';

    when "0110010"|"0110100"|"0110110"|"0111000"|"0111010"|"0111100"|"0111110"|"0110000"|"0110011"|"0110101"|"0110111"|"0111001"|"0111011"|"0111101"|"0111111"|"0110001" => ---Clear bit, in #011xxxp1
      Exc_ClrWrite <= '1';
      DATA <= RAM_DATA_OUT;

    
    when "0100000" =>    --BCD 0 #0100000r
      if(IR(0) = '0') then
        DATA <= STD_LOGIC_VECTOR(A);
      else
        DATA <= STD_LOGIC_VECTOR(B);
      end if;
      Exc_DoubleWrite <= '1';

    when "0010000"|"0010001" =>    --Debounce
      if IR(1) = '0' then
        DATA <= debounce_out0;
      else
        DATA <= debounce_out1;
      end if;

      Exc_DBWrite <= '1';


    when "0000010"|"0000011" =>	       -- STOR R,M
      null;
      
    when others => null;
  end case;
end case;	
end process;

end a;

