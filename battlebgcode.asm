.thumb
.thumb_func

.org 0x08b01480

main:
	ldr r1, time
	ldrb r1, [r1]
	ldr r2, =lut
	lsl r1, r1, #0x2
	add r2, r1, r2
	ldr r1, [r2]
	add r0, r1, r0
	mov r1, #0x20
	mov r2, #0x60
	ldr r3, pushpal
	bl bx_r3
	pop {r4,r5}
	pop {r0}
	bx r0

bx_r3:
	bx r3

.align 2
pushpal: .word 0x080703EC+1 @0x080703A8+1 for compressed
time:	.word 0x0203C000
lut:		.word 0x120
		.word 0x60
		.word 0x0
		.word 0xC0
