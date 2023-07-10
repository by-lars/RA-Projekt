# Call fib subroutine
addi a0,a0,20
call fib

# Print a0 return value to cosole
li a7,1
ecall

# End Program
li a7,10
ecall

# Argument n is in a0
# a0 is also return value
fib:
    addi t0 ,a0, -1
    blez t0, rip_bozo
    
    #Save a0 and return addr
    addi sp,sp,-16
    sw a0, 0(sp)
    sw ra, 4(sp)
    
    # fib(n-1)
    addi a0,a0,-1
    call fib
 
    lw t0, 0(sp) # Load original n
    sw a0, 0(sp) # Save fib(n-1)

    # fib(n-2) 
    addi a0, t0, -2
    call fib
    
    # Load fib(n-1)
    lw t0, 0(sp)
    
    # fib(n-1) + fib(n-2)
    add a0, a0, t0 
    
    # Restore rd
    lw ra, 4(sp)
    
    # Cleanup Stack
    addi sp,sp,16
    
rip_bozo:
    ret