`ifndef testbench
`define testbench

import fifo_types::*;

module testbench(fifo_itf itf);

fifo_synch_1r1w dut (
    .clk_i     ( itf.clk     ),
    .reset_n_i ( itf.reset_n ),

    // valid-ready enqueue protocol
    .data_i    ( itf.data_i  ),
    .valid_i   ( itf.valid_i ),
    .ready_o   ( itf.rdy     ),

    // valid-yumi deqeueue protocol
    .valid_o   ( itf.valid_o ),
    .data_o    ( itf.data_o  ),
    .yumi_i    ( itf.yumi    )
);

// Clock Synchronizer
default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err); 
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

task enqueue(input word_t indata);
	itf.data_i = indata;
    itf.valid_i = 1;
    @(tb_clk)
    itf.valid_i = 0;

endtask : enqueue


task dequeue(output word_t outdata);
    outdata = itf.data_o;
    itf.yumi = 1;
    @(tb_clk)
    itf.yumi = 0;
endtask : dequeue


task simult(input word_t indata, output word_t outdata);
    outdata = itf.data_o;
    itf.data_i = indata;
    itf.valid_i = 1;
    itf.yumi = 1;
    @(tb_clk)
    itf.yumi = 0;
    itf.valid_i = 0;
	
endtask : simult


word_t val;

logic [cap_p<<1:0][32:0] check;

initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.

    


	for (int i = 0, int j = 0; i<cap_p; i++, j = (j%cap_p)) begin


        enqueue(j);
        check[j] = j;
        j++;
        enqueue(j);
        check[j] = j;
        j++;

        //pop
        dequeue(val);
        
        assert(val == check[i]) else begin 
            $display("popped value %d shoulda been now showing %d\n", val, check[i], itf.data_o);
            $error ("error detected");
        end

    end



	for (int i = 0, int j = 0; i<cap_p; i++, j = (++j%cap_p)) begin
        


            //pop
            dequeue(val);
            
            assert(val == j) else begin 
                $display("popped value %d shoulda been %d now showing %d\n", val, j, itf.data_o);
                $error ("error detected");
            end


    end

    //push
    
    for (int i = 0, int j = 0; i < cap_p; i++) begin
        enqueue(j);
        j++;
        simult(j, val);
        j++;
        assert(val == i) else begin 
                $display("popped value %d shoulda been %d now showing %d\n", val, j, itf.data_o);
                $error ("error detected");
        end
    end


    


    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif

