.data
frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels
xVel:		.word	0		# x velocity start 0
yVel:		.word	0		# y velocity start 0
xPos:		.word	50		# x position
yPos:		.word	27		# y position
tail:		.word	7624		# location of rail on bit map display

questionMark: .asciiz "?"      # Question mark character
.text
main:
### DRAW BACKGROUND SECTION
	la 	$t0, frameBuffer	# load frame buffer address
	li 	$t1, 8192		# save 512*256 pixels
	li 	$t2, 0x00d3d3d3		# load light gray color
l1:
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 	# advance to next pixel position in display
	addi 	$t1, $t1, -1	# decrement number of pixels
	bnez 	$t1, l1		# repeat while number of pixels is not zero

### DRAW BORDER SECTION
	# top wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 64		# t1 = 64 length of row
	li 	$t2, 0x00000000		# load black color
drawBorderTop:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderTop	# repeat until pixel count == 0
	
	# Bottom wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 7936		# set pixel to be near the bottom left
	addi	$t1, $zero, 64		# t1 = 512 length of row
      
drawBorderBot:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderBot	# repeat until pixel count == 0
	
	# left wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 256		# t1 = 512 length of col

drawBorderLeft:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderLeft	# repeat until pixel count == 0
	
	# Right wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 508		# make starting pixel top right
	addi	$t1, $zero, 255		# t1 = 512 length of col

drawBorderRight:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderRight	# repeat until pixel count == 0

#### DRAW ALL COLUMNS SECTION
	# Column between left border and middle (1/4 of screen width)
	la      $t0, frameBuffer     # load frame buffer address
	addi    $t0, $t0, 64        # move to position (halfway between left and middle)
	addi    $t1, $zero, 256     # t1 = height of column

drawSecondColumn:
	sw      $t2, 0($t0)         # color Pixel black
	addi    $t0, $t0, 256       # go to next pixel down
	addi    $t1, $t1, -1        # decrease pixel count
	bnez    $t1, drawSecondColumn    # repeat until pixel count == 0

	# Middle column (1/2 of screen width)
	la	$t0, frameBuffer	    # load frame buffer address
	addi    $t0, $t0, 128     # move to middle column position
	addi	$t1, $zero, 256	    # t1 = height of column
	
drawThirdColumn:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel down
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawThirdColumn	# repeat until pixel count == 0

	# Column between middle and right border (3/4 of screen width)
	la      $t0, frameBuffer     # load frame buffer address
	addi    $t0, $t0, 320       # move to fourth column position
	addi    $t1, $zero, 256     # t1 = height of column

drawFourthColumn:
	sw      $t2, 0($t0)         # color Pixel black
	addi    $t0, $t0, 256       # go to next pixel down
	addi    $t1, $t1, -1        # decrease pixel count
	bnez    $t1, drawFourthColumn    # repeat until pixel count == 0

	# New column between middle border and right border
	la      $t0, frameBuffer     # load frame buffer address
	addi    $t0, $t0, 384       # move to position (between middle and right)
	addi    $t1, $zero, 256     # t1 = height of column

drawNewColumn:
	sw      $t2, 0($t0)         # color Pixel black
	addi    $t0, $t0, 256       # go to next pixel down
	addi    $t1, $t1, -1        # decrease pixel count
	bnez    $t1, drawNewColumn  # repeat until pixel count == 0

# New column between fourth column and right border
la      $t0, frameBuffer     # load frame buffer address
addi    $t0, $t0, 448       # move to position (between fourth column and right border)
addi    $t1, $zero, 256     # t1 = height of column

drawFifthColumn:
sw      $t2, 0($t0)         # color Pixel black
addi    $t0, $t0, 256       # go to next pixel down
addi    $t1, $t1, -1        # decrease pixel count
bnez    $t1, drawFifthColumn  # repeat until pixel count == 0
# First horizontal row (1/4 from top)
la      $t0, frameBuffer     # load frame buffer address
addi    $t0, $t0, 2048      # move down to 1/4 of screen height
addi    $t1, $zero, 64      # t1 = width of row

# First equally spaced row (at 64 pixels from top)
la      $t0, frameBuffer     # load frame buffer address
addi    $t0, $t0, 2048      # move down 64 pixels (256 * 8)
addi    $t1, $zero, 64      # t1 = width of row

drawFirstRow:
sw      $t2, 0($t0)         # color Pixel black
addi    $t0, $t0, 4         # go to next pixel right
addi    $t1, $t1, -1        # decrease pixel count
bnez    $t1, drawFirstRow   # repeat until pixel count == 0

# Second equally spaced row (at 128 pixels from top)
la      $t0, frameBuffer     # load frame buffer address
addi    $t0, $t0, 4096      # move down 128 pixels (256 * 16)
addi    $t1, $zero, 64      # t1 = width of row

drawSecondRow:
sw      $t2, 0($t0)         # color Pixel black
addi    $t0, $t0, 4         # go to next pixel right
addi    $t1, $t1, -1        # decrease pixel count
bnez    $t1, drawSecondRow  # repeat until pixel count == 0

# Third equally spaced row (at 192 pixels from top)
la      $t0, frameBuffer     # load frame buffer address
addi    $t0, $t0, 6144      # move down 192 pixels (256 * 24)
addi    $t1, $zero, 64      # t1 = width of row

drawThirdRow:
sw      $t2, 0($t0)         # color Pixel black
addi    $t0, $t0, 4         # go to next pixel right
addi    $t1, $t1, -1        # decrease pixel count
bnez    $t1, drawThirdRow   # repeat until pixel count == 0

    # After drawing the grid lines, add this section to place question marks
    la $t0, frameBuffer        # Load frame buffer address
    li $t1, 8                  # Number of columns
    li $t2, 4                  # Number of rows
    li $t3, 0                  # Row counter
    li $t4, 0                  # Column counter
    
