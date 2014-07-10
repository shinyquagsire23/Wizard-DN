@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 
@      Routine by Shiny Quagsire      @
@   Checked for Leaf Green by itari   @
@ Place compiled routine at 080599F8  @
@    (this does not change for LG)    @
@  PreComp: 00 48 00 47 <pointer+1>   @
@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 

.thumb
.thumb_func

main:
ldr r0, branch
bx r0

.align 2
branch: .word 0x08b01300+1 @Replace
