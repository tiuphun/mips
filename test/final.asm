# Nguyen Tieu Phuong (20210692) - Ex10
# Write a program that gets an integer i from the user and creates the table shown below on the screen (example inputs provided). Subroutines are required for power, square, and hexadecimal (in 32 bit arithemtic, attend to overflowed results). Hint: Hexadecimal can be done with shifts and masks because the size is 32 bits.
# i       power(2,i)      square(i)       Hexadecimal(i) 
# 10      1024            100             0xA
# 7       128             49              0x7
# 16      65536           256             0x10

.data
    prompt:     .asciiz         "\nEnter an integer:"
    header:     .asciiz         "\ni\t\tpower(2,i)\tsquare(i)\thex(i)\n"
    tab:        .asciiz         "\t\t"
    error:      .asciiz         "OVF\t\t"
    input_err:  .asciiz         "\nInvalid input"
.text
.globl      main
main:
    # Print the prompt
    li          $v0, 4
    la          $a0, prompt
    syscall

    # Read the user input
    li          $v0, 5
    syscall
    move        $s0, $v0        
    
    # Check for valid input
    blez        $s0, exit
    nop
    proceed:
        # Print the table header
        li          $v0, 4
        la          $a0, header
        syscall

        # Call the subroutine
        jal         print_table

print_table:
    # Print i
    li          $v0, 1
    move        $a0, $s0
    syscall
    li          $v0, 4
    la          $a0, tab
    syscall

    # pow(2,i)
    li      $t0, 30                 # The maximum possible input value for pow (2^30 = 1073741824 < 2^31-1)
    bgt     $s0, $t0, overflow_pow  # If the input is greater than $t0, the result will overflow
    nop
    jal     pow                     # Else goto pow
    j       print_pow
    overflow_pow:
        li      $v0, 4
        la      $a0, error
        syscall
        j       end_pow
    print_pow:
        li          $v0, 1
        move        $a0, $s1
        syscall
        li          $v0, 4
        la          $a0, tab
        syscall
    end_pow:
    

    # square(i)
    li      $t0, 46340              # The maximum possible input value for square (sqrt of max int: 2^31-1)
    bgt     $s0, $t0, overflow_sq   # If the input is greater than $t0, the result will overflow
    nop
    jal     square                  # else goto square
    j		print_sq				
    overflow_sq:
        li      $v0, 4
        la      $a0, error
        syscall
        j       end_sq
    print_sq:
        li          $v0, 1
        move        $a0, $s2
        syscall
        li          $v0, 4
        la          $a0, tab
        syscall
    end_sq:

    # hex(i)
    jal         hex
    
finish:
    li          $v0, 10
    syscall

# ------------------------------------------------------------------------------
# Procedure pow
# @brief              raise 2 to the power of i
# @param[in]          s0              the power that 2 will be raised into 
# @param[out]         s1              2^i
# ------------------------------------------------------------------------------
pow:
    li	        $s1, 1			    # init $s1, 2^0 = 1
    li          $t1, 0              # increment counter
    pow_loop:
        sll		$s1, $s1, 1			# multiply i by 2
        j		test                # done? check condition
    test:
        addi    $t1, $t1, 1         # advance the index j
        slt		$t2, $t1, $s0		# set $t2 to 1 if j < i
        bne     $t2, $0, pow_loop   # repeat if j < i
    end_pow_loop:
        jr      $ra

# ------------------------------------------------------------------------------
# Procedure square
# @brief              return i*i
# @param[in]          s0              the number i
# @param[out]         s2              the result i*i
# ------------------------------------------------------------------------------ 
square:
    # Calculate square(i)
    mul     $s2, $s0, $s0
    jr      $ra

# ------------------------------------------------------------------------------
# Procedure hex
# @brief              print i in hexadecimal, digit by digit
# @param[in]          s0              the number i
# @param[out]         s3              the hexadecimal value of i
# ------------------------------------------------------------------------------
hex:
    # Convert decimal to hex
        li      $t1, 28             # set counter to 28 (number of bits in a decimal integer)
        li      $t2, 0x0F           # set mask to 0x0F (to extract the lower 4 bits)
    convert_loop:
        srlv    $t3, $s0, $t1       # shift user input right by counter bits
        and     $t3, $t3, $t2       # mask the lower 4 bits

        # Convert remainder to hex digit
        addi    $t3, $t3, 48        # convert to ASCII digit by add '0' 
        blt     $t3, 58, skip       # skip if digit is less than '9'
        addi    $t3, $t3, 7         # adjust for letters 'A' to 'F'
    skip:
    continue:
        # Print hex digit
        li 		$v0, 11
        move 	$a0, $t3
        syscall
        subi    $t1, $t1, 4         # Decrement counter by 4 bits
        addi	$t9, $0, -4
        bne     $t1, $t9, convert_loop  # Check if counter is -4 (done)
    done:
        jr      $ra

exit:
        li          $v0, 4
        la          $a0, input_err
        syscall
        li      $v0, 10
        syscall
