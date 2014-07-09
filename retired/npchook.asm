@Insert over 0805F55A

.thumb
.thumb_func

main:
	ldr r2, routine
	bx r2

.align 2
routine:	.word 0x08B01500+1
