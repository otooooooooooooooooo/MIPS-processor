//TO TEST
//instruction decoder
module I_Decoder (
	input [31:0] Instruction,
	
	
	//ALU
	output [3:0] Af,
	output I,
			 ALU_MUX_SEL,
	
	//GPR
	output[4:0] Cad,
	output GP_WE,
	output [1:0] GP_MUX_SEL,
	
	//BCE
	output[3:0] Bf,
	
	//MEMORY
	output DM_WE,
	
	//SHIFTER
	output [2:0] Shift_type,
	
	//PC
	output [1:0] PC_MUX_SEL
);

wire [5:0] opc, fun;
wire R_type, J_type, I_type, jal, srl, jalr, l, alur, alui, alu, jr;
wire [4:0] rt, rd;

//basic architecture, page 115-116
assign opc[5:0] = Instruction[31:26];
assign R_type =(opc[5] == 0) && (opc[3:0] == 0);
assign J_type = (opc[5:2] == 0) && opc[1];
assign I_type = ~(R_type || J_type);
assign rt[4:0] = Instruction[20:16];
assign rd[4:0] = Instruction[15:11];
assign fun[5:0] = Instruction[5:0];

assign jal = opc[5:0] == 6'b000011;
assign alur = R_type && (fun[5:4] == 2'b10);
assign alui = I_type && (opc[5:3] == 3'b001);
assign alu = alur || alui;
assign srl = (opc[5:0] == 0) && (fun[5:0] == 6'b000010);
assign jalr = (opc[5:0] == 0) && (fun[5:0] == 6'b001001);
assign l = opc[5:3] == 3'b100;
assign jr = (opc[5:0] == 0) && fun[5:0] == 6'b001000;

//ALU
assign Af[3:0] = R_type ? fun[3:0] : {(~opc[2] && opc[1]), opc[2:0]}; //basic architecture, page 117
assign I = I_type;
assign ALU_MUX_SEL = R_type; //if 1 then Rt field

//GPR
assign Cad[4:0] = jal ? {5{1'b1}} : (R_type ? rd[4:0] : rt[4:0]);
assign GP_WE = alu || srl || l || jal || jalr;

//0 - alu, 1 - memory, 2 - shifter, 3 - pc
assign GP_MUX_SEL [1:0] = alu ? 0 : (opc[5:0] == 6'b100011 ? 1 : ((opc[5:0] == 0) && (fun[5:0] == 6'b000010) ? 2 : 3));

//BCE
assign Bf[3:0] = {Instruction[28:26], Instruction[16]};

//MEMORY
assign DM_WE = opc[5:0] == 6'b101011;

//SHIFTER
assign Shift_type[2:0] = Instruction[2:0];

//PC
// jr || jalr   -  0
//branch inst - 1
//j or jal - 2
//else - 3
assign PC_MUX_SEL [1:0] = jr || jalr ? 0 : ((opc[5:3] == 0 && (opc[2:0] == 3'b001 && fun[4:1] == 0 || opc[2:1] == 2'b10 || opc[2:1] == 2'b11 && fun[4:0] == 0)) ? 1 : ((J_type || jal) ? 2 : 3)); 

endmodule
