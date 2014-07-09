.thumb
.thumb_func

@Insert at 0800F290

main:
	ldr r1, offset
	bx r1

.align 2
offset:	.word 0x08b01480+1
