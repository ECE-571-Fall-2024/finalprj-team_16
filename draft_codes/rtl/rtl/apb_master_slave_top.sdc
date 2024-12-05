# Define clock
create_clock -name pclk -period 10.0 [get_ports pclk]

# Input delay constraints (adjusted to tighter limits for optimization)
set_input_delay -clock pclk -max 2.0 [get_ports preset_n]
set_input_delay -clock pclk -min 0.5 [get_ports preset_n]
set_input_delay -clock pclk -max 2.0 [get_ports add_i]
set_input_delay -clock pclk -min 0.5 [get_ports add_i]

# Output delay constraints (optimized for tighter margins)
set_output_delay -clock pclk -max 2.0 [get_ports ready_o]
set_output_delay -clock pclk -min 0.5 [get_ports ready_o]
set_output_delay -clock pclk -max 2.0 [get_ports rdata_o]
set_output_delay -clock pclk -min 0.5 [get_ports rdata_o]

# Clock uncertainty to account for jitter (reduced for tighter timing control)
set_clock_uncertainty 0.1 [get_clocks pclk]

# Input and output transition time constraints (driving cell updated for more realistic scenarios)
set_driving_cell -lib_cell INVX2 [get_ports preset_n]
set_driving_cell -lib_cell INVX2 [get_ports add_i]
set_load 0.2 [get_ports ready_o]
set_load 0.2 [get_ports rdata_o]

# False paths (removed; assuming all paths are valid, can re-add specific cases if needed)
# Example:
# set_false_path -from [get_ports add_i] -to [get_ports ready_o]

# Multicycle paths (none defined, but can add as required)
# Example:
# set_multicycle_path -setup 2 -from [get_ports add_i] -to [get_ports ready_o]

# Max and min delay constraints (tuned for realistic timing requirements)
set_max_delay 8.0 -from [get_ports add_i] -to [get_ports ready_o]
set_min_delay 0.2 -from [get_ports add_i] -to [get_ports ready_o]

# Additional general constraints
set_max_area 12000       
# Adjusted maximum area for optimization flexibility
set_max_capacitance 0.4  
# Reduced capacitance for lower delay and tighter control

# Ensure Design Compiler knows the hierarchical structure
set_case_analysis 0 [get_ports preset_n]  
# Default reset is active low


