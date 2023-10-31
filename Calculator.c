#include "mcc_generated_files/mcc.h"
#include "mcc_generated_files/lcd.h"

// defining required pins and variables
#define ada ANSELA
#define adb ANSELB

#define ta TRISA
#define tb TRISB

#define la LATA
#define pb PORTB

#define A0 LATAbits.LATA0
#define A1 LATAbits.LATA1
#define A2 LATAbits.LATA2
#define A3 LATAbits.LATA3
#define A4 LATAbits.LATA4

#define B12 PORTBbits.RB12
#define B13 PORTBbits.RB13
#define B14 PORTBbits.RB14
#define B15 PORTBbits.RB15

// functions
void setA(int index);
int whichKey();
char displayNumber(int key, int position, int *p);
int operation(char numbers[16], int num, int op);
void equal(int result);
void delete(int *p);

int main(void)
{   
    // setting up the inputs and outputs and their kinds
    ada = 0x0;
    adb = 0x0;
    ta = 0x0;
    tb = 0x0000f000;

    int key;
    int num = 0;
    int *p = &num;
    char numbers[16];
    int op = -1;

    SYSTEM_Initialize();
    LCD_Initialize();
    LCDPutCmd(LCD_HOME);

    LCDClear();

    while (true)
    {
        // detect which key is pressed
        key = whichKey();

        // if any key is pressed display it and store it
        if(key != 0)
        {
            numbers[num] = displayNumber(key, num, p);
            num += 1;
        } 

        // if "=" is pressed show the result
        if(numbers[num - 1] == '=')
        {
            int result = 0;
            
            // find the operation
            for(int i = 0; i < num; i++)
            {
                if(numbers[i] == '+')
                    op = 0;
                else if(numbers[i] == '-')
                    op = 1;
                else if(numbers[i] == 'x')
                    op = 2;
                else if(numbers[i] == '/')
                    op = 3;
            }

            // calculate the result
            result = operation(numbers, num, op);
            // show the result
            equal(result);

        }

        // wait a little bit and repeat
        __delay_ms(350);

    }  

    return -1;
}

// setting one of the A pins 1 at a time based on the index in the input
void setA(int index)
{
    if(index == 0)
    {
        A0 = 1;
        A1 = 0;
        A2 = 0;
        A3 = 0;
        A4 = 0;
    }
    else if(index == 1)
    {
        A0 = 0;
        A1 = 1;
        A2 = 0;
        A3 = 0;
        A4 = 0;
    }
    else if(index == 2)
    {
        A0 = 0;
        A1 = 0;
        A2 = 1;
        A3 = 0;
        A4 = 0;
    }
    else if(index == 3)
    {
        A0 = 0;
        A1 = 0;
        A2 = 0;
        A3 = 1;
        A4 = 0;
    }
    else if(index == 4)
    {
        A0 = 0;
        A1 = 0;
        A2 = 0;
        A3 = 0;
        A4 = 1;
    }
}

// based on A and B pins and their values decide which key is pressed
int whichKey()
{
    int key = 0;

    setA(0);

    if(B12 == 1)
        key = 1;
    else if(B13 == 1) 
        key = 6;
    else if(B14 == 1) 
        key = 11; 
    else if(B15 == 1)
        key = 16; 
    else 
    {
        setA(1);

        if(B12 == 1)
            key = 2;  
        else if(B13 == 1) 
            key = 7;
        else if(B14 == 1) 
            key = 12;
        else if(B15 == 1) 
            key = 17;
        else
        {
            setA(2);

            if(B12 == 1)
                key = 3;
            else if(B13 == 1) 
                key = 8;
            else if(B14 == 1) 
                key = 13;
            else if(B15 == 1)
                key = 18;
            else
            {
                setA(3);

                if(B12 == 1)
                    key = 4;
                else if(B13 == 1) 
                    key = 9;
                else if(B14 == 1) 
                    key = 14;
                else if(B15 == 1)
                    key = 19;
                else
                {
                    setA(4);

                    if(B12 == 1)
                        key = 5;
                    else if(B13 == 1) 
                        key = 10;
                    else if(B14 == 1) 
                        key = 15;
                    else if(B15 == 1)
                        key = 20;
                }
            }
        }
    }  

    return key;
}

// display the character pressed and return it in the output
char displayNumber(int key, int position, int *p)
{
    char c;

    if (key == 0)
        c = ' ';
    else if(key == 1)
        c = '1';
    else if(key == 2)
        c = '2';    
    else if(key == 3)
        c = '3';
    else if(key == 4)
        c = '+';
    else if(key == 5)
        c = '-';
    else if(key == 6)
        c = '4';
    else if(key == 7)
        c = '5';
    else if(key == 8)
        c = '6';
    else if(key == 9)
        c = 'x';
    else if(key == 10)
        c = '/';
    else if(key == 11)
        c = '7';
    else if(key == 12)
        c = '8';
    else if(key == 13)
        c = '9';
    else if(key == 14)
        c = '.';
    else if(key == 15)
    {
        // if "del" is pressed reset everything
        delete(p);
        return;
    }
    else if(key == 16)
        c = '(';
    else if(key == 17)
        c = '0';
    else if(key == 18)
        c = ')';
    else if(key == 19)
        c = 'E';
    else if(key == 20)
        c = '=';

    LCDGoto(position,0);
    LCDPutChar(c);

    return c;
}

// calculate the result based on the operation, numbers entered and number of them
int operation(char numbers[16], int num, int op)
{
    int A = 0;
    int B = 0;

    for(int i = 0; i < num - 1; i++)
    {
        if(numbers[i] < '0' || numbers[i] > '9')
        {   
            // operation is found
            for(int j = 0; j < i; j++)
            {
                A = 10 * A + (int)(numbers[j] - '0');
            }
            for(int j = i + 1; j < num - 1; j++)
            {
                B = 10 * B + (int)(numbers[j] - '0');
            }

            break;
        }
    }

    if(op == 0)
        return (A + B);
    else if(op == 1)
        return (A - B);
    else if(op == 2)
        return (A * B);
    else if(op == 3)
        return (A / B);

    return 0;
}

// show the input characters one by one in different places
void equal(int result)
{
    int i = 0;
    int digit = 0;

    while(result != 0)
    {
        digit = result % 10;
        LCDGoto(15 - i, 1);
        LCDPutChar('0' + digit);
        i += 1;
        result /= 10;
    }
}

// num = 0 and LCDClear
void delete(int *p)
{
    LCDClear();
    *p = -1;
}
