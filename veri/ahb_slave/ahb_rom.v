// Simple 64kb ROM with AHB interface
module ahb_rom #(
    parameter DW = 32,
    parameter AW = 16
)(
    input hclk, 
    input hresetn, 
    input hsel,
    input hready,
    input [AW-1:0] haddr,
    input [1:0] htrans, // Transfer control
    input [2:0] hsize, // Transfer size
    output hresp, // Device response (always OKAY)
    output hreadyout, // Device ready
    output [DW-1:0] hrdata // Read data output
);

// Internal signals
reg [7:0] RomData[0:65535]; // 64k byte of ROM data
integer i; // Loop counter for ROM initialization
wire ReadValid; // Address phase read valid
wire [15:0] WordAddr; // Word aligned address(addr phase)
reg [3:0] ReadEnable; // Read enable for each byte(addr phase)
reg [7:0] RDataOut0; // Read Data Output byte#0(data phase

reg [7:0] RDataOut1; // Read Data Output byte#1
reg [7:0] RDataOut2; // Read Data Output byte#2
reg [7:0] RDataOut3; // Read Data Output byte#3
// Start of main code
// Initialize ROM
initial
begin
    for (i=0;i<65536;i=i+1) begin
        RomData[i] = 8’h01; //Initialize all data to 0
    end
    $readmemh(“image.dat”, RomData); // Then read in program code
end
// Generate read control (address phase)
assign ReadValid = hsel & hready & htrans[1];
// Read enable for each byte (address phase)
always @(*) begin
    if (ReadValid) begin
        case (hsize)
        0 : // Byte
        begin
        case (haddr[1:0])
            0: ReadEnable = 4’b0001; // Byte 0
            1: ReadEnable = 4’b0010; // Byte 1
            2: ReadEnable = 4’b0100; // Byte 2
            3: ReadEnable = 4’b1000; // Byte 3
        default:ReadEnable = 4’b0000; // Address not valid
        endcase
        end
        1 : // Halfword
        begin
        if (haddr[1])
            ReadEnable = 4’b1100; // Upper halfword
        else
            ReadEnable = 4’b0011; // Lower halfword
        end
        default : // Word
            ReadEnable = 4’b1111; // Whole word
        endcase
    end 
    else
        ReadEnable = 4’b0000; // Not reading
end

// Read operation
assign WordAddr = {haddr[15:2], 2’b00}; // Get word aligned address
// Registered read
always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
    begin
        RDataOut0 <= 8’h00;
        RDataOut1 <= 8’h00;
        RDataOut2 <= 8’h00;
        RDataOut3 <= 8’h00;
    end
    else
    begin // Read when read enable is high
        RDataOut0 <= (ReadEnable[0]) ? RomData[WordAddr ] : 8’h00;
        RDataOut1 <= (ReadEnable[1]) ? RomData[WordAddr+1] : 8’h00;
        RDataOut2 <= (ReadEnable[2]) ? RomData[WordAddr+2] : 8’h00;
        RDataOut3 <= (ReadEnable[3]) ? RomData[WordAddr+3] : 8’h00;
    end
end

// Connect to top level
assign hreadyout = 1’b1; // Always ready (no waitstate)
assign hresp = 1’b0;// Always response with OKAY
// Read data output
assign hrdata = {RDataOut3, RDataOut2, RDataOut1,RDataOut0};
endmodule