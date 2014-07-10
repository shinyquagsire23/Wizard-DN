@Insert over 0808356C

.thumb
.thumb_func

main:
	ldr r3, routine
	bx r3

.align 2
routine:	.word 0x08B02500+1
