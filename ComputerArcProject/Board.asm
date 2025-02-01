.include "GetRandomCards.asm"
.include "DrawBoard.asm"
.data 
Default1: .ascii " A1 \0    A2 \0    A3 \0    A4 \0   "
Default2: .ascii " B1 \0    B2 \0    B3 \0    B4 \0   "
Default3: .ascii " C1 \0    C2 \0    C3 \0    C4 \0   "
Default4: .ascii " D1 \0    D2 \0    D3 \0    D4 \0   "



Default_Addresses: .word 0:4
Flipped_Tracker: .byte -1:16

Cards_Flipped_Count: .word 0
Unmatched_Count: .word 8

unmatched_msg: .asciiz "Unmatched cards left: "



.text
.globl Setup_Default
Setup_Default:
    # Set up default addresses
    la $t0, Default_Addresses 
    la $t1, Default1
    sw $t1, 0($t0)
    la $t1, Default2
    sw $t1, 4($t0)
    la $t1, Default3
    sw $t1, 8($t0)
    la $t1, Default4
    sw $t1, 12($t0)

    li $t3, 4 	#rowCounter
Default_Row:
    li $t1, 4 	#columnCounter

    lw $t2, 0($t0)		#get the address for the first row of default values
Default_Column:
    sw $t2, 0($a0)		#save the address of default string to board position
    addi $t2, $t2, 8	#increment to next default string
    addi $a0, $a0, 4	#increment to next board position
    addi $t1, $t1, -1	#decrement columnCounter
    bnez $t1, Default_Column #loops until column counter == 0
    addi $t0, $t0, 4	#increments to the address of next row of defaults
    addi $t3, $t3, -1	#decrements rowCounter
    bnez $t3, Default_Row	#loops until rowCounter == 0

    jr $ra
    		
.globl Flip_Card
#a0 has first board
#a1 has second board
#a2 has index
Flip_Card:
    addi $sp, $sp, -12	#push s0 - s2 to the stack
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)

    move $s0, $a0		#put argument with board1 in s0
    move $s1, $a1		#put argument with board2 in s1 (doesnt matter which one is which)
    move $s2, $a2		#put index for flip in s2

    la $t0, Flipped_Tracker	#go to our flipped tracker and negate the corresponding index
    add $t0, $t0, $s2
    lb $t1, 0($t0)
    sub $t1, $zero, $t1
    sb $t1, 0($t0)

    sll $s2, $s2, 2		#multiply index by four so it lines up with words
    add $s0, $s0, $s2	#move over to appropriate index
    add $s1, $s1, $s2
    lw $t0, 0($s0)		#swap the two addresses
    lw $t1, 0($s1)
    sw $t0, 0($s1)
    sw $t1, 0($s0)

    lw $s0, 0($sp)		#restore saved registers and return
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12

    lw $t0, Cards_Flipped_Count	#increment our cards flipped counter
    addi $t0, $t0, 1
    sw $t0, Cards_Flipped_Count

    jr $ra

.globl Check_Correct_Flips
#a0 is board slot number for first card
#a1 is board slot number for second card
#a2 is game board
Check_Correct_Flips:
    addi $sp, $sp, -16    # Save caller-saved registers on the stack
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)

    move $s0, $a0         # Save arguments: $a0 = first index, $a1 = second index, $a2 = board base address
    move $s1, $a1
    move $s2, $a2

    sll $s0, $s0, 2       # Multiply indices by 4 for word addressing
    sll $s1, $s1, 2

    add $t0, $s0, $s2     # Compute address of first card
    lw $a0, 0($t0)        # Load card value
    jal Get_Card_Group     # Call subroutine
    move $s0, $v0         # Save returned group in $s0

    add $t0, $s1, $s2     # Compute address of second card
    lw $a0, 0($t0)        # Load card value
    jal Get_Card_Group     # Call subroutine
    move $s1, $v0         # Save returned group in $s1

    li $v0, 0             # Default: cards do not match (false)
    bne $s0, $s1, Return_Check_Correct_Flips
    addi $v0, $v0, 1      # If groups match, set return value to true

Return_Check_Correct_Flips:
    lw $s0, 0($sp)        # Restore saved registers
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16     # Deallocate stack space

    la $v1, Cards_Flipped_Count   # Load cards flipped count
    lw $v1, 0($v1)

    jr $ra                # Return to caller
.globl Undo_Flips
#a0 is board 1
#a1 is board 2
#a2 is index to flip 1
#a3 is index to flip 2
Undo_Flips:
addi $sp, $sp, -8	#push old save 0 value on to stack as well as return address
sw $s0, 0($sp)	
sw $ra, 4($sp)
move $s0, $a3		#move seocond index into save value

#correct arguments alread in arg registers so
jal Flip_Card		#flip first card

move $a2, $s0		#move the second index into argument, others are still set

jal Flip_Card		#flip second card

#decrement Flipped count by 4 (since we performed 2 extra flips when returning their values)	
lw $t0, Cards_Flipped_Count	#get number stored in count

addi $t0, $t0, -4		#decrement value by 2
sw $t0, Cards_Flipped_Count	#save value

lw $s0, 0($sp)			#restore values from stack and return
lw $ra, 4($sp)
addi $sp, $sp, 8

jr $ra





.globl Convert_Cord
Convert_Cord:
addi $sp, $sp, -12
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $ra, 8($sp)
lb $s0, 0($a0)		#get the first character of input
addi $s0, $s0, -65 	#subtract the ascii value of capital A
slti $t1, $s0, 0	#check if the new value is less than 0
bnez $t1, Invalid_Cord	#if it is, input is invalid, branch away
slti $t1, $s0, 4	#if its less than 5, first character is def valid
bnez $t1, Second_Char_Check#go to check second character if first is valid
addi $s0, $s0, -32	#subtract ascii offset to check for lowercase
slti $t1, $s0, 0	#check if its less than 0
bnez $t1, Invalid_Cord 	#if it is, cord is invalid
slti $t1, $s0, 4	#only valid if less than 5
beqz $t1, Invalid_Cord

Second_Char_Check:
lb $s1, 1($a0)		#get the second character of input
addi $s1, $s1, -49	#subtract the ascii value of number 1
slti $t1, $s1, 0	#check if the new value is less than 0
bnez $t1, Invalid_Cord	#if it is, input is invalid, branch away

slti $t1, $s1, 4
beqz $t1, Invalid_Cord

#Value is valid
add $v0, $s1, $zero 	#add value of the digit - 1
sll $s1, $s0, 2		#multiply the value of the first char by 4
add $v0, $v0, $s1	#add the value of first char

la $t0, Flipped_Tracker	#checks if the card is already flipped
add $t0, $t0, $v0
lb $t0, 0($t0)
slti $t0, $t0, 0
beqz $t0, Already_Flipped#if so, jump to Already_Flipped

j Exit_Convert_Cord
Invalid_Cord:
jal Display_Invalid_Cord_Message #display a message stating the cord was invalid
li $v0, -1			#load -1 into return
j Exit_Convert_Cord

Already_Flipped:
jal Display_Already_Flipped_Message	#display a message stating the cord was invalid
li $v0, -1				#load -1 into return

Exit_Convert_Cord:
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12

jr $ra



.globl Swap_Inside_Board
#a0 board address
#a1 first swap index
#a2 second swap index

Swap_Inside_Board:
    # Calculate the address of the first element
    sll $t0, $a1, 2           # Multiply index a1 by 4 (word size) to get byte offset
    add $t0, $t0, $a0         # Add the base address of the board to get the address of the first element

    # Calculate the address of the second element
    sll $t1, $a2, 2           # Multiply index a2 by 4 (word size) to get byte offset
    add $t1, $t1, $a0         # Add the base address of the board to get the address of the second element

    # Load the values at the first and second indices
    lw $t2, 0($t0)            # Load the value at the first index (a1)
    lw $t3, 0($t1)            # Load the value at the second index (a2)

    # Swap the values
    sw $t3, 0($t0)            # Store the value of the second element at the first index
    sw $t2, 0($t1)            # Store the value of the first element at the second index

    jr $ra      
                
# Update counter after a match<---Added code
update_unmatched_count:
    lw $t0, Unmatched_Count  # Load the current count
    addi $t0, $t0, -1        # Decrement the count
    sw $t0, Unmatched_Count  # Store the updated count

    # Display the unmatched count on the screen
    li $v0, 4                # Load syscall for printing string
    la $a0, unmatched_msg    # Load address of the message "Unmatched cards left: "
    syscall                  # Print message

    li $v0, 1                # Load syscall for printing integer
    move $a0, $t0            # Move updated count to $a0 for printing
    syscall                  # Print integer

    jr $ra                   # Return from function
	
	

# Display Elapsed Time <--- Added code
.globl display_time
display_time:
    # Display minutes (t1)
    move $a0, $t1         # Load minutes into $a0 for display
    li $v0, 1             # Syscall code for print integer
    syscall

    # Display ":" separator
    li $a0, 58            # ASCII code for ":"
    li $v0, 11            # Syscall code for print character
    syscall

    # Display seconds (t2)
    move $a0, $t2         # Load seconds into $a0 for display
    li $v0, 1             # Syscall code for print integer
    syscall

    jr $ra

