//====================================================
//
//===================================================
ahb_defslave u_ahb_defslave (
    .hclk(w_hclk), 
    .hresetn(w_hresetn), 
    .hsel(w_default_hsel),
    .hready(w_hready),
    .htrans(w_htrans), // Transfer control
    //output
   .hresp(w_default_hresp), // Device response (always OKAY)
   .hreadyout(w_default_hreadyout) // Device ready
);