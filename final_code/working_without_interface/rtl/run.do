vlog apb_package.sv apb.sv tb_apb.sv

vopt work.tb_apb +acc -o tb3_opt

vsim -voptargs=+acc work.tb_apb

//add wave -position insertpoint sim:/tb_apb/*  ...*/

quit -sim
