----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:44:06 03/21/2012 
-- Design Name: 
-- Module Name:    pwm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm is
	Port (
		clk : in std_logic;
		duty : in std_logic_vector(7 downto 0);
		pulse : out std_logic
	);
end pwm;

architecture Behavioral of pwm is

	signal count_current : std_logic_vector(7 downto 0) := (others => '0');
	signal count_next : std_logic_vector(7 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			count_current <= count_next;
		end if;
	end process;
	
	count_next <= std_logic_vector(unsigned(count_current) + 1);
	pulse <= '1' when count_current < duty else '0';

end Behavioral;

