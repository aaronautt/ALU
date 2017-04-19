----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 05:54:30 PM
-- Design Name: 
-- Module Name: microram_sim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- This file simulates a 512x8 synchronous RAM component.
-- The program to be executed is encoded by initializing the "mem_data" signal (see below).
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity microram_sim is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity microram_sim;

architecture a of microram_sim is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.

--This test memory will load 4 into register A, and 9 into register B, and then
--BCD a, then B
signal mem_data : t_mem_data := (0 =>"11110000", --clear a
                                 1 =>"11110001", --clear b
                                 2 =>"00000001", --load B, 29
                                 3 =>"00011101", --location 29
                                 4 =>"00001000", --dummy out a
                                 5 =>"00000000", --Load A, 31
                                 6 =>"00011111", --load A 31
                                 7 =>"00110000", --PWMD A
                                 8 =>"00110001", --PWM B
                                 -- 7 =>"00100001", --Debounce 0, B
                                 -- 8 =>"00000000", --load a 29
                                 -- 9 =>"00011101", --location 29
                                 -- 10 =>"00000001", --load b 30
                                 -- 11 =>"00011110", --location 30
                                 -- 12 =>"00100010", --Debounce 1, A
                                 -- 13 =>"00100001", --Debounce 0, B
                                 29 =>"00000000",-- contents location 29
                                 30 =>"00001001",-- contents location 30
                                 31 =>"01001011",-- contents location 31

                                 others => "11110000"); -- all other memory locations set to CLR A instr

begin
RAM_Process : process(CLOCK)
variable memaddr : INTEGER range 0 to 511;
begin
  if(rising_edge(CLOCK)) then
     memaddr := CONV_INTEGER(ADDRESS);
     if(we='1') then
        mem_data(memaddr) <= DATAIN;
        DATAOUT <= DATAIN;
     else
        DATAOUT <= mem_data(memaddr);
     end if;
  end if;
end process;

end architecture a;

-- 0 =>"11110000", --clear a
--                                  1 =>"11110001", --clear b
--                                  2 =>"00000000", --load a loc
--                                  3 =>"00011110", --location 30
--                                  4 =>"00001000", --out a
--                                  5 =>"01000000", --bcd a
--                                  6 =>"01101101", --clear bit 3 loc
--                                  7 =>"00011110", --location 30
--                                  8 =>"00001000", --out a
--                                  9 =>"01000000", --bcd a
--                                  10 =>"11110001", --clear b
--                                  11 =>"11110001", --clear b
--                                  12 =>"00000001", --load b loc
--                                  13 =>"00011111", --location 31
--                                  14=>"00001001", --out b
--                                  15 =>"01000001", --bcd b
--                                  16 =>"00110001", --pwmd b
