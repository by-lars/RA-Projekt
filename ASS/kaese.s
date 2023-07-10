li a7,11
la a1, input_txt

call do_the_thing
li a7,10
ecall

do_the_thing:
    lb a0, 0(a1)
    beq a0,zero, the_end
    
    addi t1, a0, -32
    beq t1, zero, output
    
    addi a0, a0, 13 
    addi t1, a0, -122
    
    blez t1, output
    
    addi a0,a0 -26    
    
output:
    ecall
    addi a1,a1,1
    j do_the_thing
  

the_end:
    ret
    
.data
input_txt:
    .string "the quick brown fox jumps over the lazy dog"
    #.string "gur dhvpx oebja sbk whzcf bire gur ynml qbt"