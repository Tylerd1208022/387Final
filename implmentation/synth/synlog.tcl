history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -new /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/arctan.prj
add_file arctan.sv
add_file Add.sv
add_file comparator.sv
add_file demodulator.sv
add_file divider.sv
add_file fifo.sv
add_file FIR.sv
add_file FM_Top.sv
add_file FIR_CMPLX.sv
add_file IIR.sv
add_file IQRead.sv
add_file Multiplier.sv
add_file Sub.sv
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/arctan.prj
