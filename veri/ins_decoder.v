//========================================
//instance of ahb decoder
//========================================
ahb_decoder u_ahb_decoder(
    .i_haddr(w_i_haddr,  //[31:16]
    .ram_cs(o_ram_cs),
    .rom_cs(o_rom_cs),
    .bridge_cs(o_bridge_cs), // bridge : AHB-APB
    .def_cs(o_def_cs) // error 
);