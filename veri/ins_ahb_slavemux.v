//==================================================
//ahb slavemux instance
//=================================================

ahb_slavemux u_ahb_slavemux(
    //system
    .hclk(w_hclk), 
    .hresetn(w_hresetn), 
    .hready(w_hready),

    //rom 
    .hsel0(w_rom_hsel), 
    .hreadyout0(w_rom_hreadyout), 
    .hresp0(w_rom_hresp), 
    .hrdata0(w_rom_hrdata),

    //ram
    .hsel1(w_ram_hsel), 
    .hreadyout1(w_ram_hreadyout), 
    .hresp1(w_ram_hresp),
    .hrdata1(w_ram_hrdata), 

    //ahb_to_apb
    .hsel2(w_bridge_hsel), 
    .hreadyout2(w_bridge_hreadyout), 
    .hresp2(w_bridge_hresp), 
    .hrdata2(w_bridge_hrdata), 

    //def slave
    .hsel3(w_default_hsel),   
    .hreadyout3(w_default_hreadyout), 
    .hresp3(w_default_hresp), 

    //output 
    .hreadyout(w_mux_hreadyout), // HREADY output to AHB master and AHB slaves
    .hresp(w_mux_hresp), // HRESP to AHB master
    .hrdata(w_mux_hrdata) // Read data to AHB master
);