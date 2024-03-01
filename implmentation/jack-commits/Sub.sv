module subtractor #(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         start,
    input logic [DATA_WIDTH-1:0]        minuend,
    input logic [DATA_WIDTH-1:0]        subtrahend,
    output logic [DATA_WIDTH-1:0]       difference,
    output logic                        complete,
    output logic                        underflow
);

    logic [DATA_WIDTH:0] tempDifference;

    always_comb begin
        tempDifference = {1'b0, minuend} - {1'b0, subtrahend};
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            difference <= 0;
            underflow <= 0;
            complete <= 0;
        end else if (start) begin
            difference <= tempDifference[DATA_WIDTH-1:0];
            underflow <= tempDifference[DATA_WIDTH];
            complete <= 1;
        end
    end

endmodule
