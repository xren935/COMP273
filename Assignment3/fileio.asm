#name: Xingya Ren
#studentID: 260784116

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output

openInputErrMsg: .asciiz "ERROR: failed to open the input file"  
readErrMsg: .asciiz "ERROR: failed to read the input file"  
openOutputErrMsg: .asciiz "ERROR: failed to open the output file"  
writeErrMsg: .asciiz "ERROR: failed to write to output file."

toWrite: .asciiz "P2\n24 7\n15\n"
buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:

#Open the file to be read,using $a0
#Conduct error check, to see if file exists
#Open the file 
	li $v0 13 
#la $a0 input 
	li $a1 0  
	li $a2 0 
	syscall #this should open a file 
	
	blt $v0 $zero openInputError 
	move $s0 $v0 #save the file descriptior in $s0 
	
# You will want to keep track of the file descriptor*

# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file
	li $v0 14
	move $a0 $s0 #move the file descriptor 
	la $a1 buffer 
	li $a2 2048 #buffer length 
	syscall 
	
	bltz $v0 readError 

#print whats in the file 
	li $v0 4  
	la $a0 buffer 
	syscall 

# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)
	li $v0 16 
	move $a0 $s0 
	syscall 

	jr $ra

  

writefile:
	#open file pointed by $a0 
	la $a0 output 
	li $v0 13 
	#la $a0 fileName 
	li $a1 1 
	li $a2 0 
	syscall #this should open a file 
	move $s1 $v0 #save the file descriptior in $s0 
 	blt $v0 $0 openOutputErr 
	
	#write to file 
	li $v0 15 
	move $a0 $s1 
	la $a1 toWrite 
	la $a2 11 
	syscall 
	blt $v0 $0 writeErr 
	
	li $v0 15 
	move $a0 $s1 
	la $a1 buffer 
	la $a2 2048 
	syscall 
	blt $v0 $0 writeErr 
	
	#close; can't check exception :(
	li $v0 16 
	move $a0 $s1 
	syscall 
	jr $ra 
	
openInputError:
	la $a0, openInputErrMsg
	li $v0, 4
	syscall
	b exit

readError:
	la $a0, readErrMsg
	li $v0, 4
	syscall
	b exit
openOutputErr:
	la $a0, openOutputErrMsg
	li $v0, 4
	syscall
	b exit
  
writeErr:
	la $a0, writeErrMsg
	li $v0, 4
	syscall

exit:
	li $v0, 10
	syscall

