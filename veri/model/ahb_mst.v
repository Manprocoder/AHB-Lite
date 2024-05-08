module ahb_mst#(
    parameter DW = 32,
    parameter AW = 32
)(
    input hclk,
    input hresetn,
    input hready,
    input hresp,
    input [DW-1:0] hrdata,
    //output
    output reg [AW-1:0] haddr,
    output reg [DW-1:0] hwdata,
    output reg hwrite,
    //output hmastlock,
    output reg [2:0] hsize,   //3'b010: 32bit (word)
    output reg [2:0] hburst,  //3'b001: INCR (incrementing burst of undefined length)
                              //3'b100: WRAP8
    output reg [3:0] hprot,   //4'b0011: Non-cacheable, non-bufferable, priviledged, data access
    output reg [1:0] htrans   //IDLE, BUSY, NONSEQUENTIAL, SEQUENTIAL
);
    //local parameter
    localparam  delay = 1;

    task ahb_init();
        begin
            $display("ahb init!!!");
            haddr = 'hz;
            hwdata = 'hz;
            hwrite = 'hz;
            hsize = 'hz;
            hburst = 'hz;
            hprot = 'hz;
            htrans = 2'd0;  //IDLE
        end
    endtask

    task ahb_write();
        input [AW-1:0] addr;
        begin
           $display("ahb write!!!");
           @always(posedge hclk);
                hprot  <= 4'b0011;
                htrans <= #(delay) 2'd2;   //NONSEQ
                haddr  <= #(delay) addr;
                hwrite <= #(delay) 1'b0;
                hburst <= #(delay) 3'b101;
                hsize  <= #(delay) 3'd2;   //32bit
           for(integer i=0; i<7; i++) begin
                @always(posedge hclk);
                htrans <= #(delay) 2'd3;   //SEQ
                wait(hready);
                wait(~hresp);
                hwdata  = #(delay) i;
                haddr  <= #(delay) addr + 32'h4;
           end
                hburst <= #(delay) 'hz;
                hsize  <= #(delay) 'hz;
                haddr  <= #(delay) 'hz;
                hwdata  = #(delay) data;
        end
    endtask

    task ahb_read();
        input [AW-1:0] addr;
        output [DW-1:0] data_o;
        begin
           $display("ahb read!!!");
           @always(posedge hclk);
                hprot  <= 4'b0011;
                htrans <= #(delay) 2'd2;   //NONSEQ
                haddr  <= #(delay) addr;
                hwrite <= #(delay) 1'b0;
                hburst <= #(delay) 3'b101;  //INCR8
                hsize  <= #(delay) 3'd2;   //32bit
           for(integer i=0; i<7; i++) begin
                @always(posedge hclk);
                htrans <= #(delay) 2'd3;   //SEQ
                wait(hready);
                wait(~hresp);
                data_o  = #(delay) hrdata;
                haddr  <= #(delay) addr + 32'h4;
           end
                hburst <= #(delay) 'hz;
                hsize  <= #(delay) 'hz;
                haddr  <= #(delay) 'hz;
                data_o  = #(delay) hrdata;
        end
    endtask

endmodule