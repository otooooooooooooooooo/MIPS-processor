//TO TEST
module Main_Memory (
input clk, Reset, S, //store
input [31:0] Next_PC, data_addr_in, data_in,

output reg[31:0] PC_out,//currently executed instruction address
 Iout, //currently executed instruction 
 Mout, //if E - data_out, if ~E - next instruction
output reg E//E - execution, ~E - fetch
);

reg [31:0] memory [255:0];

initial begin
	$readmemb ("C:/VerilogProjects/CPU/memory.txt", memory);
end

always @(posedge clk) begin
	if(Reset) begin
		PC_out[31:0] <= 0;
		E <= 0;
	end
	else begin
		
		if (E) begin //execute
			Mout[31:0] <= memory[data_addr_in[31:2]][31:0];
			if (S)
				memory[data_addr_in[31:2]][31:0] <= data_in[31:0];
		end
		
		else begin //fetch
			Mout[31:0] <= memory[Next_PC[31:2]][31:0];
		end
	
	Iout[31:0] <= memory[PC_out[31:2]][31:0];
	E <= ~E;
	PC_out[31:0] <= Next_PC[31:0];
	end

	
	
end

endmodule
