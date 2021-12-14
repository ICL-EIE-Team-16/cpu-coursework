module mipsregisterfile3_tb(
);
     logic clk;
     logic reset;
     logic write_enable;
     logic  [4:0] register_a_index; //register_one from IR_Decode
     logic  [4:0] register_b_index; //register_two from IR_Decode
     logic  [4:0] write_register; //destination_register from IR_Decode
     logic  [31:0] register_a_data; 
     logic  [31:0] register_b_data;
     logic  [31:0] write_data;
    /* Generate clock, set stimulus, and also check . */
    initial begin

        $dumpfile("mipsregisterfile3_tb.vcd");
        $dumpvars(0,mipsregisterfile3_tb);

        /* Clock low. */
        clk = 0;
        reset = 1;


        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==0); //undefined
        assert(register_b_data==0); //undefined
        $display(register_a_data);
        $display(register_b_data);
        
        /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_a_index = 2;
        register_b_index=3;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==0); 
        assert(register_b_data==0); 
        $display("reg 2 and reg 3"); 
        $display(register_a_data); //should be 0 in reg 2 
        $display(register_b_data); //should be 0 in reg 3

        /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_a_index = 5;
        register_b_index=6;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==0); 
        assert(register_b_data==0);  
        $display("reg 5 and reg 6"); 
        $display(register_a_data); //should be 0 in reg 5 
        $display(register_b_data); //should be 0 in reg 6


        /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_a_index = 28;
        register_b_index=30;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==0); 
        assert(register_b_data==0);  
        $display("reg 28 and 30"); 
        $display(register_a_data); //should be 0 in reg 28
        $display(register_b_data); //should be 0 in reg 30

        /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_a_index = 28;
        write_register =28;
        write_data=10;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==10);  
        $display("reg 28");  
        $display(register_a_data); //should be 10 in reg 28 

        /* Drive new   s */
        reset = 0;
        write_enable=0;
        register_a_index = 28;
        write_register =28;
        write_data=50;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_a_data==10);   
        $display("no wenable therefore no change in reg 28");
        $display(register_a_data); //should be 10 in reg 28 

            /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_b_index = 28;
        write_register =28;
        write_data=50;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_b_data==50);  
        $display("reg 28");  
        $display(register_b_data); //should be 50 in reg 28 
        

            /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_b_index = 28;
        write_register =28;
        write_data=25;
        
        /* Rising edge */
        #1 clk = 1;
        /* Falling edge */
        #1 clk = 0;


        /* Check s */
        assert(register_b_data==25);   
        $display("reg 28"); 
        $display(register_b_data); //should be 25 in reg 28 
        /* Drive new   s */
        reset = 0;
        write_enable=1;
        register_a_index = 2;
        write_register = 4;
        write_data = 10;
        register_b_index=4;
        

        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;

               #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        
        /* Check s */
        assert(register_a_data==0); 
        assert(register_b_data==10);  
        $display(register_a_data); //should be 0 in reg 2 
        $display(register_b_data); //should be 10 in reg 4

        
        /* Drive new   s */
        write_enable=0;
        register_a_index = 4;
        write_register = 4;
        write_data = 20;


        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        /* Check s */
        assert(register_a_data==20); //should fail as wenable is 0 therefore should still remain 0 from reset
        assert(register_a_data==10);
        $display(register_a_data);

              /* Drive new   s */
        write_enable=1;
        register_a_index =31; //should be 10 in reg 31
        write_data=20;
        write_register=31;


        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        /* Check s */


        assert(register_a_data==20); //true
        $display(register_a_data); //should be 20 in reg 31


        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        /* Check s */

                      /* Drive new   s */
        write_enable=1;
        register_a_index =0; 
        write_data=20;
        write_register=0;


        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        /* Check s */


        assert(register_a_data==20); //false
        $display(register_a_data); //should be 0 in reg 0


        /* Rising edge */
        #1 clk = 1;

        /* Falling edge */
        #1 clk = 0;
        /* Check s */





    end


    mipsregisterfile3 mipsregisterfile(
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .register_a_index(register_a_index),
        .register_b_index(register_b_index),
        .write_register(write_register),
        .register_a_data(register_a_data),
        .register_b_data(register_b_data),
        .write_data(write_data)
    );
endmodule
