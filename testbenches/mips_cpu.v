module mips_cpu(
    input logic clk,
    input logic reset,
    output logic active,
    output logic[31:0] register_v0
);
    logic[4:0] counter = 0;

    always_ff @(posedge clk) begin
        if (active == 1) begin
            counter <= counter + 1;
        end
        if (counter == 5'b11111) begin
            active <= 0;
            register_v0 <= 0;
        end
        if (reset == 1) begin
            active <= 1;
        end
    end
endmodule : mips_cpu