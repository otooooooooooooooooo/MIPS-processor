//DONE
//TESTED
module GPR (
 input clk, write_enable,
 input [4:0] addrA, addrB, addrC,
 
 input [31:0] data_in_C,
 
 output[31:0] data_out_A, data_out_B
);

reg [31:0] data [0:31]; 

initial begin
     $readmemb("values.txt", data);
	  data[0][31:0] = 0; //gpr0 should always stay 0
end

assign data_out_A[31:0] = data[addrA[4:0]][31:0]; //independent from clock
assign data_out_B[31:0] = data[addrB[4:0]][31:0];

always @(posedge clk) begin
	if (write_enable && ~(addrC[4:0] == 0)) begin
		data[addrC[4:0]][31:0] <= data_in_C[31:0];
	end
end


endmodule

