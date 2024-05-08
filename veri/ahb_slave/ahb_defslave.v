module ahb_defslave (
    input hclk,
    input hresetn,
    input hsel, // connect to HSEL_DefSlave from AHB decoder
    input [1:0] htrans, // Transfer command
    input hready, // System-wide HREADY
    output hreadyout, // Slave ready output
    output hresp // Slave response output  
);

// Internal signals
wire TransReq; // Transfer Request
reg [1:0] RespState; // FSM for two cycle error response
wire [1:0] NextState; // next state for RespState
// Start of main code
assign TransReq = hsel & htrans[1] & hready; 
// to default slave because address is invalid
// Generate next state for the FSM
// Encoding : 01 - Idle (bit 0 is HREADYOUT, bit 1 is RESP[0])
// 10 - 1st cycle of error response
// 11 - 2nd cycle of error response
assign NextState = {(TransReq | (~RespState[0])),(~TransReq)};
// Registering FSM state
always @(posedge hclk or negedge hresetn)
begin
    if (~hresetn)
        RespState <= 2’b01; // bit 0 is reset to 1, ensuring HREADYOUT is 1
    else // at reset
        RespState <= NextState;
end
// Connect to output
assign hreadyout = RespState[0];
assign hresp = RespState[1];
endmodule