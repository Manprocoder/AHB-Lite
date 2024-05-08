
//ahb slave
`include "./ahb_slave/ahb_defslave.v"
`include "./ahb_slave/ahb_ram.v"
`include "./ahb_slave/ahb_rom.v"
`include "./ahb_slave/ahb_slavemux.v"
`include "./ahb_slave/ahb_to_apb.v"

//ahb master
`include "./model/ahb_mst.v"
`include "./model/ahb_decoder.v"
