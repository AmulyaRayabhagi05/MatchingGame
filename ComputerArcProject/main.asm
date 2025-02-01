#main.asm

.include "GetRandomCards.asm"
.data
Cards: .word 0:16
Board: .word 0:16
User_Input: .word 0:8 #allocates way more space than nessisary because I dont trust users
start_time: .word 0

Total_Attempted_Flips: .word 0
Num_Cards: .word 16
.text

.globl main
.globl Board
main:
#jal Win_Music
#jal Draw_Win_Screen
#j End_Program
la $a0, Cards 	#load the cards array as an argument
jal Get_Cards	#get the cards and store them in Cards array

la $a0, Board	#setup hidden board
jal Setup_Default


Game_Loop:
addi $sp, $sp, -4    # Make space on the stack
    sw $ra, 0($sp)       # Save $ra to the stack

    lw $a0, Total_Attempted_Flips
    jal Display_Num_Flips
    la $a0, Board        # Draw the hidden board
    jal Draw_Board

    jal Get_User_Input   # Get first card to flip
    move $s0, $v0        # Store input in s0
    la $a0, Board        # Load the arguments and flip the card
    la $a1, Cards        # Load the cards address into $a1
    move $a2, $v0        # Move the user input (card index) into $a2
    jal Flip_Card
    jal Increment_Attempted_Flips

    # Restore $ra before returning from Game_Loop
    lw $ra, 0($sp)       # Restore $ra from stack
    addi $sp, $sp, 4     # Restore stack pointer
    jr $ra  
    
    lw $a0, Total_Attempted_Flips
    jal Display_Num_Flips
    la $a0, Board
    jal Draw_Board

    move $a0, $s0		#load two guesses into arguments
    move $a1, $s1
    la $a2, Board		#load board into argument
    jal Check_Correct_Flips	#check if flips matched

    beqz $v0, Wrong_Guess	#if cards dont match, go to wrong guess

     la $t0, Num_Cards	#otherwise grab num cards constant
     lw $t0, 0($t0)

     beq $t0, $v1, Exit	#if cards flipped == num cards, exit
    jal Correct_Guess_Noise
    j Game_Loop		#otherwise loop again

    jr $ra

Wrong_Guess:
jal Wrong_Guess_Noise
jal Display_Not_A_Match #Display message saying selected cards dont match

jal Pause_Game_Flow	#pauses the game before flipping incorrect cards back over

la $a0, Board		#load both boards and incorrect flip index into arguments
la $a1, Cards	
move $a2, $s0
move $a3, $s1
jal Undo_Flips		#undo the flips

j Game_Loop

jr $ra 

Exit:

la $a0, Board 	#load the cards array as an argument
jal Draw_Board 	#draw all of the cards
jal Draw_Win_Screen
jal Win_Music

#la $a0, Board
#jal Draw_Board

End_Program:
li $v0, 10	#exit the program
syscall


Get_User_Input:
    addi $sp, $sp, -4         # Preserve return address
    sw $ra, 0($sp)

    jal Prompt_User_Input     # Outputs text to prompt input

    li $v0, 8                 # System call for reading a string
    la $a0, User_Input        # Address where input will be stored
    li $a1, 4                 # Length of expected input
    syscall

    # Process User_Input to convert it to an integer index
    la $a0, User_Input        
    jal Convert_Cord          # Convert string input to integer, stores in $v0

    li $t0, -1                # Define -1 as an invalid input marker
    beq $v0, $t0, Get_User_Input  # If invalid, prompt user again

    # $v0 now contains the validated input; no further modifications

    lw $ra, 0($sp)            # Restore return address
    addi $sp, $sp, 4
    jr $ra                    # Return with $v0 holding the card index




#requests a string input, pauses the game until the player
#types any key
Pause_Game_Flow:
la $a0, User_Input	#puts input buffer, we dont care about the data but its still required
li $a1, 1		#expects one input so game will resume as soon as anything is typed
li $v0, 8		#load read string system code
syscall

jr $ra



Increment_Attempted_Flips:
lw $t0, Total_Attempted_Flips
addi $t0, $t0, 1
sw $t0, Total_Attempted_Flips
jr $ra


# Start Timer<--- RTimer
.globl start_timer
start_timer:
    li $v0, 30            # Syscall to get the current time
    syscall
    sw $v0, start_time    # Store the current time as start time
    jr $ra
    

# Calculate Elapsed Time<---- Calucuate time
.globl calculate_elapsed_time
calculate_elapsed_time:
    li $v0, 30            # Syscall to get the current time
    syscall
    lw $t0, start_time    # Load start time
    sub $t1, $v0, $t0     # Calculate elapsed time in seconds

    # Convert to minutes and seconds
    li $t2, 60            # Load 60 into $t2 (as divisor)
    div $t1, $t2          # Divide total seconds ($t1) by 60 to get minutes
    mflo $t1              # $t1 = minutes (quotient)
    mfhi $t2              # $t2 = remaining seconds (remainder)

    # Display the time in "MM:SS" format
    jal display_time      # Call function to output minutes and seconds
    jr $ra
