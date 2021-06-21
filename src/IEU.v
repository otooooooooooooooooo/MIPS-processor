//DONE
//TESTED
module IEU 
(
	input U, //input is unsigned or not
	input [17:0] immediateIN,
	
	output [31:0] immediateOUT
);

//last N bits stays the same as input
assign immediateOUT[17:0] = immediateIN[17:0]; 

//first M-N bits of output are filled with 0 if unsigned, input sign bit if signed
assign immediateOUT[31:18] = U ?  {(14){1'b0}} : {(14){immediateIN[17]}};

endmodule
