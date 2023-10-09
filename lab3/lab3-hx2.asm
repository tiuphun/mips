# Laboratory Exercise 3, Home Assignment 2
.text
    	li      $s0, 0x0563         	# set a value for $s0
    	andi    $t0, $s0, 0xff      	# extract the LSB of $s0
    	andi    $t1, $s0, 0x0400    	# extract bit 10 of $s0
    	
    	#1. EXTRACT MSB OF S0
    	andi 	$t2, $s0, 0xFF000000  	# Perform bitwise AND between $s0 and the mask
	    srl 	$t2, $t2, 24          	# Shift the result 24 bits to the right to obtain the MSB

    	#2. CLEAR LSB OF S0
    	andi $s0, $s0, 0xFFFFFF00  	# Perform bitwise AND between $s0 and the mask
    	
    	#3. SET LSB OF S0
    	ori $s0, $s0, 0x00000001  	# Perform bitwise OR between $s0 and the mask

    	#4. CLEAR S0
    	li	$s0, 0			# clear $s0