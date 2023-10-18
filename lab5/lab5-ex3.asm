# Laboratory Exercise 5, Home Assignment 2
.data
x: 	.space 		1000					# destination string x, empty
y:	.asciiz		"Hello"					# src string y

.text
strcpy:
	add 	$s0, $0, $0					# s0 = i = 0
loop:
	la		$a0, x						# a0: address of x[0]
	la		$a1, y						# a1: address of y[0]
	add 	$t1, $s0, $a1				# t1	= s0 + a1 = i + y[0]
										#		= address of y[i]
	lb		$t2, 0($t1)					# t2 	= value at t1 = y[i]
	add 	$t3, $s0, $a0				# t3	= s0 + a0 = i + x[0]
										#		= address of x[i]
	sb		$t2, 0($t3)					# x[i] 	= t2 = y[i], copy the char y -> i
	beq		$t2, $0, end_of_strcpy		# if y[i] == 0, exit
	nop
	addi	$s0, $s0, 1					# s0 = s0 + 1 <-> i = i + 1
	j		loop						# next character
	nop
end_of_strcpy:
print:
	li 		$v0, 4
    la 		$a0, x						# print out x to check
    syscall 