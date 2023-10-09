# Laboratory Exercise 3, Assignment 4
.data
A: 	.word	1000000000000000000
B: 	.word 	999999999999999999
.text
start:
    li      $t0, 0              # No overflow is default status
    addu    $s3, $s1, $s2       # s3 = s1 + s2
    xor     $t1, $s1, $s2       # Test if $s1 and $s2 have the same sign

    bltz    $t1, EXIT           # If not, exit 
    xor     $t2, $s3, $s1       # Check if $s3 and $s1 have the same sign
    bltz    $t2, EXIT       	# If yes (t2 positive), no overflow
    j       OVERFLOW 		    # If no, overflow
OVERFLOW:
    li      $t0, 1              # the result is overflow
EXIT: