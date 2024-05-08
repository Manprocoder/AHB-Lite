//=============================================
//
//============================================
ahb_rom #(
    DW,
    AW
)u_ahb_rom(
    .hclk(w_hclk), 
    .hresetn(w_hresetn), 
    .hsel(w_rom_hsel),
    .hready(w_hready),
    .haddr(w_haddr),
    .htrans(w_htrans), // Transfer control
    .hsize(w_hsize), // Transfer size

    //output
    .hresp(w_rom_hresp), // Device response (always OKAY)
    .hreadyout(w_rom_hreadyout), // Device ready
    .hrdata(w_rom_hrdata) // Read data output
);
