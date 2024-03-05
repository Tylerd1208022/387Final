module iq_read #(
    parameter DATA_WIDTH = 16, 
    parameter QUANTIZE_WIDTH = 10, 
    parameter SAMPLES = 1024 // Number of I/Q samples to process
)(
    input logic clock, 
    input logic reset, 
    input logic [DATA_WIDTH*2-1:0] iq_data_in[SAMPLES], 
    output logic [QUANTIZE_WIDTH-1:0] i_data_out[SAMPLES], 
    output logic [QUANTIZE_WIDTH-1:0] q_data_out[SAMPLES] 
);

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            // Reset logic to clear the output arrays
            for (int i = 0; i < SAMPLES; i++) begin
                i_data_out[i] <= 0;
                q_data_out[i] <= 0;
            end
        end else begin
            for (int i = 0; i < SAMPLES; i++) begin
                // I upper half Q lower half
                i_data_out[i] <= iq_data_in[i][DATA_WIDTH*2-1 -: DATA_WIDTH] >> (DATA_WIDTH - QUANTIZE_WIDTH);
                q_data_out[i] <= iq_data_in[i][DATA_WIDTH-1:0] >> (DATA_WIDTH - QUANTIZE_WIDTH);
            end
        end
    end
endmodule
