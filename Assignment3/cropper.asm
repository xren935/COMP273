#name: Xingya Ren
#studentID: 260784116

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 6
y1: .word 1
y2: .word 6
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 
openInputErrMsg: .asciiz "ERROR: failed to open the input file"  
readErrMsg: .asciiz "ERROR: failed to read the input file"  
openOutputErrMsg: .asciiz "ERROR: failed to open the output file"  
writeErrMsg: .asciiz "ERROR: failed to write to output file."

toWrite: .asciiz "P2\n24 7\n15\n"
filler:	 .asciiz "0123456789\n "

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    	lw $a0 x1 
    	lw $a1 x2 
    	lw $a2 y1
    	lw $a3 y2
    #appropriate stack positions outlined in function*
    	addiu $sp, $sp, -20 #stack: 4*5 = 20 
   
	jal crop
	addiu $sp, $sp, 20
	
	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
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



crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
	sub $s0, $a1, $a0	#$s0 is the width of the resultant pgm 
	sub $s1, $a3, $a2	#$s1 .......height....................

	lw $s2 16($sp) #16($sp)=buffer
	lw $s3 20($sp) #20($sp)=newbuffer that will be made
	#copy the counters from flipper to loop through 
	li $t1 -1	# counter for column 
	li $t2 0 
	li $t3 0	# counter for rows 
	li $t4 0 	#newBuff counter 
	li $t5 0	#element counter $t7 
	li $t7 32	#the ascii code for 'space 
	li $t9 10	#the ascii code for '\n' 
	loop: #loop through the buffer 
		lb $t0 buffer($t5)	#load the first byte of the buffer 
		addi $t5 $t5 1	#Increment the element counter 
		beq $t0 $zero cut	#null -> end of buffer -> terminate 
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
		sb $t0 newbuff($t4) 
		addi $t4 $t4 1 
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
		
	cut: 
		#x0--a0--col
		#y0--a2--row 
		move $t0 $a0 
		move $t1 $a2 
		li $t2 0 
		
	loopNStore: 
		mul $t4 $t1 24 
		add $t4 $t4 $t0 
		lb $t7 newbuff($t4) 
		sb $t7 newbuff($t2) 
		addi $t2 $t2 1 
		addi $t0 $t0 1 
		beq $t0 $a1 switchR
		b loopNStore 
	switchR: 
		addi $t1 $t1 1 
		bge $t1 $a3 end 
		move $t0 $a0 
		b loopNStore 
		
	end:    jr $ra 
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.

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
	li $t1, 50
	sb $t1, headerbuff+3
	lb $t1, filler($t0)
	sb $t1, headerbuff+4
	li $t2, 5
	b cropp

	cropp:
	li $t1 32
	sb $t1 headerbuff($t2)
	addi $t2 $t2 1

	move $t0, $s1
	blt $t0 10 print0New
	subi $t0 $t0 10
	blt $t0 10 print1New
	subi $t0, $t0, 10
	blt $t0, 10, print2New

	print0New:
	lb $t1, filler($t0)
	sb $t1, headerbuff($t2)

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
	addi $t2, $t2, 1
	li $t1, 10
	sb $t1, headerbuff($t2)
	addi $t2, $t2, 1
	li $t1, 49
	sb $t1, headerbuff($t2)
	addi $t2, $t2, 1
	li $t1, 53
	sb $t1, headerbuff($t2)
	addi $t2, $t2, 1
	li $t1, 10
	sb $t1, headerbuff($t2)

	addi $t2, $t2, 1
	move $a0, $v0
	la $a1, headerbuff
	move $a2, $t2
	
	li $v0, 15
	syscall
	blt $v0, $0, writeErr
	
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
		
	greaterThan9: #2-digits 
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
