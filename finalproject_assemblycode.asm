# This program will execute the "Simon Says" game, along with displaying 
# outputs on the VGA
#
# written by M. Tran and A. Callman

	.data
Array:	.space 40			#space for the first Array

Array2:	.space 40			#space for the second Array
	
	.text

.eqv BG_COLOR, 0x00	 		# black (0/7 red, 0/7 green, 0/3 blue)
.eqv VG_ADDR, 0x11100000
.eqv VG_COLOR, 0x11140000

main:
    	li sp, 0x10000     		#initialize stack pointer
	li s2, VG_ADDR     		#load MMIO addresses 
	li s3, VG_COLOR    

	# fill screen using default color
	call draw_background 
	call startScreen
	
begin:	
	la	t0, Array		# set t0 to location of the start of the Array
	addi	s5, t0, 40		# set the limit of the array to 40
read:	beq	s5, t0, set		
	lw	t2, 0x11008000		# load random numbers to address until it is 
					# filled up with 10 random numbers
	sw	t2, 0(t0)
	addi	t0, t0, 4
	j read


# Since the values in Array are 4 bit values, we want them to translate into 
# sixteen bit values, where it 0001 would translate to 0000000000000001, 0011 translates
# to 0000000000000100, and so on
set:	la	t0, Array		# here we want to translate the values from the start of Array
	la	t1, Array2
	li	s5, 0
	addi	s5, t0, 40
	
transfer:
	beq	s5, t0, set2		# branches if we reached the end of Array
	li	t4, 15
	lw	t5, 0(t0)		# load the value from Array
	bltu 	t5, t4, fourt		# branches if the value from Array is less than 15
	li	t5, 0x8000		# 1000000000000000
ledTranslate:
	sw	t5, 0(t1)		# after it translates, it stores the 16 bit value into Array2
	addi	t0, t0, 4		# goes to next index
	addi	t1, t1, 4
	j transfer
	
set2:
	addi	t2, x0, 0		#count for 10
	addi	s6, x0, 10		#limit of array
	addi	t0, t0, -40		#go to beginning of array	
	li	a4, 0
	li	t1, 0
	add	t2, t1, x0
	
beginLED:
	la	t0, Array2
	li	t1, 0
	lw	t5, 0(t0)		# loads LED value from Array2
back:	sw	t5, 0x11080000, a6	# turns LED on
	j delay				# delays led so it shows visibly
	
endDelay:
	sw	x0, 0x11080000, a6	# turns LED off
	bne	t2, t1, incre1		# goes to incre1 if there is more than one in the sequence
	j checkSwitches			# jumps to check the switches
	
incre1:
	addi	t0, t0, 4
	lw	t5, 0(t0)
	addi	t1, t1, 1
	j back	
	
# Here it checks the sequence of switches that the user inputs.

checkSwitches:
	la	t0, Array2		# resets the location of Array2
	li	t1, 0
	lw	t5, 0(t0)		# gets the LED value
again:	lw	t6, 0x11000000		# only reads the switches if a switch is high
	beqz	t6, again		# if no switch is read, then it loops again
	j delaySwitch			# jumps to delay the switches so that it will continue 
					# once the switch is back to 0
					
# Here it checks the value of the LED to the value of the switch
endDelaySwitch:
	bne	t5, s11, over		# goes to the game over screen if they are not equal
	bne	t2, t1, incre2		# it it is correct, then checks to see if it reaches
					# the end of the sequence of switches, if not then goes 
					# to incre2
	addi	t2, t2, 1		# adds 1 to t2 so that it will go to the next value in Array2
	beq	t2, s6, win		# if it reaches the end of Array2, then go to the youWin screen
	j beginLED			# if not, then goes back to the sequence of LEDs
	
incre2:
	addi	t0, t0, 4
	lw	t5, 0(t0)
	addi	t1, t1, 1
	j again


# Here it calls the win screen 
win:	call draw_background 		# makes the background black
	call youWin			# writes you win! on the screen
	j reset
	
	
over:	##update score and display game over
	call draw_background 
	call gameOver			#go to game over screen
over2:	lw	t3, 0x11000020		#if button is pressed start over
	beqz	t3, over2
	j reset
	

	#resets the game
reset:	la	t0, Array
	addi	s5, t0, 40
	j begin

done: j done


#delays-----------------------------------------------------------------------------------------------------


delaySwitch:				#this delay waits to read the switch until the switch is off
	li	s11, 0
	add	s11, t6, x0
notOff1:
	lw	t6, 0x11000000		#loops until the switch is off
	bnez 	t6, notOff1
	j endDelaySwitch


delay:					#this delay gives time for the led to show and then to turn off
	li 	a4, 10000000
loop3:	beqz  	a4, dd		
	addi 	a4, a4, -1	
	j loop3				
dd:	j endDelay


#LEDs---------------------------------------------------------------------------------------------------
#this section helps decode the unput of the first array to translate it into readable LEDs in Array2	
fourt:	li	t4, 14
	bltu	t5, t4, threet
	li	t5, 0x4000		#0100000000000000
	j ledTranslate
threet:	li	t4, 13
	bltu	t5, t4, twelv
	li	t5, 0x2000		#0010000000000000
	j ledTranslate	
twelv:	li	t4, 12
	bltu	t5, t4, ele
	li	t5, 0x1000		#0001000000000000
	j ledTranslate	
ele:	li	t4, 11
	bltu	t5, t4, ten
	li	t5, 0x800		#0000100000000000
	j ledTranslate
ten:	li	t4, 10
	bltu	t5, t4, nin
	li	t5, 0x400		#0000010000000000
	j ledTranslate
nin:	li	t4, 9
	bltu	t5, t4, eight
	li	t5, 0x200		#0000001000000000
	j ledTranslate
eight:	li	t4, 8
	bltu	t5, t4, sev
	li	t5, 0x100		#0000000100000000
	j ledTranslate
sev:	li	t4, 7
	bltu	t5, t4, six
	li	t5, 0x80		#0000000010000000
	j ledTranslate
six:	li	t4, 6
	bltu	t5, t4, five
	li	t5, 0x40		#0000000001000000
	j ledTranslate
five:	li	t4, 5
	bltu	t5, t4, four
	li	t5, 0x20		#0000000000100000
	j ledTranslate
four:	li	t4, 4
	bltu	t5, t4, three
	li	t5, 0x10		#0000000000010000
	j ledTranslate
three:	li	t4, 3
	bltu	t5, t4, two
	li	t5, 0x8			#0000000000001000
	j ledTranslate
two:	li	t4, 2
	bltu	t5, t4, one
	li	t5, 0x4			#0000000000000100
	j ledTranslate
one:	li	t4, 1
	bltu	t5, t4, zer
	li	t5, 0x2			#0000000000000010
	j ledTranslate	
zer:	
	li	t5, 0x1			#0000000000000001
	j ledTranslate





# Press Button To Start Screen-----------------------------------------------------------------

startScreen:
	li a3, 0xFF		# color white (7/7 red, 7/7 green, 3/3 blue)
	#P
	li a0, 8		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 11		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 22		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 9		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 9		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#R
	li a0, 13		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 16		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 22		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 16		# X coordinate
	li a1, 24		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 14		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 14		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 18		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 19		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 20		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 19		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 19		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 19		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 20		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#S
	li a0, 22		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 22		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 22		# X coordinate
	li a1, 25		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 25		# X coordinate
	li a1, 21		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 25		# X coordinate
	li a1, 24		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 23		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#S
	li a0, 27		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 22		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 27		# X coordinate
	li a1, 25		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 30		# X coordinate
	li a1, 21		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 30		# X coordinate
	li a1, 25		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 28		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 29		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 28		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 29		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 28		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 29		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3


	#B
	li a0, 35		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 38		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 22		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 38		# X coordinate
	li a1, 24		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 36		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 37		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 36		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 37		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 36		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 37		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#U
	li a0, 40		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 43		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 41		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 42		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#TT
	li a0, 46		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 45		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 47		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 50		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 49		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 51		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	
	#O
	li a0, 53		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 56		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 54		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 55		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 54		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 55		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#N
	li a0, 58		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 61		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 59		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 60		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#To
	#T
	li a0, 67		# X coordinate
	li a1, 20		# starting Y coordinate
	li a2, 26		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 66		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 68		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#O
	li a0, 70		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 73		# X coordinate
	li a1, 21		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 71		# start X coordinate
	li a1, 20		# Y coordinate
	li a2, 72		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 71		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 72		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	
	#S
	li a0, 22		# X coordinate
	li a1, 31		# starting Y coordinate
	li a2, 33		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 22		# X coordinate
	li a1, 37		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 26		# X coordinate
	li a1, 31		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 26		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 37		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 23		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 25		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 34		# Y coordinate
	li a2, 25		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 38		# Y coordinate
	li a2, 25		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#T
	li a0, 32		# X coordinate
	li a1, 30		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 34		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#A
	li a0, 38		# X coordinate
	li a1, 31		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 42		# X coordinate
	li a1, 31		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 39		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 41		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 39		# start X coordinate
	li a1, 34		# Y coordinate
	li a2, 41		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#R
	li a0, 46		# X coordinate
	li a1, 30		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 50		# X coordinate
	li a1, 31		# starting Y coordinate
	li a2, 33		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 50		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 47		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 49		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 47		# start X coordinate
	li a1, 34		# Y coordinate
	li a2, 49		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#T
	li a0, 56		# X coordinate
	li a1, 30		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 54		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 58		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	j begin
	
# You Win! Screen -------------------------------------------------------------
youWin:
	li a3, 0xFF		# color white (7/7 red, 7/7 green, 3/3 blue)
	li a0, 30		# X coordinate
	li a1, 22		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 34		# X coordinate
	li a1, 22		# starting Y coordinate
	li a2, 25		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 32		# X coordinate
	li a1, 26		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#O
	li a0, 37		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 41		# start X coordinate
	li a1, 23		# Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify: a3, s2, s3
	li a0, 38		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 38		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#U
	li a0, 44		# X coordinate
	li a1, 22		# starting Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 48		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify: a3, s2, s3
	li a0, 45		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 47		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#Win
	#W
	li a0, 29		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# X coordinate
	li a1, 39		# starting Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# X coordinate
	li a1, 43		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 32		# X coordinate
	li a1, 43		# Y coordinate
	call draw_dot  # must not modify s2, s3
	
	#I
	li a0, 38		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 36		# start X coordinate
	li a1, 35		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 36		# start X coordinate
	li a1, 43		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#N
	li a0, 43		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 44		# X coordinate
	li a1, 36		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 45		# X coordinate
	li a1, 38		# starting Y coordinate
	li a2, 40		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 46		# X coordinate
	li a1, 40		# starting Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 47		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	
	li a0, 50		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 41		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 50		# X coordinate
	li a1, 43		# Y coordinate
	call draw_dot  # must not modify s2, s3
	
	ret
	

# Scores --------------------------------------------------------------------
zeroScore:
	#zero
	li a0, 30		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
	#one
oneScore:
	li a0, 32		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	ret
	
twoScore:
	#two
	li a0, 30		# X coordinate
	li a1, 55		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 52		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 31		# X coordinate
	li a1, 54		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 32		# X coordinate
	li a1, 53		# Y coordinate
	call draw_dot  # must not modify s2, s3
	ret
	
threeScore:
	#three
	li a0, 30		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 30		# X coordinate
	li a1, 55		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 32		# X coordinate
	li a1, 53		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 52		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 54		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
fourScore:
	#four
	li a0, 30		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 53		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
fiveScore:	
	#five
	li a0, 30		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 53		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 54		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
sixScore:
	#six
	li a0, 30		# X coordinate
	li a1, 52		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 53		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 32		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	ret
	
sevenScore:
	#seven
	li a0, 33		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
eightScore:
	#eight
	li a0, 30		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret

nineScore:	
	#nine
	li a0, 30		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 53		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	ret
	
# Game Over Screen ------------------------------------------------------------------------------

gameOver:	
	#GAME OVER ------------------------
	#G
	li a3, 0xFF		# color white (7/7 red, 7/7 green, 3/3 blue)
	li a0, 30		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 34		# X coordinate
	li a1, 27		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 34		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 34		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 33		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 34		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#A
	li a0, 37		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 41		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 38		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 38		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 40		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	
	#M
	li a0, 44		# X coordinate
	li a1, 22		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 47		# X coordinate
	li a1, 22		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 50		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 30		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 44		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 49		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 53		# X coordinate
	li a1, 23		# starting Y coordinate
	li a2, 29		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 54		# start X coordinate
	li a1, 22		# Y coordinate
	li a2, 57		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 54		# start X coordinate
	li a1, 26		# Y coordinate
	li a2, 55		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 54		# start X coordinate
	li a1, 30		# Y coordinate
	li a2, 57		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#O
	li a0, 30		# X coordinate
	li a1, 36		# starting Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 34		# start X coordinate
	li a1, 36		# Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 35		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 43		# Y coordinate
	li a2, 33		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#V
	li a0, 38		# X coordinate
	li a1, 35		# starting Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 42		# start X coordinate
	li a1, 35		# Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify: a3, s2, s3
	li a0, 38		# start X coordinate
	li a1, 43		# Y coordinate
	li a2, 41		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 46		# X coordinate
	li a1, 36		# starting Y coordinate
	li a2, 42		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 47		# start X coordinate
	li a1, 35		# Y coordinate
	li a2, 50		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 47		# start X coordinate
	li a1, 43		# Y coordinate
	li a2, 50		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 47		# start X coordinate
	li a1, 39		# Y coordinate
	li a2, 48		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#R
	li a0, 53		# X coordinate
	li a1, 36		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 57		# X coordinate
	li a1, 36		# starting Y coordinate
	li a2, 38		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 57		# X coordinate
	li a1, 40		# starting Y coordinate
	li a2, 43		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 53		# start X coordinate
	li a1, 35		# Y coordinate
	li a2, 56		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 54		# start X coordinate
	li a1, 39		# Y coordinate
	li a2, 56		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	
	#Score ----------------------------------
	#S
	li a0, 3		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 52		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 3		# X coordinate
	li a1, 55		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 6		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 6		# X coordinate
	li a1, 54		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 4		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 4		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 4		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#C
	li a0, 8		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 9		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 9		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 11		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 11		# X coordinate
	li a1, 55		# Y coordinate
	call draw_dot  # must not modify s2, s3
	
	#O
	li a0, 13		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 16		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 14		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 14		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#R
	li a0, 18		# X coordinate
	li a1, 50		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 21		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 52		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 21		# X coordinate
	li a1, 54		# starting Y coordinate
	li a2, 56		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 19		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 20		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 19		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 20		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	
	#E
	li a0, 23		# X coordinate
	li a1, 51		# starting Y coordinate
	li a2, 55		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 24		# start X coordinate
	li a1, 50		# Y coordinate
	li a2, 25		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 24		# start X coordinate
	li a1, 53		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 24		# start X coordinate
	li a1, 56		# Y coordinate
	li a2, 25		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	li a0, 28		# X coordinate
	li a1, 51		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 28		# X coordinate
	li a1, 55		# Y coordinate
	call draw_dot  # must not modify s2, s3

	#Press Button --------------------------------------------------------------
	#P
	li a0, 3		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 6		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 5		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 4		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 4		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#R
	li a0, 8		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 11		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 5		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 11		# X coordinate
	li a1, 7		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 9		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 9		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 10		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 13		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 14		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 14		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 14		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 14		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 15		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3

	#S
	li a0, 17		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 5		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 17		# X coordinate
	li a1, 8		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 20		# X coordinate
	li a1, 4		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 20		# X coordinate
	li a1, 7		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 18		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 19		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 18		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 19		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 18		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 19		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#S
	li a0, 22		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 5		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 22		# X coordinate
	li a1, 8		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 25		# X coordinate
	li a1, 4		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 25		# X coordinate
	li a1, 7		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 23		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 23		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 24		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3


	#B
	li a0, 30		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 5		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# X coordinate
	li a1, 7		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 31		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 6		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 31		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 32		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#U
	li a0, 35		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 38		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 36		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 37		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#TT
	li a0, 41		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 40		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 42		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 45		# X coordinate
	li a1, 3		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 44		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 46		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	
	#O
	li a0, 48		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 51		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 8		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 49		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 50		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 49		# start X coordinate
	li a1, 9		# Y coordinate
	li a2, 50		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#N
	li a0, 53		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 56		# X coordinate
	li a1, 4		# starting Y coordinate
	li a2, 9		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 54		# start X coordinate
	li a1, 3		# Y coordinate
	li a2, 55		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#To Reset------------------------------------------------------------
	
	#T
	li a0, 4		# X coordinate
	li a1, 11		# starting Y coordinate
	li a2, 17		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 3		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 5		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#O
	li a0, 7		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 16		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 10		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 16		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 8		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 9		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 8		# start X coordinate
	li a1, 17		# Y coordinate
	li a2, 9		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#R
	li a0, 15		# X coordinate
	li a1, 11		# starting Y coordinate
	li a2, 17		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 18		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 13		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 18		# X coordinate
	li a1, 15		# starting Y coordinate
	li a2, 17		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 16		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 17		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 16		# start X coordinate
	li a1, 14		# Y coordinate
	li a2, 17		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 20		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 16		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 21		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 22		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 21		# start X coordinate
	li a1, 14		# Y coordinate
	li a2, 22		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 21		# start X coordinate
	li a1, 17		# Y coordinate
	li a2, 22		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#S
	li a0, 24		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 13		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 24		# X coordinate
	li a1, 16		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 27		# X coordinate
	li a1, 12		# Y coordinate
	call draw_dot  # must not modify s2, s3
	li a0, 27		# X coordinate
	li a1, 15		# starting Y coordinate
	li a2, 16		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 25		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 26		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 25		# start X coordinate
	li a1, 14		# Y coordinate
	li a2, 26		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 25		# start X coordinate
	li a1, 17		# Y coordinate
	li a2, 26		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#E
	li a0, 29		# X coordinate
	li a1, 12		# starting Y coordinate
	li a2, 16		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 30		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 31		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 14		# Y coordinate
	li a2, 30		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	li a0, 30		# start X coordinate
	li a1, 17		# Y coordinate
	li a2, 31		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	#T
	li a0, 34		# X coordinate
	li a1, 11		# starting Y coordinate
	li a2, 17		# ending Y coordinate
	call draw_vertical_line  # must not modify s2, s3
	li a0, 33		# start X coordinate
	li a1, 11		# Y coordinate
	li a2, 35		# ending X coordinate
	call draw_horizontal_line  # must not modify: a3, s2, s3
	
	li	t1, 0
	beq	t2, t1, zeroScore
	addi	t1, t1, 1
	beq	t2, t1, oneScore
	addi	t1, t1, 1
	beq	t2, t1, twoScore
	addi	t1, t1, 1
	beq	t2, t1, threeScore
	addi	t1, t1, 1
	beq	t2, t1, fourScore
	addi	t1, t1, 1
	beq	t2, t1, fiveScore
	addi	t1, t1, 1
	beq	t2, t1, sixScore
	li	t1, 7
	beq	t2, t1, sevenScore
	addi	t1, t1, 1
	beq	t2, t1, eightScore
	addi	t1, t1, 1
	beq	t2, t1, nineScore
	
	ret

# draws a horizontal line from (a0,a1) to (a2,a1) using color in a3
# Modifies (directly or indirectly): t0, t1, a0, a2
draw_horizontal_line:
	addi sp,sp,-4
	sw ra, 0(sp)
	addi a2,a2,1	#go from a0 to a2 inclusive
draw_horiz1:
	call draw_dot  # must not modify: a0, a1, a2, a3
	addi a0,a0,1
	bne a0,a2, draw_horiz1
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# draws a vertical line from (a0,a1) to (a0,a2) using color in a3
# Modifies (directly or indirectly): t0, t1, a1, a2
draw_vertical_line:
	addi sp,sp,-4
	sw ra, 0(sp)
	addi a2,a2,1
draw_vert1:
	call draw_dot  # must not modify: a0, a1, a2, a3
	addi a1,a1,1
	bne a1,a2,draw_vert1
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# Fills the 60x80 grid with one color using successive calls to draw_horizontal_line
# Modifies (directly or indirectly): t0, t1, t4, a0, a1, a2, a3
draw_background:

	addi sp,sp,-4
	sw ra, 0(sp)
	li a3, BG_COLOR	#use default color
	li a1, 0	#a1= row_counter
	li s8, 60 	#max rows
start:	li a0, 0
	li a2, 79 	#total number of columns
	call draw_horizontal_line  # must not modify: t4, a1, a3
	addi a1,a1, 1
	bne s8,a1, start	#branch to draw more rows
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# draws a dot on the display at the given coordinates:
# 	(X,Y) = (a0,a1) with a color stored in a3
# 	(col, row) = (a0,a1)
# Modifies (directly or indirectly): t0, t1
draw_dot:
	andi s9,a0,0x7F	# select bottom 7 bits (col)
	andi s10,a1,0x3F	# select bottom 6 bits  (row)
	slli s10,s10,7	#  {a1[5:0],a0[6:0]} 
	or s9,s10,s9	# 13-bit address
	sw s9, 0(s2)	# write 13 address bits to register
	sw a3, 0(s3)	# write color data to frame buffer
	ret
