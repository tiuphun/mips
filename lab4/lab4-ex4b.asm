# Laboratory Exercise 4, Assignment 4b
.data
I:		.word		7
J:		.word		1
.text
	# assign I, J
	la 	    $t8, I
	la 	    $t9, J
	lw		$s1, 0($t8)         # I = s1
	lw		$s2, 0($t9)         # J = s2
	
	# conditional
start:
    slt     $t0, $s1, $s2       # i >= j ? t0 = 0 : t0 = 1
                                # i < j ? t0 = 1 : t0 = 0
    bne     $t0, $0, else       # branch to else if i < j
    addi    $t1, $t1, 1         # then part: x = x+1
    addi    $t3, $zero, 1       # z = 1
    j       endif               # skip "else" part
else:
    addi    $t2, $t2, -1        # begin else part: y = y - 1
    add     $t3, $t3, $t3       # z = 2*z 
endif:
