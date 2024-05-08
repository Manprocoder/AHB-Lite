//===================================
//read and write simulation
//==================================
reg [31:0] rdata;
 
initial begin
	wait(mrst);
	com_delay(5);
	u_ahb_mst.ahb_init();

	com_delay(5);
	u_ahb_mst.ahb_read(0x00000000);
	com_delay(3);
	u_ahb_mst.ahb_write(0x20000000);
	com_delay(3);
	u_ahb_mst.ahb_read(0x20000000, u_ahb_mst.hrdata);
end