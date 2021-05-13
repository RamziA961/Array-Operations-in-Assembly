#Ramzi Abou Chahine -- Final Project

.eqv PRINT_INT 1
.eqv PRINT_STRING 4
.eqv PRINT_CHAR 11
.eqv INPUT_INT 5
.eqv SYS_EXIT 10

.data

# the array that would hold stack elements
arr: .word 0:100
size: .word 0
	
endl:		.asciiz  "\n" 
space:		.asciiz  " "
label_arr:	.asciiz  "Current elements: "
label_inst:	.asciiz  "Enter 1 to push, 2 to pop, 3 to find max, 4 to rotate, 0 to exit\n"
label_invalid:	.asciiz  "Invalid option \n"
label_empty:	.asciiz  "Array is empty \n"
label_max:	.asciiz  "Max is: "

.text														
main:
	la $s0, arr 		#load start address of array in $s0
	lw $s1, size		#initialize array size to -1
	addi $s1, $s1, -1
	j programLoop		#begin program loop			


programLoop:
	li $v0, PRINT_STRING	
	la $a0, label_inst 	#print program instructions
	syscall
	
	li $v0, INPUT_INT	#prompt user for input
	syscall
	
	move $a0, $v0 		#pass input int to upcoming function call
	jal determine_operation #jump to function that tests input
	beq $zero, $zero programLoop		
		
		
determine_operation:
	sw $ra, ($sp)		#store return address to main in stack
	addi $sp, $sp, -4 	#increment stack pointer address
	
	beq $a0, 1, push	#check operation to determine appropriate branch
	beq $a0, 2 , pop
	beq $a0, 3 , max
	beq $a0, 4 , rotate
	beq $a0, 0 , exit
	j operation_error

			
exit:
	li $v0, SYS_EXIT
	syscall
	

print_arr:
	beq $s1, -1, print_arr_error 	#if array is empty branch off
	add $s0, $s0, -4		#decrement to last filled slot in array
	
	li $v0, PRINT_STRING		#load print string sys call
	la $a0, label_arr		#load string
	syscall
	
	move $t0, $s1			#move size to temp register	
	li $t1, 4			#load int 4 into temp register
	mult  $t0, $t1			#multiply size of array by 4 to subtract from array pointer
	mflo $t0			#move result of multiplication back to t0
	sub $s0, $s0, $t0		#subtract product from array pointer 
	
	li $s2, -1			#counter for loop
	j print_arr_loop		#start loop to traverse array
	
	
print_arr_error:
	li $v0, PRINT_STRING
	la $a0, label_empty 	#notify user that array is empty
	syscall
	j return_to_address

print_arr_loop:
	li $v0, PRINT_INT 	#load print int system call
	lw $a0, ($s0)		#load value from array to arg register
	syscall			#print
	
	li $v0, PRINT_STRING	#load print string sys call
	la $a0, space		#load space char
	syscall
	
	addi $s0, $s0, 4 	#traverse array by incrementing array pointer
	addi $s2, $s2, 1	#increment counter
	bne $s1, $s2, print_arr_loop 	#loop
	

	li $v0, PRINT_STRING
	la $a0, endl		#print new line escaped char
	syscall
		
	j return_to_address

return_to_address:
	addi $sp, $sp, 4	#pop stack to retrieve return address from stack pointer
	lw $ra, ($sp)		#load return address
	jr $ra			#return to address

operation_error:		#notify user that operation is invalid
	li $v0, PRINT_STRING
	la $a0, label_invalid
	syscall
	j return_to_address	#get next operation
		
push:
	li $v0, INPUT_INT	#get input from user
	syscall

	move $t0, $v0		#move input to temp register
	sw $t0, ($s0)		#store input in array
	
	addi $s0, $s0, 4	#increment array address to add new values		
	addi $s1, $s1, 1	#increment size of array
	
	j print_arr		#print array

pop:
	beq $s1, -1, print_arr_error	#if array is empty
	addi $s1, $s1, -1		#decrement size
	addi $s0, $s0, -4		#decrement array address to overwrite
	
	j print_arr			#print array


max:
	beq $s1, -1, print_arr_error 	#if array is empty branch off
	add $s0, $s0, -4		#decrement to last filled slot in array
	
	move $t0, $s1			#move size to temp register	
	li $t1, 4			#load int 4 into temp register
	mult  $t0, $t1			#multiply size of array by 4 to subtract from array pointer
	mflo $t0			#move result of multiplication back to t0
	sub $s0, $s0, $t0		#subtract product from array pointer 
	
	li $s2, 0			#counter for loop
	lw $s3, ($s0)			#load first value in array to register
	addi $s0, $s0, 4		#skip first value in array
	
	beq $s1, $s2, max_print		#if array has 1 element
	j max_loop

max_loop:
	lw $a0, ($s0)		#get value from array
	jal max_compare		#jump to compare function
	
	addi $s0, $s0, 4 	#traverse array by incrementing array pointer
	addi $s2, $s2, 1	#increment counter
	
	bne $s1, $s2, max_loop 	#loop
	
	j max_print
	
max_compare:
	sw $ra, ($sp)			#store return address in stack
	addi $sp, $sp, -4		#decrement stack pointer
	
	bgt $a0, $s3, max_replace 	#if new value greater current than max
	
	j return_to_address		#return to max loop
	
max_replace:
	move $s3, $a0		#replace current max with new max
	j return_to_address	#return to max loop
	
	
max_print:
	li $v0, PRINT_STRING	#print max string
	la $a0, label_max
	syscall
	
	li $v0, PRINT_INT
	move $a0, $s3		#move max to arg register for printing
	syscall
	
	li $v0, PRINT_STRING	#print new line
	la $a0, endl
	syscall
	
	j print_arr
	

rotate:
	beq $s1, -1, print_arr_error 	#if array is empty branch off
	beq $s1, 0, print_arr		#if array has one element
	
	addi $s0, $s0, -4	#decrement array pointer to last occupied slot
	lw $t2, ($s0)		#load last value into temp register
	
	move $t0, $s1		#move size to temp register	
	li $t1, 4		#load int 4 into temp register
	mult  $t0, $t1		#multiply size of array by 4 to subtract from array pointer
	mflo $t0		#move result of multiplication back to t0
	sub $s0, $s0, $t0	#subtract product from array pointer 
	
	li $s2, 0		#counter for loop
	j rotate_loop
	
rotate_loop:
	lw $t3, ($s0)		#load curr value to temp register
	sw $t2, ($s0)		#overwrite curr value with last value
	
	move $t2, $t3			#move curr value to temp to t2 for next iteration
	addi $s0, $s0, 4		#increment array pointer
	addi $s2, $s2, 1		#increment counter
	bne $s1, $s2, rotate_loop	#loop if counter not equal to size
	
	sw $t2, ($s0)		#store remaining value in last slot of array
	addi $s0, $s0, 4	#increment array to next empty slot
	j print_arr