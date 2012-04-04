----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:38:50 04/03/2012 
-- Design Name: 
-- Module Name:    adc_controller_state_machine - Behavioral 
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

entity adc_controller_state_machine is
    Port ( adc_clk : in  STD_LOGIC;
           start_capture : in  STD_LOGIC;
           adc_start : out  STD_LOGIC;
			  adc_address_latch_enable : out std_logic;
			  adc_end_of_conversion : in std_logic;
			  adc_output_enable : out std_logic;
			  data_ack : in std_logic;
			  new_data : out std_logic);
end adc_controller_state_machine;

architecture Behavioral of adc_controller_state_machine is

	type state_type is (idle, address_latch_up, starting, address_latch_down, waiting_for_conversion_eoc_high, waiting_for_conversion_eoc_low, raise_output_enable, data_ready);
	signal current_state, next_state : state_type := idle;
	
	-- Data Registers
	signal adc_start_current, adc_start_next : std_logic := '0';
	signal adc_address_latch_enable_current, adc_address_latch_enable_next : std_logic := '0';
	signal adc_output_enable_current, adc_output_enable_next : std_logic := '0';

begin

	-- State Latch Process
	process(adc_clk)
	begin
		if rising_edge(adc_clk) then
			current_state <= next_state;
		end if;
	end process;
	
	-- Next state process
	process(current_state, start_capture, adc_end_of_conversion, data_ack)
	begin
		case current_state is
			when idle =>
				if start_capture = '1' then
					next_state <= address_latch_up;
				else
					next_state <= idle;
				end if;
			when address_latch_up =>
				next_state <= starting;
			when starting =>
				next_state <= address_latch_down;
			when address_latch_down =>
				next_state <= waiting_for_conversion_eoc_high;
			when waiting_for_conversion_eoc_high =>
				if adc_end_of_conversion = '1' then
					next_state <= waiting_for_conversion_eoc_high;
				else
					next_state <= waiting_for_conversion_eoc_low;
				end if;
			when waiting_for_conversion_eoc_low =>
				if adc_end_of_conversion = '0' then
					next_state <= waiting_for_conversion_eoc_low;
				else
					next_state <= raise_output_enable;
				end if;
				
			when raise_output_enable =>
				next_state <= data_ready;
				
			when data_ready =>
				if data_ack = '1' then
					next_state <= idle;
				else
					next_state <= data_ready;
				end if;
			
			when others =>
				next_state <= idle;
				
		end case;
	end process;
	
	-- Data Latch Process
	process(adc_clk)
	begin
		if rising_edge(adc_clk) then
			adc_start_current <= adc_start_next;
			adc_address_latch_enable_current <= adc_address_latch_enable_next;
			adc_output_enable_current <= adc_output_enable_next;
		end if;
	end process;
	
	-- Next Data Logic
	process(current_state, adc_start_current, adc_address_latch_enable_current, adc_output_enable_current)
	begin
		-- By default, registers will keep their current value
		adc_start_next <= adc_start_current;
		adc_address_latch_enable_next <= adc_address_latch_enable_current;
		adc_output_enable_next <= adc_output_enable_current;
	
		case current_state is
			when idle =>
				adc_output_enable_next <= '0';
			when address_latch_up =>
				adc_address_latch_enable_next <= '1';
			when starting =>
				adc_start_next <= '1';
			when address_latch_down =>
				adc_address_latch_enable_next <= '0';
			when waiting_for_conversion_eoc_high =>
				adc_start_next <= '0';
			when waiting_for_conversion_eoc_low =>
				-- Keep as defaults
				
			when raise_output_enable =>
				adc_output_enable_next <= '1';
				
			when data_ready =>
				-- Leave as defaults
			
			when others =>
				-- Leave as defaults
		end case;
	end process;

	-- Assign outputs
	adc_start <= adc_start_current;
	adc_address_latch_enable <= adc_address_latch_enable_current;
	adc_output_enable <= adc_output_enable_current;
	
	new_data <= '1' when current_state = data_ready else '0';


end Behavioral;

