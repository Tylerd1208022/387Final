import uvm_pkg::*;

interface fmradio_uvm_if;
    logic clock,                    
    logic reset,                                  
    logic [DATA_WIDTH - 1 : 0] data_in,  
    logic [DATA_WIDTH - 1 : 0] volume,
    logic                      wr_en,    
    logic [DATA_WIDTH - 1 : 0] left_audio, 
    logic [DATA_WIDTH - 1 : 0] right_audio 
endinterface
