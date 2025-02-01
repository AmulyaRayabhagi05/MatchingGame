
.data
Wrong_Guess_Notes: .byte 70, 46#, 120, 120, 120, 60, 60, 60, 60, 60
Correct_Guess_Notes: .byte 60, 72
Duration: .word 150
Carry_Over_Duration: .word 175
Instrument: .byte 96
Volume: .byte 100

Win_Music_Notes: .byte 62, 66, 70, 62, 66, 70, 64, 68, 72, 65, 69, 73
Win_Rest_MS: .word 25, 25, 15, 25, 25, 150, 25, 25, 15, 25, 25, 150,
Win_Music_Length: .word 12
Win_Instrument: .byte 96
Win_Duration: .word 0
Win_Carry_Over_Duration: .word 125
Zero: .byte 0


.text
  
.globl Wrong_Guess_Noise
#serve as a test to understand noise output
Wrong_Guess_Noise:
la $t0, Wrong_Guess_Notes

li $v0, 31
lb $a0, 0($t0)
lw $a1, Carry_Over_Duration 
lb $a2, Instrument
lb $a3, Volume
syscall

li $v0, 32
lw $a0, Duration
syscall

li $v0, 31
lb $a0, 1($t0)
lw $a1, Carry_Over_Duration 
lb $a2, Instrument
lb $a3, Volume
syscall

jr $ra

.globl Correct_Guess_Noise

Correct_Guess_Noise:
la $t0, Correct_Guess_Notes

li $v0, 31
lb $a0, 0($t0)
lw $a1, Carry_Over_Duration 
lb $a2, Instrument
lb $a3, Volume
syscall

li $v0, 32
lw $a0, Duration
syscall

li $v0, 31
lb $a0, 1($t0)
lw $a1, Carry_Over_Duration 
lb $a2, Instrument
lb $a3, Volume
syscall

jr $ra


.globl Win_Music

Win_Music:
addi $sp, $sp, -12
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

la $s0, Win_Music_Notes
lw $s1, Win_Music_Length
la $s2, Win_Rest_MS


Music_Loop:
li $v0, 33
lb $a0, 0($s0)
#lw $t0, 0($s2)
#lw $t1, Win_Carry_Over_Duration
#mul $t1, $t1, $t0
lw $a1, Win_Carry_Over_Duration
lb $a2, Win_Instrument
lb $a3, Volume
syscall

li $v0, 32
lw $t0, Win_Duration
lw $a0, 0($s2)
add $a0, $a0, $t0
syscall

addi $s0, $s0, 1
addi $s1, $s1, -1
addi $s2, $s2, 4
bnez $s1, Music_Loop

lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp, $sp, 12

jr $ra


