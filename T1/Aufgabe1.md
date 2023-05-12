# Aufgabe 1 

1. 
> addi  x6, x0, 7
> ori   x2, x0, 5
> add   x31, x6, x2

Binär Muster:
> 000000000111 00000 000 00110 0010011
> 000000000101 00000 110 00010 0010011
> 0000000 00010 00110 000 11111 0110011

2. 
> x6 = 00111
> x2 = 00101
> x31 => 00111+ 00101 = 01100

3. 
PC Register speichert den aktuellen Speicherort im Programm
=> 0x1000 -> 0x1001 -> 0x1010

Nächste Instruktion + Operanten werden aus dem Speicher geholt ( FETCH )
Nach der Dekodierung, Ausführung der Befehle mit Operanten ( EXECUTE )

4. 
> addi  x2, x0, 7
> ori   x6, x0, 5
> add   x31, x6, x2
> jal   x0, 0x1000     
    > 11111111010111111111 00000 1100111

Signed Offset wird auf den PC addiert und Return Adresse in x0-Register geschrieben ( voided )