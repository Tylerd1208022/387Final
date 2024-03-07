history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -new /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Multiplier.prj
add_file Multiplier.sv
add_file IQRead.sv
add_file IIR.sv
add_file FM_Top.sv
add_file FIR.sv
add_file fifo.sv
add_file divider_tb.sv
project -new /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Add.prj
add_file Add.sv
add_file arctan.sv
add_file comparator.sv
add_file demodulator.sv
add_file divider.sv
add_file fifo.sv
add_file FIR.sv
add_file FIR_CMPLX.sv
add_file FM_Top.sv
add_file IIR.sv
add_file IQRead.sv
add_file Multiplier.sv
add_file Sub.sv
add_file testFIR.sv
add_file testFIR_CMPLX.sv
add_file testIIR.sv
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
add_file -verilog ./Add.sv
add_file -verilog ./arctan.sv
add_file -verilog ./comparator.sv
add_file -verilog ./demodulator.sv
add_file -verilog ./divider.sv
add_file -verilog ./fifo.sv
add_file -verilog ./FIR.sv
add_file -verilog ./FIR_CMPLX.sv
add_file -verilog ./FM_Top.sv
add_file -verilog ./IIR.sv
add_file -verilog ./IQRead.sv
add_file -verilog ./Multiplier.sv
add_file -verilog ./Sub.sv
project -run  
set_option -top_module top_level
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Multiplier.prj
project -close /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Add.prj
