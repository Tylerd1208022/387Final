setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/Demodulator/comparator.sv"
vlog -work work "../../sv/Demodulator/divider.sv"
vlog -work work "../../sv/Demodulator/arctan.sv"
vlog -work work "../../sv/Demodulator/demodulator.sv"
vlog -work work "../../sv/Demodulator/demod_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.demod_tb -wlf demod_tb.wlf

add wave -noupdate -group demod_tb/inst/
add wave -noupdate -group demod_tb/inst/ -radix hexadecimal demod_tb/inst/*

add wave -noupdate -group demod_tb/inst/atan_inst/
add wave -noupdate -group demod_tb/inst/atan_inst/ -radix hexadecimal demod_tb/inst/atan_inst/*

run -all