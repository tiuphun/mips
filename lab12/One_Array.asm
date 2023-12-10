.data

A: .space 1000

.text
     la    $a0, A
     addi  $t0, $zero, 0
     addi  $s0, $zero, 0
     addi  $k0, $zero, 250
LOOP: 	lw    $t1, 0($a0)
     	sw    $t0, 0($a0)
     	addi  $t0, $t0,1
     	addi  $s0, $s0,1
     	addi  $a0, $a0, 4
	beq   $t0, $k0, END_LOOP
	j     LOOP
END_LOOP: nop	
     
