#name: Xingya Ren
#studentID: 260784116 

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
openInputErrMsg: .asciiz "ERROR: failed to open the input file"  
readErrMsg: .asciiz "ERROR: failed to read the input file"  
openOutputErrMsg: .asciiz "ERROR: failed to open the output file"  
writeErrMsg: .asciiz "ERROR: failed to write to output file."

toWrite: .asciiz "P2\n24 7\n15\n"
filler:	 .asciiz "0123456789\n "
	.text
	.globl main

main:
    	la $a0,input	#readfile takes $a0 as input
    	jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        #either 0 or 1, specifying x or y axis flip accordingly
	jal flip


	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	li $a1 0  
	li $a2 0 
	li $v0 13 
#la $a0 input 
	syscall #this should open a file 
	blt $v0 $zero openInputError 
	move $s0 $v0 #save the file descriptior in $s0 
	
	#li $v0 14
	move $a0 $s0 #move the file descriptor 
	la $a1 buffer 
	la $a2 2048 #buffer length 
	li $v0 14
	syscall 
	bltz $v0 readError 
	
	move $s1 $v0	 #save the file descriptior in $s1 
	move $a0 $s0 
	li $v0 16	#close the file 
	syscall  
# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)

	jr $ra


flip:
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!
	li $t1 -1	#rows //counter for column 
	li $t3 0	#col //counter for rows 
	li $t5 0	#element counter $t7 
	li $t7 32	#the ascii code for 'space 
	li $t9 10	#the ascii code for '\n' 
	loop: #loop through the buffer 
		lb $t0 buffer($t5)	#load the first byte of the buffer 
		addi $t5 $t5 1	#Increment the element counter 
		beq $t0 $zero end	#null -> end of buffer -> terminate 
		beq $t0 $t7 loop	#' ' -> load the next byte 	
		beq $t0 $t9 loop	#'\n' -> load the next byte 	
		subi $t0 $t0 48	#ascii to int. (only works for 0-9) 
	
		lb $t2 buffer($t5)	#load the second/following byte to check (i.e. 11) 
		addi $t5 $t5 1	
		bne $t2 $t7 twoDigits	#if the next byte is not ' ' -> have more than one digit!!  

	reachEnd:			
		addi $t1 $t1 1	
		beq $t1 24 newRow	#24th column -> end of a row 
		  
		lw $s0 axis
		beq $s0 $0 X
		
	Y:	#flip on Y
		li $t6 23              #max col.
		sub $t6 $t6 $t1	#(row * numberOfElemebtsInARow + column) = position 
		mul $t4 $t3 24        #$t4 is the new position 
		add $t4 $t4 $t6
		sb $t0 newbuff($t4) 
		b loop

	X:	#flip on X
		li $t6 6	       #max row
		sub $t4 $t6 $t3
		mul $t4 $t4 24
		add $t4 $t4 $t1
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
		lw $s0 axis
		beq $s0 0 X
		beq $s0 1 Y
	end: 
		jr $ra 
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
#open file pointed by $a0 
	##$a1 is the add of newBuff
	#Move $t1 $a1
	move $t1 $a1 #need a1 for syscall 
	li $a1 1 
	li $a2 0
	li $v0 13 
	syscall 
	#la $a0 fileName 
	 
 	blt $v0 $0 openOutputErr 
 
#write the specified characters as seen on assignment PDF:
#P2    
#24 7
#15
	#write to file 
	move $a0 $v0 #file descriptor 
	la $a1 toWrite
	la $a2 11 
	li $v0 15 
	syscall 
	
	blt $v0 $0 writeErr 
	
#write the content stored at the address in $a1.
	li $t0 0
	li $t2 0
	write:
		beq $t0 168 stopWritting	#24*7 -> the last element 
		add $t9 $t0 $t1
		lb $a1 ($t9)
		bgt $a1 9 greaterThan9
		
	parseIn:	
		la $a1 filler($a1)									
		li $a2 1
		
		li $v0 15
		syscall
		bltz $v0 writeErr
		
		beq $t2 23 endOfRow 
		
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
	#close the file  
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
	li $v0 10
	syscall 
