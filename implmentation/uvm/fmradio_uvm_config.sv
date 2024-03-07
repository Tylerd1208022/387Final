import uvm_pkg::*;

class fmradio_uvm_configuration extends uvm_object;
    `uvm_object_utils(fmradio_uvm_configuration)

    function new(string name = "");
        super.new(name);
    endfunction: new
endclass: fmradio_uvm_configuration
