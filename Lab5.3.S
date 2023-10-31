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
//all of the B is output
    
la $11, LATB
   
lui $17, 0x0000
ori $17, $17, 0x0000f
    
addi $1, $0, 0x0167
//before each mainloop# we have defined the number(s) which are going to be shown simultaniously
    
mainLoop0:
//each mainloop# contains some loops which are going to show each one digit number but with unnoticeable delay between them 
    
sw $1, 0($11)
//display the number
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop0: 
addi $16, $16, -1
bne $16, $0, loop0
//delay between each 2 digits on 2 7-segs which shoud be unnoticeable
    
addi $9, $9, 1
bne $9, $17, mainLoop0  
//delay between each 2 states of whole 7-segs

add $9, $0, $0
//restart the counter
    
addi $1, $0, 0x0267
addi $2, $0, 0x0167  
    
mainLoop00:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop000: 
addi $16, $16, -1
bne $16, $0, loop000

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop00: 
addi $16, $16, -1
bne $16, $0, loop00
    
addi $9, $9, 1
bne $9, $17, mainLoop00
    
add $9, $0, $0
 
addi $1, $0, 0x0467
addi $2, $0, 0x0267   
addi $3, $0, 0x0106 
    
mainLoop000:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop000000: 
addi $16, $16, -1
bne $16, $0, loop000000

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop00000: 
addi $16, $16, -1
bne $16, $0, loop00000
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop0000: 
addi $16, $16, -1
bne $16, $0, loop0000
 
addi $9, $9, 1
bne $9, $17, mainLoop000    
    
add $9, $0, $0
        
addi $1, $0, 0x0867
addi $2, $0, 0x0467
addi $3, $0, 0x0206
addi $4, $0, 0x013f
    
mainLoop1:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop1: 
addi $16, $16, -1
bne $16, $0, loop1 

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
 
addi $9, $9, 1
bne $9, $17, mainLoop1  
 
add $9, $0, $0
    
addi $1, $0, 0x0867 
addi $2, $0, 0x0406    
addi $3, $0, 0x023f
addi $4, $0, 0x0106    
    
mainLoop2:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop11: 
addi $16, $16, -1
bne $16, $0, loop11 

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop22: 
addi $16, $16, -1
bne $16, $0, loop22
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop33: 
addi $16, $16, -1
bne $16, $0, loop33
    
sw $4, 0($11) 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop44: 
addi $16, $16, -1
bne $16, $0, loop44 
 
addi $9, $9, 1
bne $9, $17, mainLoop2
    
add $9, $0, $0
    
addi $1, $0, 0x0806
addi $2, $0, 0x043f    
addi $3, $0, 0x0206
addi $4, $0, 0x017f  
    
mainLoop3:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop111: 
addi $16, $16, -1
bne $16, $0, loop111

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop222: 
addi $16, $16, -1
bne $16, $0, loop222
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop333: 
addi $16, $16, -1
bne $16, $0, loop333
    
sw $4, 0($11) 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop444: 
addi $16, $16, -1
bne $16, $0, loop444 
 
addi $9, $9, 1
bne $9, $17, mainLoop3
    
add $9, $0, $0
    
addi $1, $0, 0x083f
addi $2, $0, 0x0406    
addi $3, $0, 0x027f
addi $4, $0, 0x016d  
    
mainLoop4:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop1111: 
addi $16, $16, -1
bne $16, $0, loop1111

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop2222: 
addi $16, $16, -1
bne $16, $0, loop2222
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop3333: 
addi $16, $16, -1
bne $16, $0, loop3333
    
sw $4, 0($11) 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop4444: 
addi $16, $16, -1
bne $16, $0, loop4444 
 
addi $9, $9, 1
bne $9, $17, mainLoop4 
    
add $9, $0, $0
    
addi $1, $0, 0x0806
addi $2, $0, 0x047f    
addi $3, $0, 0x026d
addi $4, $0, 0x0107  
    
mainLoop5:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop11111: 
addi $16, $16, -1
bne $16, $0, loop11111

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop22222: 
addi $16, $16, -1
bne $16, $0, loop22222
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop33333: 
addi $16, $16, -1
bne $16, $0, loop33333
    
sw $4, 0($11) 
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop44444: 
addi $16, $16, -1
bne $16, $0, loop44444 
 
addi $9, $9, 1
bne $9, $17, mainLoop5 
    
add $9, $0, $0
    
addi $1, $0, 0x087f
addi $2, $0, 0x046d   
addi $3, $0, 0x0207 
    
mainLoop6:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop111111: 
addi $16, $16, -1
bne $16, $0, loop111111

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop222222: 
addi $16, $16, -1
bne $16, $0, loop222222
    
sw $3, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop333333: 
addi $16, $16, -1
bne $16, $0, loop333333
 
addi $9, $9, 1
bne $9, $17, mainLoop6     
    
add $9, $0, $0
    
addi $1, $0, 0x086d
addi $2, $0, 0x0407   
    
mainLoop7:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop1111111: 
addi $16, $16, -1
bne $16, $0, loop1111111

sw $2, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop2222222: 
addi $16, $16, -1
bne $16, $0, loop2222222
    
addi $9, $9, 1
bne $9, $17, mainLoop7
    
add $9, $0, $0
    
addi $1, $0, 0x0807
    
mainLoop8:
    
sw $1, 0($11)
    
lui $16, 0x0000
ori $16, $16, 0x3fff 
loop11111111: 
addi $16, $16, -1
bne $16, $0, loop11111111
    
addi $9, $9, 1
bne $9, $17, mainLoop8    
    
    
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