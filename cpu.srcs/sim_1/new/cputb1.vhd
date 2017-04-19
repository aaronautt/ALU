----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 06:53:38 PM
-- Design Name: 
-- Module Name: cputb1 - Behavioral
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


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
entity cputb1 is
end cputb1;
 
architecture behavior of cputb1 is 
-- Component Declaration for the Unit Under Test (UUT)
  component cpu is
    PORT(clk : in STD_LOGIC;
         clk_250, clk100k :in STD_LOGIC;
         reset : in STD_LOGIC;
         Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
         Outport0 : out STD_LOGIC_VECTOR(7 downto 0);
         Outport1 : out STD_LOGIC_VECTOR(6 downto 0);
         PWM_OUT : out STD_LOGIC;
         OutportA, OutportB : out STD_LOGIC_VECTOR(6 downto 0);
         btn_in : in STD_LOGIC_VECTOR(1 downto 0));
  end component;

  

--Inputs
signal clk, clk_250, clk100k : std_logic := '0';
signal reset : std_logic := '1';
signal Inport0 : std_logic_vector(7 downto 0) := (others => '0');
signal Inport1 : std_logic_vector(7 downto 0) := (others => '0');
signal btn_in : std_logic_vector(1 downto 0) := "00";

--Outputs
signal Outport0 : std_logic_vector(7 downto 0);
signal Outport1 : std_logic_vector(6 downto 0);
signal an_sel : std_logic_vector(3 downto 0);
signal seven : std_logic_vector(6 downto 0);
  signal OutportA, OutportB : std_logic_vector(6 downto 0);
  signal PWM_OUT : std_logic;

  signal PC : UNSIGNED(8 downto 0);
  signal IR : STD_LOGIC_VECTOR(7 downto 0);
  signal MDR : STD_LOGIC_VECTOR(7 downto 0);

  signal A,B,C : SIGNED(7 downto 0);
  signal N,Z,V : STD_LOGIC;

  
  signal DATA : STD_LOGIC_VECTOR(7 downto 0);
-- Clock period definitions
constant clk_period : time := 10ns;
 
begin
-- Instantiate the Unit Under Test (UUT)
--C1 : ALU_TOP PORT MAP (clk => clk, reset => reset, Inport0 => Inport0, Inport1 => Inport1,
--                       Outport0 => Outport0, Outport1 => Outport1, btn_in => btn_in,
--                       an_sel => an_sel, seven => seven);

  C1 : cpu port map (clk => clk, reset => reset, Inport1 => Inport1, Inport0 => Inport0, 
                     OutportB => OutportB, OutportA => OutportA, Outport1 => Outport1,
                     Outport0 => Outport0, clk_250 => clk_250, btn_in => btn_in,
                     PWM_OUT => PWM_OUT, clk100k => clk100k);
-- Clock process 
clk_process : process begin
              clk <= '0'; wait for clk_period/2;
		      clk <= '1'; wait for clk_period/2;
              end process;

-- Stimulus process
stim_proc : process begin		
            wait for 100ns;     -- hold reset state for 100ns.
            reset <= '0';
            -- Inport0 <= "00000011"; --both buttons high, should, Debounce should Write
            -- --0's to register A and B
            -- wait for (13 * clk_period);--wait 12 clock cycles,
            -- Inport0 <= "00000000"; --both buttons high, should debounce 1's
            -- wait for (12 * clk_period);--wait 12 clock cycles
            
            wait;
            end process;

end;

