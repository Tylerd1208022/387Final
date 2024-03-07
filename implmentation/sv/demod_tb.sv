`timescale 1ns/1ns

module demod_tb();


    logic clock, reset, start, done;
    logic [31:0] x, y, gain, demod;

    demodulator#(
        .DATA_WIDTH(32)
    ) inst (
        .clock(clock),
        .reset(reset),
        .start(start),
        .x(x),
        .y(y),
        .gain(gain),
        .done(done),
        .demod(demod)
    );

    always #10 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;
        start = 0;
        x = 102;
        y = 204;
        gain = 2;
        #10;
        reset = 0;
        #10 start = 1;
        #20 start = 0;
        #790;
        start = 1;
        x = 409;
        y = 512;
        #20 start = 0;
        #1000;
        $finish;
    end


endmodule