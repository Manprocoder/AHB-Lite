/*************************************************************************************
  * FRK COMMON TASKS
  ***********************************************************************************/

// task delay
    task com_delay;
        input time num_clks;
        begin
            repeat(num_clks) @(posedge w_clk);
            // #num_clks;
        end
    endtask

// clk gen
    task gen_clk;
        input time clk_time;
        begin
            mclk = 0;
            forever #(clk_time/2) mclk = ~mclk;
        end    
    endtask

// reset gen
    task gen_reset;
        input time rst_init;
        input time rst_stop;
        begin
            mrst = 0;
            com_delay(rst_init); mrst  = 1;
            com_delay(rst_stop); mrst  = 0;
        end
    endtask
	
// finish gen
    task gen_finish;
        input time finish_time;
        begin
            com_delay(finish_time);
            $display("\n finished by limited time.");            
            $finish;
        end
    endtask

//