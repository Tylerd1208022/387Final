history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -new /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj
add_file arctan.sv
add_file comparator.sv
add_file demodulator.sv
add_file divider.sv
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj
