module PC_tb ();

    logic clk;
    logic[31:0] instruction;
    logic[31:0] register_data;
    logic zero;
    logic positive;
    logic negative;
    logic[31:0] address;
    
    initial begin
        clk = 0;
        $display("PC =%d", address);
        instruction = 32'h8; //jump register instruction (to initialize)
        register_data = 0;
        zero = 0;
        positive = 0;
        negative = 0;

        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test non-branch instruction (expected PC <= PC+4)
        instruction = {6'b100000, 26'h0};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test J and JAL instructions
        instruction = {6'b000010, 26'h40};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        instruction = {6'b000011, 26'h0};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BEQ instruction
        instruction = {6'b000100, 10'b0, 16'h7ffe};
        positive = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BGTZ instruction
        instruction = {6'b000111, 10'b0, 16'h8000};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 1;
        zero = 0;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BLEZ instruction
        instruction = {6'b000110, 10'b0, 16'h00f0};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        zero = 0;
        negative = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BNE instruction
        instruction = {6'b000101, 10'b0, 16'hff0f};
        zero = 1;
        negative = 0;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 1;
        zero = 0;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive =0;
        negative = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BGEZ instruction
        instruction = {6'b000001, 5'b0, 5'b00001, 16'h00f0};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        negative = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        zero =0;
        positive = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BGEZAL instruction
        instruction = {6'b000001, 5'b0, 5'b10001, 16'hff0f};
        positive = 0;
        negative = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        negative = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        zero =0;
        positive = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BLTZ instruction
        instruction = {6'b000001, 5'b0, 5'b0, 16'h00f0};
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        zero =0;
        negative = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);

        //test BLTZAL instruction
        instruction = {6'b000001, 5'b0, 5'b10000, 16'hff0f};
        negative = 0;
        positive = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        positive = 0;
        zero = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
        zero =0;
        negative = 1;
        #5
        clk = 1;
        #5
        clk = 0;
        $display("PC =%d", address);
    end

       
    PC dut(
        .clk(clk),
        .instruction(instruction),
        .register_data(register_data),
        .zero(zero),
        .positive(positive),
        .negative(negative),
        .address(address)
    );
    
endmodule