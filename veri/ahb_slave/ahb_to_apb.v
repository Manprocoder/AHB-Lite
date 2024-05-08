//=================================================================
// Simple AHB to APB bridge
//================================================================

module ahb_to_apb (
    input hclk,
    input hresetn,
    input hsel,
    input hready, // Transfer phase done
    input [14:0] haddr,
    input [1:0] htrans, // Transfer control
    input [2:0] hsize, // Transfer size
    input hwrite, // Write control
    //input wire HNONSEC, // Security attribute (TrustZone)
    input [3:0] hprot, // Protection information
   
    input [31:0] hwdata,
    output hreadyout,
    output [31:0] hrdata,
    output hresp, // Device response

    // APB Output
    output wire [11:0] paddr,
    output penable,
    output pwrite,
    output [2:0] pprot, // APB protection information
    output [3:0] pstrb, // APB byte strobe
    output [31:0] pwdata, 
    output wire PSEL0,
    output wire PSEL1,
    output wire PSEL2,
    output wire PSEL3,
    
    // APB Inputs
    input wire [31:0] PRDATA0,
    input wire [31:0] PRDATA1,
    input wire [31:0] PRDATA2,
    input wire [31:0] PRDATA3,
    

    input wire PREADY0, // Ready for each APB slave
    input wire PREADY1,
    input wire PREADY2,
    input wire PREADY3,
    

    input wire PSLVERR0, // Error state for each APB slave
    input wire PSLVERR1,
    input wire PSLVERR2,
    input wire PSLVERR3
    
);

    // Internal signals
    reg [15:2] AddrReg; // Address sample register
    reg [7:0] SelReg; // One-hot PSEL output register
    reg WrReg; // Write control sample register
    reg [2:0] StateReg; // State for finite state machine
    wire ApbSelect; // APB bridge is selected
    wire ApbTranEnd; // Transfer is completed on APB
    wire AhbTranEnd; // Transfer is completed on AHB
    reg [7:0] NextPSel; // Next state of One-hot PSEL
    reg [2:0] NextState; // Next state for finite state machine
    reg [31:0] RDataReg; // Read data sample register
    reg [2:0] PProtReg; // Protection information
    reg [3:0] NxtPSTRB; // Write byte strobe next state
    reg [3:0] RegPSTRB; // Write byte strobe register
    wire [31:0] muxPRDATA; // Slave multiplexer signal
    wire muxPREADY;
    wire muxPSLVERR;
// Start of main code
// Generate APB bridge select
assign ApbSelect = hsel & htrans[1] & hready;
// Generate APB transfer ended
assign ApbTranEnd = (StateReg==3’b010) & muxPREADY;
// Generate AHB transfer ended
assign AhbTranEnd = (StateReg==3’b011) | (StateReg==3’b101);
// Generate next state of PSEL at each AHB transfer
always @(*)
begin
    if (ApbSelect)
    begin
    case (haddr[14:12]) // Binary to one-hot encoding for device select
        3’b000 : NextPSel = 8’b00000001;
        3’b001 : NextPSel = 8’b00000010;
        3’b010 : NextPSel = 8’b00000100;
        3’b011 : NextPSel = 8’b00001000;
        default: NextPSel = 8’b00000000;
    endcase
    end
    else
        NextPSel = 8’b00000000;
end
// Registering PSEL output
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        SelReg <= 8’h00;
    else if (hready|ApbTranEnd)
        SelReg <= NextPSel; // Set if bridge is selected
end // Clear at end of APB transfer



// Sample control signals
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
    begin
        AddrReg <= {10{1’b0}};
        WrReg <= 1’b0;
        PProtReg<= {3{1’b0}};
    end
    else if (ApbSelect) // Only change at beginning of each APB transfer
    begin
        AddrReg <= haddr[11:2]; // Note that lowest two bits are not used
        WrReg <= hwrite;
        PProtReg<= {(~hprot[0]),hnonsec,(hprot[1])};
    end
end


// Byte write strobes
always @(*)
begin
    if (hsel & htrans[1] & hwrite)
    begin
        case (hsize[1:0])
        2’b00: // byte
        begin
        case (haddr[1:0])
            2’b00: NxtPSTRB = 4’b0001;
            2’b01: NxtPSTRB = 4’b0010;
            2’b10: NxtPSTRB = 4’b0100;
            2’b11: NxtPSTRB = 4’b1000;
        default:NxtPSTRB = 4’bxxxx; // Should not be here.
        endcase
        end
        2’b01: // half word
            NxtPSTRB = (haddr[1])? 4’b1100:4’b0011;
        default: // word
            NxtPSTRB = 4’b1111;
        endcase     
    end
    else
        NxtPSTRB = 4’b0000;
end


always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        RegPSTRB<= {4{1’b0}};
    else if (hready)
        RegPSTRB<= NxtPSTRB;
end
// Generate next state for FSM
always @(*)
begin
    case (StateReg)
        3’b000 : NextState = {1’b0, ApbSelect}; // Change to state-1 when selected
        3’b001 : NextState = 3’b010; // Change to state-2
        3’b010 : begin
            if (muxPREADY & muxPSLVERR) // Error received - Generate two cycle
            // Error response on AHB by
            NextState = 3’b100; // Changing to state-4 and 5
            else if (muxPREADY & ~muxPSLVERR) // Okay received
            NextState = 3’b011; // Generate okay response in state 3
            else // Slave not ready
            NextState = 3’b010; // Unchange
        end
        3’b011 : NextState = {1’b0, ApbSelect}; // Terminate transfer

        3’b100 : NextState = 3’b101; // Goto 2nd cycle of error response
        3’b101 : NextState = {1’b0, ApbSelect}; // 2nd Cycle of Error response
    // Change to state-1 if selected
    default : // Not used
        NextState = {1’b0, ApbSelect}; // Change to state-1 when selected
    endcase
end


// Registering state machine
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        StateReg <= 3’b000;
    else
        StateReg <= NextState;
end

// Slave Multiplexer
assign muxPRDATA =  ({32{SelReg[0]}} & PRDATA0) |
                    ({32{SelReg[1]}} & PRDATA1) |
                    ({32{SelReg[2]}} & PRDATA2) |
                    ({32{SelReg[3]}} & PRDATA3) ;

assign muxPREADY =  (SelReg[0] & PREADY0) |
                    (SelReg[1] & PREADY1) |
                    (SelReg[2] & PREADY2) |
                    (SelReg[3] & PREADY3) ;

assign muxPSLVERR = (SelReg[0] & PSLVERR0) |
                    (SelReg[1] & PSLVERR1) |
                    (SelReg[2] & PSLVERR2) |
                    (SelReg[3] & PSLVERR3) ;

// Sample PRDATA
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        RDataReg <= {32{1’b0}};
    else if (ApbTranEnd|AhbTranEnd)
        RDataReg <= muxPRDATA;
end


// Connect outputs to top level
assign paddr = {AddrReg[15:2], 2’b00}; // from sample register
assign pwrite = WrReg; // from sample register
assign pprot = PProtReg; // from sample register
assign pstrb = RegPSTRB;
assign pwdata = hwdata; // No need to register (HWDATA is in data phase)
assign PSEL0 = SelReg[0]; // PSEL for each APB slave
assign PSEL1 = SelReg[1];
assign PSEL2 = SelReg[2];
assign PSEL3 = SelReg[3];

assign penable= (StateReg == 3’b010); // PENABLE to all AHB slaves
assign hreadyout = (StateReg == 3’b000)|(StateReg == 3’b011)|(StateReg==3’b101);
assign hrdata = RDataReg;
assign hresp = (StateReg==3’b100)|(StateReg==3’b101);


endmodule