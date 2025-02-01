.data
Unmatched_Count: .word 18
unmatched_msg: .asciiz "Unmatched cards left: "
.text

.globl update_unmatched_count
update_unmatched_count:
    lw $t0, Unmatched_Count  # Load the current count
    jal Check_Correct_Flips
    bnez $v0, Update_Count
    
    # Display the unmatched count on the screen
    li $v0, 4                # Load syscall for printing string
    la $a0, unmatched_msg    # Load address of the message "Unmatched cards left: "
    syscall                  # Print message

    li $v0, 1                # Load syscall for printing integer
    move $a0, $t0            # Move updated count to $a0 for printing
    syscall                  # Print integer

    jr $ra                   # Return from function
Update_Count:
    addi $t0, $t0, -2        # Decrement the count
    sw $t0, Unmatched_Count  # Store the updated count
    jr $ra