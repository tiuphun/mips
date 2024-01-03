# Nguyen Tieu Phuong - 20210692
# Simulate the working of RAID 5, 3 disks, with parity. Assume each data block is 4 chars.
# Constraint: Input size must be 8x (x is an integer).
# Input: DCE.****ABCD1234HUSTHUST
#     Disk 1              Disk 2              Disk 3
#  ---------------     ---------------     ---------------
# |   DCE.        |   |   ****        |   [[6e, 69, 6f, 04]]
# |   ABCD        |   [[70, 70, 70, 70]]  |   1234        |
# [[00, 00, 00, 00]]  |   HUST        |   |   HUST        |
#  _______________     ---------------     ---------------

.data
Disk1:      .space      32
Disk2:      .space      32
Disk3:      .space      32
parity:     .space      32
hexChar:    .byte       '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
input:      .space      256
errMsg:     .asciiz     "Input string should have size as a multiple of 8. Please try again.\n"

diskHeader: .asciiz     "     Disk 1                 Disk 2                 Disk 3     \n"
border:     .asciiz     "----------------       ----------------       ----------------\n"
comma:      .asciiz     ","
leftPipe:   .asciiz     "|     "
midPipe:    .asciiz     "     |       "
leftBracket:.asciiz     "[[ "
rightBracket:.asciiz    "]]       "
newline:    .asciiz     "\n"

prompt:     .asciiz     "Try again?"

.text
            la      $s1, Disk1
            la      $s2, Disk2
            la      $s3, Disk3
            la      $a2, parity		
getInput:   li      $v0, 8
            la      $a0, input
            li      $a1, 200
            syscall
            move    $s0, $a0		# s0 chua dia chi xau moi nhap
            li      $v0, 4
            la      $a0, diskHeader
            syscall
            li      $v0, 4
            la      $a0, border
            syscall
	
#-----------------------kiem tra do dai co chia het cho 8 khong--------------------------
length:     addi    $t3, $zero, 0 	# t3 = length
	        addi    $t0, $zero, 0 	# t0 = index

check_char: add     $t1, $s0, $t0 	# t1 = address of string[i]
	        lb      $t2, 0($t1) 		# t2 = string[i]
	        nop
	        beq     $t2, 10, test_length 	# t2 = '\n' ket thuc xau
	        nop
	        addi    $t3, $t3, 1 	# length++
	        addi    $t0, $t0, 1	# index++
	        j       check_char
	        nop
test_length: move   $t5, $t3
	        and     $t1, $t3, 0x0000000f		# xoa het cac byte cua $t3 ve 0, chi giu lai byte cuoi
	        bne     $t1, 0, test1			# byte cuoi bang 0 hoac 8 thi so chia het cho 8
	        j       split1
test1:	    beq     $t1, 8, split1
	        j error1
error1:	    li      $v0, 4
	        la      $a0, errMsg
	        syscall
	        j       getInput

#---------------------------------------------------------------------------
# Calc parity
# param[in]
# return
#---------------------------------------------------------------------------
hex:        li      $t4, 7              # loop counter
hexLoop:    blt     $t4, $0, endHex
            sll     $s6, $t4, 2         # s6 = t4 * 4 = {28, 24, 20...}
            srlv    $a0, $t8, $s6       # a0 = t8 >> s6
            andi    $a0, $a0, 0x0000000f      # keep last byte of $a0
            la      $t7, hexChar
            add     $t7, $t7, $a0
            bgt     $t4, 1, continue
            lb      $a0, 0($t7)         # print hex[a0]
            li      $v0, 11
            syscall
continue:   addi    $t4, $t4, -1
            j       hexLoop
endHex:     jr      $ra			
				

#-----------------------------------RAID 5 SIMULATION----------------------------------------
# *******************************************************************************************

# FIRST TURN: DISK 1, 2 FOR DATA; DISK 3 FOR PARITY
#--------------------------------------------------
split1:     addi    $t0, $0, 0          # nb of byte will be printed
            addi    $t9, $0, 0
            addi    $t8, $0, 0
            la      $s1, Disk1
            la      $s2, Disk2
            la      $a2, parity
            la      $s0, input
print11:    li      $v0, 4
            la      $a0, leftPipe
            syscall
b11:        lb      $t1, ($s0)
            addi    $t3, $t3, -1
            sb      $t1, ($s1)          # t1 = addr of Disk1's byte
b21:        add     $s5, $s0, 4
            lb      $t2, ($s5)          # t2 = addr of Disk2's byte
            addi    $t3, $t3, -1
            sb      $t2, ($s2)
b31:        xor     $a3, $t1, $t2
            sw      $a3, ($a2)
            addi    $a2, $a2, 4
            addi    $t0, $t0, 1
            addi    $s0, $s0, 1
            addi    $s1, $s1, 1
            addi    $s2, $s2, 1
            bgt     $t0, 3, reset
            j       b11
reset:      la      $s1, Disk1
            la      $s2, Disk2
print12:    lb      $a0, ($s1)
            li      $v0, 11
            syscall
            addi    $t9, $t9, 1
            addi    $s1, $s1, 1
            bgt     $t9, 3, next11
            j       print12
next11:     li      $v0, 4
            la      $a0, midPipe
            syscall
            li      $v0, 4
            la      $a0, leftPipe
            syscall
print13:    lb      $a0, ($s2)
            li      $v0, 11
            syscall
            addi    $t8, $t8, 1
            addi    $s2, $s2, 1
            bgt     $t8, 3, next12
            j       print13
next12:     li      $v0, 4
            la      $a0, midPipe
            syscall
            li      $v0, 4
            la      $a0, leftBracket
            syscall
            la      $a2, parity
            addi    $t9, $0, 0
print14:    lb      $t8, ($a2)
            jal     hex
            li      $v0, 4
            la      $a0, comma
            syscall
            addi    $t9, $t9, 1
            addi    $a2, $a2, 4
            bgt     $t9, 2, end1        # 3 commas for a parity entry
            j       print14
end1:       lb      $t8, ($a2)
            jal		hex				
            li      $v0, 4
            la      $a0, rightBracket
            syscall
            li      $v0, 4
            la      $a0, newline
            syscall
            beq     $t3, 0, exit       

# SECOND TURN: DISK 1, 3 FOR DATA; DISK 2 FOR PARITY
#---------------------------------------------------
split2:     la      $a2, parity
            la      $s1, Disk1
            la      $s3, Disk3
            addi    $s0, $s0, 4
            addi    $t0, $0, 0
print21:    li      $v0, 4
            la      $a0, leftPipe
            syscall
b12:        lb      $t1, ($s0)
            addi    $t3, $t3, -1
            sb      $t1, ($s1)
b32:        add     $s5, $s0, 4
            lb      $t2, ($s5)
            addi    $t3, $t3, -1
            sb      $t2, ($s3)
b22:        xor     $a3, $t1, $t2
            sw      $a3, ($a2)
            addi    $a2, $a2, 4
            addi    $t0, $t0, 1
            addi    $s0, $s0, 1
            addi    $s1, $s1, 1
            addi    $s3, $s3, 1
            bgt     $t0, 3, reset2
            j       b12
reset2:	    la      $s1, Disk1
            la      $s3, Disk3
            addi    $t9, $0, 0
print22:    lb      $a0, ($s1)
            li      $v0, 11
            syscall
            addi    $t9, $t9, 1
            addi    $s1, $s1, 1
            bgt     $t9, 3, next21
            j print22
next21:	    li      $v0, 4
            la      $a0, midPipe
            syscall
            la      $a2, parity
            addi    $t9, $0, 0
            li      $v0, 4
            la      $a0, leftBracket
            syscall
print23:    lb      $t8, ($a2)
            jal     hex
            li      $v0, 4
            la      $a0, comma
            syscall
            addi    $t9, $t9, 1
            addi    $a2, $a2, 4
            bgt     $t9, 2, next22
            j       print23		
next22:	    lb      $t8, ($a2)
            jal     hex
            li      $v0, 4
            la      $a0, rightBracket
            syscall
            li      $v0, 4
            la      $a0, leftPipe
            syscall
            addi    $t8, $0, 0
print24:    lb      $a0, ($s3)
            li      $v0, 11
            syscall
            addi    $t8, $t8, 1
            addi    $s3, $s3, 1
            bgt     $t8, 3, end2
            j       print24
end2:	    li      $v0, 4
            la      $a0, midPipe
            syscall
            li      $v0, 4
            la      $a0, newline
            syscall
            beq     $t3, 0, exit
# THIRD TURN: DISK 2, 3 FOR DATA; DISK 1 FOR PARITY
#---------------------------------------------------
split3:	    la      $a2, parity
            la      $s2, Disk2
            la      $s3, Disk3
            addi    $s0, $s0, 4
            addi    $t0, $0, 0
print31:    li      $v0, 4
            la      $a0, rightBracket
            syscall
b23:	    lb      $t1, ($s0)
            addi    $t3, $t3, -1
            sb      $t1, ($s1)
b33:	    add     $s5, $s0, 4
            lb      $t2, ($s5)
            addi    $t3, $t3, -1
            sb      $t2, ($s3)
b13:	    xor     $a3, $t1, $t2
            sw      $a3, ($a2)
            addi    $a2, $a2, 4
            addi    $t0, $t0, 1
            addi    $s0, $s0, 1
            addi    $s1, $s1, 1
            addi    $s3, $s3, 1
            bgt     $t0, 3, reset3
            j       b23
reset3:	    la      $s2, Disk2
            la      $s3, Disk3
            la      $a2, parity
            addi    $t9, $0, 0
print32:    lb      $t8, ($a2)
            jal     hex
            li      $v0, 4
            la      $a0, comma
            syscall
            addi    $t9, $t9, 1
            addi    $a2, $a2, 4
            bgt     $t9, 2, next31
            j       print32		
next31:	    lb      $t8, ($a2)
            jal     hex
            li      $v0, 4
            la      $a0, rightBracket
            syscall
            li      $v0, 4
            la      $a0, leftPipe
            syscall
            addi    $t9, $0, 0
print33:    lb      $a0, ($s2)
            li      $v0, 11
            syscall
            addi    $t9, $t9, 1
            addi    $s2, $s2, 1
            bgt     $t9, 3, next32
            j       print33
next32:	    addi    $t9, $0, 0
            addi    $t8, $0, 0
            li      $v0, 4
            la      $a0, midPipe
            syscall	
            li      $v0, 4
            la      $a0, leftPipe
            syscall	
print34:    lb      $a0, ($s3)
            li      $v0, 11
            syscall
            addi    $t8, $t8, 1
            addi    $s3, $s3, 1
            bgt     $t8, 3, end3
            j       print34
end3:	    li      $v0, 4
            la      $a0, midPipe
            syscall
            li      $v0, 4
            la      $a0, newline
            syscall
            beq     $t3, 0, exit
#-------------------------------------END OF TURN----------------------------------------
nextLoop:   addi    $s0, $s0, 4
            j       split1
exit:       li      $v0, 4
            la      $a0, border
            syscall
            j       ask
#**************************************************************************************
#-------------------------------------TRY AGAIN?----------------------------------------
ask:	    li      $v0, 50
            la      $a0, prompt
            syscall
            beq     $a0, 0, clear
            nop
            j       terminate
            nop
clear:	    la      $s0, input      # clear the input 
            add     $s3, $s0, $t5	# s3: dia chi byte cuoi cung duoc su dung trong string
            li      $t1, 0
again:      sb      $t1, ($s0)		# set byte o dia chi s0 thanh 0
            nop
            addi    $s0, $s0, 1
            bge     $s0, $s3, getInput
            nop
            j       again
            nop

#---------------------------------END OF PROGRAM------------------------------------------            
terminate:  li      $v0, 10
            syscall
