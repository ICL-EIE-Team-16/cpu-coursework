module PC_tb ();

    logic clk, reset;
    logic fetch, exec1, exec2;
    logic[6:0] internal_code;
    logic[15:0] offset;
    logic[25:0] instr_index;
    logic[31:0] register_data;
    logic zero, positive, negative;
    logic[31:0] address;
    logic halt;
    
    //set a clock
    initial begin

        $dumpfile("PCv2_tb.vcd");
        $dumpvars(0, PCv2_tb);

        clk = 0;
        repeat (1000) begin
            #1 clk = !clk;
        end
    end

    //define the chages of state at each cycle and what state the machine starts from after a reset:
    initial begin
        repeat (1000) begin
            @(posedge clk);
            $display("fetch=%b, exec1=%b, exec2=%b, time=%t", fetch, exec1, exec2, $time);
            if (reset == 0) begin
                exec2 = 0;
                fetch = 1;
                @(posedge clk);
                $display("fetch=%b, exec1=%b, exec2=%b, time=%t", fetch, exec1, exec2, $time);
                fetch = 0;
                exec1 = 1;
                @(posedge clk);
                $display("fetch=%b, exec1=%b, exec2=%b, time=%t", fetch, exec1, exec2, $time);
                exec1 = 0;
                exec2 = 1;
            end
        end
    end
    
    // initialise the PC
    initial begin
        reset = 0;
        fetch = 0; exec1 = 0; exec2 = 0;
        internal_code = 1;
        offset = 0;
        instr_index = 0;
        register_data = 0;
        zero = 0;
        positive = 0;
        negative = 0;
        #1 reset = 1;
        #9;
        reset = 0;
        
        //test jr instruction
        #7 register_data = 32'h4;
        @(posedge exec1);
        internal_code = 41; // jump-register instruction
        @(posedge exec1);
        assert (address == 32'hbfc0000c) else $fatal(2, "Expected address = 32'hbfc0000c"); // check correctness of branch delay slot
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'h4) else $fatal(2, "Expected address = 32'h4"); //check jump from 2 instructions ago was executed
        @(posedge exec1);
        assert (address == 32'h8) else $fatal(2, "Expected address = 32'h8");
    
        //test jump instruction
        internal_code = 38; // J
        instr_index = 26'd25000; //jump to address 100000
        @(posedge exec1);
        assert (address == 32'hc) else $fatal(2, "Expected address = 32'hc");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd100000) else $fatal(2, "Expected address = 100000");
        @(posedge exec1);
        assert (address == 32'd100004) else $fatal(2, "Expected address = 100004");

        //test jump and link instruction
        internal_code = 39; // JAL
        instr_index = 26'd50000; // jump to address 200000
        @(posedge exec1);
        assert (address == 32'd100008) else $fatal(2, "Expected address = 100008");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd200000) else $fatal(2, "Expected address = 200000");
        @(posedge exec1);
        assert (address == 32'd200004) else $fatal(2, "Expected address = 200004");

        //test BEQ instruction
        internal_code = 30;
        offset = 25000; // jump to PC + 100000
        @(posedge exec1);
        assert (address == 32'd200008) else $fatal(2, "Expected address = 200008");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd200012) else $fatal(2, "Expected address = 200012"); //branch shouldn't have happened as condition wasn't met
        internal_code = 30;
        offset = 25000;
        zero = 1;
        @(posedge exec1);
        assert (address == 32'd200016) else $fatal(2, "Expected address = 200016");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd300012) else $fatal(2, "Expected address = 300012"); //check branch from 2 instructions ago was executed

        //test BGEZ instruction
        internal_code = 31;
        offset = 25000; // jump to PC + 100000
        zero = 0;
        negative = 1;
        @(posedge exec1);
        assert (address == 32'd300016) else $fatal(2, "Expected address = 300016");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd300020) else $fatal(2, "Expected address = 300020"); //branch shouldn't have happened as condition wasn't met
        internal_code = 31;
        offset = 25000;
        negative = 0;
        positive = 1;
        @(posedge exec1);
        assert (address == 32'd300024) else $fatal(2, "Expected address = 300024");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd400020) else $fatal(2, "Expected address = 400020"); //check branch from 2 instructions ago was executed

        //test BGEZAL instruction
        internal_code = 32;
        offset = 25000; // jump to PC + 100000
        positive = 0;
        negative = 1;
        @(posedge exec1);
        assert (address == 32'd400024) else $fatal(2, "Expected address = 400024");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd400028) else $fatal(2, "Expected address = 400028"); //branch shouldn't have happened as condition wasn't met
        internal_code = 32;
        offset = 25000;
        negative = 0;
        positive = 1;
        @(posedge exec1);
        assert (address == 32'd400032) else $fatal(2, "Expected address = 400032");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd500028) else $fatal(2, "Expected address = 500028"); //check branch from 2 instructions ago was executed

        //test BGTZ instruction
        internal_code = 33;
        offset = 25000; // jump to PC + 100000
        positive = 0;
        zero = 1;
        @(posedge exec1);
        assert (address == 32'd500032) else $fatal(2, "Expected address = 500032");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd500036) else $fatal(2, "Expected address = 500036"); //branch shouldn't have happened as condition wasn't met
        internal_code = 33;
        offset = 25000;
        zero = 0;
        positive = 1;
        @(posedge exec1);
        assert (address == 32'd500040) else $fatal(2, "Expected address = 500040");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd600036) else $fatal(2, "Expected address = 600036"); //check branch from 2 instructions ago was executed

      //test BLEZ instruction
        internal_code = 34;
        offset = 25000; // jump to PC + 100000
        positive = 1;
        zero = 0;
        @(posedge exec1);
        assert (address == 32'd600040) else $fatal(2, "Expected address = 600040");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd600044) else $fatal(2, "Expected address = 600044"); //branch shouldn't have happened as condition wasn't met
        internal_code = 34;
        offset = 25000;
        negative = 1;
        positive = 0;
        @(posedge exec1);
        assert (address == 32'd600048) else $fatal(2, "Expected address = 600048");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd700044) else $fatal(2, "Expected address = 700044"); //check branch from 2 instructions ago was executed

        //test BLTZ instruction
        internal_code = 35;
        offset = 25000; // jump to PC + 100000
        negative = 0;
        positive = 1;
        @(posedge exec1);
        assert (address == 32'd700048) else $fatal(2, "Expected address = 700048");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd700052) else $fatal(2, "Expected address = 700052"); //branch shouldn't have happened as condition wasn't met
        internal_code = 35;
        offset = 25000;
        negative = 1;
        positive = 0;
        @(posedge exec1);
        assert (address == 32'd700056) else $fatal(2, "Expected address = 700056");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd800052) else $fatal(2, "Expected address = 800052"); //check branch from 2 instructions ago was executed

        //test BLTZAL instruction
        internal_code = 36;
        offset = 25000; // jump to PC + 100000
        negative = 0;
        zero = 1;
        @(posedge exec1);
        assert (address == 32'd800056) else $fatal(2, "Expected address = 800056");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd800060) else $fatal(2, "Expected address = 800060"); //branch shouldn't have happened as condition wasn't met
        internal_code = 36;
        offset = 25000;
        zero = 0;
        negative = 1;
        @(posedge exec1);
        assert (address == 32'd800064) else $fatal(2, "Expected address = 800064");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd900060) else $fatal(2, "Expected address = 900060"); //check branch from 2 instructions ago was executed

        //test BNE instruction
        internal_code = 37;
        offset = 25000; // jump to PC + 100000
        negative = 0;
        zero = 1;
        @(posedge exec1);
        assert (address == 32'd900064) else $fatal(2, "Expected address = 900064");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd900068) else $fatal(2, "Address = %d, Expected address = 900068", address); //branch shouldn't have happened as condition wasn't met
        internal_code = 37;
        offset = 25000;
        zero = 0;
        positive = 1;
        @(posedge exec1);
        assert (address == 32'd900072) else $fatal(2, "Expected address = 900072");
        internal_code = 1; //non-jump
        @(posedge exec1);
        assert (address == 32'd1000068) else $fatal(2, "Expected address = 1000068"); //check branch from 2 instructions ago was executed

        //Test halt behavior
        internal_code = 41; //jump register instruction
        register_data = 0; // jump to address 0;
        @(posedge exec1);
        internal_code = 1; //non jump instruction which would normally increment the PC by 4
        //however PC should not be incrememnted anymore as address 0 was fetched so CPU is halted.


    end
    
    initial begin
        repeat (1000) begin
            @(posedge fetch);
            $display("PC=%d", address);
        end
    end

    PCv2 dut(
        .clk(clk), .reset(reset),
        .fetch(fetch), .exec1(exec1), .exec2(exec2),
        .internal_code(internal_code),
        .offset(offset),
        .instr_index(instr_index),
        .register_data(register_data),
        .zero(zero), .positive(positive), .negative(negative),
        .address(address),
        .halt(halt)
    );
    
endmodule