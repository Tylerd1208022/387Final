module IIR #(
    parameter TAP_COUNT = 2,
    parameter FB_TAP_COUNT = 2,
    parameter DECIMATION_FACTOR = 1,
    parameter MULT_PER_CYCLE = 1,
    parameter DATA_WIDTH = 32
)(
    input logic                     clock,
    input logic                     reset,
    input logic [DATA_WIDTH - 1:0]  newData,
    input logic                     newDataAvailable,
    input logic                     rd_en,
    output logic [DATA_WIDTH - 1:0] filteredData,
    output logic                    done,
    output logic                    in_rd_en
);
    //Insert from fm_radio.h
    localparam [0:TAP_COUNT-1][DATA_WIDTH - 1:0]FB_TAPS = {(32'h000000B2),(32'h000000B2)};
    localparam [0:31][DATA_WIDTH - 1:0] TAPS= {(32'h00000000),(32'hFFFFFD66),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),
    (32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),
    (32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0),(32'h0)};


    logic [DATA_WIDTH - 1:0] fir_output;
    logic fir_done;
    FIR #(
        .TAP_COUNT(TAP_COUNT),
        .DECIMATION_FACTOR(DECIMATION_FACTOR),
        .MULT_PER_CYCLE(MULT_PER_CYCLE),
        .DATA_WIDTH(DATA_WIDTH),
        .TAPS(TAPS)
    ) feedforward_fir (
        .clock(clock),
        .reset(reset),
        .newData(newData),
        .newDataAvailible(newDataAvailable),
        .rd_en(rd_en),
        .dotProd(fir_output),
        .done(fir_done),
        .in_rd_en(in_rd_en)
    );

    typedef enum logic[1:0] {IDLE, CALC_FEEDBACK, DONE_CALC} IIRstate;
    IIRstate state_s, state_n;

    logic [FB_TAP_COUNT:0][DATA_WIDTH - 1:0] feedback_delays ;
    logic [DATA_WIDTH - 1:0] feedback_result;
    logic [DATA_WIDTH - 1:0] filteredData_n;

    always_comb begin
        state_n = state_s;
        feedback_result = 0;
        filteredData_n = filteredData;
        done = 0;

        case (state_s)
            IDLE: begin
                if (newDataAvailable) begin
                    state_n = CALC_FEEDBACK;
                end
            end
            CALC_FEEDBACK: begin
                for (int i = 0; i < FB_TAP_COUNT; i++) begin
                    feedback_result += feedback_delays[i] * FB_TAPS[i];
                end
                filteredData_n = fir_output - feedback_result;
                state_n = DONE_CALC;
            end
            DONE_CALC: begin
                done = 1;
                state_n = IDLE;
            end
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state_s <= IDLE;
            feedback_delays <= '0;
            filteredData <= '0;
        end else begin
            state_s <= state_n;
            filteredData <= filteredData_n;
            for (int i = FB_TAP_COUNT - 1; i > 0; i--) begin
                feedback_delays[i] <= feedback_delays[i - 1];
            end
            feedback_delays[0] <= filteredData;
        end
    end

endmodule
