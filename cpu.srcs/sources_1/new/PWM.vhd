----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2017 09:19:09 AM
-- Design Name: 
-- Module Name: PWM - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PWM is
  Port (clk : in std_logic;
        DC : in std_logic_vector(7 downto 0); -- a number between 0 and 10
        LED_sig : out std_logic);
end PWM;

architecture Behavioral of PWM is

  --01100100 "100" in binary
  signal pwm_count : std_logic_vector(7 downto 0) := "00000000";
  signal duty_cycle : std_logic_vector(7 downto 0) := "00000000"; 
begin

 pwm_pr0c : process(clk)
 begin
   if rising_edge(clk) then
     pwm_count <= pwm_count + 1;

     if DC > "01100100" then
       duty_cycle <= "00000000";
     else
       duty_cycle <= DC;
     end if;

     if pwm_count = "01100101" then --at 101 pwm count resets
       pwm_count <= "00000000";
     end if;

     if pwm_count = "00000000" and duty_cycle > "00000000" then
       LED_sig <= '1';
     elsif pwm_count = duty_cycle then
       LED_sig <= '0';
     else
       LED_sig <= '0';
     end if;
     end if;
   end process;




end Behavioral;
