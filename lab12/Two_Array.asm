.data

A: .space 1000
B: .space 1000

.text
     la    $a0, A
     la    $a1, B     
     addi  $t0, $zero, 0
     addi  $s0, $zero, 0
     addi  $k0, $zero, 250
LOOP: 	lw    $t1, 0($a0)
     	sw    $t0, 0($a0)
     	
     	lw    $t1, 0($a1)
     	sw    $t0, 0($a1)
     	     	
     	addi  $t0, $t0,1
     	addi  $s0, $s0,1
     	addi  $a0, $a0, 4
     	addi  $a1, $a1, 4     	
	beq   $t0, $k0, END_LOOP
	j     LOOP
END_LOOP: nop	
     
