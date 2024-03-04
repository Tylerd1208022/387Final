history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -new /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj
add_file arctan.sv
add_file comparator.sv
add_file demodulator.sv
add_file divider.sv
project -run  
timing_corr::q_opt_corr_qii  -impl_name {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj|rev_1}  -impl_result {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/rev_1/divider.vqm}  -sdc_verif 
timing_corr::q_correlate_db_qii  -paths_per 1  -qor 1  -sdc_verif  -impl_name {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj|rev_1}  -impl_result {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/rev_1/divider.vqm}  -load_sta 
timing_corr::pro_qii_corr  -paths_per 1  -qor 1  -sdc_verif  -impl_name {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj|rev_1}  -impl_result {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/rev_1/divider.vqm}  -load_sta 
timing_corr::q_correlate_db_qii  -paths_per 1  -qor 1  -sdc_verif  -impl_name {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj|rev_1}  -impl_result {/home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/rev_1/divider.vqm}  -load_sta 
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Winter24/FPGA/387Final/implmentation/sv/Demodulator/arctan.prj
