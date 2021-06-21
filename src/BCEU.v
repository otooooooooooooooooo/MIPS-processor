//DONE
//TESTED
module BCEU(
	input [31:0] a, b, //test operands
	input [3:0] bf, //branch function
	
	output reg bcres
);

always @(*) begin
	case (bf[3:0]) 
		4'b0010 : bcres <= a[31];
		4'b0011 : bcres <= ~a[31];
		4'b1000, 4'b1001  : bcres <= (a == b);
		4'b1010, 4'b1011 : bcres <= ~(a == b);
		4'b1100, 4'b1101 : bcres <= a[31] || a[31:0] == 0;
		4'b1110, 4'b1111 : bcres <= ~a[31] && ~(a[31:0] == 0);
		default : bcres <= 0;
	
	endcase
end


endmodule
