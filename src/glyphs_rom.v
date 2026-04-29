`default_nettype none

module glyphs_rom(
    input  wire [5:0] c,     // Character index (0-35)
    input  wire [3:0] y,     // Row index (0-11)
    input  wire [2:0] x,     // Column index (0-7)
    output reg        pixel
);
    reg [7:0] rb; 

    always @(*) begin
        case (c % 36) 
            // --- PHILIPPINE ---
            0, 5, 6, 28: // P
                case(y) 2,3:rb=8'hFC; 4,5:rb=8'hC6; 6,7:rb=8'hFC; 8,9,10:rb=8'hC0; default:rb=0; endcase
            1:           // H
                case(y) 2,3,4,5,7,8,9,10:rb=8'hC6; 6:rb=8'hFE; default:rb=0; endcase
            2, 4, 7, 11, 17: // I
                case(y) 2,3,9,10:rb=8'h7E; 4,5,6,7,8:rb=8'h18; default:rb=0; endcase
            3:           // L
                case(y) 2,3,4,5,6,7,8:rb=8'hC0; 9,10:rb=8'hFC; default:rb=0; endcase
            8, 19:       // N (Improved Diagonal)
                case(y) 2,3:rb=8'hC6; 4:rb=8'hE6; 5:rb=8'hF6; 6:rb=8'hD6; 7:rb=8'hC6; 8:rb=8'hCE; 9,10:rb=8'hC6; default:rb=0; endcase
            9, 15:       // E
                case(y) 2,3,6,10:rb=8'hFC; 4,5,7,8,9:rb=8'hC0; default:rb=0; endcase
            
            // --- IC / BOOTCAMP C ---
            12, 25:      // C (Unified & Readable)
                case(y) 2,10:rb=8'h7E; 3,9:rb=8'hC3; 4,5,6,7,8:rb=8'hC0; default:rb=0; endcase

            // --- DESIGN ---
            14:          // D
                case(y) 2,10:rb=8'hF8; 3,4,5,6,7,8,9:rb=8'hC6; default:rb=0; endcase
            16:          // S
                case(y) 2,3,6,10:rb=8'h7E; 4,5:rb=8'hC0; 7,8,9:rb=8'h06; default:rb=0; endcase
            18:          // G
                case(y) 2,3,10:rb=8'h7E; 4,5:rb=8'hC0; 6:rb=8'hCE; 7,8,9:rb=8'hC6; default:rb=0; endcase

            // --- BOOTCAMP ---
            21:          // B (Improved Waist)
                case(y) 2,9,10:rb=8'hFC; 3,4,7,8:rb=8'hC6; 5,6:rb=8'hF8; default:rb=0; endcase
            22, 23, 31:  // O / 0 (Rounded, No Corner Dots)
                case(y) 2,10:rb=8'h3C; 3,9:rb=8'h66; 4,5,6,7,8:rb=8'hC3; default:rb=0; endcase
            24:          // T
                case(y) 2:rb=8'hFF; 3,4,5,6,7,8,9,10:rb=8'h18; default:rb=0; endcase
            26:          // A (Balanced Crossbar)
                case(y) 2:rb=8'h3C; 3,4,5:rb=8'h66; 6,7:rb=8'hFF; 8,9,10:rb=8'hC3; default:rb=0; endcase
            27:          // M
                case(y) 2:rb=8'hC3; 3:rb=8'hE7; 4:rb=8'hFF; 5:rb=8'hDB; 6,7,8,9,10:rb=8'hC3; default:rb=0; endcase
            
            // --- 2026! ---
          //  30, 32:      // 2 (Sharp Z-Shape)
          //      case(y) 2:rb=8'h7E; 3:rb=8'h66; 4,5:rb=8'h06; 6:rb=8'h7E; 7,8,9:rb=8'hC0; 10:rb=8'hFF; default:rb=0; endcase
          // --- FINETUNED 2 (Indices 30, 32) ---
            30, 32: 
                case(y)
                    2:      rb = 8'h3E; //   XXXXX_  (Rounded top-left)
                    3:      rb = 8'h63; //  XX____XX (Upper curve)
                    4:      rb = 8'h03; //  ______XX (Right side)
                    5:      rb = 8'h06; //  _____XX_ (Begin diagonal)
                    6:      rb = 8'h1C; //  ___XXX__ (Middle diagonal)
                    7:      rb = 8'h30; //  __XX____ (Lower diagonal)
                    8:      rb = 8'h60; //  _XX_____ (Lower side)
                    9:      rb = 8'hC0; //  XX______ (Bottom-left corner)
                    10:     rb = 8'hFF; //  XXXXXXXX (Solid flat base)
                    default: rb = 0;
                endcase
		  
		  
		    33:          // 6 (Clear Belly)
                case(y) 2,10:rb=8'h7E; 3,4,5:rb=8'hC0; 6:rb=8'hFC; 7,8,9:rb=8'hC6; default:rb=0; endcase
            34:          // !
                case(y) 2,3,4,5,6,7,9,10:rb=8'h18; default:rb=0; endcase
            
            // Indices 10, 13, 20, 29, 35: Blank Spaces
            default: rb = 8'h00; 
        endcase
        
        pixel = rb[7-x];
    end
endmodule