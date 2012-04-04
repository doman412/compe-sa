----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:45:22 04/03/2012 
-- Design Name: 
-- Module Name:    adc_controller - Behavioral 
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

entity adc_controller is
    Port ( clk : in  STD_LOGIC;
           start_capture : in  STD_LOGIC;
           
           adc_address_latch_enable : out  STD_LOGIC;
           adc_output_enable : out  STD_LOGIC;
           adc_start : out  STD_LOGIC;
           adc_end_of_conversion : in  STD_LOGIC;
			 
			  new_data : out std_logic;
			  data_ack : in std_logic);
end adc_controller;

architecture Behavioral of adc_controller is

	-- Signal for the slow clock generator
	signal clk_count : natural range 0 to 110 := 0;
	
	signal adc_clk_signal : std_logic;
	
	-- Signal that triggers the ADC controller state machine
	signal start_capture_slow_domain : std_logic;
	
	-- Indicates that the data has been read from the ADC
	signal data_ack_slow_domain : std_logic;
	
	-- Component that converts fast domain signals to slow domain signals
	component fast_to_slow_domain_converter is
    Port ( fast_signal : in  STD_LOGIC;
           target_domain_clk : in  STD_LOGIC;
           slow_signal : out  STD_LOGIC);
	end component;
	
	-- State machine controller
	
	component adc_controller_state_machine is
		 Port ( adc_clk : in  STD_LOGIC;
				  start_capture : in  STD_LOGIC;
				  adc_start : out  STD_LOGIC;
				  adc_address_latch_enable : out std_logic;
				  adc_end_of_conversion : in std_logic;
				  adc_output_enable : out std_logic;
				  data_ack : in std_logic;
				  new_data : out std_logic);
	end component;


begin

	
	-- Convert the start_capture signal to the slow domain
	converter1: fast_to_slow_domain_converter port map (
		fast_signal => start_capture,
		target_domain_clk => clk,
		slow_signal => start_capture_slow_domain
	);
	
	-- Convert the data_ack signal to the slow domain
	converter2: fast_to_slow_domain_converter port map (
		fast_signal => data_ack,
		target_domain_clk => clk,
		slow_signal => data_ack_slow_domain
	);

	
	controller: adc_controller_state_machine port map (
		 adc_clk => clk,
		 start_capture => start_capture_slow_domain,
		 adc_start => adc_start,
		 adc_address_latch_enable => adc_address_latch_enable,
		 adc_end_of_conversion => adc_end_of_conversion,
		 adc_output_enable => adc_output_enable,
		 data_ack => data_ack_slow_domain,
		 new_data => new_data);
	

end Behavioral;

