module ahb_decoder(
    input [15:0] i_haddr,  //[31:16]
    output reg ram_cs,
    output reg rom_cs,
    output reg bridge_cs // bridge : AHB-APB
    output def_cs // error 
);

    always@(*) begin
        case(i_haddr)
        16'h0000: rom_cs = 1;
        16'h2000: ram_cs = 1;
        16'h4000: bridge_cs = 1;
        default:
            begin
               rom_cs = 1;
               ram_cs = 0;
               bridge_cs = 0;
            end
        endcase
    end
    assign def_cs = ~(ram_cs | bridge_cs);

endmodule