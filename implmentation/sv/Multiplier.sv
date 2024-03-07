module multiplier #(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         out_rd_en,  // I dont think we need this as its driven by a FIFO
    input logic                         dataAvailible,
    input logic [DATA_WIDTH-1:0]        multiplicand,
    input logic [DATA_WIDTH-1:0]        multiplier,
    output logic [DATA_WIDTH-1:0]     product,
    output logic                        complete
);

    logic [2*DATA_WIDTH-1:0] tempProduct;
    logic   write_s, write_c;

    always_comb begin
        write_c = write_s;
        tempProduct = product;
        complete = 0;
        if (write_s == 1'b1) begin
            complete = 1;
            if (out_rd_en == 1'b1) begin
                write_c = 0;
            end
        end else begin
            tempProduct = multiplier * multiplicand;
            if (dataAvailible) begin
                write_c = 1;
            end
        end
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            product <= 0;
            write_s <= 0;
        end else begin
            product <= tempProduct[31:0];
            write_s <= write_c;
        end
    end

endmodule
