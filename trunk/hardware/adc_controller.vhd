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
           interrupt : out  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (7 downto 0);
			  
           adc_address_latch_enable : out  STD_LOGIC;
           adc_output_enable : out  STD_LOGIC;
           adc_start : in  STD_LOGIC;
           adc_end_of_conversion : in  STD_LOGIC;
			  adc_clk : out std_logic);
end adc_controller;

architecture Behavioral of adc_controller is

	signal clk_count : natural range 0 to 110 := 0;

begin

	process(clk)
	begin
		if clk'event and clk = '1' then
			if clk_count = 110 then
				clk_count <= 0;
			else
				clk_count <= clk_count + 1;
			end if;
		end if;
	end process;
	
	process(clk_count)
	begin
		if clk_count < 55 then
			adc_clk <= '0';
		else
			adc_clk <= '1';
		end if;
	end process;

end Behavioral;

