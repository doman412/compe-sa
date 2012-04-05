----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:43:33 04/04/2012 
-- Design Name: 
-- Module Name:    slow_to_fast_domain_converter - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity slow_to_fast_domain_converter is
    Port ( fast_signal : out  STD_LOGIC;
           target_domain_clk : in  STD_LOGIC;
           slow_signal : in  STD_LOGIC);
end slow_to_fast_domain_converter;

architecture Behavioral of slow_to_fast_domain_converter is

	type state_type is (nothing, low, high);
	signal current_state, next_state : state_type := nothing;

begin

	process(target_domain_clk)
	begin
		if rising_edge(target_domain_clk) then
			current_state <= next_state;
		end if;
	end process;
	
	process(current_state, slow_signal)
	begin
		case current_state is
			when nothing =>
				if slow_signal = '0' then
					next_state <= low;
				else
					next_state <= nothing;
				end if;
			when low =>
				if slow_signal = '0' then
					next_state <= low;
				else
					next_state <= high;
				end if;
			when high =>
				if slow_signal = '0' then
					next_state <= low;
				else
					next_state <= nothing;
				end if;
			when others =>
				next_state <= nothing;
		end case;
	end process;
	
	fast_signal <= '1' when current_state = high else '0';

end Behavioral;

