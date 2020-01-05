#studentName: Xingya Ren
#studentID: 260784116 

# This MIPS program should sort a set of numbers using the QSort algorithm
# The program should use MMIO

.data
#any any data you need be after this line 
welcome: .asciiz "Welcome to QuickSort\n"
prompt2: .asciiz "\nThe sorted array is: "
prompt3: .asciiz "\nThe array is re-initialized\n"
emptyArrr: .asciiz "Please enter the array that you want to sort, with a space between each number.\nType <c> to clear, <s> to display, or <q> to quit\n"
.align 2
#inputStr: .space 800 #assuming the max. space needed is 800 bytes/200 words/ints/
numbuffer: .space 800 
 
#sortBuffer: .space 800	#space to store integers consecutively, in order to implement QSort easier 

comsp:	.asciiz ", "	
Array_size:	.space	4
space:	.asciiz " "
newL:	.asciiz "\n"


	.text
	.globl main

	# all subroutines you create must come below "main"

#display the welcome msg using MMIO write 
main: 
	#constants needed for comparison 
	li $s0 32 #space 
	li $s1 48 #0 
	li $s2 57 #9 
	li $s3 99 #'c'
	li $s4 113 #'q'
	li $s5 115 #'s' 
	la $a0 welcome 
	jal print 
##############FINISHED PRINTING THE WELCOME MESSAGE#################
#Take user input--MMIO Read 
	#Store the input in an arry
afterWelcome:
	#li $a0 0 #ptr to memory 
arrFactory:
	li $a0 0 #ptr to memory; start again 
	jal sbrk #allocate heap memory 
	addi $sp $sp -4 #space for the array
	sw $zero 0($sp) #move to stack 
	addi $sp $sp -4	
	sw $v0 0($sp)
loopThrough:
	lw $a2 4($sp) 
	lw $a1 0($sp) 
	jal printArr
	
	la $a1 numbuffer #the array of nums 
	jal storeToBuff #just like in q1 
	
	la $a0 numbuffer
	la $a1 numbuffer 
	li $v0 1 
	jal aNum 
	
	add $s7 $v0 $0 #need to get the size of the arr 
	subi $sp $sp 4
	sw $s7 0($sp) 
	
	add $a0  $s7 $zero 
	jal sbrk
	add $a1 $v0 $zero 
	
	la $a0 numbuffer
	jal oneDig #one/two digit stoto store 
	
	subi $sp $sp 4 #make space 
	sw $v0 0($sp) 
	add $s6 $v0 $0 
	li $t1 0 #null 
	
	beq $t9 'q' quit 
	beq $t9 'c' clear 
	beq $t9 's' sort 
	
sort: #Quick sort, divide and concqre! 
	lw $a3 0($sp) #load arr adrs 
	addi $sp $sp 4
	
	lw $a1 0($sp) #load arr length
	addi $sp $sp 4 
	
	lw $a2 0($sp) #a2: the old arr 
	addi $sp $sp 4 
	
	lw $a0 0($sp) #a0: length of the old arr 
	addi $sp $sp 4 
	jal merge  #merge the two 
	
	addi $sp $sp -4 #make space 
	sw $v1 0($sp) 
	addi $sp $sp -4 
	sw $v0 0($sp) 
	
	move $a0 $v0 #addrs of array 
	move $a1 $v1 #length  
	li $a3 0 
	jal qs 
	j loopThrough
#a0 has the arr A1 has the length 
qs: 	
	subi $sp $sp 8 #2wrds 
	subi $a3 $a3 8 
	sw $a0 0($sp) 
	sw $a1 4($sp) 
	
fill:
	beqz $a3 return #reached end 
	lw $a0 0($sp) #old arr
	lw $a1 4($sp) #old length 
	lb $a2 0($a0) #pivot
	
	subi $sp $sp 4 
	sw $ra 0($sp) #save the adrs 
	jal divid 
	
	lw $ra 0($sp) 
	addi $sp $sp 4 
	lw $a2 4($sp) #restore length 
	sub $a1 $v1 $v0
	sub $a2 $a2 $a1
	
	li $t0 1
	addi $sp $sp 8 #the stack is freee~
	addi $a3 $a3 8 
	
	beqz $a2 emptyArr 
	subi $sp $sp 8 
	subi $a3 $a3 8 
	sw $a2 4($sp) 
	sw $v1 0($sp) 
	
emptyArr: 
	ble $a1 $t0, fill2	 
	addi $a0 $v0 0	 
	j qs #qs it again 
fill2:
	lw $a0 0($sp) #arr
	lw $a1 4($sp)#its length 
	j fill
	
divid:	
	addi $v0 $a0 0	#beginning of the first part 
	addi $v1 $a0 1	#.................2nd part 
compare: 
	beqz $a1 end
	lb $t0 0($a0)#pint to the beginning 
	addi $a0 $a0 1 #advance ptr 
	subi $a1 $a1 1
	blt $t0 $a2 swap 
	j compare
		
swap:	
	lb $t1 0($v1) #the second part 
	sb $t1 -1($a0)#save to its previous location 
	sb $t0, 0($v1) 
	addi $v1, $v1, 1
	j compare
end: 	
	lb $t0 -1($v1) #reset v0 v1 
	sb $t0 0($v0)
	sb $a2 -1($v1)
	jr $ra
			
merge: 
	addi $sp $sp -4
	sw $ra 0($sp)	
	add $a0 $a0 $a1 #new length 
	jal sbrk 
	lw $ra 0($sp) #rest the ptr 
	addi $sp $sp 4	
	add $t1 $v0 $zero #ptr to the new arr 
	add $v1 $a0 $zero #length 	
	sub $a0, $a0, $a1 #restor 
	beqz $v1 return		
	beqz $a0 copyArr1
	
copyArr:
	lb $t0 0($a2)	#load and store byte 
	sb $t0 0($t1)	
	addi $t1 $t1 1	#advance ptr 
	addi $a2 $a2 1	
	subi $a0 $a0 1 #move a0 back 1
	bnez $a0 copyArr #not done, loop back 
	beqz $a1 return
copyArr1:
	lb $t0 0($a3)	#load and store byte 
	sb $t0 0($t1)	
	addi $t1 $t1 1	#advance ptr 
	addi $a3 $a3 1	
	addi $a1 $a1 -1 #move a0 back 1
	bnez $a1 copyArr1
	jr $ra 
clear: 
	#print prompt 3 
	la $a0 prompt3
	addi $sp $sp 16 
	jal print 
	j arrFactory
	
oneDig: 
	lb $t1 0($a0) #current char
	addi $a0 $a0 1 
	beqz $t1 return 
	beq $t1 $s0 oneDig #move to the next 
	
	lb $t2 0($a0) 
	bgt $t2 $s0 twoDig 
	addi $t1 $t1 -48 #convert back ascii to number 
	sb $t1 0($a1) #store in array 
	addi $a1 $a1 1 
	j oneDig 
	
twoDig: 
	li $t3 10 #\n
	subi $t1 $t1 48 
	mul $t1 $t1 $t3 #*10 
	addi $t2 $t2 -48 
	add $t1 $t1 $t2 
	sb $t1 0($a1) 
	addi $a1 $a1 1 
	addi $a0 $a0 1 #ptrs moved
	j oneDig
	
sbrk:	#alloc heap memory
	li $v0 9
	syscall
	jr $ra
aNum: 
	lb $t1 0($a0) #t1 has the current char
	addi $a0 $a0 1 #advance ptr
	beq $t1 $s0 aNum #end of a #
	
	bnez $t1 goodNum
	add $v0 $zero $zero 
	jr $ra 
numOrSpace: 
	lb $t1 0($a0) 
	addi $a0 $a0 1 #advacne ptr
	bne $t1 $s0 goodNum
	lb $t2 0($a0) 
	beq $t2 $s0 numOrSpace #ASSUMPTION: there's only 2 digits  
	beq $t2 $zero endNum #the end!
	addi $v0 $v0 1 

goodNum: 	
	sb $t1 0($a1) #save in t1
	addi $a1 $a1 1 
	bne $t1 $zero numOrSpace
	jr $ra 
endNum: 
	sb $t2 0($a1) 
	jr $ra 
#return: jr $ra 
quit: 
	li $v0 10 
	syscall #KILL THE PROGRAM 
	
	
storeToBuff: 
	#move sp back 
	subi $sp $sp 4 
	sw $ra 0($sp) #store the addrs to jump back


readMMIO: 
	jal read
	move $a0 $v0 #saved in a0 to use for write 
	jal write 
	
	beq $a0 $s3 backToMain
	beq $a0 'q' backToMain
	beq $a0 's' backToMain 
	
	j readMMIO 
	
backToMain: 
	#reset ra 
	lw $ra 0($sp)
	addi $sp $sp 4 
	sb $zero 0($a1) 
	add $t9 $a0 $zero 
	jr $ra

read: 
	lui $t0 0xffff 
loop_read2: 
	lw $t1 0($t0) 
	andi $t1 $t1 0x0001 
	beq $t1 $zero loop_read2
	
	lw $v0 4($t0) 
	jr $ra 
write: 
	lui $t0 0xffff 
	#check if its a numebr
	#li $s1 59 #for 9  
	bgt $a0 $s2 return #not a num
	beq $a0 $s0 needToPrint
	#li $s2 48 #for 0
	bge $a0 $s1 needToPrint 
	j return 
	
needToPrint: 
	lw $t1 8($t0) 		 
	andi $t1 $t1 0x0001	 
	beq $t1 $zero needToPrint	 
	
	sw $a0 12($t0) 		 
	sb $a0 0($a1)			
	addi $a1 $a1 1
	
return : jr $ra

print: #print whatever is stored in the address 
	lb $a3 0($a0) 
	addi $a0 $a0 1 
	beq $a3 $0 return #reached a nullj; finished; jump back  

write_loop:
	lui $t0 0xffff
	lw $t1 8($t0) 
	andi $t1 $t1 0x0001 #leave only the last bit 
	beqz $t1 write_loop 
	sw $a3 12($t0) 
	j print
	
printArr: 
	beqz $a2 emptyArray # print something to stop it !!! 
	#lw $a1 0($sp) #advance sp over the array 
	#lw $a2 4($sp) 
	#jal showArray
	#ready to read and print the array 
	addi $sp $sp -4 
	sw $ra 0($sp) #store the return address so i can jumpt back to print
	la $a0 prompt2 
#print prompt 2 
#li $t2 0 #counter_index 
#loopStr_prompt2:
#	la $a0 prompt2 
#	lb $s1 prompt2($t2) 
#	beq $s1 $zero continue_prompt2
#	move $a0 $s1 
	
#write the string; via MMIO 
#Writeprompt2:  lui $t0, 0xffff 	#ffff0000
##	andi $t1,$t1,0x0001
##	sw $a0, 12($t0) 	#data	
##	j loopStrprompt2
########finished printing prompt2 
	jal print 
	
	#need to reset the return address!!!
	lw $ra 0($sp) 
	addi $sp $sp 4 
	
printloop1: #print the input arr 
	lui $t0 0xffff
	lb $a0 0($a1) 
	#if is num between 0-9
		#add 48 to get its ascii 
	li $t1 10 
	blt $a0 $t1 add48 
	#else two digits :( 
	div $a0 $t1 
	mflo $a0 #lower half 
	addi $a0 $a0 48 

printloop2:
	lw $t1 8($t0) 
	andi $t1 $t1 0x0001 
	beq $t1 $zero printloop2
	sw $a0 12($t0) 
	mfhi $a0 #the 10th digit
	
add48: 
	addiu $a0 $a0 48 #now $a0 has its ascii 
	
checknull: 
	lw $t1 8($t0) 
	andi $t1 $t1 0x0001 #mask
	beq $t1 $zero checknull #infiloop
	sw $a0 12($t0) 
	add $a0 $s0 $zero 
	
checknullsecond:
	lw $t1 8($t0) 
	andi $t1 $t1 0x0001 #mask
	beq $t1 $zero checknullsecond #infiloop
	sw $a0 12($t0) 
	#add $a0 $s0 $zero
	#move the ptrs
	addi $a1 $a1 1 
	subi $a2 $a2 1 
	#if not null,print
	bnez $a2 printloop1
	subi $a0 $s0 22 #new line 
	
checknullthird:
	lw $t1 8($t0) 
	andi $t1 $t1 0x0001 #mask
	beq $t1 $zero checknullsecond #infiloop
	sw $a0 12($t0) 
	jr $ra 
	
	li $v0 1
	lb $a0 0($a1) #store current # 
	syscall #syscall?? 
	
	li $v0 11 #a num 
	add $a0 $s0 $zero 
	syscall #space 
	
	addi $a1 $a1 1 
	subi $a2 $a2 1 
	#if not null,print
	
	bne $a2 $zero printloop1
	li $v0 11
	subi $a0 $s0 22 
	syscall 
	
	jr $ra #main 
	

emptyArray:				 
	#the array is empty 
	#if no stop here -> keeps printing 0 				 
	addi $sp, $sp, -4		
	sw $ra, 0($sp)			 
	la $a0, emptyArrr		 
	jal print
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	
