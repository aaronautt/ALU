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
signal mem_data : t_mem_data := (0  =>"11110000",-- clear a
                                 1  =>"11110001",-- clear b
                                 2  =>"00001000",--  Out A
                                 3  =>"00000000",--  load a
                                 4  =>"00011110",--  location 30
                                 5  =>"00001000",--  Out A
                                 6  =>"01101101",-- clear bit 3 location 30
                                 7  =>"00011110",-- location 30
                                 8  =>"00001000",-- out a
                                 9  =>"00000000",--  load a
                                 10  =>"00011110",--  location 30
                                 11  =>"00001000",--  Out A
                                 29 =>"00000100",-- contents location 29
                                 30 =>"00001001",-- contents location 30
                                 31 =>"00001010",-- contents location 31

                                 --0  =>"11110000",--  clear
                                 --1  =>"00000000",--  load a
                                 --2  =>"00011101",--  location 29
                                 --3  =>"00001000",--  Out A
                                 --4  =>"01000000",--  BCD A
                                 --5  ="00001000">"10100000",--  lsl r
                                 --6  =>"00001000",--  Out A
                                 --7  =>"00100000",--  debounce a
                                 --8  =>"00001000",--  out a
                                 --9  =>"01000000",--  bcd a
                                 --10 =>"00000001",-- load b
                                 --11 =>"00011110",-- location 30
                                 --12 =>"10000000",-- add a
                                 --13 =>"00001000",-- out a
                                 --14 =>"01000000",-- bcd a
                                 --15 =>"11110000",-- clear a
                                 --16 =>"11110001",-- clear b
                                 --17 =>"00000000",-- load a location 31
                                 --18 =>"00011111",-- location 31
                                 --19 =>"00001000",--  Out A
                                 --20 =>"01101101",-- clear bit 3 location 31
                                 --21 =>"00011111",-- location 31
                                 --22 =>"00001000",-- out a
                                 --23 =>"00000000",-- load a location 31
                                 --24 =>"00011111",-- location 31
                                 --25 =>"00001000",--  Out A
                                 --26 =>"00000000",--
                                 --27 =>"00000000",--
                                 --28 =>"00000000",--
                                 --29 =>"00000100",-- contents location 29
                                 --30 =>"00001001",-- contents location 30
                                 --31 =>"00001010",-- contents location 31

--0 => "11110000", -- CLR A (dummy first instruction)
                                 --1 => "00000000", -- LOAD 13,A  
                                 --2 => X"0D",      -- ADDRESS -> 13
                                 --3 => "00001000", -- OUT A
                                 --4 => "01000000", -- BCDO A
                                 --5 => "10100000", -- LSL A       
                                 --6 => "00001000", -- OUT A
                                 --7 => "01100000", -- debounce 0, A
                                 --8 => "00001000", -- OUT A
                                 --9 => "00000001", -- LOAD 14,B  
                                 --10 => X"0E",      -- ADDRESS -> 14
                                 --11 => "10000000", -- ADD A 
                                 --12 => "00001000", -- OUT A       
                                 ---- test data --
                                 --13 => "00000001", -- memory location 10 set to 1
                                 --14 => "00000101", -- memory location 11 set to 5
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

