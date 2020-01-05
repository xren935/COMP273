#name: Xingya Ren
#studentID: 260784116

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
openInputErrMsg: .asciiz "ERROR: failed to open the input file"  
readErrMsg: .asciiz "ERROR: failed to read the input file"  
openOutputErrMsg: .asciiz "ERROR: failed to open the output file"  
writeErrMsg: .asciiz "ERROR: failed to write to output file."

toWrite: .asciiz "P2\n24 7\n15\n"
filler:	 .asciiz "0123456789\n "
#
# Confession: My border is prettier, isn't it? 
# 	      Okay...I couldn't figure out why lft/right borders are not there 
#	      Also, when the width exceeds 10 (say, when width=3 and totalWidth=13) the array messes up :(  
#	      
#

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	li $v0 13 
#la $a0 input 
	li $a1 0  
	li $a2 0 
	syscall #this should open a file 
	blt $v0 $zero openInputError 
	move $s0 $v0 #save the file descriptior in $s0 
	
	li $v0 14
	move $a0 $s0 #move the file descriptor 
	la $a1 buffer 
	la $a2 2048 #buffer length 
	syscall 
	bltz $v0 readError 
	move $s1 $v0 #save the file descriptior in $s1 

# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)
	li $v0 16 
	move $a0 $s0 
	syscall 

	jr $ra

bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
	li $s0 24		# current x
	li $s1 7		# current y
	lw $a2 ($a2)
	add $s0 $s0 $a2	#right border #EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
	add $s0 $s0 $a2	#left 
	add $s1 $s1 $a2	#top height + borderwidth*2 
	add $s1 $s1 $a2	#bottom 
	#s0: new width // s1: new height 
	li $t0 0 #offset/counter
	li $t1 0
	li $t2 15		# white(15) boarder 
	mul $t3 $a2 $s0 #top and bottom 
	li $t4 0 #new addrs 
	li $t5 0 #new adrs 
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.

	top: 
	bge $t0 $t3 stopTop	# adding the top border
	add $t4 $a1 $t0
	sb $t2 0($t4) #found a boarder spot 
	addi $t0 $t0 1
	b top

	
	stopTop:
	move $t0 $0 #clear out t0 
	sub $t4 $s1 $a2 
	mul $t4 $t4 $s0
	add $t4 $t4 $a1
	
	
	btm:
	bge $t0 $t3 stopBtm	# adding the bottom border
	add $t5 $t4 $t0
	sb $t2 ($t5)
	addi $t0 $t0 1
	b btm 
	
	stopBtm:
	mul $t5 $a2 $s0	# the original offset
	add $t5 $t5 $a1	# the original address
	li $t4 0	# initialize counter 
	#now left and right! 
		bge:
		bge $t4 7 end
		li $t0 0
		
		fill:
		beq $t0 $a2 endfill
		add $t6 $t0 $t5
		sb $t2 ($t6) #found a spot (t6 is the adrs)
		addi $t0 $t0 1
		b fill
		
		endfill:
		add $t5 $t5 $a2
		addi $t5 $t5 24
		li $t0 0

		fillAgain:
		beq $t0 $a2 endfillAgain
		add $t6 $t0 $t5
		sb $t2 ($t6)
		addi $t0 $t0 1
		b fillAgain

	endfillAgain:
		add $t5 $t5 $a2
		addi $t4 $t4 1
		b bge
		
	end:
		li $t1 -1	#counter for column
		li $t3 0	#counter for rows
		li $t5 0	#element counter
		li $t7 32	#ascii for 'space'
		li $t9 10	#ascii for \n
	
	loop:	
		#loop through the buffer 
		lb $t0 buffer($t5)	#load the first byte of the buffer 
		addi $t5 $t5 1	#Increment the element counter 
		beq $t0 $zero quit	#null -> end of buffer -> terminate 
		beq $t0 $t7 loop	#' ' -> load the next byte 	
		beq $t0 $t9 loop	#'\n' -> load the next byte 	
		subi $t0 $t0 48	#ascii to int. (only works for 0-9) 
	
		lb $t2 buffer($t5)	#load the second/following byte to check (i.e. 11) 
		addi $t5 $t5 1	
		bne $t2 $t7 twoDigits	#if the next byte is not ' ' -> have more than one digit!!  
	reachEnd:			
		addi $t1 $t1 1	
		beq $t1 24 newRow	#24th column -> end of a row 
	store: 	
		#li $t4 0 
		add $t6 $t1 $a2 
		add $t4 $t3 $a2 
		mul $t4 $t4 $s0 
		add $t4 $t4 $t6 
		sb $t0 newbuff($t4) 
		b loop 
			
	twoDigits:	 
		beq $t2 $zero reachEnd	#null -> terminate 
		beq $t2 $t9 reachEnd	#new line 
		subi $t2 $t2 48		#get the int for the ascii code 
		addi $t0 $t2 10
		b reachEnd
		
	newRow:
		addi $t3 $t3 1 		#go to the next row 
		li $t1 0
		b store 
		
	quit: jr $ra 
	
	move $t1 $a1
	li $a1 1
	li $a2 0
	li $v0 13
	syscall
	blt $v0 $0 openOutputErr

writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
#la $a0, output		#writefile will take $a0 as file location
	#la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
	#jal writefile
	move $s2 $a1 
	li $v0 13 
	#la $a0 fileName 
	li $a1 1 
	li $a2 0 
	syscall #this should open a file 
	#move $s1 $v0 #save the file descriptior in $s0 
 	blt $v0 $0 openOutputErr 
	
	li $t0 80 
	sb $t0 headerbuff 
	
	li $t0 50 
	sb $t0 headerbuff+1 

	li $t0 10
	sb $t0 headerbuff+2 
	#fill the buffer 
	 
	move $t0 $s0
	blt $t0 10 print0 
	subi $t0 $t0 10
	blt $t0 10 print1
	subi $t0 $t0 10
	blt $t0 10 print2

	print0:	
	lb $t1 filler($t0)
	sb $t1 headerbuff+3
	li $t2 4

	b cropp

	print1:
	li $t1 49
	sb $t1 headerbuff+3
	lb $t1 filler($t0)
	sb $t1 headerbuff+4
	li $t2 5
	b cropp

	print2:
	li $t1 50
	sb $t1 headerbuff+3
	lb $t1 filler($t0)
	sb $t1 headerbuff+4
	li $t2 5
	b cropp

	cropp:
	li $t1 32
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1

	move $t0, $s1
	blt $t0 10 print0New
	subi $t0 $t0 10
	blt $t0 10 print1New
	subi $t0 $t0 10
	blt $t0 10 print2New

	print0New:
	lb $t1 filler($t0)
	sb $t1 headerbuff($t2)

	b cropping

	print1New:
	li $t1 49
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1
	lb $t1 filler($t0)
	sb $t1 headerbuff($t2)
	b cropping

	print2New:
	li $t1 50
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1
	lb $t1 filler($t0)
	sb $t1 headerbuff($t2)
	b cropping 

	cropping:
	addi $t2 $t2 1
	li $t1 10
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1
	li $t1 49
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1
	li $t1 53
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1
	li $t1 10
	sb $t1 headerbuff($t2)

	addi $t2 $t2 1
	move $a0 $v0
	la $a1 headerbuff
	move $a2 $t2
	
	li $v0 15
	syscall
	blt $v0 $0 writeErr
	
#write the content stored at the address in $a1.
	li $t0, 0
	la $t1 newbuff 
	li $t2, 0
	mul $t7 $s0 $s1
	subi $s0 $s0 1
	write:	
		beq $t0 $t7 stopWritting 
		#beq $t0 168 stopWritting	#24*7 -> the last element 
		add $t9 $t0 $t1
		lb $a1 ($t9)
		bgt $a1 9 greaterThan9
		
	parseIn:	
		la $a1 filler($a1)									
		li $a2 1
		
		li $v0 15
		syscall
		bltz $v0 writeErr
		
		bge $t2 $s0 endOfRow 
		
		li $t4 11
		la $a1 filler($t4)	#writing 'space'								
		li $a2 1
		
		li $v0, 15
		syscall
		blt $v0 $zero writeErr
		
		addi $t0 $t0 1
		addi $t2 $t2 1
		b write
		
	greaterThan9: #more than one digit 
		move $t3 $a1   
		li $t4 1      
		la $a1 filler($t4) 
		li $a2 1
		
		li $v0 15
		syscall                    
		blt $v0 $zero writeErr
		subi $a1 $t3 10
		b parseIn
		
	endOfRow:
		li $t2 0
		li $a1 10
		la $a1 filler($a1)
		li $a2 1
		
		li $v0 15
		syscall
		blt $v0 $zero writeErr
		addi $t0 $t0 1
		b write
		
	stopWritting:
	#close the file (make sure to check for errors)
		li $v0, 16
		syscall
		jr $ra




openInputError:
	la $a0 openInputErrMsg
	li $v0 4
	syscall
	b exit
	
readError:
	la $a0 readErrMsg
	li $v0 4
	syscall
	b exit
	
openOutputErr:
	la $a0 openOutputErrMsg
	li $v0 4
	syscall
	b exit
writeErr:
	la $a0, writeErrMsg
	li $v0, 4
	syscall
exit:
	li $v0, 10
	syscall
