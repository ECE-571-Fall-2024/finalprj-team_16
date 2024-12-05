vlog apb.sv tb.sv

vopt work.tb_apb_master_slave -o tb_apb_master_slave_opt

vsim work.tb_apb_master_slave -voptargs=+acc

add wave -position insertpoint  \
sim:/tb_apb_master_slave/apb_intf/pclk

add wave -position insertpoint  \
sim:/tb_apb_master_slave/apb_intf/preset_n

add wave -position insertpoint  \
sim:/tb_apb_master_slave/apb_intf/psel

add wave -position insertpoint  \
sim:/tb_apb_master_slave/apb_intf/penable

add wave -position insertpoint  \
sim:/tb_apb_master_slave/apb_intf/paddr

add wave -position insertpoint  \
sim:/tb_apb_master_slave/uut/add_i

add wave -position insertpoint  \
sim:/tb_apb_master_slave/uut/external_wdata_i

add wave -position insertpoint  \
sim:/tb_apb_master_slave/uut/rdata_o

add wave -position insertpoint  \
sim:/tb_apb_master_slave/uut/ready_o

run -all
