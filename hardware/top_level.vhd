--
-- KCPSM3 reference design - Real Time Clock with UART communications
--
-- Ken Chapman - Xilinx Ltd - October 2003
--
-- The design demonstrates the following:-
--           Connection of KCPSM3 to Program ROM
--           Connection of UART macros supplied with PicoBlaze with
--                Baud rate generation
--           Definition of input and output ports with 
--                Minimum decoding
--                Pipelining where appropriate
--           Interrupt circuit with
--                Simple fixed period timer
--                Automatic clearing using interrupt acknowledge from KCPSM3
--
-- The design is set up for a 55MHz system clock and UART communications rate of 38400 baud.
-- Please read design documentation to modify to your own requirements.
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2003.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
------------------------------------------------------------------------------------
--
--
entity top_level is
    Port (    tx : out std_logic;
              rx : in std_logic;
             clk : in std_logic;
				 led : out std_logic_vector(7 downto 0);
				 adc_clk : out std_logic;
				 adc_start : out std_logic;
				 adc_address_latch_enable : out std_logic;
				 adc_output_enable : out std_logic;
				 adc_end_of_conversion : in std_logic;
				 adc_data : in std_logic_vector(7 downto 0));
    end top_level;
--
------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of top_level is
--
------------------------------------------------------------------------------------
--
-- declaration of KCPSM3
--
  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component oscope
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
--
-- declaration of UART transmitter with integral 16 byte FIFO buffer
--
  component uart_tx
    Port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
						 buffer_has_data : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component;
--
-- declaration of UART Receiver with integral 16 byte FIFO buffer
--
  component uart_rx
    Port (            serial_in : in std_logic;
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
  end component;
--
-- Insert DCM component declaration here
--
component dcm
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2			  : out	  std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;


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

component slow_to_fast_domain_converter is
    Port ( fast_signal : out  STD_LOGIC;
           target_domain_clk : in  STD_LOGIC;
           slow_signal : in  STD_LOGIC);
end component;
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address         : std_logic_vector(9 downto 0);
signal instruction     : std_logic_vector(17 downto 0);
signal port_id         : std_logic_vector(7 downto 0);
signal out_port        : std_logic_vector(7 downto 0);
signal in_port         : std_logic_vector(7 downto 0);
signal write_strobe    : std_logic;
signal read_strobe     : std_logic;
signal interrupt       : std_logic;
signal interrupt_ack   : std_logic;
--
-- Signals for connection of peripherals
--
signal uart_status_port : std_logic_vector(7 downto 0);

--
-- Signals for UART connections
--
signal          baud_count : integer range 0 to 127 :=0;
signal        en_16_x_baud : std_logic;
signal       write_to_uart : std_logic;
signal				 tx_data_present : std_logic;
signal             tx_full : std_logic;
signal        tx_half_full : std_logic;
signal      read_from_uart : std_logic;
signal             rx_data : std_logic_vector(7 downto 0);
signal     rx_data_present : std_logic;
signal             rx_full : std_logic;
signal        rx_half_full : std_logic;

signal		uart_reset		: std_logic := '0';
--
-- Signals for DCM

signal clk55MHz : std_logic;
signal clk5MHz : std_logic;
signal clk500KHz : std_logic;
signal clk_count : natural range 0 to 9;
signal locked : std_logic;
signal reset : std_logic := '0';

--
-- Signals for LED
--
signal led_internal : std_logic_vector(7 downto 0) := (others => '0');

--
-- Signals for ADC
--
signal adc_data_ack : std_logic := '0';
signal adc_new_data : std_logic;
signal adc_new_data_slow_domain : std_logic;
signal adc_start_capture : std_logic := '0';



------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => '0',
                       clk => clk55MHz);
 
  program_rom: oscope
    port map(      address => address,
               instruction => instruction,
                       clk => clk55MHz);
							  
							  your_instance_name : dcm
  port map
   (-- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    CLK_OUT1 => clk55MHz,
	 CLK_OUT2 => clk5MHz,
    -- Status and control signals
    RESET  => RESET,
    LOCKED => LOCKED);
	 
	 process(clk5MHz)
	 begin
		if rising_edge(clk5MHz) then
			if clk_count = 9 then
				clk_count <= 0;
			else
				clk_count <= clk_count + 1;
			end if;
		end if;
	 end process;
	 
	 process(clk_count)
	 begin
		if clk_count < 5 then
			clk500KHz <= '0';
		else
			clk500KHz <= '1';
		end if;
	 end process;
	 
	 converter1: slow_to_fast_domain_converter
    Port map( fast_signal => adc_new_data,
           target_domain_clk => clk55MHz,
           slow_signal => adc_new_data_slow_domain);

	 
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- UART FIFO status signals to form a bus
  --

  uart_status_port <= "00" & tx_data_present & rx_data_present & rx_full & rx_half_full & tx_full & tx_half_full ;

  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk55MHz)
  begin
    if clk55MHz'event and clk55MHz='1' then
	 
		case port_id(1 downto 0) is

        
        -- read UART status at address 00 hex
        when "00" =>    in_port <= uart_status_port;

        -- read UART receive data at address 01 hex
        when "01" =>    
			in_port <= rx_data;
			
			when "10" =>
				in_port <= adc_data;
				
			when "11" =>
				in_port <= "0000000" & adc_new_data;
        
        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    in_port <= "XXXXXXXX";  

      end case;

      -- Form read strobe for UART receiver FIFO buffer.
      -- The fact that the read strobe will occur after the actual data is read by 
      -- the KCPSM3 is acceptable because it is really means 'I have read you'!

     if port_id(1 downto 0) = "01" and read_strobe = '1' then
		read_from_uart <= '1';
	  else
		read_from_uart <= '0';
	  end if;
	  
	  -- Form data acknowledge for ADC
	  
	  if port_id(1 downto 0) = "10" and read_strobe = '1' then
		adc_data_ack <= '1';
	  else
		adc_data_ack <= '0';
	  end if;

    end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

--  -- adding the output registers to the clock processor
--   
  output_ports: process(clk55MHz)
  begin
  
	

    if rising_edge(clk55MHz) then
		--Defaults
		write_to_uart <= '0';
		uart_reset <= '0';
		adc_start_capture <= '0';
		
		if write_strobe = '1' then
			case port_id(1 downto 0) is
				when "00" =>
					uart_reset <= '1';
				when "01" =>
					-- out_port is already wired to uart_tx, just need to strobe
					-- write_to_uart signal
					write_to_uart <= '1';
				when "10" =>
					led_internal <= out_port;
					
				when "11" =>
					adc_start_capture <= '1';
				when others =>
					-- Do nothing
			end case;
		end if;
    end if; 

  end process output_ports;

  --
  -- write to UART transmitter FIFO buffer at address 01 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --
	
  -- write_to_uart <= write_strobe and port_id(0);
  
  
  --
  -- No interrupt yet
  --
  interrupt <= '0';
  
  -- Map signal to out
  led <= led_internal;
  

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- UART  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --

  transmit: uart_tx 
  port map (            data_in => out_port, 
                   write_buffer => write_to_uart,
                   reset_buffer => uart_reset,
                   en_16_x_baud => en_16_x_baud,
                     serial_out => tx,
							buffer_has_data => tx_data_present,
                    buffer_full => tx_full,
               buffer_half_full => tx_half_full,
                            clk => clk55MHz );

  receive: uart_rx
  port map (            serial_in => rx,
                         data_out => rx_data,
                      read_buffer => read_from_uart,
                     reset_buffer => uart_reset,
                     en_16_x_baud => en_16_x_baud,
              buffer_data_present => rx_data_present,
                      buffer_full => rx_full,
                 buffer_half_full => rx_half_full,
                              clk => clk55MHz );  
										
										
	my_adc: adc_controller
    Port map ( clk => clk500KHz,
           start_capture => adc_start_capture,
           
			  
           adc_address_latch_enable => adc_address_latch_enable,
           adc_output_enable => adc_output_enable,
           adc_start => adc_start,
           adc_end_of_conversion => adc_end_of_conversion,
			
			  new_data => adc_new_data_slow_domain,
			  data_ack => adc_data_ack);
  
 --
  -- Set baud rate to 38400 for the UART communications
  -- Requires en_16_x_baud to be 614400Hz which is a single cycle pulse every 90 cycles at 55MHz 
  --
  -- NOTE : If the highest value for baud_count exceeds 127 you will need to adjust 
  --        the range of integers in the signal declaration for baud_count.
  --

  baud_timer: process(clk55MHz)
  begin
    if clk55MHz'event and clk55MHz='1' then
      if baud_count=89 then
           baud_count <= 0;
         en_16_x_baud <= '1';
       else
           baud_count <= baud_count + 1;
         en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_timer;
  
  adc_clk <= clk500KHz;
  reset <= '0';
end Behavioral;
