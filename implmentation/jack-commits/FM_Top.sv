module top_level #(
    parameter DATA_WIDTH = 32
) (
    input logic clock,                    
    input logic reset,                  
    input logic start,                    
    input logic [DATA_WIDTH - 1 : 0] i_data,    
    input logic [DATA_WIDTH - 1 : 0] q_data,   
    input logic [DATA_WIDTH - 1 : 0] volume,    
    output logic [DATA_WIDTH - 1 : 0] left_audio, 
    output logic [DATA_WIDTH - 1 : 0] right_audio 
);
    logic [DATA_WIDTH - 1 : 0] gain;
    logic [DATA_WIDTH - 1 : 0] fir_cmplx_out, fir_demod_out, fir_mult_out, fir_add_out, fir_sub_out;
    logic [DATA_WIDTH - 1 : 0] demod, add_out, sub_out;
    logic [DATA_WIDTH - 1 : 0] gain_left_out, gain_right_out;
    logic fir_cmplx_done, fir_demod_done, fir_mult_done, fir_add_done, fir_sub_done;
    logic demod_done, add_done, sub_done, gain_left_done, gain_right_done;

    // FIR CMPLX placeholder module
    fir_cmplx #(.DATA_WIDTH(DATA_WIDTH)) fir_cmplx_inst (
        .clock(clock),
        .reset(reset),
        .start(start),
        .data_in(i_data),
        .data_out(fir_cmplx_out),
        .done(fir_cmplx_done)
    );

    // Demodulator module
    demodulator #(.DATA_WIDTH(DATA_WIDTH)) demod_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_cmplx_done),
        .x(fir_cmplx_out),
        .y(q_data),
        .gain(gain),
        .done(demod_done),
        .demod(demod)
    );

    // FIR after demodulation placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_demod_inst (
        .clock(clock),
        .reset(reset),
        .start(demod_done),
        .data_in(demod_out),
        .data_out(fir_demod_out),
        .done(fir_demod_done)
    );

    // Adder module
    adder #(.DATA_WIDTH(DATA_WIDTH)) add_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_demod_done),
        .addend1(fir_demod_out),
        .addend2(fir_demod_out), // Placeholder for actual second addend
        .sum(add_out),
        .complete(add_done)
    );

    // FIR after addition placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_add_inst (
        .clock(clock),
        .reset(reset),
        .start(add_done),
        .data_in(add_out),
        .data_out(fir_add_out),
        .done(fir_add_done)
    );

    // Subtractor module
    subtractor #(.DATA_WIDTH(DATA_WIDTH)) sub_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_demod_done),
        .minuend(fir_demod_out),
        .subtrahend(fir_demod_out), // Placeholder for actual second subtrahend
        .difference(sub_out),
        .complete(sub_done)
    );

    // FIR after subtraction placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_sub_inst (
        .clock(clock),
        .reset(reset),
        .start(sub_done),
        .data_in(sub_out),
        .data_out(fir_sub_out),
        .done(fir_sub_done)
    );

    // Gain (multiplier) module for left audio
    multiplier #(.DATA_WIDTH(DATA_WIDTH)) gain_left_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_add_done),
        .multiplicand(fir_add_out),
        .multiplier(volume),
        .product(gain_left_out),
        .complete(gain_left_done)
    );

    // Gain (multiplier) module for right audio
    multiplier #(.DATA_WIDTH(DATA_WIDTH)) gain_right_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_sub_done),
        .multiplicand(fir_sub_out),
        .multiplier(volume),
        .product(gain_right_out),
        .complete(gain_right_done)
    );

    // Output assignment for left and right audio channels
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            left_audio <= 0;
            right_audio <= 0;
        end else if (gain_left_done && gain_right_done) begin
            left_audio <= gain_left_out;
            right_audio <= gain_right_out;
        end
    end

endmodule
