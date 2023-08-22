	.file	"hello.c"
	.option nopic
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	mv	a5,a0
	sd	a1,-32(s0)
	sw	a5,-20(s0)
	li	a3,0
	li	a2,0
	li	a1,0
	lui	a5,%hi(main._omp_fn.0)
	addi	a0,a5,%lo(main._omp_fn.0)
	call	GOMP_parallel
	li	a5,0
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	3
.LC0:
	.string	"Hello from process: %d\n"
	.text
	.align	1
	.type	main._omp_fn.0, @function
main._omp_fn.0:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	sd	a0,-24(s0)
	call	omp_get_thread_num
	mv	a5,a0
	mv	a1,a5
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	printf
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main._omp_fn.0, .-main._omp_fn.0
	.ident	"GCC: (GNU) 11.1.0"
	.section	.note.GNU-stack,"",@progbits
