// (c) Technion IIT, Department of Electrical Engineering 2018
// Written By David Bar-On  June 2018
// Edited by Guy Shapira August 2021


// ---t----
// |       |
// lt      rt
// |       |
// ---m----
// |       |
// lb      rb
// |       |
// ---b----

module seg7(
        input  logic [3:0]  input_dig,
        output logic [6:0] output_seg
    );

    //seven seg decoder
    always_comb
    begin
        case(input_dig)
            4'h1:
                output_seg = 7'b1111001;
            4'h2:
                output_seg = 7'b0100100;
            4'h3:
                output_seg = 7'b0110000;
            4'h4:
                output_seg = 7'b0011001;
            4'h5:
                output_seg = 7'b0010010;
            4'h6:
                output_seg = 7'b0000010;
            4'h7:
                output_seg = 7'b1111000;
            4'h8:
                output_seg = 7'b0000000;
            4'h9:
                output_seg = 7'b0011000;
            4'ha:
                output_seg = 7'b0001000;
            4'hb:
                output_seg = 7'b0000011;
            4'hc:
                output_seg = 7'b1000110;
            4'hd:
                output_seg = 7'b0100001;
            4'he:
                output_seg = 7'b0000110;
            4'hf:
                output_seg = 7'b0001110;
            4'h0:
                output_seg = 7'b1000000;
        endcase
    end

endmodule
