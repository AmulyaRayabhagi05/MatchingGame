#this file contains subroutines for any output functions the program needs


.data
Vertical_Line: .ascii "|\0  "
New_Line: .ascii "|\n\0 "
Four_Spaces:.ascii "    \0"
Horizontal_Line: .ascii "\n+----+----+----+----+\n\0"

Prompt_User_Input_Text: .ascii "Please choose a card to flip: \0"
Not_A_Match_Text: .ascii "Not a match! Press any key to continue... \0"
Invalid_Cord_Message: .asciiz "Invalid cord entered \n"
Already_Flipped_Message: .asciiz "Already flipped this card :( \n"
Num_Flips_Message: .asciiz "\nFlips: "

Win_Text_Row_1 : .asciiz "\n _   _   		 \n"
Win_Text_Row_2 : .asciiz "| | | |   ______   _    _                                        __\n"
Win_Text_Row_3 : .asciiz "| |_| |  |  __  | | |  | |                                      |  |\n"
Win_Text_Row_4 : .asciiz "|_   _|  | |  | | | |  | |    __    __    __   _    ___   _	|  |\n"
Win_Text_Row_5 : .asciiz "  | |    | |  | | | |  | |    \\ \\  /  \\  / /  | |  |   \\ | |	|__|\n"
Win_Text_Row_6 : .asciiz "  | |    | |__| | | |__| |     \\ \\/ /\\ \\/ /   | |  | |\\ \\| |     __ \n"
Win_Text_Row_7 : .asciiz "  |_|    |______| |______|      \\__/  \\__/    |_|  |_| \\___|	|__|\n"





.text
.globl Draw_Board

Draw_Board:
addi $sp, $sp, -8
sw $s0, 0($sp) 		#store s0 on the stack
sw $ra, 4($sp)
move $s0, $a0 		#put the card addresses in a save address

li $v0, 4 		#initializes all syscalls to print strings
li $t0, 4 		#Column Counter

la $a0, Horizontal_Line	#first row has to be drawn seperately
syscall 

Draw_Col:
li $t1, 4 		#Row Counter

Draw_Row:
la $a0, Vertical_Line 	#draws the line between the cards
syscall

lw $a0, 0($s0) 		#draws the text on the card
syscall

addi $s0, $s0, 4	#increments card address
addi $t1, $t1, -1	#decrement row counter
bnez $t1, Draw_Row	#if(rowCounter != 0) branch to Draw_Row

la $a0, Vertical_Line	#draw final line
syscall
la $a0, Horizontal_Line	#draw the whole divider row
syscall

addi $t0, $t0, -1	#decrement columnCounter
bnez $t0, Draw_Col	#if(columnCounter != 0) branch to Draw_Col
		
lw $s0, 0($sp)		#replace s0 from the stack
lw $ra, 4($sp)
addi $sp, $sp, 8	#fix stack address
jr $ra			#return


.globl Prompt_User_Input
#prompts the user to enter a coordinate
Prompt_User_Input:

la $a0, Prompt_User_Input_Text	#load text into argument
li $v0, 4			#load print text call code
syscall

jr $ra				#return

.globl Display_Not_A_Match
#outputs text saying the selected pair weren't a match
Display_Not_A_Match:

la $a0, Not_A_Match_Text	#load text into argument
li $v0, 4			#load print text system code into argument
syscall				#print

jr $ra				#return

.globl Display_Invalid_Cord_Message

Display_Invalid_Cord_Message:

la $a0, Invalid_Cord_Message	#load text into argument
li $v0, 4			#load print text system code into argument
syscall				#print

jr $ra				#return

.globl Display_Already_Flipped_Message
Display_Already_Flipped_Message:

la $a0, Already_Flipped_Message	#load text into argument
li $v0, 4			#load print text system code into argument
syscall				#print

jr $ra				#return

.globl Display_Num_Flips
#a0 contains number of flips


Display_Num_Flips:
move $t0, $a0	#move number of flips so we can use argument register

la $a0, Num_Flips_Message	#output message "Flips: "
li $v0, 4
syscall 



move $a0, $t0			#put the number of flips back in a0
li $v0, 1			#load print integer system code
syscall


jr $ra

.globl Draw_Win_Screen

Draw_Win_Screen:
la $a0, Win_Text_Row_1
li $v0, 4
syscall
la $a0, Win_Text_Row_2
li $v0, 4
syscall
la $a0, Win_Text_Row_3
li $v0, 4
syscall
la $a0, Win_Text_Row_4
li $v0, 4
syscall
la $a0, Win_Text_Row_5
li $v0, 4
syscall
la $a0, Win_Text_Row_6
li $v0, 4
syscall
la $a0, Win_Text_Row_7
li $v0, 4
syscall

jr $ra



