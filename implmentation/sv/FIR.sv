module FIR #(
    parameter TAP_COUNT = 8,
    parameter DECIMATION_FACTOR = 1,
    parameter MULT_PER_CYCLE = 8,
    parameter DATA_WIDTH = 32
)(
    input logic                     clock,
    input logic                     reset,
    input logic [DATA_WIDTH - 1:0]  newData,
    input logic                     newDataAvailible,
    input logic [DATA_WIDTH - 1:0]  TAPS[TAP_COUNT],
    output logic [DATA_WIDTH - 1:0] dotProd,
    output logic                    done,
    output logic                    in_rd_en
);

    typedef enum logic[1:0] {shift, mult, doneCalc} FIRstate;
    FIRstate state_s, state_c;
    localparam MULT_CYCLE_COUNT = TAP_COUNT / MULT_PER_CYCLE;

    logic [TAP_COUNT-1:0] [DATA_WIDTH-1:0] shiftRegNow, shiftRegNext;
    logic [7:0] shiftCounter_s, shiftCounter_c;
    logic [7:0] multCounter_s, multCounter_c;
    logic [DATA_WIDTH-1:0] dotProd_c;
    logic [MULT_PER_CYCLE-1:0] [31:0] dotProdSubOps;
    int i;

    always_comb begin
        shiftRegNext = shiftRegNow;
        state_c = state_s;
        shiftCounter_c = shiftCounter_s;
        multCounter_c = multCounter_s;
        dotProd_c = dotProd;
        in_rd_en = 0;
        case (state_s)
        shift: begin
            in_rd_en = 1;
            if (newDataAvailible == 1'b1) begin
                shiftCounter_c = shiftCounter_s + 1;
                shiftRegNext[TAP_COUNT-1:1] = shiftRegNow[TAP_COUNT-2:0];
                shiftRegNext[0] = newData;
                if (shiftCounter_s == DECIMATION_FACTOR - 1) begin
                    shiftCounter_c = 0;
                    multCounter_c = 0;
                    state_c = mult;
                end 
            end
        end
        mult: begin
            multCounter_c = multCounter_s + 1;
            for(i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
               dotProdSubOps[i] = TAPS[(multCounter_s * MULT_PER_CYCLE) + i] * shiftRegNow[(multCounter_s * MULT_PER_CYCLE) + i];
            end
            for(i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
               dotProd_c += dotProdSubOps[i] / (4'h00000400); //DEQUANTIZE
            end
            if (multCounter_s == MULT_CYCLE_COUNT - 1) begin
                state_c = doneCalc;
                multCounter_c = 0;
            end
        end
        doneCalc: begin
            done = 1;
            state_c = shift;
        end
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset == 1'b1) begin
            state_s <= shift;
            shiftRegNow <= 0;
            shiftCounter_s <= 0;
            multCounter_s <= 0;
            dotProd <= 0;
        end else begin
            state_s <= state_c;
            shiftRegNow <= shiftRegNext;
            shiftCounter_s <= shiftCounter_c;
            multCounter_s <= multCounter_c;
            dotProd <= dotProd_c;
        end
    end

endmodule