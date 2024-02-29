setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -work work "../../sv/Demodulator/comparator.sv"
vlog -work work "../../sv/Demodulator/divider.sv"
vlog -work work "../../sv/Demodulator/divider_tb.sv"

vsim -voptargs=+acc +notimingchecks -L work work.divider_tb -wlf divider_tb.wlf

add wave -noupdate -group divider_tb/inst/
add wave -noupdate -group divider_tb/inst/ -radix hexadecimal divider_tb/inst/*

add wave -noupdate -group divider_tb/inst/comp/
add wave -noupdate -group divider_tb/inst/comp/ -radix hexadecimal divider_tb/inst/comp/*

run -all