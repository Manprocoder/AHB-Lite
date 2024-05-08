`timescale 1ns / 1ns

//==================================================
// alias defined
//==================================================
`define CLK_PERIOD_NS 10.0

//==================================================
// files list
// -IP RTL files here.
//==================================================
`include "list.v"

//==================================================
// defined
//==================================================

module TB;
//==================================================
// Parameters
//==================================================
    parameter DW = 32;
    parameter AW = 32;

//==================================================
// SIGNALS here
//==================================================
	//global signal
    reg        mclk     ;
    reg        mrst     ;
    integer    clk_cter ;

    //system
    wire w_hclk;
    wire w_hresetn;
    wire w_hready = 1'b1;

    //common IOs
    wire [15:0] w_haddr;
    wire [31:0] w_hwdata;
    wire [1:0] w_htrans; // Transfer control
    wire [2:0] w_hsize; // Transfer size

    //==================
    //AHB Master IOs
    //==================
    wire w_m_hready;
    wire w_m_hresp;
    wire [31:0] w_m_hrdata;
    //output
    wire [31:0] w_m_haddr;
    wire [31:0] w_m_hwdata;
    wire w_m_hwrite;
    wire [2:0] w_m_hsize;   //3'b010: 32bit (word)
    wire [1:0] w_m_hburst;  //3'b001: INCR (incrementing burst of undefined length)
    wire [3:0] w_m_hprot;   //4'b0011: Non-cacheable, non-bufferable, priviledged, data access
    wire [1:0] w_m_htrans;   //IDLE, BUSY, NONSEQUENTIAL, SEQUENTIAL

    //====================
    //decoder IOs
    //====================
    wire [15:0] w_i_haddr;  //[31:16]
    wire o_ram_cs;
    wire o_rom_cs;
    wire o_bridge_cs; // bridge : AHB-APB
    wire o_def_cs; // error 

    //============
    //ROM IOs
    //============
   
    wire w_rom_hsel;

    wire w_rom_hresp; 
    wire w_rom_hreadyout; 
    wire [31:0] w_rom_hrdata;

    //============
    //RAM IOs
    //============
    wire w_ram_hsel;
    wire w_hwrite;
    wire w_ram_hresp; 
    wire w_ram_hreadyout; 
    wire [31:0] w_ram_hrdata;

    //====================
    //default slave IOs
    //====================
    wire w_default_hsel;
   
    wire w_default_hresp;
    wire w_default_hreadyout;

    //=============================
    //AHB_slavemux IOs
    //=============================
    
    //rom 
    /*wire w_rom_hsel; 
      wire w_rom_hreadyout; 
      wire w_rom_hresp; 
      wire [31:0] w_rom_hrdata;*/

    //ram
    /*wire w_ram_hsel;
    wire w_ram_hreadyout; 
    wire w_ram_hresp;
    wire [31:0] w_ram_hrdata;*/

    //ahb_to_apb
    /*wire w_bridge_hsel; 
    wire w_bridge_hreadyout; 
    wire w_bridge_hresp;
    wire [31:0] w_bridge_hrdata; */

    //def slave
    /*wire w_default_hsel;  
    wire w_default_hreadyout; 
    wire w_default_hresp; */

    //output 
    wire w_mux_hreadyout; // HREADY output to AHB master and AHB slaves
    wire w_mux_hresp; // HRESP to AHB master
    wire [31:0] w_mux_hrdata; // Read data to AHB master

    //=================
    //AHB to APB bridge
    //=================

    wire [14:0] w_bridge_haddr;               //[14:0]
    wire [3:0] w_hprot; // Protection information

    //output to ahb_slavemux
    wire w_bridge_hreadyout;
    wire [31:0] w_bridge_hrdata;
    wire w_bridge_hresp; 

    // APB Output
    wire [11:0] w_paddr;   //[11:0]
    wire w_penable;
    wire w_pwrite;
    //wire w_pprot; // APB protection information
    //wire w_pstrb; // APB byte strobe
    wire [31:0] w_pwdata;
    wire w_psel0;
    wire w_psel1;
    wire w_psel2;
    wire w_psel3;
    
    // APB Inputs
    wire [31:0] w_prdata0;
    wire [31:0] w_prdata1;
    wire [31:0] w_prdata2;
    wire [31:0] w_prdata3;
    
    wire w_pready0; // Ready for each APB slave
    wire w_pready1;
    wire w_pready2;
    wire w_pready3;
    
    wire w_pslverr0; // Error state for each APB slave
    wire w_pslverr1;
    wire w_pslverr2;
    wire w_pslverr3;


	

	//========================================
	//connect IOs
	//========================================

    //system signal assignment
	assign hresetn = mrst;
    assign w_hclk = mclk;

    //chipselect assignment (decoder)
    assign w_rom_hsel = o_rom_cs;
    assign w_ram_hsel = o_ram_cs;
    assign w_bridge_hsel = o_bridge_cs;
    assign w_default_hsel = o_def_cs;

    assign w_i_haddr = w_haddr[31:16];

    //AHB master assignment
    assign w_hresp_slave = w_mux_hresp;
    assign w_hready_slave = w_mux_hreadyout;
    assign w_hrdata = w_mux_hrdata;

    assign w_haddr = w_m_haddr[15:0];
    assign w_htrans = w_m_htrans; // Transfer control
    assign w_hsize = w_m_hsize; // Transfer size

    //SLAVE assignment
    assign w_hwdata = w_m_hwdata;
    assign w_hwrite = w_m_hwrite;
    assign w_htrans = w_m_htrans;
    assign w_hsize = w_m_hsize;
    assign w_hprot = w_m_hprot;

//==================================================
// INSTANCE here
//==================================================

	//master
	`include "ins_ahb_mst.v"
    `include "ins_decoder.v"

    //slave
    `include "ins_ahb_defslave.v"
    `include "ins_ram.v"
    `include "ins_rom.v"
    `include "ins_ahb_slavemux.v"
    `include "ins_ahb_to_apb.v"
	

//==================================================
// dump for debugging
//==================================================
    initial begin
    `ifndef SIM_GTKWAVE         //iverilog + gtkwave
        $dumpfile("TB.vcd");
        $dumpvars(0, TB);
    `endif
    `ifdef SIM_VERDI            //VERDI
        $fsdbDumpfile("TB.fsdb");
        $fsdbDumpvars(0, TB);
    `endif
    `ifdef SIM_SHM              //SHM
        $shm_open("TB.shm");
        $shm_probe(TB, "ACS");
    `endif
    end

//==================================================
// fork tasks
//==================================================
    initial begin
        fork
            gen_clk     ( `CLK_PERIOD_NS );
            gen_reset   ( 10, 400_000    );
            gen_finish  ( 500_000      );
        join
    end

    initial begin
        clk_cter = 0;
    end

    always@(posedge w_clk) begin
        clk_cter = clk_cter + 1;  
        $display("clks counter = %d",clk_cter);
    end

    initial begin
        $display("[INFO] main_clock_frequency = %d", 1000.0/`CLK_PERIOD_NS);
    end

//==================================================
// TESTCASE(s) here
// -stm1
//==================================================
`ifndef SIM_STIMULUS_1
	`include "stm.v"
`endif

//==================================================
// Frank tasks
// -common tasks
// -master tasks
// -slave tasks
//==================================================
    `include "tasks_frk.v"

endmodule
