import mult_types::*;

module testbench(multiplier_itf.testbench itf);

add_shift_multiplier dut (
    .clk_i          ( itf.clk          ),
    .reset_n_i      ( itf.reset_n      ),
    .multiplicand_i ( itf.multiplicand ),
    .multiplier_i   ( itf.multiplier   ),
    .start_i        ( itf.start        ),
    .ready_o        ( itf.rdy          ),
    .product_o      ( itf.product      ),
    .done_o         ( itf.done         )
);

assign itf.mult_op = dut.ms.op;
default clocking tb_clk @(negedge itf.clk); endclocking

// error_e defined in package mult_types in file types.sv
// Asynchronously reports error in DUT to grading harness
function void report_error(error_e error);
    itf.tb_report_dut_error(error);
endfunction : report_error


// Resets the multiplier
task reset();
    itf.reset_n <= 1'b0;
    ##5;
    itf.reset_n <= 1'b1;
    ##1;
endtask : reset

// DO NOT MODIFY CODE ABOVE THIS LINE

/* Uncomment to "monitor" changes to adder operational state over time */
//initial $monitor("dut-op: time: %0t op: %s", $time, dut.ms.op.name);
initial itf.reset_n = 1'b0;
int i;
int j;
initial begin
    reset();
/********************** Your Code Here *****************************/


    for(i = 0; i < 256; i++)begin
        for(j = 0; j < 256; j++)begin

            itf.multiplicand <= i;
            itf.multiplier <= j;
            itf.start <= 1;
            @(itf.done);
            $display("i = %0d j = %0d product = %0d | %0d",i,j, i*j, itf.product);
            itf.start <= 0;
            reset();
            

        end
    end



    /*******************************************************************/
    itf.finish(); // Use this finish task in order to let grading harness
                  // complete in process and/or scheduled operations
    $error("Improper Simulation Exit");
end




endmodule : testbench
