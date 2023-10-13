# Laboratory Exercise 4, Assignment 4d
.data
I:		.word		7
J:		.word		1
M:      .word       10
N:      .word       -3
.text
	# assign I, J, M, N
	la 	    $t8, I
	la 	    $t9, J
    la      $t6, M 
    la      $t7, N
	lw		$s1, 0($t8)         # I = s1
	lw		$s2, 0($t9)         # J = s2
    lw      $s3, 0($t6)         # M = s3
    lw      $s4, 0($t7)         # N = s4
    
	# conditional
start:
    add     $s5, $s1, $s2       # sum (s5) = I + J
    add     $s6, $s3, $s4       # sum (s6) = M + N
    slt     $t4, $s6, $s5       # I + J > M + N ? t4 = 1 : t4 = 0
    bne     $t4, $0, else       # branch if I + J > M + N
    addi    $t1, $t1, 1         # then part: x = x+1
    addi    $t3, $zero, 1       # z = 1
    j       endif               # skip "else" part
else:
    addi    $t2, $t2, -1        # begin else part: y = y - 1
    add     $t3, $t3, $t3       # z = 2*z 
endif: