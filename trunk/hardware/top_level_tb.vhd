--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:38:55 04/02/2012
-- Design Name:   
-- Module Name:   C:/Users/Tom/Desktop/compe-sa/hardware/top_level_tb.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_level
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
 
ENTITY top_level_tb IS
END top_level_tb;
 
ARCHITECTURE behavior OF top_level_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   component top_level is
    Port (    tx : out std_logic;
              rx : in std_logic;
             clk : in std_logic;
				 led : out std_logic_vector(7 downto 0);
				 adc_clk : out std_logic;
				 adc_start : out std_logic;
				 adc_address_latch_enable : out std_logic;
				 adc_output_enable : out std_logic;
				 adc_end_of_conversion : in std_logic);
    end component;
    

   --Inputs
   signal rx : std_logic := '1';
   signal clk : std_logic := '0';
	signal adc_end_of_conversion : std_logic := '0';

 	--Outputs
   signal tx : std_logic;
   signal led : std_logic_vector(7 downto 0);
	signal adc_clk : std_logic;
	signal adc_start : std_logic;
	signal adc_address_latch_enable : std_logic;
	signal adc_output_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_level PORT MAP (
          tx => tx,
          rx => rx,
          clk => clk,
          led => led,
			 adc_clk => adc_clk,
			 adc_start => adc_start,
			 adc_address_latch_enable => adc_address_latch_enable,
			 adc_output_enable => adc_output_enable,
			 adc_end_of_conversion => adc_end_of_conversion
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
