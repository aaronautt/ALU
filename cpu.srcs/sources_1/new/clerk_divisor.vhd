----------------------------------------------------------------------------------
-- Engineer: Aaron Crump
-- Class: EGR 426
-- 
-- Create Date: 01/23/2017 09:19:07 AM
-- Design Name: 
-- Module Name: clk - Behavioral
-- Project Name: roshambo
-- Target Devices: 
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

entity clk_divise is
    Port ( clock_in : in STD_LOGIC;
           clk_out : out std_logic;
           clock_out_slow : out std_logic;
           clock_out_fast : out std_logic;
           clock_out_1hz : out std_logic);
end clk_divise;
--10 ms = 100110001001011010000000
--4000000 = 40ms = 1111010000100100000000
--400000 = 4ms = 1100001101010000000
--200000 = 2ms  = 0110000110101000000
--10000 = 1/10 ms = 10011100010000
architecture Behavioral of clk_divise is

signal clk_count : std_logic_vector (18 downto 0) := "0000000000000000000";  
signal slow_count : std_logic_vector (23 downto 0) := "000000000000000000000000";
signal fast_count : std_logic_vector (13 downto 0) := "00000000000000"; --10000 hz clock
signal count1hz : std_logic_vector (26 downto 0) := "000000000000000000000000000";

-- makes three clock signals of three different speeds

-- 4 ms clock, 250 hz
begin
    process(clock_in)
    begin
        if rising_edge(clock_in) then
            clk_count <= clk_count + 1;    
            if clk_count = "1100001101010000000" then -- 4ms tick
                clk_count <= "0000000000000000000";
                clk_out <= '1';
            elsif clk_count = "0110000110101000000" then -- off at 2ms
                clk_out <= '0';
            end if;
        end if;
    end process;

-- 10 ms clock, 100 hz

    process(clock_in)
    begin
        if rising_edge(clock_in) then
            slow_count <= slow_count + 1;
            if slow_count = "100110001001011010000000" then -- 10ms tick
                slow_count <= "000000000000000000000000";
                clock_out_slow <= '1';
            elsif slow_count = "000001100001101010000000" then -- off at 2ms
                clock_out_slow <= '0';
            end if;
        end if;
    end process;
    
-- 1/10 ms clock, 10000 hz
    process(clock_in)
    begin
        if rising_edge(clock_in) then
            fast_count <= fast_count + 1;
            if fast_count = "10011100010000" then
                fast_count <= "00000000000000";
                clock_out_fast <= '1';
            elsif fast_count <= "01001110001000" then
                clock_out_fast <= '0';
            end if;
        end if;
    end process;

    --1Hz clock
    process(clock_in)
    begin
      if rising_edge(clock_in) then
        count1hz <= count1hz + 1;
        if count1hz = "101111101011110000100000000" then
          count1hz <= "000000000000000000000000000";
          clock_out_1hz <= '1';
        elsif count1hz <= "010000000000000000000000000" then
          clock_out_1hz <= '0';
        end if;
      end if;
    end process;



end Behavioral;
