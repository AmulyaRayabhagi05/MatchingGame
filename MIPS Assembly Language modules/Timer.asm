.data
initial_time: .word 0
minMsg: .asciiz " Min: "
secMsg: .asciiz " Sec: "
newline: .asciiz "\n"


.text
.globl Timer
Timer:
    # Get current time
    li $v0, 30          # Syscall to get system time
    syscall             # Returns milliseconds in $a0

    # Load and save initial time on first call
    lw $t1, initial_time
    beqz $t1, SetInitialTime

    # Subtract initial time and convert to minutes/seconds
    sub $t0, $a0, $t1   # Subtract initial time from current time
    li $t2, 1000        # Conversion factor for milliseconds to seconds
    div $t0, $t2        # Divide by 1000
    mflo $t0            # Get seconds in $t0

    # Convert seconds to minutes and seconds
    li $t2, 60          # Divisor for minutes conversion
    div $t0, $t2        # Divide total seconds by 60
    mflo $t3            # Minutes in $t3
    mfhi $t4            # Remaining seconds in $t4

    # Print minutes
    li $v0, 1           # Print integer syscall
    move $a0, $t3       # Load minutes
    syscall

    # Print " Min: "
    li $v0, 4           # Print string syscall
    la $a0, minMsg      
    syscall

    # Print seconds
    li $v0, 1           # Print integer syscall
    move $a0, $t4       # Load seconds
    syscall

    # Print " Sec: "
    li $v0, 4           # Print string syscall
    la $a0, secMsg      
    syscall

    jr $ra              # Return

SetInitialTime:
    # Save initial time
    sw $a0, initial_time
    # Display 0:0 for initial time
    li $v0, 1
    li $a0, 0
    syscall

    li $v0, 4               
    la $a0, minMsg
    syscall
    
    li $v0, 1
    li $a0, 0
    syscall


    li $v0, 4               
    la $a0, secMsg
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    jr $ra