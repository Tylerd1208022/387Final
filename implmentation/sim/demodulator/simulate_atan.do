setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/Demodulator/comparator.sv"
vlog -work work "../../sv/Demodulator/divider.sv"
vlog -work work "../../sv/Demodulator/arctan.sv"
vlog -work work "../../sv/Demodulator/arctan_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.arctan_tb -wlf arctan_tb.wlf

add wave -noupdate -group arctan_tb/inst/
add wave -noupdate -group arctan_tb/inst/ -radix hexadecimal arctan_tb/inst/*

add wave -noupdate -group arctan_tb/inst/div_inst/
add wave -noupdate -group arctan_tb/inst/div_inst/ -radix hexadecimal arctan_tb/inst/div_inst/*

run -all