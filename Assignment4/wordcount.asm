#studentName: Xingya Ren
#studentID: 260784116 

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
wrdCount: .asciiz "Word count\nEnter the text segment:\n\t"
searchWrd: .asciiz "\nEnter the search word:\n\t"
occurrPromt_firstPrt: .asciiz "\nThe word ' "
occurrPromt_secondPrt: .asciiz "' occurred "
occurrPromt_thirdPrt: .asciiz " time(s)."
lastPrompt: .asciiz "\npress 'e' to enter another segment of text or 'q' to quit\n"

.align 2
inputStr: .space 600 #in case the input is huge 
keyWrd: .space 600 
counter: .space 4  
numbuffer: .space 4 
userInputChar: .space 1 #either 'e' or 'q' 

nomatch:    .asciiz     "No Match(es) Found"
found:      .asciiz     " Match(es) Found"
newline:    .asciiz     "\n"
quo1:       .asciiz     "'"
quo2:       .asciiz     "'\n"


	.text
	.globl main

main:	# all subroutines you create must come below "main"

#First, print "Word count \n Enter the text segment:\n"
#$a0 has the char 
	li $t2 0 #counter_index 
	
loopStr:
	la $a0 wrdCount 
	lb $s1 wrdCount($t2) 
	beq $s1 $zero continue 
	move $a0 $s1 
	
#write the string; via MMIO 
Write:  lui $t0, 0xffff 	#ffff0000
Loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j loopStr
##################Finished printing the prompt--Word Count: #####################

#Get the string from user, save it and print it 
#MMIO Read and Write from mmio.asm
continue:
echo:	jal Read1		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	 
	jal Write1
	j echo

Read1:  	
	lui $t0, 0xffff 	#ffff0000
Loop1_1:
	 
	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1_1
	lw $v0, 4($t0) 		#data	
	#Check if the user hit return(\n) 
	li $t2 '\n'
	beq $v0 $t2 endInput
	#li $t4 0 #counter
	#else, save it!! 
	la $a2 inputStr
	sb $v0 inputStr($t4)
	addi $t4 $t4 1 
	jr $ra

Write1:  
	lui $t0, 0xffff 	#ffff0000
Loop2_1: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2_1
	sw $a0, 12($t0) 	#data	
	jr $ra
	
##########Finished printing user input(the original string)############

endInput: 
	#print "\nEnter the search word:\n"
	li $t2 0 #counter_index 
	
loopStr2:
	la $a0 searchWrd 
	lb $s1 searchWrd($t2) 
	beq $s1 $zero continue_keyWrd
	move $a0 $s1 
	
#write the string; via MMIO 
Write2:  lui $t0, 0xffff 	#ffff0000
Loop2_2: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2_2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j loopStr2
##########Finished printing the 2nd prompt############
#take the word to search from user, save it, print it 
#Get the string from user, save it and print it 
#MMIO Read and Write from mmio.asm
continue_keyWrd:
echo_keyWrd:	
	jal Read1_keyWrd		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	 
	jal Write1_keyWrd
	j echo_keyWrd

Read1_keyWrd:  	
	lui $t0, 0xffff 	#ffff0000
Loop1_1_keyWrd:
	 
	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1_1_keyWrd
	lw $v0, 4($t0) 		#data	
	#Check if the user hit return(\n) 
	li $t2 '\n'
	beq $v0 $t2 beginSearch
	#li $t5 0 #counter
	#else, save it!! 
	la $a2 keyWrd
	sb $v0 keyWrd($t5)
	addi $t5 $t5 1 
	jr $ra

Write1_keyWrd:  
	lui $t0, 0xffff 	#ffff0000
Loop2_keyWrd: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2_keyWrd
	sw $a0, 12($t0) 	#data	
	jr $ra
##########################################################

#search/count the # of occurrence of the keyWrd in the inputStr
beginSearch:  
 la $a0 inputStr #pointer to the first char 
 la $a1 keyWrd 
 
 addSpace: 
 #add 'space' at the end of inputStr and keyWrd! 
 lb $t1 0($a0) #first char 
 addiu $a0 $a0 1 
 beq $t1 $zero foundTheEnd 
 j addSpace     
 
 addSpace_key:
 lb $t1 0($a1) 
 addiu $a1 $a1 1 
 beq $t1 $zero foundTheEnd_Key 
 j addSpace_key
 
    # read sentence 
 
    #la      $a1,100                 # length of buffer
spaceAddedStartSearch: 
    la      $a2,inputStr                 # buffer address
    jal     rdstr

    # read scan word
    #la      $a1,30                  # length of buffer
    la      $a2,keyWrd               # buffer address
    jal     rdstr
####degbug PRINT 
  
###
    la      $t7,inputStr                 # pointer to first char in string
    li      $t8,0                   # zero the match count

strloop:
    move    $t6,$t7                 # start scan where we left off in string
    #here the pointer should starts at the next word('s first character)
    #addi $t6 $t6 3 
    
    la      $t5,keyWrd               # start of word to scan for
    li      $t4,0x20                # get ascii space

wordloop:
    lbu     $t0,0($t6)              # get char from string
    addiu   $t6,$t6,1               # advance pointer within string

    lbu     $t1,0($t5)              # get char from scan word
    addiu   $t5,$t5,1               # advance pointer within scan word

    bne     $t0,$t1,wordfail        # char mismatch? if yes, fly
    bne     $t1,$t4,wordloop        # at end of scan word? if no, loop

    addi    $t8,$t8,1               # increment match count

wordfail:
    addiu   $t7,$t7,1               # advance starting point within string
    lbu     $t0,0($t7)              # get next char in sentence
    
#make it point to the next beginning char 
#$t7 is the string pointer 
#should point it to the beginning of the next word
#if points to 'space'
	#point to the next char 
#if points to null
	#end it 
#else
	#advance till pointing to ' ' 
    beq $t0 $zero endOfSentence
    beq $t0 $t4 haveASpace 
    j wordfail
    #bnez    $t0,strloop             # end of sentence? if no, loop
    

 endOfSentence:  
    beqz    $t8,exit                # any match? if no, fly
    sw $t8 counter 
    
    #la $a0 counter 
    #lw $t0 0($a0)
    #move $a0 $t0 
    #li $v0 1 
    #syscall 
    #move $s0 $t8 #save the counter to $s0 
    #$t8 has the count!!
    #li      $v0,1                   # syscall to print integer
                   # print match count
    #syscall 
    
    #li      $v0,4                   # syscall to print string
    #la      $a0,found               # move found into a0
    #syscall
    j	printResult 

exit:
    li $s0 0  
    sw  $s0 counter 
    j printResult 

#endprogram:
    #j printResult 
#
     
    
haveASpace: 
    addi $t7 $t7 1 #now it points to the next word's first char 
    j strloop 
	

# rdstr -- read in and clean up string (convert '.' and newline to space)
#
# arguments:
#   a0 -- prompt string
#   a1 -- buffer length
#   a2 -- buffer address
#
# registers:
#   t0 -- current character
#   t1 -- newline char
#   t2 -- ascii period
#   t3 -- ascii space
rdstr:
 
    # get the string
    move    $a0,$a2                 # get buffer address
    
    li      $t1,0x0A                # get ascii newline
    li      $t2,0x2E                # get ascii dot
    li      $t3,0x20                # get ascii space

    # clean up the string so the matching will be easier/simpler
rdstr_loop:
    lbu     $t0,0($a0)              # get character
beq $t0 $zero rdstr_done 
    beq     $t0,$t1,rdstr_nl        # fly if char is newline
   # beq     $t0,$t2,rdstr_dot       # fly if char is '.'

rdstr_next:
    addiu   $a0,$a0,1               # advance to next character
    j       rdstr_loop

#rdstr_dot:
  #  sb      $t0,0($a0)              # replace dot with space
  #  j       rdstr_loop

rdstr_nl:
    sb      $t3,0($a0)              # replace newline with space

    j       rdstr_done              # comment this out to get debug print

    # debug print the cleaned up string
    

rdstr_done:
    jr      $ra                     # return

foundTheEnd: 
#$t0 is the address of the last null-termin. char 
li $t9 0x20 
subiu $a0 $a0 1 
sb $t9 0($a0) #now there's a space at the end of the input string 
#need to add a space at the end of the keyWrd 
j addSpace_key
 
 foundTheEnd_Key: 
 li $t9 0x20 
 subiu $a1 $a1 1 
 sb $t9 0($a1)
 j spaceAddedStartSearch
#######THIS IS WORKINGGGGGG 
		
quit:   li $v0 10 
	syscall 
############FINISHED COUNTING######################################
#########******##########*******################
###########**############*****#*****##****


#need to print: prompt1 + keyWrd + promt2 + counter + promt3
#s0 has the counter 
printResult: 
#remove that space that i added?
la $a0 keyWrd

#removeSpace_key:

 #lb $t0 0($a0) 
 #addiu $a0 $a0 1 
 #beq $t0 $zero reachedTheEnd_Key 
 #j removeSpace_key 
 
 
	#print the first prompt 
startsToPrint: 
	li $t2 0 #counter_index 
	
prompt1_loop:
	la $a0 occurrPromt_firstPrt 
	lb $s1 occurrPromt_firstPrt($t2) 
	beq $s1 $zero keyWrd_loop
	move $a0 $s1 
	
#write the string; via MMIO 
Write_prompt1:  lui $t0, 0xffff 	#ffff0000
prompt1_loop2: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,prompt1_loop2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j prompt1_loop 
#####################################
keyWrd_loop: #prints the keyWrd 
	li $t2 0 
keyWrd_loop1:
	la $a0 keyWrd 
	lb $s1 keyWrd($t2) 
	beq $s1 $zero prompt2_loop
	move $a0 $s1 
	
#write the string; via MMIO 
Write_keyWrd:  lui $t0, 0xffff 	#ffff0000
keyWrd_loop2: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,keyWrd_loop2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j keyWrd_loop1 
####################################
prompt2_loop: 
	li $t2 0 
prompt2_loop1:
	la $a0 occurrPromt_secondPrt 
	lb $s1 occurrPromt_secondPrt($t2) 
	beq $s1 $zero counter_loop
	move $a0 $s1 
	
#write the string; via MMIO 
Write_prompt2:  lui $t0, 0xffff 	#ffff0000
prompt2_loop2: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,prompt2_loop2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j prompt2_loop1  
##############################
#QUESTIONS: SPACE AFTER EACH AND EVERY CHAR ????? 
#PRINTING/OUTPUTING COUNTER(STORED IN A BUFFER)
counter_loop: 
	la $a0 counter 
	lb $t0 0($a0) #now t0 should have the counter in it =-= 
	#move $a0 $t0 
	#li $v0 1 
	#syscall 
	
	addi $t1 $0 10 
	div $t0 $t1 
	mflo $2
	beq $t2 0 skip 
	addi $t2 $t2 48 
	addi $t3 $0 0 
	sb $t2 numbuffer($t3) 
	
	skip: 
	mfhi $t2 #get remainder 
	addi $t2 $t2 48 
	addi $t3 $t3 1 
	sb $t2 numbuffer($t3) #numbuffer has the nice, (ascii coded) number in it 
##
#la $a0 numbuffer 
#li $v0 4 
#syscall 
##
	li $t2 1
 #print the counter  #convert to ascii code 
counter_loop1:  
	la $a0 numbuffer 
	lb $s1 numbuffer($t2) 
	beq $s1 $zero prompt3_loop
	move $a0 $s1
Write_counter:  lui $t0, 0xffff 	#ffff0000
counter_Loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,counter_Loop2
	#printing the counter using syscall 
	sw $a0, 12($t0) 	#data	
	 addi $t2 $t2 1 
	j counter_loop1
	 
######################
prompt3_loop: 
	#print the first prompt 
	li $t2 0 #counter_index 
	
prompt3_loop1:
	la $a0 occurrPromt_thirdPrt 
	lb $s1 occurrPromt_thirdPrt($t2) 
	beq $s1 $zero finishedPrinting
	move $a0 $s1 
	
#write the string; via MMIO 
Write_prompt3:  lui $t0, 0xffff 	#ffff0000
prompt3_loop2: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,prompt3_loop2
	sw $a0, 12($t0) 	#data	

	addi $t2 $t2 1 
	j prompt3_loop1
 
   
 #press e to go back to the beginning of the program and clear buffer!!
 #press q to kill the program 
 finishedPrinting: 
 #first, print the last prompt 
 li $t2 0 #counter_index 
	
looplastPrompt:
	la $a0 lastPrompt 
	lb $s1 lastPrompt($t2) 
	beq $s1 $zero getUserInput 
	move $a0 $s1 
	
#write the string; via MMIO 
write_lastPrompt:  
	lui $t0, 0xffff 	#ffff0000
Loop2_lastPrompt: 	
	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2_lastPrompt
	sw $a0, 12($t0) 	#data	
	addi $t2 $t2 1 
	j looplastPrompt
	
getUserInput: 
#get the user to input 'e' or 'q' 
 

echo_getUserInput:	
	jal Read1_getUserInput		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	 
	#jal Write1_getUserInput
	j echo_getUserInput

Read1_getUserInput:  	
	lui $t0, 0xffff 	#ffff0000
Loop1_1_getUserInput:
	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1_1_getUserInput
	lw $v0, 4($t0) 		#data	
	#Check if the user hit return(\n) 
	li $t2 'e'
	 
	beq $v0 $t2 endInput_getUserInput_again
	li $t3 'q' 
	beq $v0 $t3 endInput_getUserInput_end
	#li $t4 0 #counter
	#else, save it!! 
	#la $a2 userInputChar
	#sb $v0 userInputChar($t4)
	#addi $t4 $t4 1 
	#jr $ra

  
	#lui $t0, 0xffff 	#ffff0000
 end: 
 li $v0 10 
 syscall 
 
endInput_getUserInput_again: 
 
la $a0, inputStr 
	jal clearBuffer
	la $a0, keyWrd
	jal clearBuffer
	la $a0, counter
	jal clearBuffer		
	la $a0, userInputChar
	jal clearBuffer	
	li $t0 0 
	li $t1 0 
	li $t2 0 
	li $t3 0 
	li $t4 0 
	li $t5 0 
	li $t6 0 
	li $t7 0 
	li $t8 0 
	li $t9 0 
	j main
	
clearBuffer: 
	#$a0 = buffer3
	#$v0 = buffer3, but emptied 
	li $t0, 0		#store value 
	add $t1, $t0, $t0	#counter
clearLoop: 
	beq $t1, 599, doneClear
	sb $t0, 0($a0)
	addi $a0, $a0, 1
	addi $t1, $t1, 1
	j clearLoop
doneClear: 
 
	jr $ra

finished: 
j main 

endInput_getUserInput_end: 
#kill the program 
 li $v0 10 
 syscall  






