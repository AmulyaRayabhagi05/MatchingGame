.data
Cards: .word 0:16
Board: .word 0:16
User_Input: .word 0:8 #allocates  more space than nessisary 

Total_Attempted_Flips: .word 0
Num_Cards: .word 16
Won_Time: .asciiz "You finished in "

promptMsg:  .asciiz "\nEnter 'quit' to exit or press any key to continue: "
buffer:     .space 10
quitStr:    .asciiz "quit"
msg_timer: .asciiz " Elapsed Time: "

.text
.globl main
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize game
    la $a0, Cards
    jal Get_Cards
    la $a0, Board
    jal Setup_Default
    
 



 


Game_Loop:
 

lw $a0, Total_Attempted_Flips

jal Display_Num_Flips
# Display timer message
la $a0, msg_timer   # Load timer message
li $v0, 4           # Syscall to print string
syscall   
jal Timer
#jal update_unmatched_count
la $a0, Board	#draw the hidden board
jal Draw_Board

    li $v0, 4
    la $a0, promptMsg
    syscall
    
    li $v0, 8
    la $a0, buffer
    li $a1, 10
    syscall
    
    la $a0, buffer
    la $a1, quitStr
    jal check_quit
    beq $v0, 1, End_Program    # Use existing Exit label
    	
jal Get_User_Input	#get first card to flip
move $s0, $v0		#store input in s0
la $a0, Board		#load the arguements and flip the card
la $a1, Cards
move $a2, $v0
jal Flip_Card

jal Increment_Attempted_Flips

lw $a0, Total_Attempted_Flips
jal Display_Num_Flips
la $a0, Board 		#load the cards array as an argument
jal Draw_Board 		#draw all of the cards

jal Get_User_Input	#get the second card to flip
move $s1, $v0		#store second input in s1
la $a0, Board		#load the arguments and flip the card
la $a1, Cards
move $a2, $v0		
jal Flip_Card	

jal Increment_Attempted_Flips


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

Exit:

la $a0, Board 	#load the cards array as an argument
jal Draw_Board 	#draw all of the cards
jal Draw_Win_Screen

la $a0, Won_Time  # You won
li $v0, 4           # Syscall to print string
syscall             # Print message

jal Timer
jal Win_Music

#la $a0, Board
#jal Draw_Board

End_Program:

li $v0, 10	#exit the program

syscall


Get_User_Input:
addi $sp, $sp, -4	#preserve return address on stack
sw $ra, 0($sp)

jal Prompt_User_Input 	#outputs text prompting input

li $v0, 8		#load system code for reading string
la $a0, User_Input	#pass address where input will be stored
li $a1, 4		#pass length of expected input
syscall

la $a0, User_Input 	#convert string input into the related integer
jal Convert_Cord

li $t0, -1 		#constant used to describe invalid input
beq $v0, $t0, Get_User_Input#if input is invalid, get a new one
lw $ra, 0($sp)		#grab return address
addi $sp, $sp, 4
jr $ra 			#otherwise return





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


check_quit:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    move $s1, $a1
    li $v0, 0
compare_loop:
    lb $t0, ($s0)
    lb $t1, ($s1)
    
    beqz $t1, check_end
    beqz $t0, restore
    
    blt $t0, 'A', skip_convert
    bgt $t0, 'Z', skip_convert
    addi $t0, $t0, 32
 skip_convert:
    bne $t0, $t1, restore
    
    addi $s0, $s0, 1
    addi $s1, $s1, 1
    j compare_loop
check_end:
    lb $t0, ($s0)
    beq $t0, 10, match
    beq $t0, 0, match
    j restore
match:
    li $v0, 1
    
restore:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
