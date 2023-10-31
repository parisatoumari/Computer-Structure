//LAB_2
//MELIKA RAJABI 99101608 
//PARISA TOUMARI 

//----------------------------- Initializing the time unit
`timescale 1ns/1ns
//------------------------------------------------------

module fp_adder (
//----------------------- Port directions and deceleration
   input [31:0] a, 
   input [31:0] b, 
   output [31:0] s
   );
//------------------------------------------------------

//------------------------------------- Wire deceleration
    wire sign_a;
    wire [7:0] E_a;
    wire [7:0]exponent_a;
    wire hidden_a;
    wire [25:0] fraction_a;
    
    wire sign_b;
    wire [7:0] E_b;
    wire [7:0] exponent_b;
    wire hidden_b;
    wire [25:0] fraction_b;

    wire sign_large;
    wire [7:0] exponent_large;
    wire [25:0] fraction_large;
    wire [28:0] FRACTION_LARGE;

    wire sign_small;
    wire [7:0] exponent_small;
    wire [25:0] fraction_small;
    wire [28:0] FRACTION_SMALL;

    wire [26:0] shifted_fraction_small;

    wire [28:0] sum;
    wire [28:0] SUM;
    wire [28:0] normalizedSum;
    wire [28:0] NorSum;
    wire [28:0] NorSumm;
    wire [28:0] Sum;
    wire [28:0] SUMFINAL;

    wire [7:0] Exponent;
    wire [7:0] EXPONENT;
    wire [7:0] EpreFinal;
    wire [7:0] EFinal;
    wire [7:0] EFINAL;

    wire [7:0] subtraction;
    wire [7:0] shift;

    wire [25:0] lostBits;
    wire [28:0] sticky;

    wire [4:0] k;
    wire carry;
//------------------------------------------------------

//------------------------------------ Combinational logic
    assign sign_a = a[31];
    assign sign_b = b[31];

    assign E_a = a[30:23];
    assign E_b = b[30:23];

    assign hidden_a = E_a > 0 ? 1'b1 : 1'b0;
    assign hidden_b = E_b > 0 ? 1'b1 : 1'b0;

    assign exponent_a = E_a > 0 ? a[30:23] : {8'b00000001};
    assign exponent_b = E_b > 0 ? b[30:23] : {8'b00000001};

    assign fraction_a = {hidden_a, a[22:0], 2'b00};
    assign fraction_b = {hidden_b, b[22:0], 2'b00};
    //unpacking the 32-bit number given with respect to the E

    assign {carry, subtraction} = exponent_a - exponent_b;
    //calculating the amount of smaller number's shift

    assign sign_small = carry == 0 ? sign_b : sign_a;  
    assign sign_large = carry == 0 ? sign_a : sign_b;  

    assign exponent_small = carry == 0 ? exponent_b : exponent_a;  
    assign exponent_large = carry == 0 ? exponent_a : exponent_b; 

    assign Exponent = exponent_large;

    assign fraction_small = carry == 0 ? fraction_b : fraction_a;  
    assign fraction_large = carry == 0 ? fraction_a : fraction_b; 
    //swapping numbers in order to know which one is smaller and which one is larger

    assign shift = carry == 0 ? subtraction : -subtraction;

    assign lostBits = shift <= 26 ? fraction_small << (26 - shift) : fraction_small;
    //save bits that are going to be lost 

    assign shifted_fraction_small = {fraction_small >> shift, |lostBits};
    //OR the lost bits and save it in an extra bit at the end

    assign FRACTION_SMALL = sign_small ? {sign_small, sign_small, -shifted_fraction_small} : {sign_small, sign_small, shifted_fraction_small};
    assign FRACTION_LARGE = sign_large ? {sign_large, sign_large, -fraction_large, 1'b0} : {sign_large, sign_large, fraction_large, 1'b0};

    assign sum = FRACTION_LARGE + FRACTION_SMALL;
    //add two numbers with paying attention to extends and G, R, S bits and also the hidden bit

    assign SUM = sum[28] ? -sum : sum;
    //take the absolute value of sum

    assign k = SUM[27] ? 27 :
               SUM[26] ? 26 :
               SUM[25] ? 25 :
               SUM[24] ? 24 :
               SUM[23] ? 23 :
               SUM[22] ? 22 :
               SUM[21] ? 21 :
               SUM[20] ? 20 :
               SUM[19] ? 19 :
               SUM[18] ? 18 :
               SUM[17] ? 17 :
               SUM[16] ? 16 :
               SUM[15] ? 15 :
               SUM[14] ? 14 :
               SUM[13] ? 13 :
               SUM[12] ? 12 :
               SUM[11] ? 11 :
               SUM[10] ? 10 :
               SUM[9] ? 9:
               SUM[8] ? 8 :
               SUM[7] ? 7 :
               SUM[6] ? 6 :
               SUM[5] ? 5 :
               SUM[4] ? 4 :
               SUM[3] ? 3 :
               SUM[2] ? 2 :
               SUM[1] ? 1 : 0;

    assign normalizedSum = k > 25 ? SUM >> (k - 26) : SUM << (26 - k);
    assign EXPONENT = k > 25 ? (Exponent + k - 26 ) : (Exponent - 26 + k);
    //finding the location of the first 1 and shift the number in order to have it in the 3rd place from left

    assign EpreFinal = Exponent + k > 26 ? EXPONENT : 8'b00000000; 
    assign NorSum = Exponent + k > 26 ? normalizedSum : SUM << (Exponent - 1);
    //for denormalized display make the exponent 0 and shift the number back until E is 1

    assign sticky = k > 25 ? SUM << (54-k) : SUM << 28;
    assign NorSumm = {NorSum[28:1], |sticky};

    assign Sum = NorSumm[2] == 0 ? NorSumm :
                 NorSumm[1] == 1 ? (NorSumm + 4'b1000) :
                 NorSumm[0] == 1 ? (NorSumm + 4'b1000) :
                 NorSumm[3] == 0 ? NorSumm : (NorSumm + 4'b1000);
    //round the number with paying attention to the new sticky bit

    assign EFinal = |SUM ? EpreFinal : 8'b00000000;
    //if there is no 1 the exponent and the number are both 0 (denormalized)

    assign SUMFINAL = Sum[27] ? Sum >> 1 : Sum; 
    assign EFINAL =  Sum[27] ? EFinal + 1 : EFinal;
    //renormalize in case of special situations after rounding 

    assign s = (a[30:0] == 0) ? b :
               (b[30:0] == 0) ? a : {sum[28], EFINAL, SUMFINAL[25:3]};
    //packing the sign, exponent and the fractional part
    //pay attention to -0 
//------------------------------------------------------

endmodule

