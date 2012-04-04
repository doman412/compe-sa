--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:25:59 04/03/2012
-- Design Name:   
-- Module Name:   C:/Users/Tom/Desktop/compe-sa/hardware/fast_to_slow_domain_converter_tb.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fast_to_slow_domain_converter
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
 
ENTITY fast_to_slow_domain_converter_tb IS
END fast_to_slow_domain_converter_tb;
 
ARCHITECTURE behavior OF fast_to_slow_domain_converter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fast_to_slow_domain_converter
    PORT(
         fast_signal : IN  std_logic;
         target_domain_clk : IN  std_logic;
         slow_signal : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal fast_signal : std_logic := '0';
   signal target_domain_clk : std_logic := '0';
	signal fast_clk : std_logic := '0';

 	--Outputs
   signal slow_signal : std_logic;

   -- Clock period definitions
	constant fast_clk_period : time := 10 ns;
   constant target_domain_clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fast_to_slow_domain_converter PORT MAP (
          fast_signal => fast_signal,
          target_domain_clk => target_domain_clk,
          slow_signal => slow_signal
        );

   -- Clock process definitions
   target_domain_clk_process :process
   begin
		target_domain_clk <= '0';
		wait for target_domain_clk_period/2;
		target_domain_clk <= '1';
		wait for target_domain_clk_period/2;
   end process;
	
	process
	begin
		fast_clk <= '0';
		wait for fast_clk_period/2;
		fast_clk <= '1';
		wait for fast_clk_period/2;
	end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		fast_signal <= '1';
		wait for fast_clk_period;
		fast_signal <= '0';

      wait;
   end process;

END;
