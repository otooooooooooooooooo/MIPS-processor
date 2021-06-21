//DONE
//TESTED
module Shifter(
	input [1:0] funct, //shift type
	input [31:0] a, //num to shift
	input [4:0] N, //shift amount
	
	output reg[31:0] R //result
);

always @(*) begin
	case (funct[1:0])
		2'b00 : R[31:0] <= a[31:0] << N[4:0]; //logical left shift
		2'b10 : R[31:0] <= a[31:0] >> N[4:0]; //logical right shift
		2'b11 : R[31:0] <= (a[31:0] >> N[4:0] ) | ({32{a[31]}} << (32 - N[4:0]));
		default : R[31:0] <= a[31:0];
	
	endcase

end

endmodule
