    addi  sp,sp,-16   # register sichern
    sw    ra,0(sp)
    sw    s0,4(sp)
    sw    s1,8(sp)

    la    s0,hw_txt   # zeiger auf erstes Zeichen des Strings
loop:
    lb    a0,0(s0)
    beq   a0,zero,end_loop
    li    a7,11       # Zeichen ausgeben
    ecall
    addi  s0,s0,1     # Zeiger auf nächstes Zeichen des Strings
    j     loop
end_loop:

    lw    ra,0(sp)    # register restaurieren
    lw    s0,4(sp)
    lw    s1,8(sp)
    addi  sp,sp,16

    li    a7,10       # programm beenden
    ecall

    .data
hw_txt:
    .string "Hello,World\n"
