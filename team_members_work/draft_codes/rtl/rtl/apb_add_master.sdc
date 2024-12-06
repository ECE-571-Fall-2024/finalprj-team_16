# Define the clock
create_clock -name pclk -period 10.0 [get_ports pclk]  
# Clock period is 10ns (100 MHz). Adjust this value to your design requirements.

# Define input delays
set_input_delay -clock pclk 2.5 [get_ports {preset_n add_i prdata_i pready_i}] 
# Input delay of 2.5ns from external source to input ports. Adjust based on external environment.

# Define output delays
set_output_delay -clock pclk 2.5 [get_ports {psel_o penable_o paddr_o pwrite_o pwdata_o}]
# Output delay of 2.5ns from output ports to external destination. Adjust based on external environment.

# Define input port driving strength
set_driving_cell -lib_cell INV_X1 -pin Z [get_ports {preset_n add_i prdata_i pready_i}]
# Use a realistic driving cell for input ports based on your technology library.

# Define output port load
set_load 0.05 [get_ports {psel_o penable_o paddr_o pwrite_o pwdata_o}]
# Set realistic output loads for the output ports. Adjust based on your target library.

# Constrain multi-bit buses
set_max_delay -from [get_ports {add_i[*]}] -to [get_ports {pwdata_o[*]}] 10.0
# Maximum delay between add_i and pwdata_o constrained to one clock period.

# Set false paths or exceptions (if applicable)
# Uncomment and customize if false paths exist:
# set_false_path -from [get_ports preset_n] -to [get_ports {psel_o penable_o paddr_o}]
# set_false_path -through [get_pins *state_q/D] # Example for state registers

# Ensure no unconstrained paths exist
set_min_delay 0.1 [all_inputs] [all_outputs]  ;# Minimum delay for all paths
set_max_delay 10.0 [all_inputs] [all_outputs] ;# Maximum delay for all paths

# Set operating conditions (optional)
set_operating_conditions WORST
# WORST ensures the design is analyzed for worst-case delays.

# Report constraints for debugging
report_timing -delay_type max -path_type full_update
report_constraints -all_violators

