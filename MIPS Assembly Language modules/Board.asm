.data 
Default1: .ascii " A1 \0    A2 \0    A3 \0    A4 \0   "
Default2: .ascii " B1 \0    B2 \0    B3 \0    B4 \0   "
Default3: .ascii " C1 \0    C2 \0    C3 \0    C4 \0   "
Default4: .ascii " D1 \0    D2 \0    D3 \0    D4 \0   "



Default_Addresses: .word 0:4
Flipped_Tracker: .byte -1:16

Cards_Flipped_Count: .word 0
.text
.globl Setup_Default
Setup_Default:
#put all of the addresses for our default state in an array
#that can be looped over
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
bnez $t1, Default_Column#loops until column counter == 0
addi $t0, $t0, 4	#increments to the address of next row of defaults
addi $t3, $t3, -1	#decrements rowCounter
bnez $t3, Default_Row	#loops until rowCounter == 0

jr $ra			#return


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
lw $t0, 0($s0)		#swap the two addressses
lw $t1, 0($s1)
sw $t0, 0($s1)
sw $t1, 0($s0)

lw $s0, 0($sp)		#restore save registers and returns
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
addi $sp, $sp, -16	#push store values 0-2 onto the stack 
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $ra, 12($sp)		#push return address to the stack
move $s0, $a0		#store arguments in store values 0-2
move $s1, $a1
move $s2, $a2

sll $s0, $s0, 2		#multiply first index by 4 for word indexing
sll $s1, $s1, 2		#multiply second index by 4 for word indexing

add $t0, $s0, $s2 	#add first index to board address
lw $a0, 0($t0)		#load string address at the value into argument
jal Get_Card_Group	#call subroutine to find group card belongs to
move $s0, $v0		#put its group into s0

add $t0, $s1, $s2	#add second index to board address
lw $a0, 0($t0)		#load string address at second index into argument
jal Get_Card_Group	#call subroutine to find group second card belongs to
move $s1, $v0		#store its group in s1

li $v0, 0		#put false into return register
bne $s0, $s1, Return_Check_Correct_Flips
addi $v0, $v0, 1	#if they are equal, make return value true

Return_Check_Correct_Flips:
lw $s0, 0($sp)		#restore values from stack
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $ra, 12($sp)
addi $sp, $sp, 16

la $v1, Cards_Flipped_Count	#put the total number of cards flipped into second return value
lw $v1, 0($v1)

jr $ra			#return

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
jal Display_Invalid_Cord_Message#display a message stating the cord was invalid
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

sll $a1, $a1, 2		#mult both indexs by 4 
sll $a2, $a2, 2

add $t1, $a0, $a1	#get addresses for the swap
add $t2, $a0, $a2

lw $t3, 0($t1)		#load the values we want to swap into temps
lw $t4, 0($t2)

sw $t3, 0($t2)		#store those temps back in to their swapped posisions
sw $t4, 0($t1)

jr $ra








