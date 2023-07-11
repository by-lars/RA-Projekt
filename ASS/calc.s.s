# Entry Point
main:
    la a0, input_txt
   
    call calculator
    
    li a7, 1
    ecall
    
    li a7, 10
    ecall        # Exit

# Calculates a simple expression of the forms
#    x+y, x-y, x*y, x/y
#
# @param a0 char[] input
# @return a0 calculated value
calculator:
    addi sp,sp, -16         # Reserve Stack
    sw ra, 0(sp)

    sw a0, 4(sp)            # char in[]
   
    li a1, 0
    call scan_decimal 
    sw a1, 8(sp)            # int first_value = value;
    mv a1, a0               # int len_of_first_numer = scan_decimal(in, 0)
    
    lw a0, 4(sp)            # in
    add a0, a0, a1          # in[len_of_first_number]
    lb t0, 0(a0)            
    sw t0, 12(sp)            # char operation = in[len_of_first_number]
    
    lw a0, 4(sp)
    addi a1,a1, 1           # len_of_first_number+1
    call scan_decimal
    sw a1, 16(sp)           # int second_value = value;

    lw a0, 8(sp)     #num1
    lw a1, 12(sp)    #op
    lw a2, 16(sp)    #num2
    
    li t0, 43               # case '+'
    beq a1, t0, op_add
    
    li t0, 45               # case '-'
    beq a1, t0, op_sub
    
    li t0, 47               # case '/'
    beq a1, t0, op_div
    
    li t0, 42               # case '*'
    beq a1, t0, op_mul

calc_finish:
    lw ra, 0(sp)            # Restore Stack
    addi sp,sp, 16 
    
    ret                     # Return    


op_add:
    add a0, a0, a2
    j calc_finish

op_sub:
    sub a0, a0, a2
    j calc_finish
    
op_div:
    div a0, a0, a2
    j calc_finish
    
op_mul:
    mul a0, a0, a2
    j calc_finish
    
# Parses a number from string at start idx
#
# @param a0 char str[]
# @param a1 int startidx
#
# @return a0 idx-startidx
# @return a1 parsed value
scan_decimal:
    addi sp,sp, -16         # Reserve Stack
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv t0 a1                 # int idx=startidx;
    mv t1 zero               # int is_negative=0;
    
    add s0, a0, t0           # str[idx]
    lb t2, 0(s0)
    li t3, 45
    bne t3, t2, scan1        # if(str[idx]=='-')
    addi t1, t1, 1           # is_negative=1;
    addi t0, t0, 1           # idx+=1;
    
scan1:
    mv t4 zero               # int val = 0;
scan_while:
    add s0, a0, t0           # str[idx]
    lb t2, 0(s0)             # while('0' <= str[idx] && str[id]<='9')
    li t3, 48
    blt t2, t3, scan_fix_sign
    li t3, 57
    bgt t2,t3, scan_fix_sign 
 
    li t3, 10
    mul t4, t4, t3          # val = val * 10
    add t4, t4, t2          # + str[idx]
    li t3, 48
    sub t4, t4, t3          # - '0' 
    
    addi t0, t0, 1          # idx += 1 
    j scan_while
    
scan_fix_sign:
    beq t1, zero, scan_return # if(is_negative)
    sub t4, zero, t4          # val = -val
    
scan_return:
    sub a0, t0, a1          # return idx-startidx
    mv a1 t4
    
    lw ra, 0(sp)            # Restore Registers
    lw s0, 4(sp)
    addi sp, sp, 16         # Restore Stack
    
    ret                     # return;
    
.data
input_txt:
    .string "-35*10"
    
    