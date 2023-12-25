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