----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2017 05:31:51 PM
-- Design Name: 
-- Module Name: ALU_TOP - Behavioral
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
USE ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_TOP is
  Port (clk,reset : in STD_LOGIC;
        an_sel : out STD_LOGIC_VECTOR(3 downto 0);
        seven : out STD_LOGIC_VECTOR(6 downto 0);
        Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
        Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
        btn_in : in STD_LOGIC_VECTOR(1 downto 0));
end ALU_TOP;

architecture Behavioral of ALU_TOP is

  component cpu is
    PORT(clk : in STD_LOGIC;
         clk_250 :in STD_LOGIC;
         reset : in STD_LOGIC;
         Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
         Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
         OutportA, OutportB : out STD_LOGIC_VECTOR(6 downto 0);
         btn_in : in STD_LOGIC_VECTOR(1 downto 0);
         PWM_DC : out STD_LOGIC_VECTOR(3 downto 0));
  end component;


  
  component mux is
    port(an_sel : out std_logic_vector (3 downto 0); --anode selection
         seven : out std_logic_vector (6 downto 0); -- seven segment display selection
           clk : in std_logic;
           InportA, InportB : in std_logic_vector(6 downto 0));
  end component;


  component clk_divise is
    Port ( clock_in : in STD_LOGIC;
           clk_out : out std_logic;--250Hz
           clock_out_slow : out std_logic;--100Hz
           clock_out_fast : out std_logic;--1000hz
           clock_out_1hz : out std_logic);--1Hz
  end component;


  ---------------PWM component ----------------------------------
  -- component PWM is
  --   Port (clk : in std_logic;
  --         DC : in std_logic_vector(3 downto 0); -- a number between 0 and 10
  --         LED_sig : out std_logic);
  -- end component;


signal portA, portB : std_logic_vector(6 downto 0);
signal clk250, clk100, clk1k, clk1hz : std_logic;
  signal pwm_dc : std_logic_vector(3 downto 0);
  signal PC : UNSIGNED(8 downto 0);
  signal IR : STD_LOGIC_VECTOR(7 downto 0);
  signal MDR : STD_LOGIC_VECTOR(7 downto 0);

  signal A,B,C : SIGNED(7 downto 0);
  signal N,Z,V : STD_LOGIC;
-- ---------- Declare the common data bus ------------------
  signal DATA : STD_LOGIC_VECTOR(7 downto 0);

begin
---
  -- uncomment this to run it on a simulation
  C1 : cpu port map (clk => clk1hz, reset => reset, Inport1 => Inport1, Inport0 => Inport0, 
                     OutportB => portB, OutportA => portA, Outport1 => Outport1,
                     Outport0 => Outport0, clk_250 => clk250, btn_in => btn_in,
                     PWM_DC => pwm_dc, PCt => PC,
                     IRt => IR,
                     MDRt => MDR,
                     At => A,
                     Bt => B,
                     Ct => C,
                     Nt => N,
                     Zt => Z,
                     Vt => V,
                     DATAt => DATA);

--uncomment this for the board
  C1 : cpu port map (clk => clk1hz, reset => reset, Inport1 => Inport1, Inport0 => Inport0, 
                     OutportB => portB, OutportA => portA, Outport1 => Outport1,
                     Outport0 => Outport0, clk_250 => clk250, btn_in => btn_in,
                     PWM_DC => pwm_dc);
  

--  P1 : PWM port map(clk => clk1k, DC => pwm_dc, )

  M1 : mux port map (clk => clk250, an_sel => an_sel, seven => seven,
                     InportA => portA, InportB => portB);

  C2 : clk_divise port map (clock_in => clk, clk_out => clk250, clock_out_fast => clk1k,
                            clock_out_slow => clk100, clock_out_1hz => clk1hz);

end Behavioral;
