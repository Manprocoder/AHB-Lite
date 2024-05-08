module ahb_slavemux (
    input hclk, 
    input hresetn,
    input hready,

    input hsel0, // HSEL for AHB Slave #0
    input hreadyout0, // HREADY for Slave connection #0
    input hresp0, // HRESP for slave connection #0
    input [31:0] hrdata0, // HRDATA for slave connection #0

    input hsel1, 
    input hreadyout1, 
    input hresp1,
    input [31:0] hrdata1, 

    input hsel2, 
    input hreadyout2, 
    input hresp2, 
    input [31:0] hrdata2, 

    input hsel3,   //def slave
    input hreadyout3, 
    input hresp3, 

    output hreadyout, // HREADY output to AHB master and AHB slaves
    output hresp, // HRESP to AHB master
    output [31:0] hrdata // Read data to AHB master
);

    // Internal signals
reg [3:0] SampledHselReg;
// Registering select
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        SampledHselReg <= {4{1’b0}};
    else if (hready) // advance pipeline if multiplexed HREADY is 1
        SampledHselReg <= {hsel3, hsel2, hsel1, hsel0};
end

assign hreadyout = (SampledHselReg[0] & hreadyout0)|(SampledHselReg[1] & hreadyout1)|
                    (SampledHselReg[2] & hreadyout2)|(SampledHselReg[3] & hreadyout3)|(SampledHselReg ==4’b0000);

assign hrdata = ({32{SampledHselReg[0]}} & hrdata0)|({32{SampledHselReg[1]}} & hrdata1)|
                    ({32{SampledHselReg[2]}} & hrdata2);

assign hresp = (SampledHselReg[0] & hresp0)|(SampledHselReg[1] & hresp1)|(SampledHselReg[2] & hresp2)|(SampledHselReg[3] & hresp3);

endmodule