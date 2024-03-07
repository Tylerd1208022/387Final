module adder #(
    parameter DATA_WIDTH = 32
) (
    input logic                         clock,
    input logic                         reset,
    input logic                         out_rd_en,  // I dont think we need this as its driven by a FIFO
    input logic                         dataAvailible,
    input logic [DATA_WIDTH-1:0]        addend1,
    input logic [DATA_WIDTH-1:0]        addend2,
    output logic [DATA_WIDTH-1:0]     sum,
    output logic                        complete
);

    logic [DATA_WIDTH-1:0] tempSum;
    logic   write_s, write_c;

    always_comb begin

        tempSum = sum;
        complete = 0;
        if (write_s == 1'b1) begin
            complete = 1;
            if (out_rd_en == 1'b1) begin
                write_c = 0;
            end
        end else begin
            tempSum = addend1 + addend2;
            if (dataAvailible) begin
                write_c = 1;
            end
        end
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            sum <= 0;
            write_s <= 0;
        end else begin
            sum <= tempSum;
            write_s <= write_c;
        end
    end

endmodule
