la t0,input
lb t1,0(t0)
lb t2,1(t0)
lb t3,2(t0)

addi t1,t1,-48
addi t2,t2,-43
addi t3,t3,-48

beq t2,zero,calc_add
j calc_sub


calc_add:
    add t1,t3,t1
    j out

calc_sub:
    sub t1,t1,t3
    j out

out:
    li a7,1
    add a0,t1,zero
    ecall
    li a7, 10
    ecall

input:
    .string "1-2"