setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/FIR.sv"
vlog -work work "../sv/testFIR.sv"

vsim -voptargs=+acc +notimingchecks -L work work.FIR_tb -wlf FIR_tb.wlf

add wave -noupdate -group FIR_tb/inst/
add wave -noupdate -group FIR_tb/inst/ -radix hexadecimal FIR_tb/inst/*

run -all