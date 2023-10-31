#include <xc.h>

//You cannot use sp as a general purpose register.

#define TIMER_PERIOD (20000)	// maximum value is 65535, actual rate is 5,000,000/TIMER_PERIOD

#define CT_INT_ON (1)
#define CT_INT_PRIOR_3 (3)

.global main

// defining required arrays
.data

seg:
.word 0x0000, 0x0000, 0x0000, 0x0000 
//    seg1, seg2, seg3, seg4
InterruptCounter:
.word 0x0000
    
studentID:    
.word 0x0009, 0x0009, 0x0001, 0x0000, 0x0001, 0x0008, 0x0005, 0x0007

patterns:
.word 0x003f, 0x0006, 0x005b, 0x004f, 0x0066, 0x006d, 0x007d, 0x0007, 0x007f, 0x0067
numbers:
.word 1, 2, 3, 4, 5, 6, 7, 8, 9
      
.text
   
.ent main 
main:

jal InterruptSetup

la $8, ANSELB
sw $0, 0($8)

la $8, TRISB
sw $0, 0($8)
    
la $8, LATB
sw $0, 0($8)

// loading addresses
la $8, seg
la $11, studentID

la $1, patterns
la $2, numbers

// defining required registers
addi $17, $0, 0x0800
addi $5, $0, 0x0080
addi $13, $0, 0
    
loop:
     
    // loading one digit of the student number
    lw $12, 0($11)
    
    // detecting the digit
    beq $12, $0, zeroo
    lw $3, 0($2)
    beq $12, $3, one
    lw $3, 4($2)
    beq $12, $3, two
    lw $3, 8($2)
    beq $12, $3, three
    lw $3, 12($2)
    beq $12, $3, four
    lw $3, 16($2)
    beq $12, $3, five
    lw $3, 20($2)
    beq $12, $3, six
    lw $3, 24($2)
    beq $12, $3, seven
    lw $3, 28($2)
    beq $12, $3, eight
    lw $3, 32($2)
    beq $12, $3, nine
    
    // displaying the digit loaded 
    continue: 
    
    //delay
    lui $4, 0x0003
    ori $4, $4, 0xffff
    delay:
    addi $4, $4, -1
    bne $4, $0, delay
    
    add $12, $0, $3
    
    //implementing appropriate k
    or $9, $12, $17 
    //storing the complete register into appropriate seg
    sw $9, 0($8)
    
    //go to next digit, seg and k
    addi $11, $11, 4
    addi $8, $8, 4
    srl $17, $17, 1
    
    //repeat until 4 digits have been displayed
    bne $17, $5, loop
    //restart seg and k and move student number 1 step forward
    addi $17, $0, 0x0800
    la $8, seg
    addi $11, $11, -12
    
    //repeat until student number is finished
    addi $13, $13, 1
    
    lw $3, 16($2)
    slt $14, $13, $3
    bne $14, $0, loop
    //restart student number and counter then repeat
    la $11, studentID 
    addi $13, $0, 0
    j loop
 
// loading required pattern for each digit 
zeroo:
    lw $3, 0($1)
    j continue
one:
    lw $3, 4($1)
    j continue
two:
    lw $3, 8($1)
    j continue
three:
    lw $3, 12($1)
    j continue
four:
    lw $3, 16($1)
    j continue
five:
    lw $3, 20($1)
    j continue
six:
    lw $3, 24($1)
    j continue
seven:
    lw $3, 28($1)
    j continue
eight:
    lw $3, 32($1)
    j continue
nine:
    lw $3, 36($1)
    j continue  
 
 .end main     
 
/*********************************************************************
 * This is the actual interrupt handler that gets installed
 * in the interrupt vector table. It jumps to the core-timer
 * interrupt handler function.
 *
 * Note: The ".section .vector_0" is not allocatable. Hence to force
 * this section to be allocatable, use the "ax" directive.
 ********************************************************************/
.section .vector_0,code
   j      CoreTimerIntHandler

/*********************************************************************
 * CoreTimerIntHandler()
 * Interrupt handler function for core-timer. The function
 * clears the interrupt flag, shows one digit on the seven segment board and updates the
 * core-timer registers.
 *
 * pre-condition: A jump to ISR is registered in vector table
 * Input: none
 * Output: none
 * Side effect: shows one digit on the seven segment board
 ********************************************************************/
.text
.ent CoreTimerIntHandler 
CoreTimerIntHandler:
   /* interrupt prologue */
   addiu sp, sp, -20
   sw $1, 0(sp)
   sw t0, 4(sp)
   sw t1, 8(sp)
   
   mfc0 t1, $14          /* read EPC register (program counter at last exeption) */
   sw t1, 12(sp)      /* save EPC on stack */
   
   mfc0 t1, $12         /* read STATUS register */
   sw t1, 16(sp)         /* save STATUS on stack */
   
   mfc0        t0, $13          /* read CAUSE register */
   srl         t0, t0,0xA      /* align RIPL (Requested Interrupt Priority Level) to bit 0 */
   ins         t1, t0, 10, 6      /* insert RIPL to IPL(Interrupt Priority Level) field (copy and replace from 6 LSBs of k0 to k1 starting at bit 10 of k1, k1<15:10> = k0<5:0>) */
   ins         t1, zero, 1, 4	/* k1<4:1> = zero<3:0> */
   mtc0        t1, $12         /* write STATUS register  (status<15:10> = cause<15:10>, status<4:1> = 0)  */
   
   
   /* set up t0 with time period and then call the update core-timer routine for next interrupt. */
   ori     t0, zero, TIMER_PERIOD
   mtc0	   $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0	   t0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   /* clear interrupt flag */
   addiu   t1, zero, 1
   la      t0, IFS0CLR
   sw      t1, 0(t0)	// IFS0<0> = 0
   
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   la t0, LATBCLR
   addi t1, zero, 0x0fff
   sw t1, 0(t0)
   
   la t1, InterruptCounter
   lw t0, 0(t1)
   addiu t0, t0, 4
   sw t0, 0(t1)	      // InterruptCounter = InterruptCounter + 4
   andi t0, t0, 0xf     // t0 = InterrupCounter%16
   la t1, seg
   add t0, t1, t0       // t0 = seg address + InterrupCounter%16
   
    lw t1, 0(t0)        // t1 = pattern
    andi t1, t1, 0x0fff
    la t0, LATBSET
    sw t1, 0(t0)        // LATB<11:0> = seg<11:0>
      
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   /* interrupt epilogue */
   di                      /* disable interrupts */
   
   lw t1, 12(sp)      /* restore EPC from stack */
   mtc0 t1, $14
   
   lw t1, 16(sp)         /* restore STATUS from stack */
   mtc0 t1, $12
   
   lw $1, 0(sp)
   lw t0, 4(sp)
   lw t1, 8(sp)
   addiu sp, sp, 20
   
   ei                        /* enable interrupts */
   /* return from interrupt */
   eret        
.end CoreTimerIntHandler
   
 /*********************************************************************
 * InterruptSetup()
 *
 * cause<23> = 1
 * ei
 * count = 0
 * compare = TIMER_PERIOD
 * IFS0CLR<0> = 0
 * IPC0<4:2> = CT_INT_PRIOR_3
 * IEC0<0> = CT_INT_ON
 ********************************************************************/
.ent InterruptSetup
InterruptSetup:
    /* function prologue - save registers used in this function 
     * on stack and adjust stack-pointer
     */
   addiu   sp, sp, -8
   sw      s0, 0(sp)
   sw      s1, 4(sp)

   //INTEnableSystemMultiVectoredInt:
   mfc0    s0, $13
   lui     s1, 0x0080
   or      s0, s0, s1
   mtc0    s0, $13  // bit <23> (IV bit = Interrupt Vector) in the cause register ($13) in coprocessor0 is set
   ei      /* enable system-wide interrupts */
   
   //OpenCoreTimer:
   ori     s0, zero, TIMER_PERIOD  // s0 = TIMER_PERIOD
   mtc0	   $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0	   s0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   //mCTClearIntFlag:
   addiu   s1, zero, 1
   la      s0, IFS0CLR
   sw      s1, 0(s0)	// bit <0> in the Interrupt Flag Status register is cleared
   
   //mCTSetIntPriority:
   addiu   s1, zero, (7 << 2)
   la      s0, IPC0CLR
   sw      s1, 0(s0)
   ori     s0, zero, CT_INT_PRIOR_3 // s0 = CT_INT_PRIOR_3
   sll     s1, s0, 2
   la      s0, IPC0SET
   sw      s1, 0(s0)	// bits <4:2> in the Interrupt Priority Control register (of the core timer interrupt), which are the core timer interrupt priority bits = CT_INT_PRIOR_3
   
   //mCTIntEnable:
   ori     s1, zero, CT_INT_ON	// s1 = CT_INT_ON
   la      s0, IEC0SET
   sw      s1, 0(s0)	// bit <0> in the Interrupt Enable Control register (of the core timer interrupt), which is the core timer interrupt enable bit = CT_INT_ON
   
   /* function epilogue - restore registers used in this function
     * from stack and adjust stack-pointer
     */
   lw      s1, 4(sp)
   lw      s0, 0(sp)
   addiu   sp, sp, 8
   
   /* return to caller */
   jr      ra
.end InterruptSetup