----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:10:52 04/03/2012 
-- Design Name: 
-- Module Name:    fast_to_slow_domain_converter - Behavioral 
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

entity fast_to_slow_domain_converter is
    Port ( fast_signal : in  STD_LOGIC;
           target_domain_clk : in  STD_LOGIC;
           slow_signal : out  STD_LOGIC);
end fast_to_slow_domain_converter;

architecture Behavioral of fast_to_slow_domain_converter is

	signal stretched : std_logic := '0';
	signal stretched_synced : std_logic := '0';
	
	type state_type is (nothing_detected, low_detected, rise_detected);
	signal current_state, next_state : state_type := nothing_detected;

begin

	-- First task is to use the fast signal to latch in a '1'
	process(fast_signal, stretched_synced)
	begin
		if stretched_synced = '1' then
			stretched <= '0';
		elsif rising_edge(fast_signal) then
			stretched <= '1';
		end if;
	end process;
	
	-- Next task is to synchronize the stretched pulse
	process(target_domain_clk)
	begin
		if rising_edge(target_domain_clk) then
			stretched_synced <= stretched;
		end if;
	end process;
	
	-- Final task is to use an edge detector to capture one clock period of the signal
	-- We use a state machine edge detector
	-- state latch process
	process(target_domain_clk)
	begin
		if rising_edge(target_domain_clk) then
			current_state <= next_state;
		end if;
	end process;
	
	-- Next state logic
	process(current_state, stretched_synced)
	begin
		case current_state is
			when nothing_detected =>
				if stretched_synced = '0' then
					next_state <= low_detected;
				else
					next_state <= nothing_detected;
				end if;
			when low_detected =>
				if stretched_synced = '1' then
					next_state <= rise_detected;
				else
					next_state <= low_detected;
				end if;
			when rise_detected =>
				next_state <= nothing_detected;
			when others =>
				next_state <= nothing_detected;
		end case;
	end process;
	
	-- Output Logic
	slow_signal <= '1' when current_state = rise_detected else '0';

end Behavioral;

