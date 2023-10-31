//===========================================================
//
//			Name & Student ID:
//       Melika Rajabi - 99101608
//
//			Implemented Instructions are:
//			R format:  add(u), sub(u), and, or, xor, nor, slt, sltu;
//			I format:  beq, bne, lw, sw, addi(u), slti, sltiu, andi, ori, xori, lui.
//
//===========================================================

`timescale 1ns/1ns

   `define ADD  4'h0
   `define SUB  4'h1
   `define SLT  4'h2
   `define SLTU 4'h3
   `define AND  4'h4
   `define OR   4'h5
   `define NOR  4'h6
   `define XOR  4'h7
   `define LUI  4'h8

module single_cycle_mips 
(
	input clk,
	input reset
);
 
	initial begin
		$display("Single Cycle MIPS Implemention");
		$display("Melika Rajabi");
	end

	reg [31:0] PC;          // Keep PC as it is, its name is used in higher level test bench

   wire [31:0] instr;
   wire [ 5:0] op   = instr[31:26];
   wire [ 5:0] func = instr[ 5: 0];

   wire [31:0] RD1, RD2, AluResult, MemReadData;

   wire AluZero;

   // Control Signals

   wire PCSrc;

   reg SZEn, ALUSrc, RegDst, MemtoReg, RegWrite, MemWrite, Branch, BranchNot; //required registers


   reg [3:0] AluOP;

	
	// CONTROLLER COMES HERE

   assign PCSrc = Branch? AluZero:
                  BranchNot? !AluZero:
                  0;
   //PCSrc is Branch && AluZero for beq and BranchNot && !AluZero for bne and 0 for the rest

   always @(*) begin

      SZEn = 1'bx;
      AluOP = 4'hx;
      ALUSrc = 1'bx;
      RegDst = 1'bx;
      MemtoReg = 1'bx;
      RegWrite = 1'b0;
      MemWrite = 1'b0;
      //initial values

      case(op)

         6'b000000: //R-types
               begin
               SZEn <= 1'b1;
               ALUSrc <= 1'b0;
               RegDst <= 1'b1;
               MemtoReg <= 1'b0;
               RegWrite <= 1'b1;
               MemWrite <= 1'b0;
               Branch <= 1'b0; 
               BranchNot <= 1'b0; 

               case(func)

                  6'b100000 : //ADD
                     AluOP <= `ADD;
                  6'b100001 : //ADDU
                     AluOP <= `ADD;
                  6'b100010 : //SUB
                     AluOP <= `SUB;
                  6'b100011 : //SUBU
                     AluOP <= `SUB;
                  6'b100100 : //AND
                     AluOP <= `AND;
                  6'b100101 : //OR
                     AluOP <= `OR;
                  6'b100110 : //XOR
                     AluOP <= `XOR;
                  6'b100111 : //NOR
                     AluOP <= `NOR;
                  6'b101010 : //SLT
                     AluOP <= `SLT;
                  6'b101011 : //SLTU
                     AluOP <= `SLTU;
               endcase

               end

         6'b000100: //beq
               begin
               SZEn <= 1'b1;
               AluOP <= `SUB;
               ALUSrc <= 1'b0;
               RegDst <= 1'bx;
               MemtoReg <= 1'bx;
               RegWrite <= 1'b0;
               MemWrite <= 1'b0;
               Branch <= 1'b1;
               BranchNot <= 1'b0; 
               end

         6'b000101: //bne
               begin
               SZEn <= 1'b1;
               AluOP <= `SUB;
               ALUSrc <= 1'b0;
               RegDst <= 1'bx;
               MemtoReg <= 1'bx;
               RegWrite <= 1'b0;
               MemWrite <= 1'b0;
               Branch <= 1'b0;
               BranchNot <= 1'b1; 
               end

         6'b001000: //addi
               begin
               SZEn <= 1'b1;
               AluOP <= `ADD;
               ALUSrc <= 1'b1;
               RegDst <= 1'b0;
               MemtoReg <= 1'b0;
               RegWrite <= 1'b1;
               MemWrite <= 1'b0;
               Branch <= 1'b0;
               BranchNot <= 1'b0; 
               end

         6'b001001: //addiu
               begin
               SZEn <= 1'b0;
               AluOP <= `ADD;
               ALUSrc <= 1'b1;
               RegDst <= 1'b0;
               MemtoReg <= 1'b0;
               RegWrite <= 1'b1;
               MemWrite <= 1'b0;
               Branch <= 1'b0; 
               BranchNot <= 1'b0; 
               end              

         6'b001010: //slti
                begin
                SZEn <= 1'b1;
                AluOP <= `SLT;
                ALUSrc <= 1'b1;
                RegDst <= 1'b0;
                MemtoReg <= 1'b0;
                RegWrite <= 1'b1;
                MemWrite <= 1'b0;
                Branch <= 1'b0;
                BranchNot <= 1'b0; 
                end 

         6'b001011: //sltiu
                begin
                SZEn <= 1'b0;
                AluOP <= `SLTU;
                ALUSrc <= 1'b1;
                RegDst <= 1'b0;
                MemtoReg <= 1'b0;
                RegWrite <= 1'b1;
                MemWrite <= 1'b0;
                Branch <= 1'b0; 
                BranchNot <= 1'b0; 
                end

         6'b001100: //andi
          begin
                SZEn <= 1'b0;
                AluOP <= `AND;
                ALUSrc <= 1'b1;
                RegDst <= 1'b0;
                MemtoReg <= 1'b0;
                RegWrite <= 1'b1;
                MemWrite <= 1'b0;
                Branch <= 1'b0; 
                BranchNot <= 1'b0; 
          end

         6'b001101: //ori
          begin
                SZEn <= 1'b0;
                AluOP <= `OR;
                ALUSrc <= 1'b1;
                RegDst <= 1'b0;
                MemtoReg <= 1'b0;
                RegWrite <= 1'b1;
                MemWrite <= 1'b0;
                Branch <= 1'b0; 
                BranchNot <= 1'b0; 
          end

         6'b001110: //xori
          begin
                SZEn <= 1'b0;
                AluOP <= `XOR;
                ALUSrc <= 1'b1;
                RegDst <= 1'b0;
                MemtoReg <= 1'b0;
                RegWrite <= 1'b1;
                MemWrite <= 1'b0;
                Branch <= 1'b0; 
                BranchNot <= 1'b0; 
          end  

         6'b001111: //lui
         begin
               SZEn <= 1'bx;
               AluOP <= `ADD;
               ALUSrc <= 1'b1;
               RegDst <= 1'b0;
               MemtoReg <= 1'b0;
               RegWrite <= 1'b1;
               MemWrite <= 1'b0;
               Branch <= 1'b0;
               BranchNot <= 1'b0;  
         end                

         6'b100011: //lw
         begin
               SZEn <= 1'b0;
               AluOP <= `ADD;
               ALUSrc <= 1'b1;
               RegDst <= 1'b0;
               MemtoReg <= 1'b1;
               RegWrite <= 1'b1;
               MemWrite <= 1'b0;
               Branch <= 1'b0; 
               BranchNot <= 1'b0;  
         end   
                   
         6'b101011: //sw
         begin
               SZEn <= 1'b0;
               AluOP <= `ADD;
               ALUSrc <= 1'b1;
               RegDst <= 1'bx;
               MemtoReg <= 1'bx;
               RegWrite <= 1'b0;
               MemWrite <= 1'b1;
               Branch <= 1'b0;  
               BranchNot <= 1'b0;  
         end

      endcase
      
   end


	// DATA PATH STARTS HERE

   wire [31:0] Imm32 = SZEn ? {{16{instr[15]}},instr[15:0]} : {16'h0, instr[15:0]};     // ZSEn: 1 sign extend, 0 zero extend

   wire [31:0] PCplus4 = PC + 4'h4;

   wire [31:0] PCbranch = PCplus4 + (Imm32 << 2);

   always @(posedge clk)
      if(reset)
         PC <= 32'h0;
      else
         PC <= PCSrc ? PCbranch : PCplus4;


//========================================================== 
//	instantiated modules
//========================================================== 

// Register File

   reg_file rf
   (
      .clk   ( clk ),
      .write ( RegWrite ),
      .WR    ( RegDst   ? instr[15:11] : instr[20:16]),
      .WD    ( MemtoReg ? MemReadData  : AluResult),
      .RR1   ( instr[25:21] ),
      .RR2   ( instr[20:16] ),
      .RD1   ( RD1 ),
      .RD2   ( RD2 )
	);

   my_alu alu
   (
      .Op( AluOP ),
      .A ( RD1 ),
      .B ( ALUSrc ? Imm32 : RD2),
      .X ( AluResult ),
      .Z ( AluZero )
   );
   


//	Instruction Memory
	async_mem imem			// keep the exact instance name
	(
		.clk		   (1'b0),
		.write		(1'b0),		// no write for instruction memory
		.address	   ( PC ),		   // address instruction memory with pc
		.write_data	(32'bx),
		.read_data	( instr )
	);
	
// Data Memory
	async_mem dmem			// keep the exact instance name
	(
		.clk		   ( clk ),
		.write		( MemWrite ),
		.address	   ( AluResult ),
		.write_data	( RD2 ),
		.read_data	( MemReadData )
	);

endmodule


//==============================================================================

module my_alu(
   input  [3:0] Op,
   input  [31:0] A,
   input  [31:0] B,
   output [31:0] X,
   output        Z
   );

   wire sub = Op != `ADD;
   wire [31:0] bb = sub ? ~B : B;
   wire [32:0] sum = A + bb + sub;
   wire sltu = ! sum[32];

   wire v = sub ?
            ( A[31] != B[31] && A[31] != sum[31] )
          : ( A[31] == B[31] && A[31] != sum[31] );

   wire slt = v ^ sum[31];

   reg [31:0] x;

   always @( * )
      case( Op )
         `ADD : x = sum;
         `SUB : x = sum;
         `SLT : x = slt;
         `SLTU: x = sltu;
         `AND : x = A & B;
         `OR  : x = A | B;
         `NOR : x = ~(A | B);
         `XOR : x = A ^ B;
         `LUI : x = {B[15:0], 16'h0};
         default : x = 32'hxxxxxxxx;
      endcase

   assign X = x;
   assign Z = x == 32'h00000000;

endmodule

//============================================================================