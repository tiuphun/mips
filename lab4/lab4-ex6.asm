# Laboratory Exercise 4, Assignment 6: Find the element with largest abs value
.data
    array:      .word       3, 0, -23, 10, 44, -95      # a list of integers
    n:          .word       6                           # (given) nb. of elements in array
    max:        .word       0                           # max absolute value
    i:			.word		0							# indexes
    step: 		.word		1							# step increment	

.text
    # load variables to registers
	la		$t6, n
	lw		$s3, 0($t6)
	la		$t7, i
	lw		$s1, 0($t7)
	la		$t8, step
    lw		$s4, 0($t8)
    la      $t9, max
    lw      $s5, 0($t9)
	la		$s2, array

loop:
    # load value of A[i]
    add     $s1, $s1, $s4       	# i = i + step
    add     $t1, $s1, $s1       	# t1 = 2*s1
    add     $t1, $t1, $t1       	# t1 = 4*s1
    add     $t1, $t1, $s2      		# t1 store the address of A[i]
    lw      $t0, 0($t1)        	 	# load value of A[i] in $t0

    # compare absolute values
    abs   $t2, $t1                # set t2 = abs(A[i])

    start:
        slt     $t3, $s5, $t2       # A[i] > max ? t3 = 1 : t3 = 0
        beq     $t3, $0, continue   # if A[i] < max, continue
        add     $s5, $0, $t2        # set MAX = current element abs value
    continue:
        bne     $s1, $s3, loop		# if i != n, goto loop
