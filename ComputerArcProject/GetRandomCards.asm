
.data
NumSets: .word 4
Set1: .ascii " 20 \0   5x4 \0   10x2\0    20 \0   "
Set2: .ascii " 15 \0   5x3 \0   3x5 \0    15 \0   "
Set3: .ascii " 12 \0   4x3 \0   6x2 \0    12 \0   " 
Set4: .ascii " 36 \0   6x6 \0   12x3\0    36 \0   "

Num_Randomization_Swaps: .word 100
SetAddresses: .word 0:4

.text

#Get which set it belongs to in relation to the order of
#set addresses array
#a0 is card address

.globl Get_Card_Group
Get_Card_Group:
    li $t0, 3             # Enable looping through each set except the last
    la $t1, SetAddresses  # Load the base address of the sets

Loop_Groups:
    lw $t2, 4($t1)        # Get the current set's base address
    slt $t2, $a0, $t2     # Check if card < base address (belongs to previous set)
    bnez $t2, Return_Set  # If found, branch to the return section
    addi $t0, $t0, -1     # Decrement loop counter
    addi $t1, $t1, 4      # Move to the next set address
    bnez $t0, Loop_Groups # Repeat the loop if there are more sets to check

Return_Set:	
    sub $v0, $zero, $t0   # Calculate negative loop counter value
    addi $v0, $v0, 3      # Adjust to get the set number
    jr $ra                # Return to the caller





.globl Get_Cards
#a0 is card board
Get_Cards:
addi $sp, $sp, -8	#store card board address and return address on stack
sw $a0, 0($sp)
sw $ra, 4($sp)
la $t0, SetAddresses	#put all of the sets into an array
la $t1, Set1 
sw $t1, 0($t0)
la $t1, Set2 
sw $t1, 4($t0)
la $t1, Set3
sw $t1, 8($t0)
la $t1, Set4 
sw $t1, 12($t0)

li $t3, 4	#row counter
Store_Sets:
li $t1, 4	#column counter

lw $t2, 0($t0)	#references the set were pulling elements from
Get_Addresses_1:
sw $t2, 0($a0)		#save the element address to our card board
addi $t2, $t2, 8	#increment set address by required offset
addi $a0, $a0, 4	#increment card board address by required offset
addi $t1, $t1, -1	#decrement column counter
bnez $t1, Get_Addresses_1#if the column counter isnt == 0, keep looping
addi $t0, $t0, 4	#otherwise increment to the next set we want to pull from
addi $t3, $t3, -1	#decrement row counter
bnez $t3, Store_Sets	#check if we have incremented all rows, if not, keep looping

lw $a0, 0($sp)		#get original address back
jal Randomize_Order	#randomize card order

lw $ra, 4($sp)		#get return address and fix stack
addi $sp, $sp, 8

jr $ra			#return



Randomize_Order:
    addi $sp, $sp, -12    # store return value and save registers on stack
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)

    lw $s0, Num_Randomization_Swaps  # get the number of swaps we will do
    move $s1, $a0             # get the address of our card board

Loop_Randomize:
    li $v0, 42               # system call to get random int
    li $a0, 0                # min value of random int is 0
    li $a1, 15               # max value of random int is 15
    syscall

    move $a2, $a0            # store the random number in $a2 (second swap index)
    li $a1, 0                # first swap index is always 0th element

    # Perform the swap using the Swap_Inside_Board function
    move $a0, $s1            # Address of the board
    move $a1, $t2            # First index to swap
    move $a2, $t3            # Second index to swap
    jal Swap_Inside_Board

    addi $s0, $s0, -1        # decrement number of swaps remaining
    bnez $s0, Loop_Randomize  # repeat if more swaps are needed

    # restore values from the stack
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12        # restore stack

    jr $ra            
