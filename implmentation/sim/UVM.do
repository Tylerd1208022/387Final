setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../sv/Add.sv"
vlog -work work "../sv/arctan.sv"
vlog -work work "../sv/comparator.sv"
vlog -work work "../sv/demodulator.sv"
vlog -work work "../sv/divider.sv"
vlog -work work "../sv/FIR.sv"
vlog -work work "../sv/FIR_CMPLX.sv"
vlog -work work "../sv/FM_Top.sv"
vlog -work work "../sv/IIR.sv"
vlog -work work "../sv/IQRead.sv"
vlog -work work "../sv/Multiplier.sv"
vlog -work work "../sv/Sub.sv"


vsim -voptargs=+acc +notimingchecks -L work work.FM_TOP_tb -wlf FM_TOP_tb.wlf

add wave -noupdate -group FM_TOP_tb/inst/
add wave -noupdate -group FM_TOP_tb/inst/ -radix hexadecimal FM_TOP_tb/inst/*

run -all
