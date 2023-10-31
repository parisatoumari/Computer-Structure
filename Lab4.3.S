#include <xc.h>
#include "configbits.c"
//including header files
.global main 
.ent main
//start main    
main:

la $8, ANSELB
sw $0, 0($8)
//ports are digital so ANSELB is 0    
    
la $8, TRISB
ori $9, $0, 0x00ff
sw $9, 0($8)
//TRISB 0-7 is input so 1 and TRISB 8-15 is output so 0    
    
la $10, PORTB
la $11, LATB
    
loop:

lw $8, 0($10)
//loading the number which presents on and off inputs    

andi $12, $8, 0x000f   
andi $13, $8, 0x00f0
srl $13, $13, 4
//seperate the first 4 bits and the second 4 bits     
    
add $14, $12, $13
//add the two BCD numbers    
  
addi $15, $14, -10    
sltu $1, $14, $15
bne $1, $0, oneDigit
//decide if the result number contains one digit or two digits    

addi $15, $15, 0x0010
//if the number has two digits display a 1 in tens column and minus the previous result by 10    
   
sll $15, $15, 8
//now shift the final result by 8 to transfer the output to bits number 8-15 
sw $15, 0($11)
//store the output    
j loop
//repeat this actions in order to respond to each change of inputs    
    
oneDigit:
sll $14, $14, 8
sw $14, 0($11)
j loop
//if the number contains 1 digit use the first result and store that
    
.end main