#name: Xingya Ren
#studentID: 260784116

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
openInputErrMsg: .asciiz "ERROR: failed to open the input file"  
readErrMsg: .asciiz "ERROR: failed to read the input file"  
openOutputErrMsg: .asciiz "ERROR: failed to open the output file"  
writeErrMsg: .asciiz "ERROR: failed to write to output file."

toWrite: .asciiz "P2\n7 24\n15\n"

filler:	 .asciiz "0123456789\n "
	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile
	
	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
        jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	#$a0 has the address of the 2D array 
	#clear out $a1, $a2 
	li $a1, 0		 
	li $a2, 0
	li $v0, 13		#Open the file to be read,using $a0
	syscall
	
	blt $v0 $0 openInputError	#Conduct error check, to see if file exists
	move $s0 $v0		# You will want to keep track of the file descriptor*
	
	move $a0 $s0		# read from file
	la $a1 buffer		# use correct file descriptor, and point to buffer
	li $a2 2048		# hardcode maximum number of chars to read
	
	li $v0 14		# read from file
	syscall					
	blt $v0 $0 readError	
	
	move $s1, $v0		# $v0 contains number of characters read  
	move $a0, $s0		# save the number of char in $s1 
	
	li $v0, 16		#close the file; can't catch error :(
	syscall
	
	jr $ra


transpose:
#Can assume 24 by 7 again for the input.txt file
	#parse the content in the buffer (Q2) 
	li $t0 -1	#use $t1 for col counter 
	move $t2 $a0 	#save the addrs of buffer to t2 
	#save the addrs of newBuff ?  
	move $s0 $a1 
	
	li $t3 32	#the ascii code for space
	li $t4 10	#the ascii code for \n
 

	
	loop:	
		lb $a1 ($t2)		#Load the first byte 
		addi $t2 $t2 1	#increament the addrs 
		beq $a1 $zero end	#if $t0 is null -> reached the end of the file
		beq $a1 $t3 loop	#if 'space' -> load the next byte 	
		beq $a1 $t4 loop	#if '\n' -> load the next byte  	
		subi $a1 $a1 48		#ascii to int. (0-9) 
					#now $t0 has the int.
	
		lb $a2, ($t2)	#Load the next byte 
		addi $t2 $t2 1	#increament the counter 
		bne $a2 $t3 twoDigits	#if not blank space -> have more than one digit!  
		#store to the new buffer 
		#sb $t0 buffer($t7) 
	reachEnd:			
		addi $t0 $t0 1 #go to the next col?  
		beq $t0 24 newRow	#If end of row go to ifrow
		
	swap: 	
		mul $t6 $t0 7
		add $t6 $t1 $t6 
		add $t6 $t6 $s0 
		sb $a1 ($t6) 
		
		b loop 
		
	newRow: 
		addi $t1 $t1 1 	
		li $t0 0 
		b swap
		
	twoDigits:	 
		beq $a2 $zero reachEnd	#null -> terminate 
		beq $a2 $t4 reachEnd	#new line 
		subi $a2 $a2 48		#get the int for the ascii code 
		addi $a1 $a2 10
		b reachEnd 
		
	end: 	jr $ra	
	 
			
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

#open file to be written to, using $a0.
	move $t1 $a1 #now $t1 has the address of what we wish to write 
	
	li $a1 1
	li $a2 0
  
	li $v0 13
	syscall
	
	blt $v0 $0 openOutputErr
#write the specified characters as seen on assignment PDF:
#P2    
#24 7
#15
	move $a0 $v0
	la $a1 toWrite
	li $a2 11
  
	li $v0 15
	syscall
        blt $v0 $0 writeErr
        
#write the content stored at the address in $a1.
	li $t0, 0 #element pointer/counter 
	li $t2, 0
	write:
		beq $t0 169 stopWritting	#24*7 -> the last element 
		add $t9 $t0 $t1
		lb $a1 ($t9)
		bgt $a1 9 greaterThan9
		
	 parseIn:	
		la $a1 filler($a1)									
		li $a2 1
		
		li $v0 15
		syscall
		bltz $v0 writeErr
		
		beq $t2 6 endOfRow 
		
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

	
