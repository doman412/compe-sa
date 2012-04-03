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
 
    COMPONENT adc_controller
    PORT(
         clk : IN  std_logic;
         start_capture : IN  std_logic;
         interrupt : OUT  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         adc_address_latch_enable : OUT  std_logic;
         adc_output_enable : OUT  std_logic;
         adc_start : IN  std_logic;
         adc_end_of_conversion : IN  std_logic;
         adc_clk : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start_capture : std_logic := '0';
   signal adc_start : std_logic := '0';
   signal adc_end_of_conversion : std_logic := '0';

 	--Outputs
   signal interrupt : std_logic;
   signal data : std_logic_vector(7 downto 0);
   signal adc_address_latch_enable : std_logic;
   signal adc_output_enable : std_logic;
   signal adc_clk : std_logic;

   -- Clock period definitions
   constant clk_period : time := 18 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: adc_controller PORT MAP (
          clk => clk,
          start_capture => start_capture,
          interrupt => interrupt,
          data => data,
          adc_address_latch_enable => adc_address_latch_enable,
          adc_output_enable => adc_output_enable,
          adc_start => adc_start,
          adc_end_of_conversion => adc_end_of_conversion,
          adc_clk => adc_clk
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
