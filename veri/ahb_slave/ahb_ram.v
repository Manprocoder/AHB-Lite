module ahb_ram#(
    parameter DW = 32,
    parameter AW = 16
)(
    input hclk, 
    input hresetn,
    input hsel,
    //input [3:0] hmaster, // Master identification
    input [AW-1:0] haddr,
    input [1:0] htrans, // Transfer control
    input [2:0] hsize, // Transfer size
    input hwrite, 
    input [DW-1:0] hwdata, 
    input hready, // Transfer phase done
    output hreadyout, // Device ready
    output [DW-1:0] hrdata, // Read data output
    output hresp // Device response (always OKAY)
);

// Internal signals
reg [7:0] RamData[0:65535]; // 64k byte of RAM data
integer i; // Loop counter for zero initialization
wire ReadValid; // Address phase read valid
wire WriteValid; // Address phase write valid
reg ReadEnable; // Data phase read enable
reg WriteEnable; // Data phase write enable
reg [3:0] RegByteLane; // Data phase byte lane
reg [3:0] NextByteLane; // Next state of RegByteLane
wire [7:0] RDataOut0; // Read Data Output byte#0
wire [7:0] RDataOut1; // Read Data Output byte#1
wire [7:0] RDataOut2; // Read Data Output byte#2
wire [7:0] RDataOut3; // Read Data Output byte#3
reg [15:0] WordAddr; // Word aligned address

initial begin
    for (i=0;i<65536;i=i+1) begin
        RamData[i] = 8’h00; //Initialize all data to 0 to avoid X propagation
    end
        $readmemh(“image.dat”, RamData); // Then read in program code
end

assign ReadValid = hsel & hready & htrans[1] & ~hwrite;
assign WriteValid = hsel & hready & htrans[1] & hwrite;

always @(*) begin
    if (ReadValid | WriteValid) begin
        case (hsize)
        0 : // Byte
        begin
        case (haddr[1:0])
            0: NextByteLane = 4’b0001; // Byte 0
            1: NextByteLane = 4’b0010; // Byte 1
            2: NextByteLane = 4’b0100; // Byte 2
            3: NextByteLane = 4’b1000; // Byte 3
        default:NextByteLane = 4’b0000; // Address not valid
        endcase
        end
        1 : // Halfword
        begin
            if (haddr[1]) NextByteLane = 4’b1100; // Upper halfword
            else NextByteLane = 4’b0011; // Lower halfword
        end
        default : // Word
            NextByteLane = 4’b1111; // Whole word
        endcase
    end
    else
        NextByteLane = 4’b0000; // Not readin
end

// Registering control signals to data phase
always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
    begin
        RegByteLane <= 4’b0000;
        ReadEnable <= 1’b0;
        WriteEnable <= 1’b0;
        WordAddr <= {16{1’b0}};
    end
    else if (hready)
    begin
        RegByteLane <= NextByteLane;
        ReadEnable <= ReadValid;
        WriteEnable <= WriteValid;
        WordAddr <= {haddr[15:2], 2’b00};
    end
end
// Read operation
assign RDataOut0 = (ReadEnable & RegByteLane[0]) ? RamData[WordAddr ] : 8’h00;
assign RDataOut1 = (ReadEnable & RegByteLane[1]) ? RamData[WordAddr+1] : 8’h00;
assign RDataOut2 = (ReadEnable & RegByteLane[2]) ? RamData[WordAddr+2] : 8’h00;
assign RDataOut3 = (ReadEnable & RegByteLane[3]) ? RamData[WordAddr+3] : 8’h00;

// Registered write
always @(posedge hclk) begin
    if (WriteEnable & RegByteLane[0])
    begin
        RamData[WordAddr ] = hwdata[7:0];
    end
    if (WriteEnable & RegByteLane[1])
    begin
        RamData[WordAddr+1] = hwdata[15: 8];
    end
    if (WriteEnable & RegByteLane[2])
    begin
        RamData[WordAddr+2] = hwdata[23:16];
    end
    if (WriteEnable & RegByteLane[3])
    begin
        RamData[WordAddr+3] = hwdata[31:24];
    end
end

assign hreadyout = 1’b1; // Always ready (no waitstate)
assign hresp = 1’b0; // Always response with OKAY
//assign hexokay = hreadyout;
// Read data output
assign hrdata = {RDataOut3, RDataOut2, RDataOut1, RDataOut0};
endmodule
