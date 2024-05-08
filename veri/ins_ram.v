ahb_ram#(
    DW,
    AW
)u_ahb_rom(
    .hclk(w_hclk), 
    .hresetn(w_hresetn), 
    .hsel(w_ram_hsel),
    //input [3:0] hmaster, // Master identification
    .hready(w_hready),
    .haddr(w_haddr),
    .htrans(w_htrans), // Transfer control
    .hsize(w_hsize), // Transfer size
    .hwrite(w_hwrite), 
    .hwdata(w_hwdata), 
    //output
    .hresp(w_ram_hresp), // Device response (always OKAY)
    .hreadyout(w_ram_hreadyout), // Device ready
    .hrdata(w_ram_hrdata) // Read data output
);