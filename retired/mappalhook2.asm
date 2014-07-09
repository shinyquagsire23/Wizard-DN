@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 
@      Routine by Shiny Quagsire      @
@ Place compiled routine at 08059A20  @
@  PreComp: 00 48 00 47 <pointer+1>   @
@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 

.thumb
.thumb_func

main:
ldr r0, branch
bx r0

.align 2
branch: .word 0x08b01400+1 @Replace
