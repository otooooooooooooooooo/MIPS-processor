module CPU(
	input clk, input Reset,
	
	output [31:0] aluresout, shift_resultout, GP_DATA_INout
);

/////////////////////////OUTPUTS////////////////////
/////DECODER/////
wire [3:0] Af; // -> ALU
wire I; // -> ALU
wire ALU_MUX_SEL; // -> ALU MUX
wire [4:0] Cad; // -> DELAYER -> GPR
wire GP_WE; // -> DELAYER -> GPR
wire [1:0] GP_MUX_SEL; // -> GPR MUX -> DELAYER -> GPR
wire [3:0] Bf; // -> BCEU
wire DM_WE; // -> MEMORY (S)
wire [2:0] Shift_type; // -> Shifter
wire [1:0] PC_MUX_SEL; // -> PC_MUX -> MEMORY
/////////////////

///////GPR///////
wire [31:0] data_out_A; // -> ALU,  -> BCE, -> Shifter MUX, -> PC_MUX
wire [31:0] data_out_B; // -> ALU MUX,  -> MEMORY,  -> Shifter, -> BCE
/////////////////

//////SHIFTER////
wire [31:0] R; // -> GPR MUX
////////////////

////////ALU/////
wire [31:0] alures; // -> GPR MUX,  -> MEMORY
wire ovfalu; //
///////////////

//////BCEU//////
wire bres; // -> PC_MUX_2
////////////////

//////MEMORY////
wire [31:0] PC_out; // -> Incrementer,  -> Adder
wire [31:0] Iout; //  -> Decoder,  -> branch,  -> GPR
wire [31:0] Mout; // -> GPR MUX
wire E; // -> DELAY REGISTER -> GPR
///////////////

//////INCREMENTER/////
wire [31:0] incremented_PC; // -> PC MUX, -> PC MUX 2, -> GPR MUX
/////////////////////

//////JUMP UNIT//////
wire [31:0] jump_result; // -> PC MUX
////////////////////

////////PC_MUX_2///////
wire [31:0] PC_MUX_2_RESULT; // -> PC MUX
//////////////////////

///////ADDER/////////
wire [31:0] ADDER_RESULT; // -> PC_MUX_2
////////////////////

////////BRANCH_EXTENDER////
wire [31:0] BRANCH_EXTENDER_RESULT; // -> ADDER
//////////////////////////

///////BRANCH UNIT/////////
wire [17:0] branch; // -> BRANCH_EXTENDER, -> ALU_EXTENDER
//////////////////////////

/////////ALU_EXTENDER/////
wire [31:0] ALU_EXTENDER_RESULT; // -> ALU_MUX
/////////////////////////

/////////ALU_MUX////////
wire [31:0] ALU_MUX_RESULT; // -> ALU
////////////////////////

///////////PC_MUX////////
wire [31:0] PC_MUX_RESULT; // -> MEMORY
///////////////////////

///////GPR_MUX/////////
wire [31:0] GPR_MUX_RESULT; // -> DELAYER
///////////////////////

//////////SHIFTER_MUX//////
wire [4:0] SHIFTER_MUX_RESULT; // -> SHIFTER
//////////////////////////

//////////AND_GATE/////////
wire WE; // -> GPR
//////////////////////////

///////DELAYER////////////
reg E_delayed; // -> AND_GATE
reg GP_WE_delayed; // -> AND_GATE
reg [31:0] GPR_MUX_RESULT_delayed; // -> GPR
reg [4:0] CAD; // -> GPR
/////////////////////////


///////////////INSTANTIATIONS////////////////

/////DECODER///////// 
I_Decoder decoder(
	.Instruction(Iout[31:0]),
	
	.Af(Af[3:0]),
	.I(I),
	.ALU_MUX_SEL(ALU_MUX_SEL),
	
	.Cad(Cad[4:0]),
	.GP_WE(GP_WE),
	.GP_MUX_SEL(GP_MUX_SEL[1:0]),
	
	.Bf(Bf[3:0]),
	
	.DM_WE(DM_WE),
	
	.Shift_type(Shift_type[2:0]),
	
	.PC_MUX_SEL(PC_MUX_SEL[1:0])
);
///////////////////

////////GPR/////////
GPR gpr(
	.clk(clk),
	.write_enable(WE),
	
	.addrA(Iout[25:21]),
	.addrB(Iout[20:15]),
	.addrC(CAD[4:0]),
	.data_in_C(GPR_MUX_RESULT_delayed[31:0]),
	
	.data_out_A(data_out_A[31:0]),
	.data_out_B(data_out_B[31:0])
);
////////////////////

///////Shifter//////
Shifter shifter (
	.funct(Shift_type[1:0]),
	.a(data_out_B[31:0]),
	.N(SHIFTER_MUX_RESULT[4:0]),
	
	.R(R[31:0])
);
////////////////////

////////ALU////////
ALU alu(
	.i(I),
	.SrcA(data_out_A[31:0]),
	.SrcB(ALU_MUX_RESULT[31:0]),
	.af(Af[3:0]),
	
	.alures(alures[31:0]),
	.ovfalu(ovfalu)
);
///////////////////

////////BCEU///////
BCEU bceu(
	.a(data_out_A[31:0]),
	.b(data_out_B[31:0]),
	.bf(Bf[3:0]),
	
	.bcres(bres)
);
//////////////////

///////MEMORY/////
Main_Memory memory(
	.clk(clk),
	.Reset(Reset),
	.S(DM_WE),
	.Next_PC(PC_MUX_RESULT[31:0]),
	.data_addr_in(alures[31:0]),
	.data_in(data_out_B[31:0]),
	
	.PC_out(PC_out[31:0]),
	.Iout(Iout[31:0]),
	.Mout(Mout[31:0]),
	.E(E)
);
/////////////////////

/////INCREMENTER//////
assign incremented_PC[31:0] = PC_out[31:0] + 4;
//////////////////////

/////JUMP_UNIT///////
assign jump_result[31:0] = {incremented_PC[31:28], Iout[25:0], 2'b00};
/////////////////////

/////PC_MUX_2///////
assign PC_MUX_2_RESULT[31:0] = bres ?  ADDER_RESULT[31:0] : incremented_PC[31:0];
////////////////////

////////ADDER//////
assign ADDER_RESULT[31:0] = PC_out[31:0] + BRANCH_EXTENDER_RESULT[31:0];
///////////////////

////BRANCH_EXTENDER//
reg U = 0;
IEU branch_extender(
	.U(U),
	.immediateIN(branch[17:0]),
	
	.immediateOUT(BRANCH_EXTENDER_RESULT[31:0])
);
/////////////////////

////////BRANCH UNIT///
assign branch[17:0] = {Iout[15:0], 2'b00};
//////////////////////

////////ALU_EXTENDER/////
IEU alu_extender(
	.U(Af[2]),
	.immediateIN(branch[17:0]),
	
	.immediateOUT(ALU_EXTENDER_RESULT[31:0])
);
////////////////////////

////////ALU_MUX////////
assign ALU_MUX_RESULT[31:0] = ALU_MUX_SEL ? data_out_B[31:0] : ALU_EXTENDER_RESULT[31:0];
//////////////////////

////////PC_MUX///////
assign PC_MUX_RESULT[31:0] = PC_MUX_SEL[1:0] == 0 ? data_out_A[31:0] : (PC_MUX_SEL[1:0] == 1 ? PC_MUX_2_RESULT[31:0] : (PC_MUX_SEL[1:0] == 2 ? jump_result[31:0] : incremented_PC[31:0]));
////////////////////

////////GPR_MUX//////
assign GPR_MUX_RESULT[31:0] = GP_MUX_SEL[1:0] == 0 ? alures[31:0] : (GP_MUX_SEL[1:0] == 1 ? Mout[31:0] : (GP_MUX_SEL[1:0] == 2 ? R[31:0] : incremented_PC[31:0]));
////////////////////

////////SHIFTER_MUX//////
assign SHIFTER_MUX_RESULT[4:0] = Shift_type[2] ? data_out_A[4:0] : Iout[10:6]; /////
////////////////////////

/////////AND_GATE//////
assign WE = E_delayed && GP_WE_delayed;
//////////////////////

//////DELAYER////////
always @(posedge clk) begin
	E_delayed <= E;
	GP_WE_delayed <= GP_WE;
	GPR_MUX_RESULT_delayed[31:0] <= GPR_MUX_RESULT[31:0];
	CAD[4:0] <= Cad[4:0];
end
///////////////////


///CPU OUTPUTS////
assign aluresout[31:0] = alures[31:0];
//assign shift_resultout[31:0] = R[31:0] > 0 ? R[31:0] : shift_resultout[31:0];
assign shift_resultout[31:0] = R[31:0];
assign GP_DATA_INout[31:0] = GPR_MUX_RESULT_delayed[31:0];
/////////////////

endmodule
