# Laboratory Exercise 5, Assignment 2
.data
A:		.word		21
B:		.word		10
sum:	.word		0
str1: 	.asciiz 	"The sum of "
str2:	.asciiz		" and "
str3:	.asciiz 	" is "

.text	
	lw		$s1, A
	la		$t1, 0($s1)
	lw		$s2, B
	la		$t2, 0($s2)
	add		$t3, $t1, $t2	# sum = a + b
	
	# print "The sum of "
    li 		$v0, 4
    la 		$a0, str1
    syscall 				
    
    # print A
    move    $a0, $t1
    li		$v0, 1
    syscall					
    
    # print " and "
    li 		$v0, 4
    la		$a0, str2
    syscall					
    
    # print B
    move    $a0, $t2
    li		$v0, 1
    syscall					
    
    # print " is "
    li 		$v0, 4
    la		$a0, str3
    syscall					
    
    # print the sum
    move	$a0, $t3
    li		$v0, 1
    syscall					
    
    # exit
    li $v0, 10
    syscall
