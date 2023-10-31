#include <xc.h>
//#include "configbits.c"
    
.global main 
.ent main
main:
    
.data
input:
.word 0x11111111
.text
//assigning 32-bit of memory named "data" to the number entered in front of ".word"
    
la $8, ANSELB
sw $0, 0($8)    
    
la $8, TRISB
ori $9, $0, 0x00ff
sw $9, 0($8)
    
la $11, LATB
    
la $2, input
//loading the address named "input" into $2
lw $3, 0($2) 
//loading the number saved in this address into $3
sll $3, $3, 8   
//transfer the number to output
sw $3, 0($11) 
//store the number in the output
 
.end main