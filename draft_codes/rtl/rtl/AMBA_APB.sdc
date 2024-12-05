# Define the primary clock
# Assuming a 100 MHz clock period for P_clk (adjust if different)
create_clock -name P_clk -period 10.0 [get_ports P_clk]

# Set input delay constraints
# Assuming a 2 ns delay for external input setup time (adjust based on environment)
set_input_delay 2.0 -clock P_clk [get_ports {P_rst P_addr P_selx P_enable P_write P_wdata}]

# Set output delay constraints
# Assuming a 2 ns delay for external output hold time (adjust based on environment)
set_output_delay 2.0 -clock P_clk [get_ports {P_ready P_slverr P_rdata}]

# Specify max transition time for design reliability
# Assuming a 2 ns max transition time for all nets
set_max_transition 2.0 [all_clocks]
set_max_transition 2.0 [all_inputs]
set_max_transition 2.0 [all_outputs]

# Specify max capacitance (for driving outputs and nets)
# Assuming a 10 pF max capacitance (adjust based on environment)
set_max_capacitance 10.0 [all_inputs]
set_max_capacitance 10.0 [all_outputs]

# Specify max fanout for better timing
# Assuming a max fanout of 10 (adjust based on design requirements)
set_max_fanout 10.0 [all_inputs]
set_max_fanout 10.0 [all_outputs]

# Define timing exceptions to avoid over-constraining
# False path: Setup state transitions are not timing-critical
set_false_path -from [get_registers present_state_reg] -to [get_registers next_state_reg]

# Multicycle paths: Assume transitions between states occur in 2 clock cycles
set_multicycle_path 2 -from [get_registers present_state_reg] -to [get_registers next_state_reg]

# Add constraints for internal signals if required
# Uncomment and specify additional signals if needed
# set_input_delay 2.0 -clock P_clk [get_ports internal_signal]
# set_output_delay 2.0 -clock P_clk [get_ports internal_signal]
