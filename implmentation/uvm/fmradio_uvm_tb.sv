
import uvm_pkg::*;
import fmradio_uvm_package::*;

`include "fmradio_uvm_if.sv"

`timescale 1 ns / 1 ns

module fmradio_uvm_tb;

    fmradio_uvm_if vif();

    fmradio #(
    ) fmradio_inst (
        .clock(vif.clock),
        .reset(vif.reset),
        .data_in(vif.data_in),
        .volume(vif.volume),
        .wr_en(vif.wr_en),
        .left_audio(vif.left_audio),
        .right_audio(vif.right_audio)
    );

    initial begin
        // store the vif so it can be retrieved by the driver & monitor
        uvm_resource_db#(virtual fmradio_uvm_if)::set
            (.scope("ifs"), .name("vif"), .val(vif));

        // run the test
        run_test("fmradio_uvm_test");        
    end

    // reset
    initial begin
        vif.clock <= 1'b1;
        vif.reset <= 1'b0;
        @(posedge vif.clock);
        vif.reset <= 1'b1;
        @(posedge vif.clock);
        vif.reset <= 1'b0;
    end

    // 10ns clock
    always
        #(CLOCK_PERIOD/2) vif.clock = ~vif.clock;
endmodule






