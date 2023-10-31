//===========================================================
//
//			Name & Student ID:
//       Parisa Toumari
//
//			Implemented Instructions are:
//			R format: add, sub, addu, subu, and, or, xor, nor, slt, sltu, jr, jalr, multu, mfhi, mflo;
//			I format: beq, bne, lw, sw, addi, addiu, slti, sltiu, andi, ori, xori, lui;
//       J format: j, jal;
//
//===========================================================

`timescale 1ns/100ps

   `define ADD  3'b000
   `define SUB  3'b001
   `define SLT  3'b010
   `define SLTU 3'b011
   `define AND  3'b100
   `define XOR  3'b101
   `define OR   3'b110
   `define NOR  3'b111

module multi_cycle_mips(

   input clk,
   input reset,

   // Memory Ports
   output  [31:0] mem_addr,
   input   [31:0] mem_read_data,
   output  [31:0] mem_write_data,
   output         mem_read,
   output         mem_write
);

   // Data Path Registers
   reg MRE, MWE;
   reg [31:0] A, B, PC, IR, MDR, MAR;

   // Data Path Control Lines, do not forget, regs are not always regs !!
   reg setMRE, clrMRE, setMWE, clrMWE;
   reg Awrt, Bwrt, RFwrt, PCwrt, IRwrt, MDRwrt, MARwrt;
   reg multuStart;

   // Memory Ports Binding
   assign mem_addr = MAR;
   assign mem_read = MRE;
   assign mem_write = MWE;
   assign mem_write_data = B;

   // Mux & ALU Control Lines
   reg [2:0] aluOp;
   reg [2:0] aluSelB;
   reg [1:0] RegDst, MemtoReg;
   reg SgnExt, aluSelA, IorD;
   reg [2:0] PCsrc;
   reg mf;

   // Wiring
   wire aluZero;
   wire [31:0] aluResult, rfRD1, rfRD2;

   wire multuEnd;
   wire [31:0] hi, lo;

   wire aluzero = (IR[31:26] == 6'b000101) ? (~aluZero) : aluZero;
   //implementing branch not equal

   wire [31:0] pc = PCsrc == 2'b11 ? {PC[31:28], IR[25:0]<<2} : 
                    PCsrc == 2'b00 ? aluResult : A; 
   //implementing data path

   // Clocked Registers
   always @( posedge clk ) begin
      if( reset )
         PC <= #0.1 32'h00000000;
      else if( PCwrt )
         PC <= #0.1 pc;

      if( Awrt ) A <= #0.1 rfRD1;
      if( Bwrt ) B <= #0.1 rfRD2;

      if( MARwrt ) MAR <= #0.1 IorD ? aluResult : PC;

      if( IRwrt ) IR <= #0.1 mem_read_data;
      if( MDRwrt ) MDR <= #0.1 mem_read_data;

      if( reset | clrMRE ) MRE <= #0.1 1'b0;
          else if( setMRE) MRE <= #0.1 1'b1;

      if( reset | clrMWE ) MWE <= #0.1 1'b0;
          else if( setMWE) MWE <= #0.1 1'b1;
   end

   // Register File
   reg_file rf(
      .clk( clk ),
      .write( RFwrt ),

      .RR1( IR[25:21] ),
      .RR2( IR[20:16] ),
      .RD1( rfRD1 ),
      .RD2( rfRD2 ),

      .WR( RegDst == 2'b11 ? IR[15:11] : 
           RegDst == 2'b00 ? IR[20:16] : 
           RegDst == 2'b01 ? 5'b11111 : 5'bxxxxx ),
      .WD( MemtoReg == 2'b11 ? MDR :
           MemtoReg == 2'b00 ? aluResult : 
           MemtoReg == 2'b01 ? 
                              mf ? hi : lo 
                             : 
           MemtoReg == 2'b10 ? {IR[15:0], 16'h0000} : 2'bxx )
   );

   // Sign/Zero Extension
   wire [31:0] SZout = SgnExt ? {{16{IR[15]}}, IR[15:0]} : {16'h0000, IR[15:0]};

   // ALU-A Mux
   wire [31:0] aluA = aluSelA ? A : PC;

   // ALU-B Mux
   reg [31:0] aluB;
   always @(*)
   case (aluSelB)
      3'b000: aluB = B;
      3'b010: aluB = 32'h4;
      3'b100: aluB = SZout;
      3'b110: aluB = SZout << 2;
      3'b111: aluB = 32'h0;
   endcase

   my_alu alu(
      .A( aluA ),
      .B( aluB ),
      .Op( aluOp ),

      .X( aluResult ),
      .Z( aluZero )
   );


   // Controller Starts Here

   // Controller State Registers
   reg [5:0] state, nxt_state;

   // State Names & Numbers
   localparam
      RESET = 0, FETCH1 = 1, FETCH2 = 2, FETCH3 = 3, DECODE = 4,
      EX_ALU_R = 7, EX_ALU_I = 8,
      EX_LW_1 = 11, EX_LW_2 = 12, EX_LW_3 = 13, EX_LW_4 = 14, EX_LW_5 = 15,
      EX_SW_1 = 21, EX_SW_2 = 22, EX_SW_3 = 23,
      EX_BRA_1 = 25, EX_BRA_2 = 26,
      EX_J_1 = 31, EX_J_2 = 32, EX_JAL_1 = 33, EX_JAL_2 = 34, EX_JR_1 = 35, EX_JR_2 = 36, EX_JALR_1 = 37, EX_JALR_2 = 38,
      EX_MULTU_1 = 41, EX_MULTU_2 = 42, EX_MULTU_3 = 43, EX_MF = 44, 
      EX_LUI = 50;

   // State Clocked Register 
   always @(posedge clk)
      if(reset)
         state <= #0.1 RESET;
      else
         state <= #0.1 nxt_state;

   task PrepareFetch;
      begin
         IorD = 0;
         setMRE = 1;
         MARwrt = 1;
         nxt_state = FETCH1;
      end
   endtask

   // State Machine Body Starts Here
   always @( * ) begin

      nxt_state = 'bx;

      SgnExt = 'bx; IorD = 'bx;
      MemtoReg = 'bx; RegDst = 'bx;
      aluSelA = 'bx; aluSelB = 'bx; aluOp = 'bx;
      PCsrc = 2'bxx;
      mf = 'bx;

      PCwrt = 0;
      Awrt = 0; Bwrt = 0;
      RFwrt = 0; IRwrt = 0;
      MDRwrt = 0; MARwrt = 0;
      setMRE = 0; clrMRE = 0;
      setMWE = 0; clrMWE = 0;
      multuStart = 0;


      case(state)

         RESET:
            PrepareFetch;

         FETCH1:
            nxt_state = FETCH2;

         FETCH2:
            nxt_state = FETCH3;

         FETCH3: begin
            IRwrt = 1;
            PCwrt = 1;
            PCsrc = 2'b00;
            clrMRE = 1;
            aluSelA = 0;
            aluSelB = 3'b010;
            aluOp = `ADD;
            nxt_state = DECODE;
         end

         DECODE: begin
            Awrt = 1;
            Bwrt = 1;
            case( IR[31:26] )

               6'b000_000:             // R-format
                  case( IR[5:3] )
                     3'b000: ;
                     3'b001: 
                        case( IR[2:0] )
                           3'b000: nxt_state = EX_JR_1;           // jr
                           3'b001: nxt_state = EX_JALR_1;         // jalr
                        endcase   
                     3'b010: nxt_state = EX_MF;                   // mfhi and mflo        
                     3'b011: nxt_state = EX_MULTU_1;              // multu
                     3'b100: nxt_state = EX_ALU_R;                // add, sub, addu, subu, and, or, xor, nor
                     3'b101: nxt_state = EX_ALU_R;                // slt, sltu
                     3'b110: ;
                     3'b111: ;
                  endcase

               6'b001_000,             // addi
               6'b001_001,             // addiu
               6'b001_010,             // slti
               6'b001_011,             // sltiu
               6'b001_100,             // andi
               6'b001_101,             // ori
               6'b001_110:             // xori
                  nxt_state = EX_ALU_I;
               
               6'b001_111:             // lui
                  nxt_state = EX_LUI;

               6'b100_011:             // lw
                  nxt_state = EX_LW_1;

               6'b101_011:             // sw
                  nxt_state = EX_SW_1;

               6'b000_100,             // beq
               6'b000_101:             // bne
                  nxt_state = EX_BRA_1;     

               6'b000_010:             // j  
                  nxt_state = EX_J_1;       

               6'b000_011:             // jal
                  nxt_state = EX_JAL_1;  

            endcase
         end

         EX_ALU_R: begin
            RFwrt = 1;
            RegDst = 2'b11;
            MemtoReg = 2'b00;
            aluSelA = 1;
            aluSelB = 3'b000;
               case( IR[5:0] )
                  6'b100000 : //ADD
                     aluOp = `ADD;
                  6'b100001 : //ADDU
                     aluOp = `ADD;
                  6'b100010 : //SUB
                     aluOp = `SUB;
                  6'b100011 : //SUBU
                     aluOp = `SUB;
                  6'b100100 : //AND
                     aluOp = `AND;
                  6'b100101 : //OR
                     aluOp = `OR;
                  6'b100110 : //XOR
                     aluOp = `XOR;
                  6'b100111 : //NOR
                     aluOp = `NOR;
                  6'b101010 : //SLT
                     aluOp = `SLT;
                  6'b101011 : //SLTU
                     aluOp = `SLTU;
               endcase
            PrepareFetch;
         end

         EX_ALU_I: begin
            RFwrt = 1;
            RegDst = 2'b00;
            MemtoReg = 2'b00; 
            aluSelA = 1;
            aluSelB = 3'b100;   
               case( IR[31:26] )
               6'b001_000: begin
                  SgnExt = 1'b1;
                  aluOp = `ADD;
               end
               6'b001_001: begin           
                  SgnExt = 1'b0;
                  aluOp = `ADD;
               end
               6'b001_010: begin         
                  SgnExt = 1'b1;
                  aluOp = `SLT;
               end
               6'b001_011: begin          
                  SgnExt = 1'b0;
                  aluOp = `SLTU;
               end
               6'b001_100: begin         
                  SgnExt = 1'b0;
                  aluOp = `AND;
               end
               6'b001_101: begin            
                  SgnExt = 1'b0;
                  aluOp = `OR;
               end
               6'b001_110: begin
                  SgnExt = 1'b0;
                  aluOp = `XOR; 
               end         
               endcase                    
            PrepareFetch;
         end

         EX_LW_1: begin
            MARwrt = 1;
            IorD = 1;
            aluSelA = 1;
            aluSelB = 3'b100;
            SgnExt = 1;
            aluOp = `ADD;
            setMRE = 1;
            nxt_state = EX_LW_2;
         end

         EX_LW_2: begin
            nxt_state = EX_LW_3;            
         end

         EX_LW_3: begin
            nxt_state = EX_LW_4;            
         end

         EX_LW_4: begin
            clrMRE = 1;
            MDRwrt = 1;
            nxt_state = EX_LW_5;            
         end

         EX_LW_5: begin
            RFwrt = 1;
            RegDst = 2'b00;
            MemtoReg = 2'b11;
            PrepareFetch;            
         end

         EX_SW_1: begin
            setMWE = 1;
            MARwrt = 1;
            IorD = 1;
            aluSelA = 1;
            aluSelB = 3'b100;
            SgnExt = 1;
            aluOp = `ADD;
            nxt_state = EX_SW_2;
         end

         EX_SW_2: begin
            clrMWE = 1;
            nxt_state = EX_SW_3;
         end    

         EX_SW_3: begin
            PrepareFetch;
         end               

         EX_BRA_1: begin
            aluSelA = 1;
            aluSelB = 3'b000;
            aluOp = `SUB;
            if(aluzero)
               nxt_state = EX_BRA_2;
            else
               PrepareFetch;
         end

         EX_BRA_2: begin
            PCwrt = 1;
            PCsrc = 2'b00;
            MARwrt = 1;
            IorD = 1;
            aluSelA = 0;
            aluSelB = 3'b110;
            aluOp = `ADD;
            SgnExt = 1;
            setMRE = 1;
            nxt_state = FETCH1;
         end

         EX_J_1: begin
            PCwrt = 1;
            PCsrc = 2'b11;
            nxt_state = EX_J_2;
         end

         EX_J_2: begin
            PrepareFetch;
         end

         EX_JAL_1: begin
            PCwrt = 1;
            PCsrc = 2'b11;
            RFwrt = 1;
            MemtoReg = 2'b00;
            RegDst = 2'b01;
            aluOp = `ADD;
            aluSelA = 0;
            aluSelB = 3'b111;
            nxt_state = EX_JAL_2;
         end

         EX_JAL_2: begin
            PrepareFetch;
         end
      
         EX_JR_1: begin
            PCwrt = 1;
            PCsrc = 2'b01;
            RFwrt = 0;
            nxt_state = EX_JR_2;
         end

         EX_JR_2: begin
            PrepareFetch;
         end

         EX_JALR_1: begin
            PCwrt = 1;
            PCsrc = 2'b01;
            RFwrt = 1;
            MemtoReg = 2'b00;
            RegDst = 2'b01;
            aluOp = `ADD;
            aluSelA = 0;
            aluSelB = 3'b111;
            nxt_state = EX_JALR_2;
         end

         EX_JALR_2: begin
            PrepareFetch;
         end

         EX_MULTU_1: begin
            multuStart = 1;
            nxt_state = EX_MULTU_2;
         end

         EX_MULTU_2: begin
            if(multuEnd)
               nxt_state = EX_MULTU_3;
            else
               nxt_state = EX_MULTU_2;
         end

         EX_MULTU_3: begin
            PrepareFetch;
         end

         EX_MF: begin
            RFwrt = 1;
            MemtoReg = 2'b01;
            mf = (IR[2:0] == 3'b000) ? 1 : (IR[2:0] == 3'b010) ? 0 : 1'bx;
            RegDst = 2'b11;
            PrepareFetch;
         end

         EX_LUI: begin
            RFwrt = 1;
            RegDst = 2'b00;
            MemtoReg = 2'b10;
            PrepareFetch;
         end

      endcase

   end

   multiplier multu(
      .clk( clk ),
      .start( multuStart ),
      .A(A),
      .B(B),

      .Hi( hi ),
      .Lo( lo ),
      .ready( multuEnd )
   );

endmodule

//==============================================================================

module multiplier(
   input clk,  
   input start,
   input [31:0] A, 
   input [31:0] B, 
   output [31:0] Hi,
   output [31:0] Lo,
   output ready
   );

   reg [63:0] Product;
   reg [31:0] Multiplicand ;
   reg [5:0]  counter;

   wire product_write_enable;
   wire [31:0] adder_output;
   wire c_out;

   assign {c_out, adder_output} = Multiplicand + Product[63:32];
   assign product_write_enable = Product[0];
   assign ready = counter[5];

   always @ (posedge clk)
      
      if(start) begin

         counter <= 6'b000000 ;
         Product[31:0] <= B; 
         Product[63:32] <= 32'h00000000;
         Multiplicand <= A;

      end

      else if(!ready) begin

         counter <= counter + 1;
         Product <= Product >> 1;

         if(product_write_enable)
            Product[63:31] <= {c_out, adder_output};

      end  

   assign Hi = Product[63:32];
   assign Lo = Product[31:0]; 

endmodule

//==============================================================================

module my_alu(
   input [2:0] Op,
   input [31:0] A,
   input [31:0] B,

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
         `AND : x =   A & B;
         `OR  : x =   A | B;
         `NOR : x = ~(A | B);
         `XOR : x =   A ^ B;
         default : x = 32'hxxxxxxxx;
      endcase

   assign #2 X = x;
   assign #2 Z = x == 32'h00000000;

endmodule

//==============================================================================

module reg_file(
   input clk,
   input write,
   input [4:0] WR,
   input [31:0] WD,
   input [4:0] RR1,
   input [4:0] RR2,
   output [31:0] RD1,
   output [31:0] RD2
);

   reg [31:0] rf_data [0:31];

   assign #2 RD1 = rf_data[ RR1 ];
   assign #2 RD2 = rf_data[ RR2 ];   

   always @( posedge clk ) begin
      if ( write )
         rf_data[ WR ] <= WD;

      rf_data[0] <= 32'h00000000;
   end

endmodule

//==============================================================================
