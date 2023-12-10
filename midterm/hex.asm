.data
prompt: .asciiz "Enter a decimal integer: "
result: .asciiz "The hex value is: "

.text
.globl main

main:
    # Print prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Read decimal integer from user
    li $v0, 5
    syscall
    move $t0, $v0  # Store user input in $t0

    # Convert decimal to hex
    li $t1, 28  # Set counter to 28 (number of bits in a decimal integer)
    li $t2, 0x0F  # Set mask to 0x0F (to extract the lower 4 bits)

convert_loop:
    srlv $t3, $t0, $t1  # Shift user input right by counter bits
    and $t3, $t3, $t2  # Mask the lower 4 bits

    # Convert remainder to hex digit
    addi $t3, $t3, 48  # Convert to ASCII digit
    blt $t3, 58, skip  # Skip if digit is less than '9'
    addi $t3, $t3, 7  # Adjust for letters 'A' to 'F'

    skip:
    continue:
    # Print hex digit
    li $v0, 11
    move $a0, $t3
    syscall

    subi $t1, $t1, 4  # Decrement counter by 4 bits
	addi	$t9, $0, -4
    # Check if counter is -4
    bne $t1, $t9, convert_loop

done:
    # Print result message
    li $v0, 4
    la $a0, result
    syscall

    # Exit program
    li $v0, 10
    syscall
