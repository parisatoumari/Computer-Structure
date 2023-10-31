#include <xc.h>
#include "configbits.c"
    
.global main 
.ent main
main:

la $8, ANSELB
sw $0, 0($8)  
    
la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
    
la $11, LATB
 
addi $1, $0, 0x017d
addi $2, $0, 0x0207
addi $3, $0, 0x047f
addi $4, $0, 0x0867 
//defining the 4 numbers which are going to be shown
 
mainLoop:
      
sw $1, 0($11)
//showing the number 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop1: 
addi $16, $16, -1
bne $16, $0, loop1 
//literally do nothing which means delay, but the amount of the delay is not that long that our eyes can notice  
    
sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop2: 
addi $16, $16, -1
bne $16, $0, loop2
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop3: 
addi $16, $16, -1
bne $16, $0, loop3
    
sw $4, 0($11) 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop4: 
addi $16, $16, -1
bne $16, $0, loop4  
    
j mainLoop
//show the 4-digit number indefinitely

.end main
 
 /***TABLE OF SEVEN SEGMENT DISPLAYING DIGITS IN K4
0 : 0x013f
1 : 0x0106
2 : 0x015b
3 : 0x014f
4 : 0x0166
5 : 0x016d
6 : 0x017d
7 : 0x0107
8 : 0x017f
9 : 0x0167***/