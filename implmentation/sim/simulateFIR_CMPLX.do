setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/FIR_CMPLX.sv"
vlog -work work "../sv/testFIR_CMPLX.sv"

vsim -voptargs=+acc +notimingchecks -L work work.FIR_CMPLX_tb -wlf FIR_CMPLX_tb.wlf

add wave -noupdate -group FIR_CMPLX_tb/inst/
add wave -noupdate -group FIR_CMPLX_tb/inst/ -radix hexadecimal FIR_CMPLX_tb/inst/*

run -all