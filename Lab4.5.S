#include <xc.h>
#include "configbits.c"
.global main 
.ent main
main:

la $8, ANSELA
sw $0, 0($8)

la $8, ANSELB
sw $0, 0($8)
    
la $8, TRISA
ori $9, $0, 0x00ff
sw $9, 0($8)
//A is input so 1    
    
la $8, TRISB
sw $0, 0($8)
//B is output so 0    
    
la $10, PORTA
la $11, LATB
//load the address of inputs (A) and the address of outputs (B) 
    
loop:
  
lw $8, 0($10)
    
andi $8, $8, 0x0001
    
sll $8, $8, 8
sw $8, 0($11)
    
j loop
.end main