module multiplier #(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         start,
    input logic [DATA_WIDTH-1:0]        multiplicand,
    input logic [DATA_WIDTH-1:0]        multiplier,
    output logic [2*DATA_WIDTH-1:0]     product,
    output logic                        complete
);

    logic [2*DATA_WIDTH-1:0] tempProduct;

    always_comb begin
        tempProduct = multiplicand * multiplier;
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            product <= 0;
            complete <= 0;
        end else if (start) begin
            product <= tempProduct;
            complete <= 1;
        end
    end

endmodule
