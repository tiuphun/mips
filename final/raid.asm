# Nguyen Tieu Phuong - 20210692
# Simulate the working of RAID 5, 3 disks, with parity. Assume each data block is 4 chars.
# Constrraint: Input size must be 8x (x is an integer).
# Input: DCE.****ABCD1234HUSTHUST
#     Disk 1              Disk 2              Disk 3
#  ---------------     ---------------     ---------------
# |   DCE.        |   |   ****        |   [[6e, 69, 6f, 04]]
# |   ABCD        |   [[70, 70, 70, 70]]  |   1234        |
# [[00, 00, 00, 00]]  |   HUST        |   |   HUST        |
#  _______________     ---------------     ---------------

.data
Disk1:      .byte       0, 0, 0, 0
Disk2:      .byte       0, 0, 0, 0
Disk3:      .byte       0, 0, 0, 0

input:      .space      256
errMsg:     .asciiz     "Input string should have size as a multiple of 8. Please try again.\n"
counter:	.word		1

diskHeader: .asciiz     "Disk 1 \t\t\tDisk 2 \t\t\tDisk 3\n"
border:     .asciiz     "---------------\t\t---------------\t\t---------------\n"
newline:    .asciiz     "\n"
tab:        .asciiz     "\t\t"

.text
#---------------------------------------------------------------------------
# Get user input
# param[in]
# return
#---------------------------------------------------------------------------
readInput:  li      $v0, 8
            la      $a0, input
            li      $a1, 256
            syscall

            la      $a0, input
            jal     strlen
            remu    $a1, $v0, 8
            bnez    $a1, invalidInput
            j       disk
invalidInput: li    $v0, 4
            la      $a0, errMsg
            syscall
            j       readInput
strlen:     move    $t0, $a0            # load string addr
            li      $t1, 0              # init counter
strlenLoop: lb      $t2, 0($t0)
            beqz    $t2, strlenEnd      # byte = 0 => end of string
            addiu   $t0, $t0, 1         # goto next byte
            addiu   $t1, $t1, 1         # increment the counter
            j       strlenLoop
strlenEnd:  addiu   $t1, $t1, -1        # exclude the count for null terminator 
            move    $v0, $t1            # return length of str
            jr		$ra				

#---------------------------------------------------------------------------
# Disk turn
# param[in]
# return
#---------------------------------------------------------------------------
disk:       lw      $t0, counter
            beq     $t0, 1, parityD3
            beq     $t0, 2, parityD2
            beq     $t0, 3, parityD1

# Use Disk3 for parity and Disk1 and Disk2 for data
parityD3:   la      $t1, Disk1          
            la      $t2, Disk2
            la      $t3, Disk3          
            jal     calcParity
            j       nextTurn
# Use Disk2 for parity and Disk1 and Disk3 for data
parityD2:   la      $t1, Disk1          
            la      $t2, Disk3
            la      $t3, Disk2          
            jal     calcParity
            j       nextTurn
# Use Disk1 for parity and Disk2 and Disk3 for data
parityD1:   la      $t1, Disk2          
            la      $t2, Disk3
            la      $t3, Disk1          
            jal     calcParity
            j       nextTurn
nextTurn:   addiu   $t0, $t0, 1
            sw      $t0, counter
            li      $t1, 4                  # if counter > 3, reset
            bgt     $t0, $t1, resetTurn
            j       printDisk
resetTurn:  li      $t0, 1
            sw      $t0, counter
            j       printDisk

#---------------------------------------------------------------------------
# Calculate parity
# param[in]     $t1     first data disk
#               $t2     second data disk
#               $t3     parity disk
# return        $
#---------------------------------------------------------------------------
calcParity:     li      $t0, 0                  # init the parity byte
                li      $t4, 4                  # nb of byte in each disk
calcParityLoop: lb      $t6, 0($t1)
                lb      $t7, 0($t2)
                xor     $t0, $t0, $t6
                xor     $t0, $t0, $t7
                sb      $t0, 0($t3)             # store the parity byte
                addiu   $t1, $t1, 1             # go to next byte
                addiu   $t2, $t2, 1
                addiu   $t3, $t3, 1 
                addiu   $t4, $t4, -1            # decrease byte counter
                bnez    $t4, calcParityLoop     # not done with all 4 bytes? repeat
                jr		$ra					


#---------------------------------------------------------------------------
# Output results
# param[in]
# return
#---------------------------------------------------------------------------

printDisk:  li      $v0, 4                      # print the table header
            la      $a0, diskHeader
            syscall
            li      $v0, 4                      # print the border
            la      $a0, border
            syscall
            la      $t1, Disk1
            la      $t2, Disk2
            la      $t3, Disk3
            li      $t4, 3
printLoop:  lb      $t6, 0($t1)                 # check if there is any data left (in disk1, since data is multiple of 8)
            beqz    $t6, printDone              
            li      $t5, 4                      # print 4 bytes from current disk
printByte:  lb      $a0, 0($t1)
            li      $v0, 1
            syscall
            addiu   $t1, $t1, 1
            addiu   $t5, $t5, -1
            bnez    $t5, printByte
            la      $a0, newline
            syscall

            addiu   $t4, $t4, -1
            beqz    $t4, printDone
            move    $t1, $t2
            move    $t2, $t3
            j       printLoop
printDone:  li      $v0, 10
            syscall


#---------------------------------------------------------------------------
# Loading data to disks
# param[in]
# return
#---------------------------------------------------------------------------

disk:       la      $t1, input           # Load address of input into $t1
            li      $t9, 0               # a counter for turn
diskLoop:   rem     $s0, $t9, 3          # Calculate $t9 mod 3
            beq     $s0, 0, routine0     # If remainder is 0, go to routine0
            beq     $s0, 1, routine1     # If remainder is 1, go to routine1
            beq     $s0, 2, routine2     # If remainder is 2, go to routine2
routine0:   la      $t2, Disk1           
            la      $t3, Disk2           
            la      $t4, Disk3  
            jal     loadDisks
            j       loadParity
routine1:   la      $t2, Disk1           
            la      $t3, Disk3           
            la      $t4, Disk2   
            jal       loadDisks 
            j       loadParity       
routine2:   la      $t2, Disk2           
            la      $t3, Disk3           
            la      $t4, Disk1 
            jal       loadDisks
            j       loadParity          
           
loadDisks:  
    li      $t5, 4               # Load 4 into $t5
loadLoop1:  
    lb      $t0, 0($t1)          # Load byte from input into $t0
    beqz    $t0, endLoad         # If byte is zero, end load
    sb      $t0, 0($t2)          # Store byte in the first data disk
    addiu   $t1, $t1, 1          # Increment input address by 1
    addiu   $t2, $t2, 1          # Increment Disk1 address by 1
    addiu   $t5, $t5, -1         # Decrement $t5 by 1
    bnez    $t5, loadLoop1       # If $t5 is not zero, continue load
endLoad1:  
    li      $t5, 4               # Load 4 into $t5
loadLoop2:  
    lb      $t0, 0($t1)          # Load byte from input into $t0
    beqz    $t0, endLoad         # If byte is zero, end load
    sb      $t0, 0($t3)          # Store byte in the second data disk
    addiu   $t1, $t1, 1          # Increment input address by 1
    addiu   $t3, $t3, 1          # Increment Disk2 address by 1
    addiu   $t5, $t5, -1         # Decrement $t5 by 1
    bnez    $t5, loadLoop2       # If $t5 is not zero, continue load
endLoad2:  
    jr      $ra

loadParity:    
    li      $t5, 4               # Load 4 into $t5
loadParityLoop:
    lb      $t6, 0($t2)          # Load byte from Disk1 into $t6
    lb      $t7, 0($t3)          # Load byte from Disk2 into $t7
    xor     $t8, $t6, $t7        # XOR bytes from Disk1 and Disk2
    sb      $t8, 0($t4)          # Store parity in Disk3
    addiu   $t2, $t2, 1          # Increment Disk1 address by 1
    addiu   $t3, $t3, 1          # Increment Disk2 address by 1
    addiu   $t4, $t4, 1          # Increment Disk3 address by 1
    addiu   $t5, $t5, -1         # Decrement $t5 by 1
    bnez    $t5, loadParityLoop      # If $t5 is not zero, continue load
updateCounter:
    addiu   $t9, $t9, 1          # Increment the counter by 1
    j       diskLoop             # Go back to the start of the loop

endLoad:

#---------------------------------------------------------------------------
# Printing data from disks
# param[in]
# return
#---------------------------------------------------------------------------

printDisks: 
    la      $t2, Disk1           
    la      $t3, Disk2           
    la      $t4, Disk3           
    li      $t5, 4               # Load 4 into $t5
printLoop1:  
    lb      $t0, 0($t2)          # Load byte from Disk1 into $t0
    beqz    $t0, endPrint1       # If byte is zero, end print
    move    $a0, $t0             # Move byte to $a0
    li      $v0, 1               # Load syscall number for print integer
    syscall                      # Print integer
    addiu   $t2, $t2, 1          # Increment Disk1 address by 1
    addiu   $t5, $t5, -1         # Decrement $t5 by 1
    bnez    $t5, printLoop1      # If $t5 is not zero, continue print
endPrint1:  
    li      $t5, 4               # Load 4 into $t5
printLoop2:  
    lb      $t0, 0($t3)          # Load byte from Disk2 into $t0
    beqz    $t0, endPrint2       # If byte is zero, end print
    move    $a0, $t0             # Move byte to $a0
    li      $v0, 1               # Load syscall number for print integer
    syscall                      # Print integer
    addiu   $t3, $t3, 1          # Increment Disk2 address by 1
    addiu   $t5, $t5, -1         # Decrement $t5 by 1
    bnez    $t5, printLoop2      # If $t5 is not zero, continue print
endPrint2:  
    lb      $t0, 0($t4)          # Load byte from Disk3 into $t0
    move    $a0, $t0             # Move byte to $a0
    li      $v0, 1               # Load syscall number for print integer
    syscall                      # Print integer
    jr      $ra                  # Return from subroutine