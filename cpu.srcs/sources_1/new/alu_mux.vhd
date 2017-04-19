----------------------------------------------------------------------------------
-- Engineer: Aaron Crump
-- Class: EGR 426
-- Create Date: 01/29/2017 02:49:08 PM
-- Design Name: 
-- Module Name: mux - Behavioral
-- Project Name: ROSHAMBO
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux is
  port(an_sel : out std_logic_vector (3 downto 0); --anode selection
       seven : out std_logic_vector (6 downto 0); -- seven segment display selection
       clk : in std_logic;
       InportA, InportB : in std_logic_vector(6 downto 0);
       InportC, InportD : in std_logic_vector(6 downto 0));
end mux;

architecture Behavioral of mux is

    --on each clock tick one of the displays is written to
begin
MUX: process(clk)
variable count : std_logic_vector (1 downto 0) := "00";
      begin
        if rising_edge(clk) then
            count := count + 1;
            case count is
            when "00" =>
                an_sel <= "0111";
                seven <= InportB;
            when "01" =>
                an_sel <= "1011";
                seven <= InportA;
            when "10" =>
                an_sel <= "1101";
                seven <= InportD;
            when "11" =>
                an_sel <= "1110";
                seven <= InportC;
            when others =>
                an_sel <= "XXXX";
                seven <= "XXXXXXX";
            end case;
        end if;
   end process;



end Behavioral;
