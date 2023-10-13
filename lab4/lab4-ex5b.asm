# Laboratory Exercise 4, Assignment 5b
.data
n:			.word 		6							# nb. of loop steps
i:			.word		0							# indexes
step: 		.word		1							# step increment	
sum: 		.word 		0							# sum of array elements
array: 		.word		2, 3, 5, 8, 12, 20			# array

.text
# load variables to registers
	la			$t6, n
	lw			$s3, 0($t6)
	la			$t7, i
	lw			$s1, 0($t7)
	la			$t8, step
	lw			$s4, 0($t8)
	la			$t9, sum
	lw 			$s5, 0($t9)
	la			$s2, array
# the loop
loop:
    add     $s1, $s1, $s4       	# i = i + step
    add     $t1, $s1, $s1       	# t1 = 2*s1
    add     $t1, $t1, $t1       	# t1 = 4*s1
    add     $t1, $t1, $s2      		# t1 store the address of A[i]
    lw      $t0, 0($t1)        	 	# load value of A[i] in $t0
    add     $s5, $s5, $t0       	# sum = sum + A[i]
    slt     $t5, $s3, $s1           # i > n ? t5 = 1 : t5 = 0
    beq     $t5, $0, loop			# if i <= n, goto loop
    