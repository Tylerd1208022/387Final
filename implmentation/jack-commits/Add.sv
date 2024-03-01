module adder #(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         start,
    input logic [DATA_WIDTH-1:0]        addend1,
    input logic [DATA_WIDTH-1:0]        addend2,
    output logic [DATA_WIDTH-1:0]       sum,
    output logic                        complete,
    output logic                        overflow
);

    logic [DATA_WIDTH:0] tempSum;

    always_comb begin
        tempSum = {1'b0, addend1} + {1'b0, addend2};
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            sum <= 0;
            overflow <= 0;
            complete <= 0;
        end else if (start) begin
            sum <= tempSum[DATA_WIDTH-1:0];
            overflow <= tempSum[DATA_WIDTH];
            complete <= 1;
        end
    end

endmodule
