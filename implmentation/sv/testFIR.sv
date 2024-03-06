`timescale 1ns/1ns

module FIR_tb();

    logic clock, reset, done, dataAvail, in_rd_en;
    logic [31:0] data, dotProd;

    FIR #(
        .TAP_COUNT(32),
        .DECIMATION_FACTOR(32),
        .MULT_PER_CYCLE(1),
        .DATA_WIDTH(32),
        .TAPS('{1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8})
    ) inst (
        .clock(clock),
        .reset(reset),
        .newData(data),
        .newDataAvailible(dataAvail),
        .dotProd(dotProd),
        .done(done),
        .in_rd_en(in_rd_en)
    );

    always #10 clock = ~clock;
    int i;
    initial begin
        clock = 1;
        reset = 1;
        data = 0;
        dataAvail = 0;
        #10 reset = 0;
        #50;
        i = 0;
        dataAvail = 1;
       while(i < 50) begin
            i = i + 1;
            data = i;
            #20;
        end
        #500;
        $finish;
    end

endmodule