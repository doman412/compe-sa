--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:54:57 04/03/2012
-- Design Name:   
-- Module Name:   C:/Users/ulab/Desktop/compe-sa/hardware/adc_controller_tb.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: adc_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY adc_controller_tb IS
END adc_controller_tb;
 
ARCHITECTURE behavior OF adc_controller_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 component adc_controller is
    Port ( clk : in  STD_LOGIC;
           start_capture : in  STD_LOGIC;
           
           adc_address_latch_enable : out  STD_LOGIC;
           adc_output_enable : out  STD_LOGIC;
           adc_start : out  STD_LOGIC;
           adc_end_of_conversion : in  STD_LOGIC;
			 
			  new_data : out std_logic;
			  data_ack : in std_logic);
end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start_capture : std_logic := '0';
   signal adc_end_of_conversion : std_logic := '0';
	signal data_ack : std_logic := '0';

 	--Outputs
	signal adc_address_latch_enable : std_logic;
   signal adc_output_enable : std_logic;
	signal adc_start : std_logic;
	signal new_data : std_logic;

   -- Clock period definitions
   constant clk_period : time := 2 ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: adc_controller PORT MAP (
          clk => clk,
          start_capture => start_capture,
           adc_address_latch_enable => adc_address_latch_enable,
          adc_output_enable => adc_output_enable,
          adc_start => adc_start,
          adc_end_of_conversion => adc_end_of_conversion,
				data_ack => data_ack,
				new_data => new_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
