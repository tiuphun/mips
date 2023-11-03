# Nguyen Tieu Phuong (20210692) - Ex10
# Write a program that gets an integer i from the user and creates the table shown below on the screen (example inputs provided). Subroutines are required for power, square, and hexadecimal (in 32 bit arithemtic, attend to overflowed results). Hint: Hexadecimal can be done with shifts and masks because the size is 32 bits.
# i       power(2,i)      square(i)       Hexadecimal(i) 
# 10      1024            100             0xA
# 7       128             49              0x7
# 16      65536           256             0x10
-----------------------------------------------------------------------------------
$s0 -> i                        $t1 -> index (pow)              $t5 -> shift_amount
$s1 -> pow                      $t2 -> flag (pow)               $t6 -> shifted i
$s2 -> square                   $t3 -> total loops (hex)        $t7 -> mask
$s3 -> hex                      $t4 -> index (hex)              
$s4 -> extracted 4-bit group
-----------------------------------------------------------------------------------

.data
Message:    .asciiz     "Enter an integer:"
.text
# first print the table title

while:
    bne		    $a1, $0, end	    # if $a1 != $0 (status != OK) then goto end
    li          $v0, 51             # get user input (i) -> $a0
    la		    $a0, Message
    syscall                     
    move 	    $a0, $s0		    # $a0 = $s0
    jal			pow			        # jump to pow and save position to $ra
    jal         square
    jal         hex
    # print line by line

end:

# ------------------------------------------------------------------------------
# Procedure pow
# @brief              raise 2 to the power of i
# @param[in]          s0              the power that 2 will be raised into 
# @param[out]         s1              2^i
# ------------------------------------------------------------------------------
pow:
    addi	    $s1, $0, 1			# init $s1, 2^0 = 1
    addi        $t1, $0, 0          # increment counter
    pow_loop:
        sll		$s1, $s1, 1			# multiply i by 2
        j		test                # done? check condition
    end_pow_loop:
        jr      $ra

test:
    addi        $s1, $t1, 1         # advance the index j
    slt		    $t2, $t1, $s0		# set $s2 to 1 if j < i
    bne         $t2, $0, pow_loop   # repeat if j < i

# ------------------------------------------------------------------------------
# Procedure square
# @brief              return i*i
# @param[in]          s0              the number i
# @param[out]         s2              the result i*i
# ------------------------------------------------------------------------------ 
square:
    mul         $s2, $s0, $s0
    jr	        $ra

# ------------------------------------------------------------------------------
# Procedure hex
# @brief              return i in hexadecimal
# @param[in]          s0              the number i
# @param[out]         s3              the hexadecimal value of i
# ------------------------------------------------------------------------------
hex:
    addi        $s3, $0, 8          # number of digits (total loops needed)
    addi        $t4, $0, 0          # current digit index
    hex_loop:
        addi    $t9, $0, 7          # load subtractor 7
        sub 	$t5, $t9, $t4       # subtract current digit from 7 to reverse digit order
        sll     $t5, $t5, 4         # convert digit index -> bit index
        srlv	$t6, $s0, $t5       # shift i by the amount
        
        addi    $t7, $0, 0xF        # load the mask
        andi    $s4, $t7, $t6       # perform bitwise AND

        addi    $t8, $0, 10         # load 10 for comparison
        blt     $s4, $t8, less_than_10
        subi    $s4, $s4, 10        # subtract 10 
        addi    $s4, $s4, 65        # add 'A' (65) to get a character between 'A' and 'F'
        j		store_char		    # jump to store_char
    less_than_10:
        addi	$s4, $s4, 48		# add '0' (48) to get a character between '0' and '9'
    store_char:
        add     $t9, 
        sb      $s
    end_hex_loop:
        jr		$ra					# end
check:
    addi        $t4, $t4, 1         # advance index k
    slt         $t5, $t4, $s3       # set $t5 to 1 if k < 8
    bne         $t5, $0, hex_loop   # repeat if k < 8, not done yet