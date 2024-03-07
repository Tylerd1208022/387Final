`timescale 1ns/1ns

module arctan_tb();


    logic clock, reset, start, done;
    logic [31:0]x, y, angle;

    arctan #(
        .DATA_WIDTH(32)
    ) inst (
        .clock(clock),
        .reset(reset),
        .start(start),
        .x(x),
        .y(y),
        .angle(angle),
        .done(done)
    );

    always #10 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;
        start = 0;
        x = 40;
        y = 9;
        #20;
        reset = 0;
        start = 1;
        #20
        start = 0;
        #1000;
        x = 1;
        y = 1;
        start = 1;
        #20 start = 0;
        #1000;
        $finish; 
    end

endmodule