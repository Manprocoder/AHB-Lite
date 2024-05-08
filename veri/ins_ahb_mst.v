//=========================================
// instance of ahb master
//=========================================
ahb_mst#(
    DW,
    AW
)u_ahb_mst(
    //input
    .hclk(mclk),
    .hresetn(mrst),
    .hready(w_m_hready),
    .hresp(w_m_hresp),
    .hrdata(w_m_hrdata),
    //output
    .haddr(w_m_haddr),
    .hwdata(w_m_hwdata),
    .hwrite(w_m_hwrite),
    .hsize(w_m_hsize),   //3'b010: 32bit (word)
    .hburst(w_m_hburst),  //3'b001: INCR (incrementing burst of undefined length)
    .hprot(w_m_hprot),   //4'b0011: Non-cacheable, non-bufferable, priviledged, data access
    .htrans(w_m_htrans)    //IDLE, BUSY, NONSEQUENTIAL, SEQUENTIAL
);