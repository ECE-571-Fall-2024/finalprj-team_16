#Simple SDC constraints file
current_design ${top_design}
# Define clock for the design
create_clock -name clk -period 2.0 P_clk

# Set the Input and Output delay constraints
set_input_delay  1.5 -clock clk -max [all_inputs]
set_output_delay 1.5 -clock clk -max [all_outputs]

# Set any data-path optimization constraints
set_max_delay 0.5 -from [all_inputs] -to [all_outputs]

# Set any timing exception constraints
set_false_path -from P_rst
set_multicycle_path -from P_rst -to [all_outputs] 2


