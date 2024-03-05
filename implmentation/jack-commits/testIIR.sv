`timescale 1ns / 1ns

module IIR_tb();

    logic clock, reset, newDataAvailable, done;
    logic [31:0] newData, filteredData;
    logic [31:0] FEEDFORWARD_TAPS[8], FEEDBACK_TAPS[3];

    // Instantiate the IIR module with parameter values
    IIR #(
        .TAP_COUNT(8),
        .FB_TAP_COUNT(3),
        .DECIMATION_FACTOR(1),
        .MULT_PER_CYCLE(8),
        .DATA_WIDTH(32)
    ) iir_inst (
        .clock(clock),
        .reset(reset),
        .newData(newData),
        .newDataAvailable(newDataAvailable),
        .FEEDFORWARD_TAPS(FEEDFORWARD_TAPS),
        .FEEDBACK_TAPS(FEEDBACK_TAPS),
        .filteredData(filteredData),
        .done(done)
    );

    // Clock generation
    always #10 clock = ~clock;

    // Initial block for test stimulus
    initial begin
        // Initialize the clock and reset signals
        clock = 0;
        reset = 1;
        newData = 0;
        newDataAvailable = 0;
        // Initialize the feedforward and feedback taps
        FEEDFORWARD_TAPS = '{32'd1, 32'd2, 32'd3, 32'd4, 32'd5, 32'd6, 32'd7, 32'd8};
        FEEDBACK_TAPS = '{32'd1, 32'd2, 32'd3};

        // Release reset signal
        #20 reset = 0;
        #50;
        // Generate test data sequence
        for (int i = 0; i < 50; i++) begin
            newDataAvailable = 1;
            newData = i;
            #20;
        end
        newDataAvailable = 0;
        #100;
        $finish;
    end

endmodule
