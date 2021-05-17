@Insert over 080598CC

.thumb
.thumb_func

main:
	ldr r3, routine
	bx r3

.align 2
routine:	.word 0x08B02500+1
