//================================================
//
//===============================================

ahb_to_apb u_brigde (
    //system
    .hclk(w_hclk), 
    .hresetn(w_hresetn), 
    .hsel(w_bridge_hsel),
    .hready(w_hready),

    .haddr(w_bridge_haddr),               //[14:0]
    .htrans(w_htrans), // Transfer control
    .hsize(w_hsize), // Transfer size
    .hwrite(w_hwrite), // Write control
    //input wire HNONSEC, // Security attribute (TrustZone)
    .hprot(w_hprot), // Protection information
    .hwdata(w_hwdata),

    //output to ahb_slavemux
    .hreadyout(w_bridge_hreadyout),
    .hrdata(w_bridge_hrdata),
    .hresp(w_bridge_hresp), // Device response

    // APB Output
    .paddr(w_paddr),   //[11:0]
    .penable(w_penable),
    .pwrite(w_pwrite),
    .pprot(w_pprot), // APB protection information
    .pstrb(w_pstrb), // APB byte strobe
    .pwdata(w_pwdata), 
    .PSEL0(w_psel0),
    .PSEL1(w_psel1),
    .PSEL2(w_psel2),
    .PSEL3(w_psel3),
    
    // APB Inputs
    .PRDATA0(w_prdata0),
    .PRDATA1(w_prdata1),
    .PRDATA2(w_prdata2),
    .PRDATA3(w_prdata3),
    
    .PREADY0(w_pready0), // Ready for each APB slave
    .PREADY1(w_pready1),
    .PREADY2(w_pready2),
    .PREADY3(w_pready3),
    
    .PSLVERR0(w_pslverr0), // Error state for each APB slave
    .PSLVERR1(w_pslverr1),
    .PSLVERR2(w_pslverr2),
    .PSLVERR3(w_pslverr3)
    
);